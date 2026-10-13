#!/usr/bin/env python3
"""Domain OSINT recon: DNS, WHOIS, certificate transparency, email pattern inference."""
from __future__ import annotations
import argparse, json, re, socket, ssl, sys, urllib.request

def dns_resolve(domain: str) -> dict:
    results = {}
    for qtype, func in [("A", socket.gethostbyname_ex)]:
        try:
            _, _, addrs = socket.gethostbyname_ex(domain)
            results["A"] = addrs
        except socket.gaierror as e:
            results["A"] = [str(e)]
    return results

def fetch_crt_sh(domain: str) -> list[str]:
    url = f"https://crt.sh/?q=%.{domain}&output=json"
    ctx = ssl.create_default_context()
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Seagull-OSINT/1.0"})
        with urllib.request.urlopen(req, timeout=15, context=ctx) as r:
            data = json.loads(r.read())
        names = set()
        for entry in data:
            for name in entry.get("name_value", "").split("\n"):
                name = name.strip().lstrip("*.")
                if name and domain in name:
                    names.add(name)
        return sorted(names)
    except Exception as e:
        return [f"Error: {e}"]

def guess_email_patterns(domain: str, name: str = "john.doe") -> list[str]:
    parts = name.split(".")
    first, last = parts[0], parts[-1] if len(parts) > 1 else parts[0]
    return [
        f"{first}.{last}@{domain}",
        f"{first}{last}@{domain}",
        f"{first[0]}{last}@{domain}",
        f"{first}@{domain}",
        f"info@{domain}",
        f"admin@{domain}",
        f"contact@{domain}",
    ]

def main() -> None:
    ap = argparse.ArgumentParser(description="Domain OSINT recon")
    ap.add_argument("domain")
    ap.add_argument("--name", default="john.doe", help="Sample name for email pattern inference")
    args = ap.parse_args()

    domain = args.domain.lower().strip()
    print(f"[*] Target domain: {domain}\n")

    print("[*] DNS resolution:")
    dns = dns_resolve(domain)
    for qtype, records in dns.items():
        for r in records:
            print(f"    {qtype}: {r}")

    print("\n[*] Certificate transparency (subdomains via crt.sh):")
    subdomains = fetch_crt_sh(domain)
    for sub in subdomains[:50]:
        print(f"    {sub}")
    if len(subdomains) > 50:
        print(f"    ... and {len(subdomains) - 50} more")

    print(f"\n[*] Email pattern inference (sample name: {args.name}):")
    for pattern in guess_email_patterns(domain, args.name):
        print(f"    {pattern}")

    print(f"\n[*] Manual follow-up:")
    print(f"    WHOIS  : whois {domain}")
    print(f"    Shodan : https://www.shodan.io/search?query=hostname%3A{domain}")
    print(f"    Hunter : https://hunter.io/domain-search/{domain}")
    print(f"    GitHub : https://github.com/search?q={domain}&type=code")

if __name__ == "__main__":
    main()
