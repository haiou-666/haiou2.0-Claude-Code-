# Infrastructure OSINT

## DNS Enumeration

```bash
# Basic resolution
dig A target.com +short
dig MX target.com +short
dig TXT target.com +short  # SPF, DMARC, verification tokens
dig NS target.com +short

# Zone transfer attempt (usually blocked)
dig AXFR target.com @ns1.target.com

# Reverse DNS
dig -x 1.2.3.4 +short
```

## Certificate Transparency

```bash
# crt.sh API
curl "https://crt.sh/?q=%.target.com&output=json" | jq '.[].name_value' | sort -u

# Subfinder (active enumeration)
subfinder -d target.com -silent

# amass passive
amass enum -passive -d target.com
```

## ASN / IP Range Mapping

```bash
# Find ASN for IP
whois -h whois.cymru.com " -v 1.2.3.4"

# Get all IP ranges for an ASN
whois -h whois.radb.net -- '-i origin AS12345' | grep ^route

# BGP toolkit
curl "https://api.bgpview.io/asn/12345/prefixes" | jq '.data.ipv4_prefixes[].prefix'
```

## Historical DNS / IP Changes

```
- SecurityTrails: https://securitytrails.com/domain/target.com/history/a
- PassiveTotal / RiskIQ
- Shodan: https://www.shodan.io/search?query=hostname:target.com
- Censys: https://search.censys.io/
- FOFA: https://fofa.info/
```

## Port / Service Fingerprinting

```bash
# Shodan CLI
shodan host 1.2.3.4
shodan search "hostname:target.com" --fields ip_str,port,org,product

# masscan for IP ranges
masscan -p80,443,8080,8443,22,21,25,3389 1.2.3.0/24 --rate=1000

# nmap service version
nmap -sV -sC -p- --open 1.2.3.4 -oA output
```

## Cloud / CDN Detection

```bash
# Identify CDN/WAF
curl -I https://target.com | grep -i 'cf-ray\|x-amz\|x-cache\|x-sucuri'

# Bypass CDN to find origin IP:
# 1. Check historical DNS (SecurityTrails)
# 2. MX/mail server IP (often not behind CDN)
# 3. Certificate SAN list for subdomains
# 4. Search Shodan for SSL cert fingerprint
shodan search "ssl.cert.subject.cn:target.com" --fields ip_str,port,org
```

## GitHub / Code Leak Hunting

```bash
# GitHub search operators
site:github.com "target.com" "api_key"
site:github.com "target.com" "password"
site:github.com "target.com" ".env"

# truffleHog
trufflehog github --org=targetorg --only-verified

# gitleaks
gitleaks detect --source ./cloned_repo
```
