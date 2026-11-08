# Dance Floor Skill Check Minigame

`whellco_dance_floor` provides a dance floor skill check minigame.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_dance_floor
```

## Database

Run:

```sql
source database/whellco_dance_scores.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Dance cooldowns prevent spam.
- Rewards use `Player.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Minigame rules

- Dance cooldown: 30 seconds.
- Minigame duration: 30 seconds.
- Success threshold: 70.
- Players must be near the dance floor.
- Successful dances can earn up to $500.
- Dance records store patron, score, success, reward, and timestamp.

## Commands

Start the minigame:

```text
/dance
```

View dance information:

```text
/danceinfo
```

## Security

- Dance cooldowns are validated server-side.
- Dance location is validated server-side.
- Rewards are validated server-side.
- Dance records store patron, score, success, reward, and timestamp.