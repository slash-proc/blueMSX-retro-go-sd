# blueMSX — Retro-Go SD dynamic core

Standalone **MSX** emulator core for
[Game & Watch Retro-Go SD](https://github.com/sylverb/game-and-watch-retro-go-sd),
built from [blueMSX-go](https://github.com/sylverb/blueMSX-go).

One freestanding Cortex-M7 binary (`blueMSX.bin`) loaded into `RAM_EMU`, talking to
the launcher only through `gw_firmware_abi_t`.

| | |
|--|--|
| Packer | `sdk/tools/pack_core.py` (`CORE`) |
| SD path | `/cores/blueMSX.bin` |
| ROMs | `/roms/msx/` (`.dsk` `.rom` `.mx1` `.mx2` `.cdk` `.lzma`) |
| BIOS / DB | `/bios/msx/` (+ `msxromdb.bin`) |
| Cheats | `.mcf` |

## Memory layout

| Region | Use |
|--------|-----|
| **ITCM** | Hot code only: R800 + SlotManager (+ `vdpCommandPortLatchPending`) |
| **DTCM** | Hot state via `dtc_malloc` / `dtc_calloc` (CPU, VDP, audio chips, YJK LUT, …) |
| **AHB** | Freeable heap (`malloc` / `calloc`) for medium structs (e.g. `Machine`) |
| **RAM_EMU** | Rest of `.text`/`.rodata`/`.bss`, MSX WRAM, VRAM, framebuffer, `ram_malloc` |

## Build

**Local:** `arm-none-eabi-gcc` (hard-float `fpv5-d16`), Make, Python 3 + Pillow.

```bash
make
# or: make docker
```

Output: `blueMSX.bin` → copy to `/cores/blueMSX.bin` on the SD card.

BIOS (same set the firmware used to stage under `/bios/msx/`):

```bash
make bios
# or: BLUEMSX_SYSTEM=/path/to/blueMSX-go/system make bios
```

Writes `bios/msx/` locally (ROMs + `msxromdb.bin`). Release zips include
`cores/blueMSX.bin` **and** `bios/msx/*`. The same tree is reused by the
host build.

### Host (desktop SDL preview)

Needs `pkg-config` + SDL2 (or SDL3). Run from the repo root so `/bios/…`
paths resolve to `./bios/…`.

```bash
make bios          # once, if bios/msx/ is empty
make host          # → blueMSX_host (SDL2)
# make host HOST_SDL=3
./blueMSX_host path/to/game.rom   # or .dsk / .mx1 / …
```

Controls mirror the device pad mapping (SDL gamepad / keyboard). Quit with
the window close button or Escape (see `host/host_platform.c`).

Logos come from `src/assets/*.bmp` (from firmware `icons/c_msx.bmp` /
`h_msx_all.bmp`) and are packed with `--logo-invert`.

## Layout

- `src/porting/msx/` — GNW glue (`app_main_msx`, save states, ROM DB, i18n)
- `src/blueMSX-go/` — vendored blueMSX engine (subset)
- `host/` — SDL desktop preview (`make host` → `blueMSX_host`)
- `msx_core.ld` — ITCM + RAM_EMU linker script
- `sdk/` — ABI bridge, headers, packer (synced from firmware)

## Sync SDK from firmware

```bash
./scripts/sync_from_firmware.sh /path/to/game-and-watch-retro-go-sd
```
