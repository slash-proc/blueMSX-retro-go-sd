#!/usr/bin/env python3
"""Build a local bios/msx/ tree matching Retro-Go SD /bios/msx/.

Same content the firmware used to stage via prepare_msx_bios_files:
  MSX*.rom, Nextor.rom, MSXKANJI.rom, PANASONICDISK.rom,
  PANASONICDISK_.rom (2nd FDD disabled), msxromdb.bin.

Source tree is a blueMSX `system/` directory (Machines/Shared Roms +
Databases/msxromdb.xml). Defaults search common local checkouts; override
with --source or $BLUEMSX_SYSTEM.

Usage:
  python3 scripts/prepare_msx_bios.py
  python3 scripts/prepare_msx_bios.py --source /path/to/blueMSX-go/system
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUT = ROOT / "bios" / "msx"
COMPACT_DB = ROOT / "scripts" / "create_compact_database_file.py"

# Mirror firmware Makefile.common prepare_msx_bios_files.
SHARED_ROMS = (
    "MSX.rom",
    "MSX2.rom",
    "MSX2EXT.rom",
    "MSX2P.rom",
    "MSX2PEXT.rom",
    "MSX2PMUS.rom",
    "Nextor.rom",
    "MSXKANJI.rom",
    "PANASONICDISK.rom",
)

# Byte patch: disable 2nd FDD (same as firmware dd seek=6124).
PANASONIC_PATCH_OFFSET = 6124
PANASONIC_PATCH_VALUE = 0x00


def candidate_system_roots() -> list[Path]:
    env = os.environ.get("BLUEMSX_SYSTEM", "").strip()
    out: list[Path] = []
    if env:
        out.append(Path(env).expanduser())
    out.extend(
        [
            ROOT / "src" / "blueMSX-go" / "system",
            ROOT / "vendor" / "blueMSX-go" / "system",
            # Common sibling / historical firmware checkouts on this machine.
            Path.home()
            / "Documents/dev/gnw/ori/game-and-watch-retro-go-sd/external/blueMSX-go/system",
            Path.home()
            / "Documents/dev/gnw/game-and-watch-retro-go-sd/external/blueMSX-go/system",
        ]
    )
    return out


def resolve_system_root(explicit: Path | None) -> Path:
    if explicit is not None:
        root = explicit.expanduser().resolve()
        if not (root / "bluemsx" / "Machines" / "Shared Roms").is_dir():
            # Allow passing …/blueMSX-go (parent of system/) or …/Shared Roms.
            if (root / "system" / "bluemsx" / "Machines" / "Shared Roms").is_dir():
                return (root / "system").resolve()
            if root.name == "Shared Roms" and root.is_dir():
                # …/Machines/Shared Roms → climb to system/
                return root.parents[2].resolve()
            raise SystemExit(
                f"--source must be a blueMSX system/ tree (got {root})"
            )
        return root

    for cand in candidate_system_roots():
        shared = cand / "bluemsx" / "Machines" / "Shared Roms"
        if shared.is_dir() and (shared / "MSX.rom").is_file():
            return cand.resolve()

    raise SystemExit(
        "blueMSX system/ not found. Pass --source /path/to/blueMSX-go/system\n"
        "or set BLUEMSX_SYSTEM. Need Machines/Shared Roms/*.rom and "
        "Databases/msxromdb.xml."
    )


def prepare(system_root: Path, out_dir: Path) -> None:
    shared = system_root / "bluemsx" / "Machines" / "Shared Roms"
    db_xml = system_root / "bluemsx" / "Databases" / "msxromdb.xml"
    if not db_xml.is_file():
        raise SystemExit(f"missing {db_xml}")

    out_dir.mkdir(parents=True, exist_ok=True)

    for name in SHARED_ROMS:
        src = shared / name
        if not src.is_file():
            raise SystemExit(f"missing Shared Rom: {src}")
        shutil.copy2(src, out_dir / name)
        print(f"  {name}")

    # PANASONICDISK_.rom — 2nd FDD disabled (frees RAM; Micro Cabin needs original).
    patched = out_dir / "PANASONICDISK_.rom"
    shutil.copy2(out_dir / "PANASONICDISK.rom", patched)
    data = bytearray(patched.read_bytes())
    if len(data) <= PANASONIC_PATCH_OFFSET:
        raise SystemExit(
            f"PANASONICDISK.rom too small ({len(data)} bytes) for patch at "
            f"{PANASONIC_PATCH_OFFSET}"
        )
    data[PANASONIC_PATCH_OFFSET] = PANASONIC_PATCH_VALUE
    patched.write_bytes(data)
    print("  PANASONICDISK_.rom (2nd FDD disabled)")

    if not COMPACT_DB.is_file():
        raise SystemExit(f"missing {COMPACT_DB}")
    db_out = out_dir / "msxromdb.bin"
    subprocess.check_call(
        [sys.executable, str(COMPACT_DB), str(db_xml), str(db_out)],
        cwd=ROOT,
    )
    print(f"  msxromdb.bin ({db_out.stat().st_size} bytes)")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        type=Path,
        help="blueMSX system/ directory (or blueMSX-go root / Shared Roms path)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"output directory (default: {DEFAULT_OUT})",
    )
    args = parser.parse_args()

    system_root = resolve_system_root(args.source)
    out_dir = args.out if args.out.is_absolute() else (ROOT / args.out)
    print(f"source: {system_root}")
    print(f"out:    {out_dir}")
    prepare(system_root, out_dir.resolve())
    print("done.")


if __name__ == "__main__":
    main()
