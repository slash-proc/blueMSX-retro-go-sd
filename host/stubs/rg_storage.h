/* Host stub for rg_storage.h.
 * Shadows the firmware header (same include name) so we can provide a
 * minimal surface + <time.h> for odroid_system.h's rg_emu_slot_t.mtime.
 */
#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <time.h>
#include "config.h"

#ifndef RG_STORAGE_ROOT
#define RG_STORAGE_ROOT ""
#endif

#define RG_BASE_PATH        RG_STORAGE_ROOT "/retro-go"
#define RG_BASE_PATH_BIOS   RG_BASE_PATH "/bios"
#define RG_BASE_PATH_CACHE  RG_BASE_PATH "/cache"
#define RG_BASE_PATH_CONFIG RG_BASE_PATH "/config"
#define RG_BASE_PATH_COVERS RG_STORAGE_ROOT "/romart"
#define RG_BASE_PATH_MUSIC  RG_STORAGE_ROOT "/music"
#define RG_BASE_PATH_ROMS      RG_STORAGE_ROOT "/roms"
#define RG_BASE_PATH_HOMEBREWS RG_STORAGE_ROOT "/homebrews"
#define RG_BASE_PATH_SAVES     RG_BASE_PATH "/saves"
#define RG_BASE_PATH_THEMES RG_BASE_PATH "/themes"
#define RG_BASE_PATH_BORDERS RG_BASE_PATH "/borders"

bool rg_storage_get_adjacent_files(const char *path, char *prev_path, char *next_path);
