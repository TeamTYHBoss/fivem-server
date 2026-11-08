# Vehicle Lockpicking Minigame

`whellco_lockpick_minigame` provides a vehicle lockpicking minigame with pins, attempts, timers, and integration into the vehicle theft system.

## Startup order

```cfg
ensure qb-core
ensure whellco_vehicle_theft
ensure whellco_lockpick_minigame
```

## Minigame rules

- Duration: 20 seconds.
- Pins: 5.
- Maximum attempts: 3.
- Players must match all pins before the timer expires.
- Successful lockpicking triggers the vehicle theft alert system.

## Commands

Start the minigame:

```text
/lockpickvehicle
```

View minigame information:

```text
/lockpickinfo
```

## Security

- Minigame state is client-side only.
- Successful completion triggers a server-side theft event.
- The server validates the theft event and records the stolen vehicle.