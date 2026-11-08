# Lottery Ticket Scratch Card Minigame

`whellco_scratch_cards` provides a lottery ticket scratch card minigame.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_scratch_cards
```

## Database

Run:

```sql
source database/whellco_scratch_cards.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Scratch cards use `Player.Functions.RemoveItem('scratch_card', 1)`.
- Payouts use `Player.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Scratch card rules

- Card price: $100.
- Cooldown: 10 seconds.
- Scratch card item: `scratch_card`.
- Prize chances: 60% no prize, 25% $200, 10% $500, 4% $1,000, 1% $5,000.
- Scratch records store player, card, payout, win status, and timestamp.

## Commands

Scratch a card:

```text
/scratch
```

View scratch card information:

```text
/scratchinfo
```

## Security

- Scratch card item is validated server-side.
- Scratch cooldowns are validated server-side.
- Prize outcomes are calculated server-side.
- Scratch records store player, card, payout, win status, and timestamp.