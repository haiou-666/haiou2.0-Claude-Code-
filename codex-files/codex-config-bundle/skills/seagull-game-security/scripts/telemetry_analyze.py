#!/usr/bin/env python3
"""Summarize aim/input telemetry and emit explainable anomaly indicators."""
from __future__ import annotations
import argparse, csv, json, math, statistics
from collections import defaultdict
from pathlib import Path

def truth(v:str)->bool:return v.strip().lower() in {'1','true','yes','y'}
def angle_delta(a:float,b:float)->float:return abs((a-b+180)%360-180)
def analyze(rows:list[dict[str,str]])->dict:
    rows=sorted(rows,key=lambda r:float(r['timestamp_ms']));shots=[];hits=0;visible_shots=0;speeds=[];snaps=0;visible_since=None;reactions=[]
    prev=None
    for r in rows:
        t=float(r['timestamp_ms']);yaw=float(r['yaw']);pitch=float(r['pitch']);visible=truth(r.get('target_visible','0'))
        if visible and visible_since is None:visible_since=t
        if not visible:visible_since=None
        if prev:
            dt=max(1,t-prev[0]);dist=math.hypot(angle_delta(yaw,prev[1]),pitch-prev[2]);speed=dist/(dt/1000);speeds.append(speed)
            if dist>=15 and dt<=80:snaps+=1
        if truth(r.get('shot','0')):
            shots.append(t);hits+=int(truth(r.get('hit','0')));visible_shots+=int(visible)
            if visible_since is not None:reactions.append(t-visible_since);visible_since=None
        prev=(t,yaw,pitch)
    n=len(shots);hit_rate=hits/n if n else 0;visible_rate=visible_shots/n if n else 0;median_reaction=statistics.median(reactions) if reactions else None;snap_rate=snaps/max(1,len(speeds))
    indicators=[]
    if n>=20 and hit_rate>=.95:indicators.append({'name':'very_high_hit_rate','value':round(hit_rate,4),'note':'Review weapon, rank, sample size, and match context.'})
    if len(reactions)>=10 and median_reaction is not None and median_reaction<80:indicators.append({'name':'very_low_median_reaction_ms','value':median_reaction,'note':'Check clock sync, visibility definition, prefire, and replay interpolation.'})
    if len(speeds)>=20 and snap_rate>=.2:indicators.append({'name':'frequent_large_fast_corrections','value':round(snap_rate,4),'note':'Inspect raw input device events and target-switch context.'})
    return {'events':len(rows),'shots':n,'hits':hits,'hit_rate':round(hit_rate,4),'visible_shot_rate':round(visible_rate,4),'median_reaction_ms':median_reaction,'max_angular_speed_deg_s':round(max(speeds),2) if speeds else None,'snap_rate':round(snap_rate,4),'indicators':indicators}
def main()->None:
    ap=argparse.ArgumentParser();ap.add_argument('csv',type=Path);ap.add_argument('--group',default='player_id');args=ap.parse_args()
    with args.csv.open(newline='',encoding='utf-8-sig') as f:rows=list(csv.DictReader(f))
    required={'timestamp_ms','yaw','pitch'};missing=required-set(rows[0] if rows else {})
    if missing:raise SystemExit('missing columns: '+','.join(sorted(missing)))
    groups=defaultdict(list)
    for row in rows:groups[row.get(args.group,'all') or 'all'].append(row)
    print(json.dumps({k:analyze(v) for k,v in groups.items()},indent=2,ensure_ascii=False))
if __name__=='__main__':main()
