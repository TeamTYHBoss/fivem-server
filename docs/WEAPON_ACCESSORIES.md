# Dynamic Weapon Accessories

`whellco_weapon_accessories` provides QBCore-compatible weapon attachments, persistent accessory storage, compatibility checks, and installation costs.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_weapon_accessories
```

## Database

Run:

```sql
source database/whellco_weapon_accessories.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Accessory records use `Player.PlayerData.citizenid`.
- Installation and removal costs use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Accessories

| Accessory | Effects |
|---|---|
| Suppressor | +5 accuracy, -5 recoil |
| Flashlight | +2 accuracy |
| Extended clip | +12 magazine capacity |
| Grip | -8 recoil, +3 accuracy |
| Scope | +10 accuracy, +15 range |

## Commands

List accessories:

```text
/weaponaccessories
```

Install an accessory:

```text
/installaccessory WEAPON_PISTOL suppressor
/installaccessory WEAPON_CARBINERIFLE scope
```

Remove an accessory:

```text
/removeaccessory WEAPON_PISTOL suppressor
/removeaccessory WEAPON_CARBINERIFLE scope
```

## Security

- Accessory compatibility is validated server-side.
- Accessory records are tied to QBCore citizen IDs.
- Installation and removal costs are charged through QBCore bank balance.
- Accessory limits prevent excessive attachments.
- Accessory data is stored in MySQL and persists between sessions.