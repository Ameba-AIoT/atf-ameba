/*
 * Copyright (c) 2019, Realtek Semiconductor Corp. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <platform_def.h>

#include <drivers/console.h>
#include <ameba_console.h>

static console_uart_t console;

void ameba_console_init(void)
{
	(void)console_core_register(PLAT_AMEBASMART_BOOT_UART_BASE,
			PLAT_AMEBASMART_BOOT_UART_CLK_IN_HZ,
			PLAT_AMEBASMART_CONSOLE_BAUDRATE, &console);

	console_set_scope(&console.console, CONSOLE_FLAG_BOOT |
			CONSOLE_FLAG_RUNTIME);
}
