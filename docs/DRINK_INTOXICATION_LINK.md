# Drink Quality and Intoxication Link

`whellco_drink_intoxication_link` links drink quality to patron intoxication.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_drink_intoxication_link
```

## Database

Run:

```sql
source database/whellco_drink_intoxication.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Bartender eligibility uses `Player.PlayerData.job.name == 'bartender'`.
- Drink quality uses `Config.QualityThresholds`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Quality rules

- Poor quality: score below 70.
- Good quality: score 70 to 89.
- Excellent quality: score 90 or above.
- Intoxication gain: 5 for poor, 10 for good, 15 for excellent.
- Maximum intoxication: 100.

## Commands

Serve a drink:

```text
/drinkquality 2 85
/drinkquality 3 95
```

View drink quality information:

```text
/drinkqualityinfo
```

## Security

- Bartender eligibility is validated server-side.
- Drink quality is validated server-side.
- Intoxication is validated server-side.
- Drink records store bartender, patron, score, quality, intoxication, and timestamp.