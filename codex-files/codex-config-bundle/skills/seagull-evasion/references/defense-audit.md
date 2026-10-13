# Defense Audit and Coverage Analysis

## EDR Coverage Matrix

| Technique (ATT&CK) | Windows Defender | CrowdStrike | SentinelOne | Carbon Black |
|-------------------|-----------------|-------------|-------------|--------------|
| T1055 Process Injection | Partial | High | High | Medium |
| T1059.001 PowerShell | High | High | High | High |
| T1003.001 LSASS Dump | High | High | High | Medium |
| T1547.001 Registry Run | High | High | High | High |
| T1562.001 Disable AV | High | High | High | Medium |
| Syscall (direct) | Low | Medium | Medium | Low |
| DMA read | None | None | None | None |

## Gap Analysis Methodology

```
1. Map current security stack
   - EDR product + version
   - AV signatures (last updated)
   - Network controls (IDS/IPS/NDR)
   - Log coverage (SIEM sources)

2. Enumerate detection gaps
   - Test each ATT&CK technique against current stack
   - Note: detected / alerted / logged / missed

3. Risk rank gaps
   - Impact × Likelihood × Detectability

4. Recommend controls
   - Technical: rule/signature additions
   - Architectural: logging gaps, sensor placement
   - Process: response playbooks
```

## Detection Engineering Checklist

```
For each critical TTP, verify:
□ Log source generating events (Sysmon, ETW, WEF, PCAP)
□ Log forwarding to SIEM (no gaps in pipeline)
□ Detection rule exists (Sigma/YARA/Suricata)
□ Rule tested against real sample (not just unit test)
□ Alert threshold tuned (FP rate acceptable)
□ Response playbook defined
□ Purple team exercise completed
```

## Sysmon Coverage

```xml
<!-- Sysmon config for injection detection -->
<EventFiltering>
  <!-- Process access to LSASS -->
  <ProcessAccess onmatch="include">
    <TargetImage condition="end with">lsass.exe</TargetImage>
  </ProcessAccess>

  <!-- Remote thread creation -->
  <CreateRemoteThread onmatch="include">
    <TargetImage condition="is not">C:\Windows\System32\svchost.exe</TargetImage>
  </CreateRemoteThread>

  <!-- Suspicious network connections -->
  <NetworkConnect onmatch="include">
    <Image condition="end with">powershell.exe</Image>
    <Image condition="end with">rundll32.exe</Image>
  </NetworkConnect>
</EventFiltering>
```

## Purple Team Testing Script

```python
# Run a TTP, verify detection was triggered
import subprocess, time, requests

def test_ttp(ttp_id: str, command: str, siem_query: str, wait: int = 30):
    print(f"[*] Testing {ttp_id}: {command}")
    t0 = time.time()
    subprocess.run(command, shell=True, capture_output=True)
    time.sleep(wait)

    # Query SIEM API (Splunk/Elastic/etc.)
    # resp = requests.get(SIEM_URL, params={'query': siem_query, 'earliest': t0})
    # detected = resp.json()['results']

    print(f"[*] Expected detection in SIEM: {siem_query}")
    print(f"[?] Verify manually or via SIEM API")

# Example
test_ttp(
    'T1003.001',
    'procdump.exe -ma lsass.exe lsass.dmp',
    'index=sysmon EventCode=10 TargetImage="*lsass.exe"'
)
```
