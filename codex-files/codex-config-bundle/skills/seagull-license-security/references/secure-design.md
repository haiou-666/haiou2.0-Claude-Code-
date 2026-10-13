# Secure Design

## Online-first

Keep entitlement truth server-side. Bind activation/refresh to product, account/key, device record, version, audience, nonce, issued time, expiry, and server-side state. Use TLS plus application signatures only where message portability or offline verification requires them.

## Offline licenses

Use asymmetric signatures. Keep the private signing key outside distributed clients; embed only the public verification key. Sign a canonical payload containing license ID, product, features, customer/subject, issued time, expiry, optional device policy, version, and unique nonce.

Handle clock rollback with monotonic/server checkpoints, bounded grace periods, and explicit risk decisions. Offline revocation is inherently delayed; define update/reconnect requirements.

## Device binding

Prefer a server-managed device record and replaceable device identifiers. Treat hardware fingerprints as noisy signals, not immutable secrets. Support migration, repair, privacy, and false-positive handling.

## Lifecycle

Design issuance, activation limits, refresh, revocation, transfer, key rotation, breach response, audit logs, reseller controls, and schema/version migration together.
