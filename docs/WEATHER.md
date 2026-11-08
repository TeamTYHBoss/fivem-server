# Weather

`whellco_weather` adds realistic weather and real-time clock sync. When the computer time shows that the sun has gone down, the game mechanics make night time in game.

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