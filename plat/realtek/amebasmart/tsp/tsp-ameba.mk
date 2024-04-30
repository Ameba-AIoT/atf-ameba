# Copyright (c) 2019, Realtek Semiconductor Corp. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

# TSP source files specific to ameba platform
BL32_SOURCES		+=	plat/common/aarch64/platform_mp_stack.S	\
				plat/realtek/amebasmart/tsp/tsp_plat_setup.c\
				$(AMEBA_GIC_SOURCES)
