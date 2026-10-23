# Person OSINT

## Email → Identity Chain

```
email address
  → username pattern
  → platform search
  → linked accounts
  → real name
  → location / employer
  → other emails / phones
```

## Username Search

```bash
# sherlock
python3 sherlock username

# maigret (more sources)
python3 -m maigret username --all-sites

# Manual priority platforms:
# GitHub, GitLab, Twitter/X, LinkedIn, Instagram, Reddit, HackerNews
# Telegram, Discord (via server search), Steam
```

## Email Reputation / Breach Check

```
# Public breach databases (API):
- HaveIBeenPwned: https://haveibeenpwned.com/api/v3/breachedaccount/{email}
- DeHashed: https://dehashed.com/ (paid)
- Snusbase (paid)

# Free check:
curl "https://haveibeenpwned.com/api/v3/breachedaccount/target@example.com" \
  -H "hibp-api-key: YOUR_KEY"
```

## LinkedIn OSINT

```
# Search operators (Google):
site:linkedin.com/in/ "Company Name" "Job Title"
site:linkedin.com/in/ "target name" "city"

# Tools:
- linkedin2username: generate username wordlists from company employees
  python3 linkedin2username.py -c "Company Name"
- CrossLinked: scrape employee names
```

## GitHub / Code Leak

```bash
# Search for target's email in commits
git log --all --format='%ae %an' | grep -i "target"

# GitHub search
site:github.com "target@company.com"
site:github.com "company.com" "password"

# gitrob / truffleHog for org-wide secrets
trufflehog github --org=targetorg
```

## Phone Number OSINT

```
# Reverse lookup:
- Truecaller (app/web)
- NumLookup API
- HLR lookup (operator, country, line type)

# Telegram: +phone number search
# WhatsApp: add to contacts → check "about" and profile photo
```

## Photo / Face OSINT

```
# Reverse image search:
- Google Images
- Yandex Images (best for faces)
- TinEye

# Metadata extraction from photos:
exiftool photo.jpg | grep -iE "gps|location|author|created"
```
