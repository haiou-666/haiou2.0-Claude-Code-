#!/usr/bin/env python3
"""AOB (Array of Bytes) scanner for game memory research — supports wildcards (??)."""
from __future__ import annotations
import argparse, re, sys

def parse_pattern(pattern_str: str) -> tuple[bytes, bytes]:
    tokens = pattern_str.upper().split()
    mask = bytearray()
    data = bytearray()
    for tok in tokens:
        if tok in ("??", "?"):
            mask.append(0x00)
            data.append(0x00)
        else:
            mask.append(0xFF)
            data.append(int(tok, 16))
    return bytes(data), bytes(mask)

def scan(haystack: bytes, pattern: bytes, mask: bytes) -> list[int]:
    results = []
    plen = len(pattern)
    for i in range(len(haystack) - plen + 1):
        if all((haystack[i + j] & mask[j]) == (pattern[j] & mask[j]) for j in range(plen)):
            results.append(i)
    return results

def main() -> None:
    ap = argparse.ArgumentParser(description="AOB pattern scanner for memory dumps / binaries")
    ap.add_argument("file", help="Binary file or memory dump to scan")
    ap.add_argument("pattern", help='Byte pattern, e.g. "48 8B 05 ?? ?? ?? ?? 48 8B 40"')
    ap.add_argument("--base", type=lambda x: int(x, 0), default=0, help="Base address offset (hex ok)")
    ap.add_argument("--max-results", type=int, default=20)
    args = ap.parse_args()

    with open(args.file, "rb") as f:
        data = f.read()

    pattern, mask = parse_pattern(args.pattern)
    print(f"[*] Pattern : {args.pattern}")
    print(f"[*] Length  : {len(pattern)} bytes")
    print(f"[*] Scanning {len(data):,} bytes...\n")

    hits = scan(data, pattern, mask)
    if not hits:
        print("[!] No matches found.")
        return

    print(f"[+] {len(hits)} match(es):")
    for offset in hits[:args.max_results]:
        addr = args.base + offset
        context = data[offset:offset + len(pattern) + 8]
        hex_ctx = " ".join(f"{b:02X}" for b in context)
        print(f"    0x{addr:016X}  (file offset 0x{offset:X})  ->  {hex_ctx}")

    if len(hits) > args.max_results:
        print(f"    ... {len(hits) - args.max_results} more results omitted")

if __name__ == "__main__":
    main()
