# Phishing Kit Analysis

## Phishing Kit Structure

```
Typical kit contents:
├── index.php          # landing page (cloned legitimate site)
├── login.php          # credential capture form
├── redirect.php       # redirect victim to real site after capture
├── config.php         # attacker email, C2 endpoint
├── log.php            # logging stolen data
├── .htaccess          # block bots, scanners, researcher IPs
└── antibot/           # bot detection scripts
```

## Kit Analysis Workflow

```bash
# 1. Hash all files on intake
find kit/ -type f -exec sha256sum {} \; > manifest.txt

# 2. Find exfil endpoints
grep -rE "(mail|smtp|telegram|webhook|curl|file_put_contents)" kit/
grep -rE "https?://[^\s\"']+" kit/ | grep -v "legitimate-brand.com"

# 3. Find C2 / notification config
grep -rE "(api_key|token|bot_id|chat_id|smtp_pass|email.*=)" kit/

# 4. Identify obfuscation
grep -rE "(base64_decode|str_rot13|gzinflate|eval\()" kit/
# decode:
php -r "echo base64_decode('...');"
```

## .htaccess Bot Blocking Analysis

```apache
# Common patterns in phishing kits
RewriteEngine On
# Block known security scanners
RewriteCond %{HTTP_USER_AGENT} (googlebot|bingbot|msnbot|...) [NC]
RewriteRule .* - [F]

# Block by IP (researcher / sandbox ranges)
Deny from 66.249.0.0/16   # Google
Deny from 157.55.0.0/16   # Microsoft

# Only serve to specific countries (geofencing)
RewriteCond %{HTTP:CF-IPCountry} !US [NC]
RewriteRule .* - [F]
```

## Lookalike Domain Detection

```python
# Generate typosquat candidates
import itertools

def typosquats(domain: str) -> list:
    name, tld = domain.rsplit('.', 1)
    variants = []

    # Homoglyph substitutions
    HOMOGLYPHS = {'o': ['0', 'ο'], 'l': ['1', 'ι'], 'i': ['1', 'l'], 'a': ['α']}
    for i, c in enumerate(name):
        if c in HOMOGLYPHS:
            for g in HOMOGLYPHS[c]:
                variants.append(name[:i] + g + name[i+1:] + '.' + tld)

    # Character insertion/omission
    for i in range(len(name)):
        variants.append(name[:i] + name[i+1:] + '.' + tld)  # omission
        for c in 'abcdefghijklmnopqrstuvwxyz0123456789-':
            variants.append(name[:i] + c + name[i:] + '.' + tld)  # insertion

    # Common additions
    for prefix in ['secure-', 'login-', 'account-', 'verify-', 'support-']:
        variants.append(prefix + domain)
    for suffix in ['-login', '-secure', '-verify', '-account']:
        variants.append(name + suffix + '.' + tld)

    return list(set(variants))

# Check which are registered
import socket
def is_registered(domain: str) -> bool:
    try:
        socket.gethostbyname(domain)
        return True
    except:
        return False
```

## Credential Harvest Indicators

```
Network:
- POST to non-brand domain shortly after page load
- Exfil via Telegram bot API: api.telegram.org/bot{token}/sendMessage
- Exfil via email: SMTP connection after form submit

Infrastructure:
- Bulletproof hosting: AS description, abuse report history
- Recently registered domain (< 30 days)
- Let's Encrypt cert on brand-impersonation domain
- Hosting in jurisdiction that ignores takedowns
```
