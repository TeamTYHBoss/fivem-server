# Disguised Entry for Restricted Areas

`whellco_disguise_entry` lets players use disguise kits to enter restricted areas with a chance of detection and guard challenges.

## Guard challenges

- Guards can challenge disguised players.
- Guard challenge chance is 35% per detection check.
- Guard challenge cooldown is 20 seconds.
- The guard prompt says: `Guard: "State your business." Press [E] to convince them.`
- Players have 5 seconds to respond.
- Pressing E convinces the guard.
- Failing to respond removes the disguise and marks the entry as detected.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_disguise_entry
```

## Database

Run:

```sql
source database/whellco_disguise_entries.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Disguise kits use `Player.Functions.GetItemByName`.
- Item removal uses `Player.Functions.RemoveItem`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Disguise rules

- Required item: `disguise_kit`.
- Entry duration: 120 seconds.
- Cooldown: 300 seconds.
- Detection chance: 25% per detection check.
- Detection interval: 10 seconds.
- Maximum active disguises: 1.
- Leaving the area triggers detection.
- Expiring disguise triggers detection.

## Restricted areas

| Area | Required disguise | Radius |
|---|---|---:|
| Mission Row Police Station | Police | 50 metres |
| Pillbox Medical Centre | Medical | 50 metres |

## Detection

- Detection checks run every 10 seconds.
- Detection chance is 25% per check.
- Detection removes the disguise.
- Detection logs the entry as detected.
- Nearby police receive an alert.

## Commands

View disguise information:

```text
/disguiseinfo
```

View disguise help:

```text
/disguisehelp
```

## Security

- Disguise eligibility is validated server-side.
- Disguise cooldowns are validated server-side.
- Guard challenge cooldowns are validated server-side.
- Guard responses are validated server-side.
- Disguise items are validated server-side.
- Restricted-area access is validated server-side.
- Disguise entries are logged server-side.