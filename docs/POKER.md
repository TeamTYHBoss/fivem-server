# Poker Table Minigame

`whellco_poker` provides a poker table minigame.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_poker
```

## Database

Run:

```sql
source database/whellco_poker_hands.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Bets use `Player.PlayerData.money.cash`.
- Payouts use `Player.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Poker rules

- Minimum bet: $100.
- Maximum bet: $10,000.
- Cooldown: 10 seconds.
- Player must be near the poker table.
- Poker hands are evaluated server-side.
- Hand records store player, bet, hands, result, payout, and timestamp.

## Commands

Play poker:

```text
/poker 100
/poker 500
```

View poker information:

```text
/pokerinfo
```

## Security

- Bet limits are validated server-side.
- Cooldowns are validated server-side.
- Poker hands are evaluated server-side.
- Hand records store player, bet, hands, result, payout, and timestamp.