# Dancer Tip Jar System

`whellco_dancer_tip_jar` provides a tip jar system for strip club dancers.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_dancer_tip_jar
```

## Database

Run:

```sql
source database/whellco_dancer_tips.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Dancer eligibility uses `Player.PlayerData.job.name == 'dancer'`.
- Payment uses `Customer.Functions.RemoveMoney('cash', ...)` and `Dancer.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Tip rules

- Tip cooldown: 10 seconds.
- Minimum tip: $1.
- Maximum tip: $10,000.
- Dancer job: `dancer`.
- Payment is transferred from customer to dancer.
- Tip records store customer, dancer, amount, and timestamp.

## Commands

Tip a dancer:

```text
/tip 2 100
/tip 3 500
```

View tip information:

```text
/tipinfo
```

## Security

- Dancer eligibility is validated server-side.
- Payment is validated server-side.
- Tip cooldowns are validated server-side.
- Tip records store customer, dancer, amount, and timestamp.