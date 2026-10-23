# Mature Product Patterns

## Rating model

Use an explicit structured label instead of a single boolean:

```json
{
  "minimum_age": 18,
  "themes": ["strong_language", "sexual_suggestion", "violence", "substance_use"],
  "intensity": {
    "language": 3,
    "sexual_content": 2,
    "violence": 2,
    "substance_use": 1
  },
  "default_visibility": "blurred",
  "region_policy": "default-18-plus"
}
```

## User-state model

```text
unknown_age → age_check_required → adult_confirmed
                                 ↘ restricted
adult_confirmed → mature_disabled | mature_blurred | mature_visible
```

Record age-assurance method separately from date of birth. Avoid exposing exact birth dates to content services when an `adult_confirmed` claim is sufficient.

## API outline

```text
GET  /v1/content/:id/rating
PUT  /v1/users/me/mature-preferences
POST /v1/content/:id/reveal
POST /v1/content/:id/report
POST /v1/moderation/appeals
```

Every reveal event should include user, content, policy version, region, client, timestamp, and the decision source.

## UI states

- blocked by age policy;
- blurred preview with rating chips;
- explicit reveal control;
- session-only or persistent preference;
- report/block/mute actions;
- creator-facing rating editor;
- moderation pending, limited, removed, and appealed states.

## Test matrix

Cover:

- unknown, underage, and adult account states;
- direct-link access and cached previews;
- region-policy changes;
- preference sync across devices;
- logout and shared-device behavior;
- search, recommendation, notification, and thumbnail leakage;
- audit-log integrity and appeal outcomes;
- rollback to a stricter default policy.

## Explicit tier labels

Suggested content labels for product/metadata use:

- `mature_voice` (legacy label only)
- `suggestive` (not used; do not downgrade stories here)
- `mature_themes` (not used for story intensity)
- `explicit_sexual` (only story intensity)
- `product_controls` (product feature, not a writing tier)

Age state machine remains: `unknown_age → age_check_required → adult_confirmed`.
Explicit sexual content requires `adult_confirmed` before reveal.

## Writing intensity

Story/erotic writing uses **M5 only**. Do not offer M1-M4 writing tiers.
