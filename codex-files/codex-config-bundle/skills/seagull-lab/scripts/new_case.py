#!/usr/bin/env python3
"""Create a reproducible Seagull research case workspace."""
from __future__ import annotations
import argparse, json, re
from datetime import datetime, timezone
from pathlib import Path

def slugify(text: str) -> str:
    slug=re.sub(r'[^a-zA-Z0-9._-]+','-',text.strip()).strip('-').lower()
    return slug or 'case'

def main() -> None:
    ap=argparse.ArgumentParser();ap.add_argument('name');ap.add_argument('--root',type=Path,default=Path.cwd());ap.add_argument('--type',default='research')
    args=ap.parse_args();case=args.root/slugify(args.name)
    for rel in ['artifacts/original','work','scripts','evidence','output']: (case/rel).mkdir(parents=True,exist_ok=True)
    now=datetime.now(timezone.utc).isoformat()
    profile={'schema':1,'name':args.name,'type':args.type,'created_at':now,'timezone':'UTC','status':'open','services':[],'cleanup':[]}
    manifest={'schema':1,'case':args.name,'created_at':now,'artifacts':[]}
    (case/'case.json').write_text(json.dumps(profile,indent=2,ensure_ascii=False),encoding='utf-8')
    (case/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
    (case/'notes.md').write_text(f"# {args.name}\n\n## Objective\n\n## Environment\n\n## Commands\n\n## Observations\n\n## Hypotheses\n\n## Results\n",encoding='utf-8')
    print(case.resolve())
if __name__=='__main__':main()
