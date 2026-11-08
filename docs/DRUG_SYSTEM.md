# Drug Dealing & Crafting

`whellco_drug_system` provides QBCore-compatible crafting, selling, cooldowns, location checks, and configurable drug economy.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_drug_system
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Crafting and selling use QBCore inventory functions.
- Sale rewards use `Player.Functions.AddMoney('cash', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` as a dependency.

## Crafting recipes

| Recipe | Ingredients | Output |
|---|---|---|
| Packaged Cannabis | 3 cannabis buds, 2 plastic bags | 2 packaged cannabis |
| Packaged Cocaine | 3 cocaine, 2 plastic bags | 2 packaged cocaine |
| Packaged Methamphetamine | 3 meth, 2 plastic bags | 2 packaged methamphetamine |

## Commands

List crafting recipes:

```text
/drugrecipes
```

Craft an item:

```text
/drugcraft packaged_weed 2
/drugcraft packaged_cocaine 1
```

List sellable items:

```text
/drugsellitems
```

Sell an item:

```text
/drugsell packaged_weed 5
/drugsell packaged_cocaine 3
```

## Limits

- Maximum craft amount: 10.
- Maximum sale amount: 10.
- Crafting cooldown: 15 seconds.
- Sale cooldown: 10 seconds.
- Players must be near a configured crafting or sell location.

## Security

- Recipes, ingredients, amounts, and locations are validated server-side.
- Sale prices are randomized within configured ranges.
- Crafting and selling use per-player cooldowns.
- Sale rewards use QBCore cash.
- Players cannot sell more items than they possess.