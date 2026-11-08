# Black Market & Laundering

`whellco_blackmarket` provides QBCore-compatible black-market purchases, money laundering, cooldowns, location checks, and transaction records.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_blackmarket
```

## Database

Run:

```sql
source database/whellco_blackmarket.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Purchases use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Purchased items use `Player.Functions.AddItem(itemName, amount)`.
- Laundering converts cash to QBCore bank balance.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Black market

| Item | Price | Stock |
|---|---:|---:|
| Lockpick | $750 | 10 |
| Repair kit | $1,500 | 5 |
| Weapon attachment | $2,500 | 3 |
| Encrypted phone | $5,000 | 2 |

## Laundering

- Minimum launder amount: $100.
- Maximum launder amount: $100,000.
- Laundering fee: 15%.
- Laundering cooldown: 30 seconds.
- Players must be near the configured laundering location.

## Commands

List black-market items:

```text
/blackmarket
/blackmarketitems
```

Purchase an item:

```text
/blackmarketpurchase lockpick 2
/blackmarketpurchase repairkit 1
```

Launder money:

```text
/launder 5000
/launder 25000
```

View laundering limits:

```text
/launderinfo
```

## Security

- Purchases and laundering are validated server-side.
- Players must be near the configured black-market or laundering location.
- Purchase and laundering cooldowns prevent spam.
- Transaction records store citizen ID, type, item, amount, fee, and details.
- Laundering converts cash into QBCore bank balance after fees.
- Players cannot launder more cash than they possess.