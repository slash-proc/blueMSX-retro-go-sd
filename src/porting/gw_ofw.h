/*
 * Shim: the firmware's Core/Inc/gw_ofw.h, reduced to what the MSX port uses.
 *
 * main_msx.c calls get_ofw_is_mario() to pick a button layout. The firmware
 * owns the answer; the SDK's redefine list maps the symbol to
 * core_get_ofw_is_mario, which reads it over the ABI.
 *
 * The other queries in the firmware header (extflash size, is_present,
 * is_zelda) are deliberately left out — this core does not use them, and a
 * shim that promises more than the ABI delivers is worse than one that
 * promises less.
 */
#pragma once

#include <stdbool.h>

bool get_ofw_is_mario(void);
