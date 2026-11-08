# Player Inventory & Storage

`whellco_inventory` provides QBCore-compatible player inventories and persistent storage for vehicles, houses, stashes, and ground drops.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_inventory
```

## Database

Run:

```sql
source database/whellco_inventory.sql
```

The storage table uses a unique key on `storage_type` and `identifier`, preventing duplicate storage records.

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Player inventory uses QBCore’s built-in `Player.Functions.AddItem`, `RemoveItem`, and `GetItemByName` functions.
- Vehicle ownership checks use `exports['whellco_qbcore']:ownsVehicle()`.
- House ownership checks use `exports['whellco_housing']:ownsProperty()`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Storage types

| Type | Ownership required | Default slots | Default weight |
|---|---|---:|---:|
| Trunk | Yes | 50 | 100,000 |
| Glovebox | Yes | 15 | 25,000 |
| House | Yes | 100 | 250,000 |
| Stash | No | 50 | 100,000 |
| Ground drop | No | 20 | 50,000 |

## Commands

Open a storage container:

```text
/storage trunk VEHICLE_PLATE
/storage glovebox VEHICLE_PLATE
/storage house PROPERTY_ID
/storage stash STASH_ID
```

Open the player inventory:

```text
/openinventory
```

## Security

- Ownership is validated server-side before opening trunks, gloveboxes, or houses.
- Item amounts are validated and rounded down to whole numbers.
- Stack limits prevent oversized item stacks.
- Storage contents are serialised as JSON and saved to MySQL.
- Only configured item types can be moved into storage.

## Extending

Add a new storage type:

```lua
Config.StorageTypes['safe'] = {
    label = 'Safe',
    slots = 25,
    weight = 50000,
    requiresOwnership = true
}
```

Add a new item:

```lua
Config.AllowedItems['medkit'] = {
    label = 'Medkit',
    weight = 1000,
    stackable = true
}
```