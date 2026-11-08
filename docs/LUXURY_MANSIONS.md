# Luxury Mansions

`whellco_luxury_mansions` adds purchasable luxury mansions with configurable interiors, ownership, guest access, private events, CCTV, staff hiring, and state sell-back.

## Important note on custom MLOs

This resource provides the ownership, entrance, teleport, customisation, access control, events, CCTV, staff hiring, and database systems for mansions. The actual 3D interior assets must be supplied as FiveM MLO mapping assets. Place the custom MLO files in the relevant mapping resource and set each mansion’s `mloInterior` identifier to match the loaded interior.

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
source database/whellco_mansion_staff.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Mansion purchases use `Player.Functions.RemoveMoney`.
- Mansion sell-back uses `Player.Functions.AddMoney`.
- Mansion staff hiring uses `Player.Functions.RemoveMoney`.
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

## Gated access control

- Owners can add friends to the mansion guest list.
- Owners can remove friends from the mansion guest list.
- Guests can enter the mansion.
- Non-guests cannot enter.
- Guest lists are stored in `whellco_mansion_guests`.
- Guest limits are configurable per mansion.

## Staff hiring

- Owners can hire security guards and maids.
- Security guards cost $25,000 to hire.
- Maids cost $15,000 to hire.
- Security guards earn $500 per hour.
- Maids earn $300 per hour.
- Staff limits are configurable per mansion.
- Owners can dismiss staff at any time.
- Staff records are stored in `whellco_mansion_staff`.

## Security guard behaviour

- Security guards patrol the mansion interior.
- Guards choose random patrol points every 5 seconds.
- Guards confront players who come within 10 metres.
- Guards move toward nearby players to investigate.
- Guards use stun guns rather than lethal weapons.
- Guards have 50 armour.
- Guards are removed when the player leaves the mansion.

## Maid behaviour

- Maids clean the mansion interior.
- Maids move to random cleaning points every 10 seconds.
- Each maid increases cleanliness by 5 points every 10 seconds.
- Mansion cleanliness decreases by 2 points every 10 seconds without maids.
- Cleanliness starts at 100 when the owner enters the mansion.
- Maids are removed when the player leaves the mansion.

## Private events

- Owners can host private parties or events.
- Event names and durations are configurable.
- Event duration range is 15 to 240 minutes.
- Events are stored in `whellco_mansion_events`.
- Owners can end events at any time.

## CCTV security

- Owners can install CCTV cameras.
- Camera names and positions are configurable.
- Camera limits are configurable per mansion.
- Cameras are stored in `whellco_mansion_cameras`.
- Owners can remove cameras at any time.

## Mansion list

| Mansion | Price | Sell-back | Guests | Cameras | Security guards | Maids | Garage slots | Storage slots | Wardrobe slots |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Vinewood Hills Mansion | $5,000,000 | 70% | 20 | 8 | 4 | 4 | 6 | 200 | 100 |
| Pacific Bluffs Mansion | $7,500,000 | 70% | 30 | 12 | 6 | 6 | 8 | 250 | 150 |

## Customisation

- Wall colours: ivory, charcoal, deep navy, warm sand.
- Floor styles: marble, dark oak, polished concrete, velvet carpet.
- Lighting modes: warm evening, cool modern, candlelight, party mode.
- Customisation is stored per mansion owner.

## Sell-back rules

- Owners can sell their mansion back to the state.
- Sell-back percentage is 70% by default.
- Sell-back amount is based on the mansion’s original purchase price.
- Selling removes mansion ownership.
- Selling removes guest access, events, cameras, and staff.
- Sell-back payments are added to the owner’s bank account.

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
- Mansion guest access is validated server-side.
- Mansion staff hiring is validated server-side.
- Mansion staff limits are validated server-side.
- Mansion events are validated server-side.
- Mansion CCTV is validated server-side.
- Mansion customisation is validated server-side.
- Mansion sell-back is validated server-side.