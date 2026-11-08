# Weather

`whellco_weather` adds realistic weather and real-time clock sync. Streetlights turn on gradually as it gets darker, house windows light up at night, some windows flicker like a TV is on inside, TV windows have a subtle blue tint, some windows have curtains or blinds, silhouettes appear behind the curtains, nearby buildings, NPCs, and items spawn only, network traffic is optimized for distant players, spawned entities are pooled to reduce lag, and working swimming pools allow players and NPCs to swim with water splash particles, sound effects, dive ripples, and swimming animations.

## Weather

- Weather changes every 15 minutes.
- Weather is seasonal.
- Weather uses realistic weather types.
- Weather changes smoothly.
- Weather is synced across all players.

## Time

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

## Curtains and blinds

- Some house windows have curtains or blinds.
- Curtains and blinds are configured per house.
- Curtains and blinds use configurable models.
- Curtains and blinds use configurable positions.
- Curtains and blinds use configurable headings.
- Curtains and blinds only appear when a player is nearby.
- Curtains and blinds are removed when the player moves away.

## Silhouettes

- Silhouettes appear behind the curtains.
- Silhouettes are configured per house.
- Silhouettes use configurable models.
- Silhouettes use configurable positions.
- Silhouettes use configurable headings.
- Silhouettes only appear when a player is nearby.
- Silhouettes are removed when the player moves away.

## Nearby spawning

- Nearby buildings, NPCs, and items spawn only.
- Buildings, NPCs, and items spawn when a player is nearby.
- Buildings, NPCs, and items are removed when the player moves away.
- Buildings, NPCs, and items use configurable positions.
- Buildings, NPCs, and items use configurable models.
- Buildings, NPCs, and items use configurable headings.

## Network optimization

- Network traffic is optimized for distant players.
- Distant players receive fewer updates.
- Distant players receive less weather data.
- Distant players receive less time data.
- Distant players receive less entity data.
- Network traffic is reduced when a player is far away.
- Network traffic is reduced when a player is in a different area.

## Entity pooling

- Spawned entities are pooled to reduce lag.
- Entities are reused when possible.
- Entities are removed when a player moves away.
- Entities are pooled per house.
- Entities are pooled per type.
- Entities are pooled for curtains, silhouettes, NPCs, and items.

## Swimming pools

- Working swimming pools allow players to swim.
- Players can swim in configured pool areas.
- NPCs randomly spawn at swimming pools.
- Some NPCs swim in the pool.
- Other NPCs stand or sit near the pool.
- NPCs spawn only when a player is nearby.
- NPCs are removed when the player moves away.
- Pool NPC count is configurable.
- Pool NPC spawn chance is configurable.
- Pool NPC models and positions are configurable.

## Water splashes

- Water splash particles appear when NPCs swim.
- Water splash sound effects play when NPCs swim.
- Splashes appear when an NPC enters the pool.
- Splashes appear while an NPC is swimming.
- Splashes are limited by a cooldown.
- Splash cooldown is configurable.
- Splashes only happen when a player is nearby.
- Splashes are removed when the player moves away.

## Dive ripples

- Ripples trigger when players dive into water.
- Ripples appear when a player enters water.
- Ripples use a larger particle effect.
- Ripples use a stronger splash sound.
- Ripples have a shorter cooldown than normal splashes.
- Ripples only trigger once when entering water.
- Ripples do not repeat while a player stays in water.
- Ripples reset when the player leaves water.

## Swimming animation

- Characters use a swimming animation in water.
- Swimming NPCs use the `swimming@swim` animation dictionary.
- Swimming NPCs use the `idle` animation.
- The animation starts when an NPC enters the pool.
- The animation stops when an NPC leaves the pool.
- The animation is removed when the player moves away.
- The animation uses configurable animation settings.

## Night time

- Night time starts at 7 PM.
- Night time ends at 6 AM.
- Night time is based on the server machine clock.
- Night time is synced across all players.
- Night time enables artificial lights.
- Night time disables artificial lights during the day.

## Weather types

- CLEAR
- EXTRASUNNY
- CLOUDS
- OVERCAST
- RAIN
- CLEARING
- THUNDER
- SMOG
- FOGGY
- SNOW
- BLIZZARD
- SNOWLIGHT
- HALLOWEEN

## Seasonal weather

- Winter uses more snow and overcast weather.
- Spring uses more rain and clearing weather.
- Summer uses more clear and sunny weather.
- Autumn uses more rain and clearing weather.

## Commands

View current weather:

```text
/weatherinfo
```

## Security

- Weather is selected server-side.
- Weather is synced server-side.
- Time is synced server-side.
- Night time is synced server-side.
- Weather changes are validated server-side.