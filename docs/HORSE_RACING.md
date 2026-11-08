# Horse Racing Track Minigame

`whellco_horse_racing` provides a horse racing track minigame.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_horse_racing
```

## Database

Run:

```sql
source database/whellco_horse_bets.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Bets use `Player.PlayerData.money.cash`.
- Payouts use `Player.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Racing rules

- Minimum bet: $100.
- Maximum bet: $10,000.
- Cooldown: 15 seconds.
- Player must be near the racing track.
- Horses are defined in config with odds.
- Race results are calculated server-side.
- Bet records store player, horse, bet, winner, payout, and timestamp.

## Commands

Place a bet:

```text
/horsebet 1 100
/horsebet 2 500
```

View racing information:

```text
/horsebetinfo
```

## Security

- Bet limits are validated server-side.
- Cooldowns are validated server-side.
- Race results are calculated server-side.
- Bet records store player, horse, bet, winner, payout, and timestamp.