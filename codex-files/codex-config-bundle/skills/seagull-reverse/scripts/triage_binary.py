#!/usr/bin/env python3
"""Fast, dependency-free binary triage with hashes, magic, entropy, and strings."""
from __future__ import annotations
import argparse, hashlib, json, math, re
from collections import Counter
from pathlib import Path

MAGICS = [
    (b"MZ", "PE/COFF"), (b"\x7fELF", "ELF"), (b"\x00asm", "WebAssembly"),
    (b"dex\n", "Android DEX"), (b"PK\x03\x04", "ZIP/APK/JAR"),
    (b"\xfe\xed\xfa\xce", "Mach-O 32 BE"), (b"\xce\xfa\xed\xfe", "Mach-O 32 LE"),
    (b"\xfe\xed\xfa\xcf", "Mach-O 64 BE"), (b"\xcf\xfa\xed\xfe", "Mach-O 64 LE"),
]
KEYWORDS = re.compile(r"(?i)(http|socket|token|password|secret|license|debug|error|encrypt|decrypt|flag|admin|api|cmd|shell)")

def hashes(data: bytes) -> dict[str, str]:
    return {name: hashlib.new(name, data).hexdigest() for name in ("md5", "sha1", "sha256")}

def entropy(data: bytes) -> float:
    if not data: return 0.0
    counts = Counter(data); n = len(data)
    return -sum((c/n) * math.log2(c/n) for c in counts.values())

def detect(data: bytes) -> str:
    for magic, name in MAGICS:
        if data.startswith(magic): return name
    return "unknown/raw"

def strings(data: bytes, minimum: int) -> list[dict[str, object]]:
    out: list[dict[str, object]] = []
    ascii_rx = re.compile(rb"[\x20-\x7e]{%d,}" % minimum)
    utf16_rx = re.compile(rb"(?:[\x20-\x7e]\x00){%d,}" % minimum)
    for kind, rx, decoder in (("ascii", ascii_rx, "ascii"), ("utf16le", utf16_rx, "utf-16le")):
        for match in rx.finditer(data):
            text = match.group().decode(decoder, "replace")
            out.append({"offset": match.start(), "encoding": kind, "text": text, "interesting": bool(KEYWORDS.search(text))})
    out.sort(key=lambda x: (not x["interesting"], x["offset"]))
    return out

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("path", type=Path)
    ap.add_argument("--min-string", type=int, default=5)
    ap.add_argument("--top", type=int, default=80)
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()
    data = args.path.read_bytes()
    result = {
        "path": str(args.path.resolve()), "size": len(data), "format": detect(data),
        "magic_hex": data[:16].hex(" "), "entropy": round(entropy(data), 4),
        "hashes": hashes(data), "strings": strings(data, args.min_string)[:args.top],
    }
    if args.json: print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(f"Path: {result['path']}\nFormat: {result['format']}\nSize: {result['size']}\nEntropy: {result['entropy']}")
        for k, v in result["hashes"].items(): print(f"{k.upper()}: {v}")
        print("\nStrings:")
        for item in result["strings"]: print(f"0x{item['offset']:08x} {item['encoding']:7} {'*' if item['interesting'] else ' '} {item['text']}")
if __name__ == "__main__": main()
