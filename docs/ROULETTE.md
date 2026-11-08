# Roulette Wheel Table Minigame

`whellco_roulette` provides a roulette wheel table minigame.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_roulette
```

## Database

Run:

```sql
source database/whellco_roulette_spins.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Bets use `Player.PlayerData.money.cash`.
- Payouts use `Player.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Roulette rules

- Minimum bet: $100.
- Maximum bet: $10,000.
- Cooldown: 10 seconds.
- Player must be near the roulette table.
- Roulette results are calculated server-side.
- Spin records store player, bet, result, payout, and timestamp.

## Commands

Play roulette:

```text
/roulette number 7 100
/roulette color red 100
/roulette parity even 100
```

View roulette information:

```text
/rouletteinfo
```

## Security

- Bet limits are validated server-side.
- Cooldowns are validated server-side.
- Roulette results are calculated server-side.
- Spin records store player, bet, result, payout, and timestamp.