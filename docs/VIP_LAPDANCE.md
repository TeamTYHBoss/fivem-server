# Private VIP Lap Dance Rooms

`whellco_vip_lapdance` provides private VIP lap dance rooms with unique animations, booking, and payments.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_vip_lapdance
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Room bookings use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## VIP rooms

| Room | Price | Duration |
|---|---:|---:|
| VIP Room 1 | $2,500 | 45 seconds |
| VIP Room 2 | $3,500 | 45 seconds |

## Commands

Book a VIP room:

```text
/bookvip vip_1
/bookvip vip_2
```

View VIP information:

```text
/vipinfo
```

## Security

- Room bookings, cooldowns, and payments are validated server-side.
- Players must be near the VIP room.
- VIP room animations are client-side only.