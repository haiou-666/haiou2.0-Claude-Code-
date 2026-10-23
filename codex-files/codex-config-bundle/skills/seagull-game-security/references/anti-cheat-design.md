# Anti-Cheat Design

Use layered controls:

1. Make critical simulation and economy state server-authoritative.
2. Validate movement, fire rate, visibility, ownership, inventory, cooldowns, and state transitions on the server.
3. Sign and version assets/configuration; verify integrity before and during play.
4. Minimize sensitive client data and delay information that is not yet required.
5. Collect explainable telemetry with stable identifiers and time synchronization.
6. Correlate client integrity, server behavior, reports, and historical patterns.
7. Design review and appeal workflows for high-impact actions.

Client controls can raise cost and collect evidence but should not be the sole trust boundary. Build detections with expected false positives, confidence, required sample size, and rollback/appeal considerations.

Retest by replaying known-good and controlled anomalous sessions against the same rule set.
