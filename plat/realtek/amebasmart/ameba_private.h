/*
 * Copyright (c) 2015-2019, Realtek Semiconductor Corp. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef AMEBA_PRIVATE_H
#define AMEBA_PRIVATE_H

#include <stdint.h>

void ameba_config_setup(void);

void ameba_configure_mmu_svc_mon(unsigned long total_base,
			unsigned long total_size,
			unsigned long code_start, unsigned long code_limit,
			unsigned long ro_start, unsigned long ro_limit
#if USE_COHERENT_MEM
			, unsigned long coh_start, unsigned long coh_limit
#endif
			);

void ameba_configure_mmu_el1(unsigned long total_base,
			unsigned long total_size,
			unsigned long code_start, unsigned long code_limit,
			unsigned long ro_start, unsigned long ro_limit
#if USE_COHERENT_MEM
			, unsigned long coh_start, unsigned long coh_limit
#endif
			);

void ameba_configure_mmu_el3(unsigned long total_base,
			unsigned long total_size,
			unsigned long code_start, unsigned long code_limit,
			unsigned long ro_start, unsigned long ro_limit
#if USE_COHERENT_MEM
			, unsigned long coh_start, unsigned long coh_limit
#endif
			);

void plat_amebasmart_io_setup(void);
unsigned int plat_amebasmart_calc_core_pos(u_register_t mpidr);

void ameba_console_init(void);

/*
 * Mandatory functions for GICV3/GICV2
 */
void plat_amebasmart_gic_driver_init(void);
void plat_amebasmart_gic_init(void);
void plat_amebasmart_gic_cpuif_enable(void);
void plat_amebasmart_gic_cpuif_disable(void);
void plat_amebasmart_gic_redistif_on(void);
void plat_amebasmart_gic_redistif_off(void);
void plat_amebasmart_gic_pcpu_init(void);
#if (BOOT_FLASH)
int rtk_flash_read(void);
int ameba_dram_init(void);
#endif
#endif /* AMEBA_PRIVATE_H */
