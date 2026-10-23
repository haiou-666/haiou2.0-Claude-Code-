#!/usr/bin/env python3
"""Reference Ed25519 license issuer and verifier."""
from __future__ import annotations
import argparse, base64, json
from datetime import datetime, timedelta, timezone
from pathlib import Path
try:
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey, Ed25519PublicKey
    from cryptography.exceptions import InvalidSignature
except ImportError as e:
    raise SystemExit('Install dependency: python -m pip install cryptography') from e

def canonical(payload:dict)->bytes:return json.dumps(payload,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()
def utcnow()->datetime:return datetime.now(timezone.utc)
def iso(dt:datetime)->str:return dt.astimezone(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00','Z')
def parse_time(text:str)->datetime:return datetime.fromisoformat(text.replace('Z','+00:00')).astimezone(timezone.utc)

def genkey(args)->None:
    private=Ed25519PrivateKey.generate();public=private.public_key()
    args.private.write_bytes(private.private_bytes(serialization.Encoding.PEM,serialization.PrivateFormat.PKCS8,serialization.NoEncryption()))
    args.public.write_bytes(public.public_bytes(serialization.Encoding.PEM,serialization.PublicFormat.SubjectPublicKeyInfo))
    print(json.dumps({'private':str(args.private.resolve()),'public':str(args.public.resolve())},indent=2))
def issue(args)->None:
    key=serialization.load_pem_private_key(args.private.read_bytes(),password=None)
    now=utcnow();expires=parse_time(args.expires) if args.expires else now+timedelta(days=args.days)
    payload={'schema':1,'license_id':args.license_id,'product':args.product,'subject':args.subject,'features':sorted(set(x for x in args.features.split(',') if x)),'issued_at':iso(now),'expires_at':iso(expires),'nonce':args.nonce}
    if args.device:payload['device_policy']={'device_id':args.device}
    doc={'alg':'Ed25519','payload':payload,'signature':base64.b64encode(key.sign(canonical(payload))).decode()}
    args.output.write_text(json.dumps(doc,indent=2,ensure_ascii=False),encoding='utf-8');print(args.output.resolve())
def verify(args)->None:
    key=serialization.load_pem_public_key(args.public.read_bytes());doc=json.loads(args.license.read_text('utf-8'));errors=[]
    try:key.verify(base64.b64decode(doc['signature']),canonical(doc['payload']))
    except (InvalidSignature,KeyError,ValueError):errors.append('invalid_signature')
    p=doc.get('payload',{});now=parse_time(args.now) if args.now else utcnow()
    try:
        if now>parse_time(p['expires_at']):errors.append('expired')
    except Exception:errors.append('invalid_expiry')
    if args.product and p.get('product')!=args.product:errors.append('product_mismatch')
    if args.subject and p.get('subject')!=args.subject:errors.append('subject_mismatch')
    if args.device and p.get('device_policy',{}).get('device_id')!=args.device:errors.append('device_mismatch')
    result={'ok':not errors,'errors':errors,'payload':p};print(json.dumps(result,indent=2,ensure_ascii=False));raise SystemExit(0 if result['ok'] else 2)
def main()->None:
    ap=argparse.ArgumentParser();sub=ap.add_subparsers(dest='cmd',required=True)
    p=sub.add_parser('genkey');p.add_argument('--private',type=Path,default=Path('license-private.pem'));p.add_argument('--public',type=Path,default=Path('license-public.pem'));p.set_defaults(fn=genkey)
    p=sub.add_parser('issue');p.add_argument('--private',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--license-id',required=True);p.add_argument('--product',required=True);p.add_argument('--subject',required=True);p.add_argument('--features',default='');p.add_argument('--days',type=int,default=30);p.add_argument('--expires');p.add_argument('--nonce',required=True);p.add_argument('--device');p.set_defaults(fn=issue)
    p=sub.add_parser('verify');p.add_argument('--public',type=Path,required=True);p.add_argument('--license',type=Path,required=True);p.add_argument('--now');p.add_argument('--product');p.add_argument('--subject');p.add_argument('--device');p.set_defaults(fn=verify)
    args=ap.parse_args();args.fn(args)
if __name__=='__main__':main()
