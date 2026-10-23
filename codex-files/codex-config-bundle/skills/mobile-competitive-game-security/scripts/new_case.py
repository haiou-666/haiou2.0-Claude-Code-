#!/usr/bin/env python3
"""Create a reproducible mobile-game security case and hash supplied artifacts."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def iter_files(path: Path):
    if path.is_file():
        yield path
    elif path.is_dir():
        yield from sorted(p for p in path.rglob("*") if p.is_file())
    else:
        raise FileNotFoundError(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case_dir", type=Path, help="Output case directory")
    parser.add_argument("artifacts", nargs="*", type=Path, help="Files or directories to preserve")
    parser.add_argument("--title", default="mobile-competitive-game-security-case")
    parser.add_argument("--copy", action="store_true", help="Copy artifacts into originals/")
    args = parser.parse_args()

    case_dir = args.case_dir.resolve()
    originals = case_dir / "originals"
    work = case_dir / "work"
    output = case_dir / "output"
    logs = case_dir / "logs"
    for directory in (originals, work, output, logs):
        directory.mkdir(parents=True, exist_ok=True)

    records = []
    used_names: set[str] = set()
    for supplied in args.artifacts:
        supplied = supplied.resolve()
        base = supplied.parent if supplied.is_file() else supplied
        for source in iter_files(supplied):
            relative = source.name if supplied.is_file() else source.relative_to(base).as_posix()
            destination = None
            if args.copy:
                candidate = Path(relative)
                key = candidate.as_posix().lower()
                if key in used_names:
                    candidate = Path(f"{source.stem}-{sha256_file(source)[:8]}{source.suffix}")
                    key = candidate.as_posix().lower()
                used_names.add(key)
                destination = originals / candidate
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
            stat = source.stat()
            records.append({
                "source": str(source),
                "preserved_as": str(destination) if destination else None,
                "size": stat.st_size,
                "sha256": sha256_file(source),
            })

    manifest = {
        "schema": 1,
        "title": args.title,
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "case_dir": str(case_dir),
        "copied_artifacts": args.copy,
        "artifacts": records,
        "notes": {
            "observed": [],
            "inferred": [],
            "unresolved": [],
        },
    }
    manifest_path = case_dir / "case.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"case: {case_dir}")
    print(f"manifest: {manifest_path}")
    print(f"artifacts: {len(records)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
