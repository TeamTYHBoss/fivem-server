# Driver Test & Exam System

`whellco_driver_exam` provides QBCore-compatible driver theory exams, scoring, cooldowns, and exam history.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_driver_license
ensure whellco_driver_exam
```

## Database

Run:

```sql
source database/whellco_driver_exam.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Exam participation uses `Player.PlayerData.citizenid`.
- Exam fees use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Exams

| Exam | Price | Questions | Pass mark |
|---|---:|---:|---:|
| Car Theory Exam | $250 | 5 | 70% |
| Bike Theory Exam | $150 | 3 | 70% |

## Commands

List exams:

```text
/exams
```

Take an exam:

```text
/takeexam car
/takeexam bike
```

View instructions:

```text
/examinstructions
```

## Security

- Exam eligibility, cooldowns, and fees are validated server-side.
- Players must be near the DMV exam center to start an exam.
- Answers are validated server-side against the configured answer key.
- Exam scores and pass/fail results are stored in MySQL.
- Players cannot retake an exam immediately after finishing one.