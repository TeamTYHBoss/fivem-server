# QBCore Migration Standard

This server uses **QBCore** as its player, character, job, inventory and money framework.

## Required startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
```

All WhellCo resources must load after `qb-core`, `oxmysql`, and `whellco_qbcore`.

## QBCore integration rules

1. Obtain the framework with:

```lua
local QBCore = exports['qb-core']:GetCoreObject()
```

2. Obtain the player with:

```lua
local Player = QBCore.Functions.GetPlayer(source)
```

3. Use `Player.PlayerData.citizenid` for player-specific records.

4. Use `Player.PlayerData.identifier` only when compatibility with the legacy WhellCo character table is required.

5. Use QBCore money functions:

```lua
Player.Functions.GetMoney('cash')
Player.Functions.AddMoney('cash', amount, reason)
Player.Functions.RemoveMoney('cash', amount, reason)
Player.Functions.AddMoney('bank', amount, reason)
Player.Functions.RemoveMoney('bank', amount, reason)
```

6. Use QBCore notifications:

```lua
TriggerClientEvent('QBCore:Notify', source, message, type)
```

7. Store XP, level and other character metadata through:

```lua
Player.Functions.SetMetaData('whellco_xp', value)
Player.Functions.SetMetaData('whellco_level', value)
```

8. Never write cash or bank directly to `whellco_players`; QBCore owns those balances.

## Migration status

- `whellco_qbcore`: migrated.
- `whellco_economy`: migrated.
- `whellco_casino`: migrated.
- `whellco_characters`: migrated.
- `whellco_spawn_selector`: migrated.
- `whellco_wardrobe`: migrated.
- `whellco_housing`: migrated.
- `whellco_banking`: migrated.
- `whellco_vehicles`: migration SQL added; server logic migration pending.
- Remaining vehicle and auction systems: batch migration pending.

## Compatibility bridge

`whellco_qbcore` exposes:

- `getQbPlayer(source)`
- `getCitizenId(source)`
- `getIdentifier(source)`
- `getMoney(source, account)`
- `addMoney(source, amount, reason, account)`
- `removeMoney(source, amount, reason, account)`
- `notify(source, message, type)`

New and migrated resources should use these exports or call QBCore directly.

## Batch 2 migration

Run `resources/whellco_banking/sql/qbcore_migration.sql` and `resources/whellco_vehicles/sql/qbcore_migration.sql` once.

- Bank accounts now use QBCore citizen IDs.
- Deposits remove QBCore cash; withdrawals add QBCore cash.
- Bank transfers validate both QBCore players and update citizen-keyed accounts.
- Vehicle ownership migration converts `whellco_vehicles.owner_identifier` from license identifiers to QBCore citizen IDs.