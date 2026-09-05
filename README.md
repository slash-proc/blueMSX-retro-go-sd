# MSX — Retro-Go SD dynamic core

Standalone [blueMSX](external/blueMSX-go/) (blueMSX-go) core for
[Game & Watch Retro-Go SD](https://github.com/sylverb/game-and-watch-retro-go-sd).

Build produces `msx.bin` → `/cores/msx.bin` on SD; software goes under
`/roms/msx/` (extensions `.dsk`, `.rom`, `.mx1`, `.mx2`, `.cdk`).

Covers MSX1, MSX2 and MSX2+ — the machine is chosen in the core's own menu
(**Select MSX**), and which BIOS files you need depends on that choice.

## Requirements

- `arm-none-eabi-gcc` (hard-float `fpv5-d16`)
- GNU Make
- Python 3 + Pillow (`pip install -r requirements.txt`)

Or Docker: `make docker` (image `sylverb/retro-go-sd-builder:v1.5`).

## Quick start

```bash
git submodule update --init --recursive
make
# → msx.bin
```

Version in the packed header comes from `git describe --tags --dirty`, so an
untagged build stamps `0.0.0`.

## BIOS files

**This core ships no BIOS.** MSX needs system ROMs to boot at all, and which
ones depends on the machine you select and the media you load. They go in
`/bios/msx/` on the card:

| File | Needed for |
|---|---|
| `MSX.rom` | MSX1 |
| `MSX2.rom`, `MSX2EXT.rom` | MSX2 |
| `MSX2P.rom`, `MSX2PEXT.rom` | MSX2+ |
| `MSX2PMUS.rom` | FMPAC music — MSX2 and MSX2+ |
| `MSXKANJI.rom` | MSX2+ Japanese software |
| `PANASONICDISK.rom` | any `.dsk` / `.cdk` disk image |
| `Nextor.rom` | `.dsk` images over 720 KiB (IDE/HDD) |
| `msxromdb.bin` | optional: per-game controller and mapper settings |

blueMSX-go carries the machine ROMs under
`external/blueMSX-go/system/bluemsx/Machines/Shared Roms/`. `msxromdb.bin` is
generated from that repo's `msxromdb.xml` by its
`create_compact_database_file.py`.

Nothing validates these on device — the slot loader ignores read failures, so a
missing or truncated file is an unbootable machine with no error message.

## Multi-disk software

Disk swapping (**Change Dsk** in the core menu) finds the other disks by
scanning the *same folder* for the *same extension* in alphabetical order. Keep
a multi-disk set together in one directory and name the files so they sort in
disk order.

## Cheats

`.mcf` files under `/cheats/msx/`, named after the ROM.

## Layout

| Path | |
|---|---|
| `external/blueMSX-go/` | emulator, submodule pinned to the firmware's commit |
| `src/porting/` | the firmware's `Core/Src/porting/msx` glue, adapted |
| `ld/msx_core.ld` | SDK default plus the MSX ROM unpack buffer |
| `sdk/` | vendored SDK — refresh with `scripts/sync_from_firmware.sh` |

### Differences from the firmware build

The firmware compiles MSX in; this is a relocatable core loaded from SD, so a
few things had to change rather than move:

- **Menu strings** live in `src/porting/msx_i18n.c`. The firmware's `curr_lang`
  is private to the firmware in the dynamic-core ABI, so each core carries its
  own table and looks it up with `gw_i18n()`. All twelve MSX strings kept their
  twelve translations.
- **Switching machine** resets RAM_EMU (`ram_init`), not the AHB heap. The
  firmware called `ahb_init()`, which a core must not do: that pool belongs to
  the firmware and is shared with the launcher.
- **`_MSX_ROM_UNPACK_BUFFER`** is defined by `ld/msx_core.ld` as whatever is
  left of RAM_EMU after this core, mirroring the firmware's linker script.
- **Compressed ROMs are out.** `GNW_DISABLE_COMPRESSION` is unconditional on
  SD, so `.lzma` is not an accepted extension here.
- Small shims in `src/porting/` stand in for firmware-private headers
  (`gw_flash.h`, `gw_linker.h`, `gw_ofw.h`, `hw_sha1.h`, `rg_frogfs.h`); each
  says in its own comment what it does and does not promise.

## Status

Builds clean and packs a valid `CORE` header. **Not yet run on hardware** —
see `CHANGELOG.md` for what that leaves unverified.
