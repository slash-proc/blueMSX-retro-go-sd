/*
 * MSX menu strings, carried by the core instead of the firmware.
 *
 * The firmware's curr_lang / lang_t are private to the firmware in the
 * dynamic-core ABI (see gw_firmware_abi.h, "curr_lang / lang_t stay
 * firmware-private"). A core gets the active language code over the ABI and
 * looks up its own table, so these twelve strings moved here verbatim from
 * Core/Src/retro-go/i18n/rg_i18n_*.c on the firmware's main branch.
 *
 * English is required; everything else falls back to it automatically.
 */
#pragma once

#include "gw_core_i18n.h"

extern const gw_i18n_entry_t i18n_a_button[];
extern const gw_i18n_entry_t i18n_b_button[];
extern const gw_i18n_entry_t i18n_change_dsk[];
extern const gw_i18n_entry_t i18n_freq_50[];
extern const gw_i18n_entry_t i18n_freq_60[];
extern const gw_i18n_entry_t i18n_freq_auto[];
extern const gw_i18n_entry_t i18n_frequency[];
extern const gw_i18n_entry_t i18n_msx1_eur[];
extern const gw_i18n_entry_t i18n_msx2_eur[];
extern const gw_i18n_entry_t i18n_msx2_jp[];
extern const gw_i18n_entry_t i18n_press_key[];
extern const gw_i18n_entry_t i18n_select_msx[];
