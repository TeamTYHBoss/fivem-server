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

## Security

- Chickens are client-side only.
- Chickens do not affect server economy.
- Chickens do not affect player inventory.
- Chickens are removed when the resource stops.