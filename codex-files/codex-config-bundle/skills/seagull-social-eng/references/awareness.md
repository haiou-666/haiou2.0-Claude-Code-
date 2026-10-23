# Security Awareness Content

## Phishing Scenario Templates

### Credential Harvesting Email

```
Subject: [ACTION REQUIRED] Your account will be suspended

Indicators to teach:
- Sender domain ≠ brand domain (e.g. support@company-secure.net vs company.com)
- Urgency language: "immediate action", "24 hours", "suspended"
- Generic greeting: "Dear User" vs your actual name
- Mismatched link: display text says company.com but href points elsewhere
- Suspicious attachment: invoice.pdf.exe, document.xlsm

Training takeaway:
→ Hover over links before clicking
→ Check sender domain (not display name)
→ Go directly to site by typing URL, don't click email links
```

### Spear Phishing (Targeted)

```
Uses:
- Victim's real name (from LinkedIn)
- Correct job title and company
- References real colleague or project
- Plausible pretext (IT ticket, HR policy update, CFO wire request)

Detection harder because:
- Passes "does this make sense for me?" check
- May come from compromised legitimate account

Training takeaway:
→ Verify unusual requests via separate channel (call the person)
→ Especially for: wire transfers, credential requests, unusual software installs
```

## Pretexting Scenarios (for authorized exercises)

```
Scenario 1: IT Support
Pretext: "Hi, this is IT helpdesk. We're seeing unusual activity on your account.
         Can you verify your credentials so I can reset your access?"
Defense: IT never asks for passwords. Call back on known IT number.

Scenario 2: Executive Request (BEC)
Pretext: Email appearing to be from CEO asking for urgent wire transfer
Defense: Verify any unusual financial request via voice call to known number.

Scenario 3: Tailgating
Pretext: Person in uniform carrying boxes asks to hold door
Defense: All visitors must badge in independently regardless of hands-full.
```

## Awareness Metrics

```
Phishing simulation metrics:
- Click rate: % of users who clicked link
- Credential submission rate: % who entered credentials
- Report rate: % who reported the simulation
- Time to report: how quickly was IT notified

Target benchmarks (industry):
- Click rate < 5% after training
- Report rate > 80%
- Time to report < 30 minutes

Track by department, role level, tenure
Run simulations quarterly with increasing sophistication
```

## Quick Reference Card

```
RED FLAGS IN EMAIL:
□ Unexpected urgency or threats
□ Sender domain doesn't match company
□ Generic greeting ("Dear Customer")
□ Requests for credentials/money/sensitive data
□ Links that don't match what they say
□ Unexpected attachments (especially .exe, .xlsm, .docm)

IF SUSPICIOUS:
1. Do NOT click links or open attachments
2. Report to security team (forward as attachment)
3. Verify with sender via known phone number
4. If you clicked: report immediately, don't try to hide it

REMEMBER:
- IT will never ask for your password
- Urgency is a manipulation tactic
- When in doubt, pick up the phone
```
