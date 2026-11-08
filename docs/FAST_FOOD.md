# Fast Food Restaurants

`whellco_fast_food` adds fast food restaurants where players can purchase food and drinks. Cashiers hand over food bags, and players physically hold the food bag after purchase.

## Player food bag

- After buying food, the player physically holds a food bag.
- The food bag uses `prop_food_bag_01`.
- The bag is attached to the player’s right hand.
- The player holds the bag for 10 seconds.
- The bag is removed automatically after 10 seconds.
- The player’s animation changes while holding the bag.

## Cashier handover

- Each restaurant has a cashier NPC.
- The cashier uses the `WORLD_HUMAN_CLIPBOARD` scenario.
- When a player buys food, the cashier turns toward the player.
- The cashier triggers the player food-bag handover.
- The cashier returns to the clipboard scenario.

## Restaurant customers

- Each restaurant spawns up to 3 seated NPC customers.
- One cashier NPC stands at the counter.
- Seated customers use the `WORLD_HUMAN_SEAT_WALL_EATING` scenario.
- Customers spawn when a player comes within 30 metres.
- Customers are removed when the player moves more than 30 metres away.
- Customers order a random available menu item every 15 seconds.

## Restaurant names

- Burger Barn
- Cluckin Good
- Taco Bout It
- Pita Pan
- Noodle Ood
- Pizza Over It
- Sub-lime
- Fry-Days
- Wrap Star
- Donut Worry

## Restaurant locations

| Restaurant | Location |
|---|---|
| Burger Barn | Near Grove Street |
| Cluckin Good | Near Little Seoul |
| Taco Bout It | Near Strawberry |
| Pita Pan | Near Vespucci Beach |
| Noodle Ood | Near Del Perro |
| Pizza Over It | Near La Mesa |
| Sub-lime | Near Strawberry |
| Fry-Days | Near Grove Street |
| Wrap Star | Near Little Seoul |
| Donut Worry | Near Strawberry |

## Menu items

| Item | Price | Hunger restored | Available at |
|---|---:|---:|---|
| Burger | $25 | 25 | Burger Barn, Fry-Days |
| Fries | $10 | 10 | Burger Barn, Fry-Days |
| Fried Chicken | $30 | 30 | Cluckin Good |
| Taco | $20 | 20 | Taco Bout It |
| Pita Wrap | $22 | 22 | Pita Pan, Wrap Star |
| Noodles | $28 | 28 | Noodle Ood |
| Pizza Slice | $18 | 18 | Pizza Over It |
| Sub Sandwich | $26 | 26 | Sub-lime |
| Donut | $8 | 8 | Donut Worry |
| Soda | $5 | 5 | All restaurants |

## Purchase rules

- Players can buy food with cash.
- Items are added to the player inventory.
- Purchases are logged in `whellco_fast_food_purchases`.
- Items are only available at participating restaurants.
- Food restores hunger when consumed.
- Cashiers hand over food bags after purchase.
- Players physically hold the food bag after purchase.

## Commands

View fast food information:

```text
/foodinfo
```

View fast food help:

```text
/foodhelp
```

## Security

- Restaurant and item availability are validated server-side.
- Purchases are validated server-side.
- Purchase prices are validated server-side.
- Purchases are logged server-side.
- Food items are added server-side.
- Cashier handovers are triggered server-side.