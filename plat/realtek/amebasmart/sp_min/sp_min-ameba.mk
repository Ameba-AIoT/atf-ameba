# Copyright (c) 2019, Realtek Semiconductor Corp. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

BL32_SOURCES		+=	plat/realtek/amebasmart/sp_min/sp_min_setup.c	\
				${AMEBA_CPU_LIBS}			\
				plat/common/aarch32/platform_mp_stack.S \
				plat/common/plat_psci_common.c		\
				plat/realtek/amebasmart/ameba_pm.c		\
				plat/realtek/amebasmart/topology.c		\
				plat/realtek/amebasmart/service/rtk_svc_setup.c\
				plat/realtek/amebasmart/service/bsec_svc.c\
				${AMEBA_GIC_SOURCES}
