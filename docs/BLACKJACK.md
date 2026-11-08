# Casino Blackjack Table Minigame

`whellco_blackjack` provides a casino blackjack table minigame.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_blackjack
```

## Database

Run:

```sql
source database/whellco_blackjack_hands.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Bets use `Player.PlayerData.money.cash`.
- Payouts use `Player.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Blackjack rules

- Minimum bet: $100.
- Maximum bet: $10,000.
- Cooldown: 10 seconds.
- Player must be near the blackjack table.
- Blackjack hand values are calculated server-side.
- Hand records store player, bet, totals, result, payout, and timestamp.

## Commands

Play blackjack:

```text
/blackjack 100
/blackjack 500
```

View blackjack information:

```text
/blackjackinfo
```

## Security

- Bet limits are validated server-side.
- Cooldowns are validated server-side.
- Hand values are calculated server-side.
- Hand records store player, bet, totals, result, payout, and timestamp.