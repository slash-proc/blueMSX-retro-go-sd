# Changelog

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). A release tag must
match a section heading exactly (for example `v0.1.0`): CI reads the matching
section and uses it as the GitHub Release notes, and refuses to release without
one.

When you cut a release:

1. Move items from `[Unreleased]` into a new `## [vX.Y.Z] - YYYY-MM-DD` section.
2. Commit the changelog update.
3. Push the tag: `git tag vX.Y.Z && git push origin vX.Y.Z`

## [Unreleased]

### Added

- MSX, MSX2 and MSX2+ as a standalone Retro-Go SD dynamic core, packed as
  `msx.bin` for `/cores/`. The emulator is
  [blueMSX-go](https://github.com/sylverb/blueMSX-go) as a submodule, pinned to
  `16a4d90` — the commit the firmware uses — plus the firmware's
  `Core/Src/porting/msx` glue adapted for a relocatable core.
- One launcher system: `MSX`, folder `/roms/msx/`, extensions
  `dsk rom mx1 mx2 cdk`, cheats `.mcf`.
- `ld/msx_core.ld`, which adds `_MSX_ROM_UNPACK_BUFFER` over the SDK default:
  the tail of RAM_EMU after this core, mirroring what the firmware's linker
  script gives the MSX overlay. 341 KiB at present.

### Changed

- Menu strings moved into the core (`src/porting/msx_i18n.c`). `curr_lang` and
  `lang_t` are firmware-private in the dynamic-core ABI, so a core carries its
  own table and resolves it with `gw_i18n()`. All twelve MSX strings kept all
  twelve translations.
- Switching machine now rewinds RAM_EMU via `ram_init()`. The firmware called
  `ahb_init()`, which would rewind the *firmware's* AHB heap and take the
  launcher's allocations with it; the ABI deliberately exposes no reset for
  that pool.
- `APPID_MSX` → `APPID_CORE`. The appid identifies the process role, not the
  emulated machine, and the dynamic-core enum has three values.
- SDK refreshed to the 2026-08-31 snapshot. The tree shipped with a 2026-08-14
  snapshot predating `Core/Inc/porting/` and `appid.h`.

### Removed

- `.lzma` from the accepted extensions. `GNW_DISABLE_COMPRESSION` is
  unconditional on SD builds, so a compressed ROM would be listed in the menu
  and then handed to the core raw.

### Not verified

**This core has never run on hardware.** It compiles warning-free, links inside
its RAM_EMU budget, and packs a `CORE` header that parses correctly, and that is
the whole of what has been checked. Specifically unproven:

- **The YJK colour table.** blueMSX asks for 64 KiB from AHB via
  `ahb_only_malloc`, which the dynamic-core ABI does not offer — `mem_ctl`'s
  `GW_MEM_AHB` maps to `ahb_calloc`, which tries RAM_EMU first. The build maps
  the call to `ahb_malloc`, so that 64 KiB may land in RAM_EMU instead. MSX2+
  Screen 10/11/12 is where a problem would surface. A cleaner fix is an ABI
  append exposing an AHB-only pool.
- Whether 383 KiB of core plus a 341 KiB unpack buffer leaves enough RAM_EMU
  for the machines people actually run, particularly MSX2+ with a large disk.
- Every runtime path: BIOS loading, disk swapping, the game database, saves,
  cheats, sound. None of it has executed.
