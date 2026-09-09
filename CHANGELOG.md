# Changelog

## [v0.0.2]

### Added

- The manifest now declares all eleven files the core reads from `/bios/msx/`
  as `bios[]` entries on the `msx` system, and the release publishes them.
  Each entry carries `url`, `bytes` and `sha256`, so an installer mirrors and
  hash-checks them like any other artifact instead of asking the user to find
  freely distributable ROMs this project already ships.

### Changed

- The manifest's `kind` is now `core`, not `emulator`. A core that emulates
  nothing -- Doom -- showed that the old word named a subset rather than the
  set, so the spec took the general term and the SDK and the spec now agree.
  The previous release publishes the old value and no longer validates.

- CI stages the output of `make bios` onto the GitHub release and passes each
  file to `make_manifest.py --bios`, which fills in the hashes.

## [v0.0.1]
Initial core version for blueMSX

### Added

- Nothing

### Changed

- Nothing

### Fixed

- Nothing

### Install

- Unzip the release archive onto the SD card root (`cores/blueMSX.bin` and
  `bios/msx/*`, including `msxromdb.bin`).
- Place ROMs/Disks/HDDs under `/roms/msx/` (`.dsk` `.rom` `.mx1` `.mx2` `.cdk` `.lzma`).
- Optional cheats: `.mcf` in the /cheats/msx/ folder.
- Requires firmware whose ABI matches `SDK_VERSION` in this repository.
