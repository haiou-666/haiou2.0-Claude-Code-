# Operations and Abuse Defense

Track key and entitlement lifecycle events:

- issuance source, reseller/operator, payment/order, activation attempts, device changes, refresh, concurrent use, revocation, support override, and migration;
- IP/ASN/region, device confidence, client/build version, timestamps, nonce/replay identifiers, and error category.

Detect patterns such as rapid multi-device activation, impossible geography, shared keys, activation bursts, repeated invalid prefixes, old-client fallback, refresh storms, and reseller inventory anomalies.

Protect administration with least privilege, strong authentication, audit logs, approval for high-impact actions, export controls, and scoped API keys. Avoid exposing raw license secrets in logs, analytics, tickets, or client errors.

Prepare signing-key rotation, database leakage response, forced refresh, mass revocation, customer recovery, and backward-compatible schema migration before an incident.
