# Luxury Mansions

`whellco_luxury_mansions` adds purchasable luxury mansions with configurable interiors, ownership, customisation, and state sell-back.

## Important note on custom MLOs

This resource provides the ownership, entrance, teleport, customisation, and database systems for mansions. The actual 3D interior assets must be supplied as FiveM MLO mapping assets. Place the custom MLO files in the relevant mapping resource and set each mansion’s `mloInterior` identifier to match the loaded interior.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_luxury_mansions
```

## Database

Run:

```sql
source database/whellco_mansion_ownership.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Mansion purchases use `Player.Functions.RemoveMoney`.
- Mansion sell-back uses `Player.Functions.AddMoney`.
- Mansion ownership is stored in `whellco_mansion_ownership`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Mansion features

- Purchasable luxury mansions.
- Mansion ownership stored in the database.
- Mansion entrance markers.
- Interior teleportation.
- Configurable mansion price.
- Configurable sell-back percentage.
- Configurable garage, storage, and wardrobe capacity.
- Configurable wall colours.
- Configurable floor styles.
- Configurable lighting modes.

## Mansion list

| Mansion | Price | Sell-back | Garage slots | Storage slots | Wardrobe slots |
|---|---:|---:|---:|---:|---:|
| Vinewood Hills Mansion | $5,000,000 | 70% | 6 | 200 | 100 |
| Pacific Bluffs Mansion | $7,500,000 | 70% | 8 | 250 | 150 |

## Sell-back rules

- Owners can sell their mansion back to the state.
- Sell-back percentage is 70% by default.
- Sell-back amount is based on the mansion’s original purchase price.
- Selling removes mansion ownership.
- Selling resets mansion customisation.
- Sell-back payments are added to the owner’s bank account.

## Customisation

- Wall colours: ivory, charcoal, deep navy, warm sand.
- Floor styles: marble, dark oak, polished concrete, velvet carpet.
- Lighting modes: warm evening, cool modern, candlelight, party mode.
- Customisation is stored per mansion owner.

## Commands

View mansion menu:

```text
/mansions
```

View mansion help:

```text
/mansionhelp
```

View mansion admin information:

```text
/mansionadmin
```

## Security

- Mansion purchases are validated server-side.
- Mansion ownership is validated server-side.
- Mansion access is validated server-side.
- Mansion customisation is validated server-side.
- Mansion sell-back is validated server-side.
- Mansion purchases and sell-backs are logged through QBCore money transactions.