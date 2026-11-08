# Weather

`whellco_weather` adds realistic weather and real-time clock sync. Streetlights turn on gradually as it gets darker, house windows light up at night, some windows flicker like a TV is on inside, TV windows have a subtle blue tint, and some windows have curtains or blinds.

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