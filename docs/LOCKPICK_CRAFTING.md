# Lockpick Crafting Mechanic

`whellco_lockpick_crafting` provides QBCore-compatible lockpick crafting, material requirements, cooldowns, and crafting records.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_lockpick_crafting
```

## Database

Run:

```sql
source database/whellco_lockpick_crafting.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Material checks use `Player.Functions.GetItemByName(material)`.
- Material removal uses `Player.Functions.RemoveItem(material, amount)`.
- Crafted items use `Player.Functions.AddItem(recipeId, amount)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Recipes

| Recipe | Output | Materials |
|---|---:|---|
| Lockpick | 1 | 2 scrap metal, 1 steel |
| Advanced Lockpick | 1 | 4 scrap metal, 2 steel, 1 electronics |

## Commands

Craft a lockpick:

```text
/craftlockpick lockpick
/craftlockpick advanced_lockpick
```

View crafting information:

```text
/craftinfo
```

## Security

- Crafting location, cooldowns, and material requirements are validated server-side.
- Materials are removed only after validation.
- Crafted items are added only after completion.
- Crafting records store citizen ID, recipe, and timestamp.