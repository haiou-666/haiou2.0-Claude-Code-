#!/usr/bin/env python3
"""Audit a JSON license architecture description for common trust failures."""
from __future__ import annotations
import argparse, json
from pathlib import Path

CHECKS=[
 ('critical','private_key_in_client',True,'Private signing key is distributed in the client.'),
 ('critical','embedded_shared_secret',True,'Shared verification/signing secret is embedded in the client.'),
 ('high','client_only_verification',True,'Entitlement is decided entirely by client-controlled code.'),
 ('high','server_entitlement',False,'No server-side entitlement record or authoritative decision.'),
 ('high','asymmetric_signature',False,'Offline license lacks an asymmetric signature.'),
 ('high','replay_protection',False,'Activation/refresh flow lacks nonce or replay tracking.'),
 ('high','revocation',False,'No revocation or forced-refresh mechanism.'),
 ('medium','expiry',False,'No bounded expiry or refresh requirement.'),
 ('medium','activation_limit',False,'No activation/device/concurrency limit.'),
 ('medium','rate_limit',False,'Activation and verification endpoints lack rate limiting.'),
 ('medium','audit_log',False,'High-impact lifecycle actions are not audited.'),
 ('medium','clock_rollback_protection',False,'Offline flow has no clock rollback strategy.'),
 ('medium','update_rollback_protection',False,'Older verification logic can be restored through downgrade.'),
]
def main()->None:
    ap=argparse.ArgumentParser();ap.add_argument('config',type=Path);args=ap.parse_args();cfg=json.loads(args.config.read_text('utf-8-sig'));findings=[]
    for severity,key,bad_when,msg in CHECKS:
        value=bool(cfg.get(key,False));bad=value if bad_when else not value
        if bad:findings.append({'severity':severity,'check':key,'message':msg})
    order={'critical':0,'high':1,'medium':2,'low':3};findings.sort(key=lambda x:order[x['severity']])
    result={'finding_count':len(findings),'findings':findings};print(json.dumps(result,indent=2,ensure_ascii=False));raise SystemExit(0 if not findings else 2)
if __name__=='__main__':main()

