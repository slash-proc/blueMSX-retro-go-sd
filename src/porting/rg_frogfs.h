/*
 * Shim: FrogFS does not exist on an SD-card build.
 *
 * external/blueMSX-go/Src/Memory/RomLoader.c includes rg_frogfs.h
 * unconditionally, but its only use of the API --
 * rg_frogfs_get_file_data() -- sits inside `#ifndef
 * GNW_DISABLE_COMPRESSION`, which this core always defines. The firmware
 * gets the real header from Core/Inc/retro-go; a standalone SD core has no
 * FrogFS image to read, so there is nothing to provide.
 *
 * Declared rather than left empty so that if the compression path is ever
 * enabled here the failure is an honest link error naming the missing
 * function, not a confusing implicit-declaration warning.
 */
#pragma once

#include <stdint.h>

void rg_frogfs_get_file_data(const char *name, const uint8_t **data, uint32_t *size);
