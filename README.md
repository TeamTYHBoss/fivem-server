# FiveM Server

This repository contains the FiveM server resources and documentation.

## Fast Food Restaurants

`whellco_fast_food` adds fast food restaurants where players can purchase food and drinks. The system includes counter ordering, cashier food-bag handovers, player-held food bags, and eating food directly from the bag.

## What was added

- Fast food restaurant locations.
- A fast food menu with food and drink items.
- Cash purchases for menu items.
- Inventory items added after purchase.
- Purchase logging in `whellco_fast_food_purchases`.
- Restaurant-specific menu availability.
- Hunger restoration when food is consumed.
- Cashier NPCs at restaurant counters.
- NPC customers that order food at the counter.
- NPC customers that sit and eat inside restaurants.
- Cashier food-bag handover animation.
- Player-held food bag after purchase.
- Ability to eat food directly from the held bag.

## Restaurant customers

- Each restaurant has one cashier NPC.
- Each restaurant has up to 3 seated NPC customers.
- The cashier uses the `WORLD_HUMAN_CLIPBOARD` scenario.
- Seated customers use the `WORLD_HUMAN_SEAT_WALL_EATING` scenario.
- Customers spawn when a player comes within 30 metres.
- Customers are removed when the player moves more than 30 metres away.
- Counter customers order a random available menu item every 15 seconds.
- Customers are non-hostile and cannot be knocked over by player impacts.

## Cashier handover

- Each restaurant has a cashier NPC.
- The cashier normally uses the `WORLD_HUMAN_CLIPBOARD` scenario.
- When a player buys food, the cashier turns toward the player.
- The cashier triggers the player food-bag handover.
- The cashier returns to the clipboard scenario.

## Player food bag

- After buying food, the player physically holds a food bag.
- The food bag uses `prop_food_bag_01`.
- The bag is attached to the player’s right hand.
- The player holds the bag for 10 seconds.
- The player can eat the food from the bag by pressing **G**.
- Eating removes the food item from the player inventory.
- Eating restores hunger.
- The food bag is removed after eating.
- The food bag is removed automatically after 10 seconds if the player does not eat.

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

## Fast food controls

| Control | Action |
|---|---|
| E | View restaurant menu |
| G | Eat food from held bag |

## Fast food commands

View fast food information:

```text
/foodinfo
```

View fast food help:

```text
/foodhelp
```

## IPTV

`whellco_iptv` adds working TVs that players can use to watch channels and flick through them.

## IPTV features

- Working TV screens.
- Channel switching.
- Channel names.
- Stream playback.
- TV interaction prompt.
- TV close prompt.
- TV remote requirement.
- Channel selection UI.
- Last watched channel saving.

## TV remote

- Players need a `tv_remote` item to use the TV.
- The remote is a usable item.
- Using the remote enables TV interaction.
- Without the remote, players cannot open the TV.
- The server validates remote ownership.

## Channel selection UI

- The TV screen includes a channel list.
- Players can click a channel to select it.
- The selected channel is highlighted.
- The selected channel starts playing.
- The channel name is shown above the list.
- Players can still use arrow keys to change channels.

## Last watched channel

- The last watched channel is saved for each TV.
- The channel is saved per player and per TV.
- When a player reopens a TV, it returns to the last watched channel.
- The channel is saved when the TV is closed.
- The channel is saved in `whellco_iptv_last_channel`.

## IPTV controls

| Control | Action |
|---|---|
| E | Watch TV |
| Right arrow | Next channel |
| Left arrow | Previous channel |
| Esc | Close TV |
| Click | Select channel |

## TV locations

| TV | Location |
|---|---|
| Apartment TV | Apartment interior |
| House TV | House interior |

## Weather

`whellco_weather` adds realistic weather, real-time clock sync, streetlights, house window lights, TV-style window flicker, curtains, silhouettes, nearby-only spawning, and entity pooling.

## Weather features

- Realistic weather changes.
- Seasonal weather.
- Smooth weather transitions.
- Weather synced across all players.
- Real-time clock sync.
- Timezone-based time.
- Time synced across all players.
- Streetlights that turn on gradually.
- House windows that light up at night.
- TV-style flickering windows.
- Subtle blue tint on TV windows.
- Curtains and blinds on some windows.
- Silhouettes behind curtains.
- Nearby-only spawning for buildings, NPCs, and items.
- Entity pooling to reduce lag.
- Network traffic optimization for distant players.

## Weather time

- Time is synced to the server machine clock.
- Time updates every minute.
- Time uses the configured timezone.
- Time is synced across all players.

## Streetlights

- Streetlights begin turning on at 6 PM.
- Streetlights reach full brightness at 7 PM.
- Streetlights begin turning off at 6 AM.
- Streetlights turn off fully at 7 AM.
- Streetlight brightness changes gradually.
- Streetlight brightness is based on the server machine clock.

## House windows

- House windows light up at night.
- Windows light up after 6 PM.
- Windows turn off after 6 AM.
- Window lights are based on the server machine clock.
- Window lights only appear when a player is nearby.
- Window lights are removed when the player moves away.

## TV flicker

- Some house windows flicker like a TV is on inside.
- The first two windows in each house flicker.
- Flicker changes every 100 milliseconds.
- Flicker uses random brightness.
- Flicker only happens at night.
- Flicker stops during the day.
- TV windows use a subtle blue tint.
- The blue tint uses configurable RGB values.

## Curtains and silhouettes

- Some house windows have curtains or blinds.
- Silhouettes appear behind the curtains.
- Curtains, blinds, and silhouettes use configurable models.
- Curtains, blinds, and silhouettes use configurable positions.
- Curtains, blinds, and silhouettes use configurable headings.
- Curtains, blinds, and silhouettes only appear when a player is nearby.
- Curtains, blinds, and silhouettes are removed when the player moves away.

## Performance

- Nearby buildings, NPCs, and items spawn only.
- Entities are pooled and reused when possible.
- Entities are removed when a player moves away.
- Network traffic is reduced for distant players.
- Distant players receive fewer updates.
- Distant players receive less weather, time, and entity data.

## Weather commands

View current weather:

```text
/weatherinfo
```

## Security

- Restaurant and item availability are validated server-side.
- Purchases are validated server-side.
- Purchase prices are validated server-side.
- Purchases are logged server-side.
- Food items are added server-side.
- Food items are removed server-side when eaten.
- Cashier handovers are triggered server-side.
- TV channel sources are handled server-side.
- TV remote ownership is validated server-side.
- Last watched channel is saved server-side.
- Weather is selected server-side.
- Weather is synced server-side.
- Time is synced server-side.
- Night time is synced server-side.
- Weather changes are validated server-side.

## Recent changes

- Added NPC counter ordering.
- Added cashier food-bag handover.
- Added player-held food bag.
- Added eating food directly from the bag.
- Added working TVs with channel switching.
- Added TV remote control item.
- Added channel selection UI to the TV screen.
- Added last watched channel saving for each TV.
- Added realistic weather and real-time clock sync.
- Added streetlights that turn on gradually.
- Added house window lights at night.
- Added TV-style flickering windows with a subtle blue tint.
- Added curtains, blinds, and silhouettes behind curtains.
- Added nearby-only spawning and entity pooling.
- Added network traffic optimization for distant players.
- Updated documentation to cover all fast food, IPTV, and weather features.