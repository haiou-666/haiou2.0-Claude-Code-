#!/usr/bin/env python3
"""Hash an artifact and append/update a case manifest."""
from __future__ import annotations
import argparse, hashlib, json
from datetime import datetime, timezone
from pathlib import Path

def digest(path: Path) -> dict[str,str]:
    hs={name:hashlib.new(name) for name in ('md5','sha1','sha256')}
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):
            for h in hs.values():h.update(chunk)
    return {k:v.hexdigest() for k,v in hs.items()}

def main() -> None:
    ap=argparse.ArgumentParser();ap.add_argument('path',type=Path);ap.add_argument('--manifest',type=Path);ap.add_argument('--source',default='unspecified')
    args=ap.parse_args();p=args.path.resolve();entry={'path':str(p),'source':args.source,'size':p.stat().st_size,'hashed_at':datetime.now(timezone.utc).isoformat(),'hashes':digest(p)}
    if args.manifest:
        if args.manifest.exists():data=json.loads(args.manifest.read_text('utf-8'))
        else:data={'schema':1,'created_at':datetime.now(timezone.utc).isoformat(),'artifacts':[]}
        data.setdefault('artifacts',[]);data['artifacts']=[x for x in data['artifacts'] if x.get('path')!=str(p)];data['artifacts'].append(entry)
        args.manifest.parent.mkdir(parents=True,exist_ok=True);args.manifest.write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf-8')
    print(json.dumps(entry,indent=2,ensure_ascii=False))
if __name__=='__main__':main()
