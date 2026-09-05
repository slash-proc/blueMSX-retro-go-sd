/*
 * Shim: the firmware's Core/Inc/gw_flash.h.
 *
 * save_msx.c includes it but calls nothing from it — the firmware's OSPI
 * erase/program entry points belong to the flash-backed save path, and an SD
 * build writes savestates through the filesystem instead.
 *
 * Deliberately empty, like gw_linker.h: a core that starts driving the
 * external flash directly should fail to compile here rather than link
 * against firmware-private routines.
 */
#pragma once
