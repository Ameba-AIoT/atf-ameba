/*
 * Copyright (c) 2015-2016, Cortina Access. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <console.h>
#include <debug.h>
#include <errno.h>
#include <mmio.h>
#include <platform_def.h>
#include <arch.h>


#define _U32_MAX_ 0xffffffff

static unsigned int r3k_mips_clock_mhz = 0;

void r3k_timer_init(int clock_in_mhz)
{
    unsigned int  cause = 0;
    r3k_mips_clock_mhz = clock_in_mhz;
    /* According to RLX5381 Datasheet,
     * We need clear the DC bit at CAUSE register on CP0 */
#ifdef CONFIG_CPU_RLX
    cause = read_c0_cause();
    cause &= ~CAUSEF_DC;
    write_c0_cause(cause);
#endif
}

void udelay(int us)
{
    unsigned int start = read_c0_count();
    unsigned int now = 0;
    unsigned int delta_us = 0;

    if(us <= 0){
        us = 1;
    }else if(us > _U32_MAX_/r3k_mips_clock_mhz){
        us = _U32_MAX_/r3k_mips_clock_mhz;
    }

    do{
        now = read_c0_count();

        delta_us = (now - start)/r3k_mips_clock_mhz;

    }while(delta_us < us);
}

void mdelay(int ms)
{
    unsigned int start = read_c0_count();
    unsigned int now = 0;
    unsigned int delta_ms = 0;
    unsigned int khz = r3k_mips_clock_mhz * 1000;

    if(ms <= 0){
        ms = 1;
    }else if(ms > _U32_MAX_/khz){
        ms = _U32_MAX_/khz;
    }

    do{
        now = read_c0_count();

        delta_ms = (now - start)/khz;

    }while(delta_ms < ms);
}
