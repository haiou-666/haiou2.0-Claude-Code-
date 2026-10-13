#!/usr/bin/env python3
from __future__ import annotations
import argparse
from pathlib import Path

TEMPLATE_MAIN = '''#!/usr/bin/env python3
import argparse
from structs import demo_entities
from w2s import world_to_screen
from overlay import draw_entities

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--demo', action='store_true', default=True)
    ap.add_argument('--pid', type=int, default=0)
    args = ap.parse_args()
    entities = demo_entities()
    # live attach path reserved: when pid>0, replace demo_entities with external reader
    screen = [world_to_screen(e) for e in entities]
    draw_entities(screen)
    print('[+] pipeline ok entities=', len(entities), 'pid=', args.pid)

if __name__ == '__main__':
    main()
'''

FILES = {
    'main.py': TEMPLATE_MAIN,
    'structs.py': 'def demo_entities():\n    return [{"name":"elite","x":1,"y":2,"z":3,"hp":100}]\n',
    'w2s.py': 'def world_to_screen(e):\n    return {"name": e["name"], "sx": e["x"]*10, "sy": e["y"]*10, "hp": e["hp"]}\n',
    'overlay.py': 'def draw_entities(items):\n    for it in items:\n        print(f"DRAW {it}")\n',
    'anticheat_map.md': '# ACE surface checklist\n- modules\n- handles\n- integrity\n- input\n- network\n',
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out', type=Path)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    for name, content in FILES.items():
        (args.out / name).write_text(content, encoding='utf-8')
    print('[+] wrote', args.out)

if __name__ == '__main__':
    main()
