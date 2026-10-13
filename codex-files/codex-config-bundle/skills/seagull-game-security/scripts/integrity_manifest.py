#!/usr/bin/env python3
"""Create and verify recursive SHA-256 integrity manifests."""
from __future__ import annotations
import argparse, hashlib, json
from datetime import datetime, timezone
from pathlib import Path

def sha256(path: Path) -> str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
    return h.hexdigest()

def snapshot(root: Path, manifest: Path) -> dict:
    files=[];manifest_abs=manifest.resolve()
    for p in sorted(x for x in root.rglob('*') if x.is_file()):
        if p.resolve()==manifest_abs:continue
        files.append({'path':p.relative_to(root).as_posix(),'size':p.stat().st_size,'sha256':sha256(p)})
    return {'schema':1,'root':str(root.resolve()),'created_at':datetime.now(timezone.utc).isoformat(),'files':files}

def main() -> None:
    ap=argparse.ArgumentParser();sub=ap.add_subparsers(dest='cmd',required=True)
    for cmd in ('create','verify'):
        p=sub.add_parser(cmd);p.add_argument('root',type=Path);p.add_argument('manifest',type=Path);p.add_argument('--allow-extra',action='store_true')
    args=ap.parse_args();root=args.root.resolve();manifest=args.manifest.resolve()
    if args.cmd=='create':
        data=snapshot(root,manifest);manifest.parent.mkdir(parents=True,exist_ok=True);manifest.write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf-8');print(f"files={len(data['files'])} manifest={manifest}");return
    expected=json.loads(manifest.read_text('utf-8'));current=snapshot(root,manifest);e={x['path']:x for x in expected['files']};c={x['path']:x for x in current['files']}
    missing=sorted(set(e)-set(c));extra=sorted(set(c)-set(e));modified=sorted(p for p in set(e)&set(c) if e[p]['size']!=c[p]['size'] or e[p]['sha256']!=c[p]['sha256'])
    result={'ok':not missing and not modified and (args.allow_extra or not extra),'missing':missing,'modified':modified,'extra':extra}
    print(json.dumps(result,indent=2,ensure_ascii=False));raise SystemExit(0 if result['ok'] else 2)
if __name__=='__main__':main()
