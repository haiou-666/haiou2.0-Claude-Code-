#!/usr/bin/env python3
from __future__ import annotations
import argparse
from pathlib import Path

FILES = {
    "main.py": '''#!/usr/bin/env python3
import argparse
from entities import demo_entities
from w2s import world_to_screen
from overlay import draw

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--demo", action="store_true", default=True)
    ap.add_argument("--pid", type=int, default=0)
    args = ap.parse_args()
    ents = demo_entities()
    # live path: replace demo_entities with external/kernel reader when pid>0
    pts = [world_to_screen(e) for e in ents]
    draw(pts)
    print("[+] game-redteam pipeline ok", len(pts), "pid", args.pid)

if __name__ == "__main__":
    main()
''',
    "entities.py": "def demo_entities():\n    return [{\"name\":\"enemy\",\"x\":12,\"y\":0,\"z\":8,\"hp\":100,\"team\":2}]\n",
    "w2s.py": "def world_to_screen(e):\n    return {\"name\": e[\"name\"], \"sx\": e[\"x\"]*10, \"sy\": e[\"z\"]*10, \"hp\": e[\"hp\"]}\n",
    "overlay.py": "def draw(points):\n    for p in points:\n        print(f\"ESP {p}\")\n",
    "anticheat_matrix.md": "# AC surface\n- modules\n- handles\n- integrity\n- input\n- network\n- kernel callbacks\n",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", type=Path)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    for name, content in FILES.items():
        (args.out / name).write_text(content, encoding="utf-8")
    print("[+] wrote", args.out)

if __name__ == "__main__":
    main()
