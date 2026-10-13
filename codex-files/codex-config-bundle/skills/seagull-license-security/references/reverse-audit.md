# Reverse Audit

Trace the client verification path from startup and feature gates to final entitlement decisions.

Locate:

- activation endpoints, request/response models, headers, signatures, nonces, timestamps, and caches;
- key parsing, canonicalization, hashing, signature verification, device fingerprinting, clock checks, feature flags, and error/fallback branches;
- embedded keys/secrets, certificate pins, update channels, configuration toggles, debug endpoints, and telemetry;
- duplicated checks where one path is stronger than another.

Use static analysis plus breakpoints/hooks around crypto, comparisons, time, storage, networking, and feature gates. Document patchable branches as evidence of client trust, then move the authoritative decision or critical effect to a server-controlled boundary where possible.

For APIs, test activation count, replay, race, tenant/account ownership, product/audience confusion, downgrade, concurrency, rate limit, and error enumeration.
