# Driving School Instructor Job

`whellco_driving_school` provides QBCore-compatible driving lessons, instructor job validation, student payments, and lesson tracking.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_driver_license
ensure whellco_driver_exam
ensure whellco_driving_test
ensure whellco_driving_school
```

## Database

Run:

```sql
source database/whellco_driving_school.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Instructor eligibility uses `Player.PlayerData.job.name == 'drivinginstructor'`.
- Lesson payments use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Instructor payments use `Player.Functions.AddMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Lessons

| Lesson | Price | Duration |
|---|---:|---:|
| Basic Driving Lesson | $500 | 300 seconds |
| Advanced Driving Lesson | $1,000 | 600 seconds |
| Defensive Driving Lesson | $1,500 | 900 seconds |

## Commands

List lessons:

```text
/lessoninfo
```

Start a lesson:

```text
/startlesson basic 2
/startlesson advanced 3
/startlesson defensive 4
```

Complete a lesson:

```text
/completelesson
```

View school information:

```text
/drivingschoolinfo
```

## Security

- Instructor eligibility is validated server-side.
- Students must have enough cash before a lesson starts.
- Lesson cooldowns prevent spam.
- Lesson payments and instructor payouts are handled server-side.
- Lesson records store instructor, student, type, price, and pass status.