Vendored from sylverb/blueMSX-go @ 16a4d90dfa033db37876b5e4fe79df35b59fdc0c
(`sd` line / firmware submodule tip).

Included:
- `Src/` — emulator engine (subset used by this core)
- `libretro-common/include/` — headers needed by the port
- `system/` — Shared Roms + Databases (`msxromdb.xml`) for `make bios`

No git submodule: everything lives in this tree. `bios/msx/` remains a
generated install tree (`make bios`), gitignored.
