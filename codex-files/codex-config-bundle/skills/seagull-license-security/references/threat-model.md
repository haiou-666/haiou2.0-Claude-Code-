# License Threat Model

Analyze these failure classes:

- client-only entitlement decisions;
- embedded symmetric/shared secrets;
- predictable or low-entropy keys;
- unsigned or weakly signed license files;
- reusable activation responses and missing nonce/audience binding;
- clock rollback and stale cache acceptance;
- device fingerprints based on mutable or privacy-sensitive fields;
- unlimited activation, sharing, resale, credential stuffing, and concurrency abuse;
- verbose errors that expose key validity or account state;
- patchable success branches, bypassable network failures, and fallback modes;
- update/downgrade paths that restore older verification logic;
- admin, reseller, payment, and support workflow abuse.

A public verification key in the client is expected for asymmetric signatures. A private signing key or shared verification secret in the client is a critical design problem.

Separate resistance to casual patching from actual entitlement security. Obfuscation increases analysis cost but does not create a trustworthy decision boundary.
