#!/usr/bin/env python3
"""Extract offset-aware ASCII and UTF-16LE strings from memory dumps."""
from __future__ import annotations
import argparse, re
from pathlib import Path

def main() -> None:
    ap=argparse.ArgumentParser();ap.add_argument('path',type=Path);ap.add_argument('--min',type=int,default=5);ap.add_argument('--contains');ap.add_argument('--max',type=int,default=500)
    args=ap.parse_args();data=args.path.read_bytes();items=[]
    patterns=[('ascii',re.compile(rb'[\x20-\x7e]{%d,}'%args.min),'ascii'),('utf16le',re.compile(rb'(?:[\x20-\x7e]\x00){%d,}'%args.min),'utf-16le')]
    for kind,rx,enc in patterns:
        for m in rx.finditer(data):
            text=m.group().decode(enc,'replace')
            if args.contains and args.contains.lower() not in text.lower():continue
            items.append((m.start(),kind,text))
    items.sort()
    for off,kind,text in items[:args.max]:print(f"0x{off:08x} {kind:7} {text}")
    print(f"shown={min(len(items),args.max)} total={len(items)}")
if __name__=='__main__':main()
