# Street Food Vendor Minigame

`whellco_street_food` provides a street food vendor minigame.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_street_food
```

## Database

Run:

```sql
source database/whellco_street_food_orders.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Payment uses `Player.Functions.RemoveMoney('cash', ...)`.
- Rewards use `Player.Functions.AddItem(...)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Vendor rules

- Vendor location: `120.0, -1290.0, 29.3`.
- Food price: $75.
- Order cooldown: 10 seconds.
- Minigame duration: 20 seconds.
- Success threshold: 65.
- Foods: hot dog, burger, taco.

## Commands

Order food:

```text
/streetfood 1
/streetfood 2
/streetfood 3
```

View vendor information:

```text
/streetfoodinfo
```

## Security

- Vendor location is validated server-side.
- Food selection is validated server-side.
- Payment is validated server-side.
- Order records store patron, food, score, success, and timestamp.