/*
 * Shim: the firmware's Core/Inc/gw_linker.h.
 *
 * save_msx.c includes it but references none of its symbols — those are
 * firmware linker-script externs (extflash extents, heap bounds, stack
 * redzone) that have no meaning inside a relocatable dynamic core, which
 * knows only its own RAM_EMU budget.
 *
 * Deliberately empty rather than re-declaring them: a core that started using
 * one should fail to compile here, not link against an address that belongs to
 * the firmware's memory map.
 */
#pragma once

#include <stdint.h>

/* Defined by ld/msx_core.ld: the tail of RAM_EMU left over after this core's
 * code, data and bss. msx_database.c stages .cdk tracks there and uses it as
 * the ram_malloc base. Addresses, not objects — take the address, never the
 * value. */
extern uint8_t _MSX_ROM_UNPACK_BUFFER;
extern uint8_t _MSX_ROM_UNPACK_BUFFER_SIZE;
