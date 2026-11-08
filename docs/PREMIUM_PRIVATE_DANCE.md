# Premium Private Dance

`whellco_strip_club_premium` adds a premium private dance option for strip club performers.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_strip_club_premium
```

## Database

Run:

```sql
source database/whellco_premium_dances.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Dancer eligibility uses `Player.PlayerData.job.name == 'dancer'`.
- Payment uses `Customer.Functions.RemoveMoney('cash', ...)` and `Dancer.Functions.AddMoney('cash', ...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Premium dance rules

- Price: $25,000.
- Duration: 120 seconds.
- Cooldown: 30 seconds.
- Dancer job: `dancer`.
- Payment is transferred from customer to dancer.
- Dance records store customer, dancer, price, and timestamp.

## Commands

Request a premium dance:

```text
/premiumdance 2
/premiumdance 3
```

View premium dance information:

```text
/premiumdanceinfo
```

## Security

- Dancer eligibility is validated server-side.
- Payment is validated server-side.
- Dance cooldowns are validated server-side.
- Dance records store customer, dancer, price, and timestamp.