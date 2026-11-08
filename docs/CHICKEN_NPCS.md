# Chicken NPCs

`whellco_chicken_npcs` adds wandering chicken NPCs for restaurant kitchens.

## Chicken behaviour

- Chickens spawn near their configured kitchen location.
- Chickens wander around the kitchen.
- Chickens choose a random nearby destination.
- Chickens walk to the destination.
- Chickens choose a new destination after a short delay.
- Chickens are harmless and invincible.
- Chickens cannot be knocked over by player impacts.

## Panic behaviour

- Chickens panic when a player gets within 3 metres.
- Panicking chickens run away from the player.
- Chickens run at increased speed.
- Chickens make panic sound effects while running.
- Chickens repeat the sound every 1.5 seconds while panicking.
- Chickens drop feathers while running.
- Feathers drop every 0.4 seconds while panicking.
- Chickens leave footprints on the kitchen floor while running.
- Footprints appear every 0.6 seconds while panicking.
- Footprints fade out gradually over time.
- Footprints last for 10 seconds.
- Footprints fade over the final 3 seconds.
- Chickens kick up flour when on the counter.
- Flour effects repeat every 0.7 seconds while on the counter.
- Flour particles fade out gradually over time.
- Flour effects last for 8 seconds.
- Flour effects fade over the final 2.5 seconds.
- Chickens leave wet footprints near the sink.
- Wet footprints appear every 0.7 seconds near the sink.
- Wet footprints fade out gradually over time.
- Wet footprints last for 12 seconds.
- Wet footprints fade over the final 4 seconds.
- Chickens shake dry after getting wet.
- Chickens shake after calming down.
- Chickens shake every 3 seconds while wet.
- Chickens calm down when the player is more than 6 metres away.
- Calm chickens return to normal wandering.

## Spawn rules

- Chickens spawn when a player comes within 30 metres.
- Chickens are removed when the player moves more than 40 metres away.
- Chickens respawn when a player returns.

## Configuration

| Setting | Description |
|---|---|
| `model` | Chicken ped model |
| `coords` | Kitchen spawn location |
| `heading` | Initial facing direction |
| `wanderRadius` | Maximum wandering distance |
| `wanderInterval` | Time between new destinations |
| `panicDistance` | Distance that triggers panic |
| `panicSpeed` | Running speed while panicking |
| `calmDistance` | Distance required to calm down |
| `squawkInterval` | Time between panic sounds |
| `featherInterval` | Time between feather effects |
| `footprintInterval` | Time between footprint effects |
| `flourInterval` | Time between flour effects |
| `wetFootprintInterval` | Time between wet footprint effects |
| `shakeInterval` | Time between shake effects |
| `counters` | Counter locations that trigger flour |
| `sinks` | Sink locations that trigger wet footprints |
| `FootprintLifetime` | Total footprint lifetime |
| `FootprintFadeTime` | Time spent fading out |
| `FlourLifetime` | Total flour effect lifetime |
| `FlourFadeTime` | Time spent fading out |
| `WetFootprintLifetime` | Total wet footprint lifetime |
| `WetFootprintFadeTime` | Time spent fading out |

## Security

- Chickens are client-side only.
- Chickens do not affect server economy.
- Chickens do not affect player inventory.
- Chickens are removed when the resource stops.
- Footprints are removed when the resource stops.
- Flour effects are removed when the resource stops.
- Wet footprints are removed when the resource stops.