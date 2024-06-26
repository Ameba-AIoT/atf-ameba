/*
 * Copyright (c) 2015-2019, Realtek Semiconductor Corp. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <assert.h>
#include <platform_def.h>

#include <arch_helpers.h>
#include <common/debug.h>
#include <lib/psci/psci.h>
#include <plat/common/platform.h>

#include "ameba_private.h"

/*
 * The secure entry point to be used on warm reset.
 */
static unsigned long secure_entrypoint;

extern uint32_t arm_gic_freq_get_div(void);
extern void arm_gic_freq_switch(uint32_t pre_div);
extern void arm_gic_freq_restore(uint32_t pre_div);

/* Make composite power state parameter till power level 0 */
#if PSCI_EXTENDED_STATE_ID

#define ameba_make_pwrstate_lvl0(lvl0_state, pwr_lvl, type) \
		(((lvl0_state) << PSTATE_ID_SHIFT) | \
		 ((type) << PSTATE_TYPE_SHIFT))
#else
#define ameba_make_pwrstate_lvl0(lvl0_state, pwr_lvl, type) \
		(((lvl0_state) << PSTATE_ID_SHIFT) | \
		 ((pwr_lvl) << PSTATE_PWR_LVL_SHIFT) | \
		 ((type) << PSTATE_TYPE_SHIFT))
#endif /* PSCI_EXTENDED_STATE_ID */


#define ameba_make_pwrstate_lvl1(lvl1_state, lvl0_state, pwr_lvl, type) \
		(((lvl1_state) << PLAT_LOCAL_PSTATE_WIDTH) | \
		 ameba_make_pwrstate_lvl0(lvl0_state, pwr_lvl, type))



/*
 *  The table storing the valid idle power states. Ensure that the
 *  array entries are populated in ascending order of state-id to
 *  enable us to use binary search during power state validation.
 *  The table must be terminated by a NULL entry.
 */
static const unsigned int ameba_pm_idle_states[] = {
	/* State-id - 0x01 */
	ameba_make_pwrstate_lvl1(PLAT_LOCAL_STATE_RUN, PLAT_LOCAL_STATE_RET,
				MPIDR_AFFLVL0, PSTATE_TYPE_STANDBY),
	/* State-id - 0x02 */
	ameba_make_pwrstate_lvl1(PLAT_LOCAL_STATE_RUN, PLAT_LOCAL_STATE_OFF,
				MPIDR_AFFLVL0, PSTATE_TYPE_POWERDOWN),
	/* State-id - 0x22 */
	ameba_make_pwrstate_lvl1(PLAT_LOCAL_STATE_OFF, PLAT_LOCAL_STATE_OFF,
				MPIDR_AFFLVL1, PSTATE_TYPE_POWERDOWN),
	0,
};

/*******************************************************************************
 * Platform handler called to check the validity of the power state
 * parameter. The power state parameter has to be a composite power state.
 ******************************************************************************/
static int ameba_validate_power_state(unsigned int power_state,
				psci_power_state_t *req_state)
{
	unsigned int state_id;
	int i;

	assert(req_state);

	/*
	 *  Currently we are using a linear search for finding the matching
	 *  entry in the idle power state array. This can be made a binary
	 *  search if the number of entries justify the additional complexity.
	 */
	for (i = 0; !!ameba_pm_idle_states[i]; i++) {
		if (power_state == ameba_pm_idle_states[i])
			break;
	}

	/* Return error if entry not found in the idle state array */
	if (!ameba_pm_idle_states[i])
		return PSCI_E_INVALID_PARAMS;

	i = 0;
	state_id = psci_get_pstate_id(power_state);

	/* Parse the State ID and populate the state info parameter */
	while (state_id) {
		req_state->pwr_domain_state[i++] = state_id &
						PLAT_LOCAL_PSTATE_MASK;
		state_id >>= PLAT_LOCAL_PSTATE_WIDTH;
	}
	return PSCI_E_SUCCESS;
}

/*******************************************************************************
 * Platform handler called to check the validity of the non secure
 * entrypoint.
 ******************************************************************************/
static int ameba_validate_ns_entrypoint(uintptr_t entrypoint)
{
	/*
	 * Check if the non secure entrypoint lies within the non
	 * secure DRAM.
	 */
	if ((entrypoint >= NS_DRAM0_BASE) &&
	    (entrypoint < (NS_DRAM0_BASE + NS_DRAM0_SIZE)))
		return PSCI_E_SUCCESS;

	return PSCI_E_INVALID_ADDRESS;
}

