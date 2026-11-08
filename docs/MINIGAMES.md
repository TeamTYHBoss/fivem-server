# Server Minigames

`whellco_minigames` provides a collection of minigames to keep players interested.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_minigames
```

## Database

Run:

```sql
source database/whellco_minigames.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Coffee purchase uses `Player.Functions.RemoveMoney('cash', ...)`.
- Rewards use `Player.Functions.AddItem(...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Minigames

- Coffee vendor: buy coffee at the vendor.
- Lockpick challenge: timed lockpicking minigame.
- Terminal hack: timed hacking minigame.
- Vehicle repair: timed repair minigame.

## Commands

```text
/coffee
/lockpickgame
/hackgame
/repairgame
/minigameinfo
```

## Security

- Coffee vendor location is validated server-side.
- Coffee payment is validated server-side.
- Minigame rewards are validated server-side.
- Minigame records store player, game type, score, success, and timestamp.