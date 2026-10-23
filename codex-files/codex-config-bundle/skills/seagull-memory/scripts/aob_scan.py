#!/usr/bin/env python3
"""Scan a file or dump for AOB patterns such as '48 8B ?? ?? 89'."""
from __future__ import annotations
import argparse, mmap
from pathlib import Path

def parse_pattern(text: str) -> tuple[bytes, bytes]:
    values=[]; masks=[]
    for token in text.replace(',', ' ').split():
        if token in ('?', '??', '**'): values.append(0); masks.append(0)
        else:
            if len(token) != 2: raise ValueError(f"invalid token: {token}")
            values.append(int(token, 16)); masks.append(0xFF)
    if not values: raise ValueError('empty pattern')
    return bytes(values), bytes(masks)

def match_at(buf, offset: int, values: bytes, masks: bytes) -> bool:
    return all(not masks[i] or buf[offset+i] == values[i] for i in range(len(values)))

def main() -> None:
    ap=argparse.ArgumentParser();ap.add_argument('path',type=Path);ap.add_argument('pattern');ap.add_argument('--base',type=lambda x:int(x,0),default=0);ap.add_argument('--max',type=int,default=100)
    args=ap.parse_args(); values,masks=parse_pattern(args.pattern); hits=[]
    with args.path.open('rb') as f:
        if f.seek(0,2)==0: return
        f.seek(0)
        with mmap.mmap(f.fileno(),0,access=mmap.ACCESS_READ) as mm:
            limit=len(mm)-len(values)+1
            for off in range(max(0,limit)):
                if match_at(mm,off,values,masks):
                    hits.append(off)
                    if len(hits)>=args.max:break
    for off in hits: print(f"file=0x{off:x} virtual=0x{args.base+off:x}")
    print(f"hits={len(hits)}")
if __name__=='__main__':main()