/*******************************************************************************
 * Platform handler called when a CPU is about to enter standby.
 ******************************************************************************/
static void ameba_cpu_standby(plat_local_state_t cpu_state)
{
	assert(cpu_state == PLAT_LOCAL_STATE_RET);

	/*
	 * Enter standby state
	 * dsb is good practice before using wfi to enter low power states
	 */
	dsb();
	wfi();
}

/*******************************************************************************
 * Platform handler called when a power domain is about to be turned on. The
 * mpidr determines the CPU to be turned on.
 ******************************************************************************/
static int ameba_pwr_domain_on(u_register_t mpidr)
{
	int rc = PSCI_E_SUCCESS;
	unsigned pos = plat_core_pos_by_mpidr(mpidr);
	uint64_t *hold_base = (uint64_t *)PLAT_AMEBASMART_HOLD_BASE;

	hold_base[pos] = PLAT_AMEBASMART_HOLD_STATE_GO;
	sev();

	return rc;
}

/*******************************************************************************
 * Platform handler called when a power domain is about to be turned off. The
 * target_state encodes the power state that each level should transition to.
 ******************************************************************************/
void ameba_pwr_domain_off(const psci_power_state_t *target_state)
{
	assert(0);
}

/*******************************************************************************
 * Platform handler called when a power domain is about to be suspended. The
 * target_state encodes the power state that each level should transition to.
 ******************************************************************************/
void ameba_pwr_domain_suspend(const psci_power_state_t *target_state)
{
	assert(0);
}

/*******************************************************************************
 * Platform handler called when a power domain has just been powered on after
 * being turned off earlier. The target_state encodes the low power state that
 * each level has woken up from.
 ******************************************************************************/
void ameba_pwr_domain_on_finish(const psci_power_state_t *target_state)
{
	assert(target_state->pwr_domain_state[MPIDR_AFFLVL0] ==
					PLAT_LOCAL_STATE_OFF);

	/* Only Core1 is running in here */
	uint32_t pre_div = arm_gic_freq_get_div();
	arm_gic_freq_switch(pre_div);

	plat_amebasmart_gic_pcpu_init();
	/* Enable the gic cpu interface */
	plat_amebasmart_gic_cpuif_enable();

	arm_gic_freq_restore(pre_div);
}

/*******************************************************************************
 * Platform handler called when a power domain has just been powered on after
 * having been suspended earlier. The target_state encodes the low power state
 * that each level has woken up from.
 ******************************************************************************/
void ameba_pwr_domain_suspend_finish(const psci_power_state_t *target_state)
{
	assert(0);
}

/*******************************************************************************
 * Platform handlers to shutdown/reboot the system
 ******************************************************************************/
static void __dead2 ameba_system_off(void)
{
	ERROR("AMEBA System Off: operation not handled.\n");
	panic();
}

static void __dead2 ameba_system_reset(void)
{
	ERROR("AMEBA System Reset: operation not handled.\n");
	panic();
}

static const plat_psci_ops_t plat_amebasmart_psci_pm_ops = {
	.cpu_standby = ameba_cpu_standby,
	.pwr_domain_on = ameba_pwr_domain_on,
	.pwr_domain_off = ameba_pwr_domain_off,
	.pwr_domain_suspend = ameba_pwr_domain_suspend,
	.pwr_domain_on_finish = ameba_pwr_domain_on_finish,
	.pwr_domain_suspend_finish = ameba_pwr_domain_suspend_finish,
	.system_off = ameba_system_off,
	.system_reset = ameba_system_reset,
	.validate_power_state = ameba_validate_power_state,
	.validate_ns_entrypoint = ameba_validate_ns_entrypoint
};

int plat_setup_psci_ops(uintptr_t sec_entrypoint,
			const plat_psci_ops_t **psci_ops)
{
	uintptr_t *mailbox = (void *) PLAT_AMEBASMART_TRUSTED_MAILBOX_BASE;

	*mailbox = sec_entrypoint;
	secure_entrypoint = (unsigned long) sec_entrypoint;
	*psci_ops = &plat_amebasmart_psci_pm_ops;

	return 0;
}
