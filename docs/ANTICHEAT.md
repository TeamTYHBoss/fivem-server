# Adaptive QBCore Anti-Cheat System

`whellco_anticheat` provides adaptive, graduated anti-cheat monitoring for QBCore servers.

## Important limitation

No anti-cheat can be completely foolproof. This system uses layered server-side checks, adaptive thresholds, audit trails, and graduated enforcement to reduce false positives and make abuse harder.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_anticheat
```

## Database

Run:

```sql
source database/whellco_anticheat.sql
```

## Adaptive learning

- Adaptive thresholds start conservative.
- Staff can mark detections as false positives.
- False-positive feedback reduces player scores.
- Threshold adjustments are limited to prevent abuse.
- Detection history is stored for review.

## Graduated enforcement

- Warning threshold: 20 points.
- Kick threshold: 50 points.
- Quarantine threshold: 80 points.
- Permanent ban threshold: 100 points.
- Automatic permanent bans are enabled by default.
- High-confidence events create audit records before enforcement.

## Detection layers

- Invalid money amounts.
- Invalid item amounts.
- Event flooding.
- Vehicle spawn spam.
- Impossible movement.
- Teleport detection.
- Weapon spawn detection.
- Godmode detection.

## Commands

View anti-cheat status:

```text
/anticheatstatus
```

View anti-cheat information:

```text
/anticheatinfo
```

## Security

- Detection and enforcement run server-side.
- Client reports are treated as signals, not proof.
- Automatic permanent bans are enabled by default.
- Permanent bans require a score of 100 or higher.
- Audit trails store detection, score, and case details.