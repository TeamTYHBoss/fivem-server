# Black Market Part Dealer

`whellco_part_dealer` provides QBCore-compatible sales of chopped vehicle parts and scrap metal.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_chop_shop
ensure whellco_part_dealer
```

## Database

Run:

```sql
source database/whellco_part_dealer.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Part sales use `Player.Functions.RemoveItem(partType, amount)`.
- Sale payouts use `Player.Functions.AddMoney('cash', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_chop_shop` as dependencies.

## Part prices

| Part | Price |
|---|---:|
| Engine | $1,800 |
| Transmission | $1,500 |
| Brakes | $1,000 |
| Suspension | $900 |
| Turbo | $3,000 |
| Armor | $1,200 |
| Body | $2,500 |
| Scrap metal | $150 |

## Commands

Sell chopped parts:

```text
/sellpart engine 2
/sellpart turbo 1
/sellpart body 3
```

Sell scrap metal:

```text
/sellscrap 5
/sellscrap 10
```

View part prices:

```text
/partdealerinfo
```

## Security

- Part type, amount, cooldowns, and location are validated server-side.
- Players must have the part before selling.
- Sale payouts are handled server-side.
- Sale records store citizen ID, part type, amount, and payout.