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

## Security

- Chickens are client-side only.
- Chickens do not affect server economy.
- Chickens do not affect player inventory.
- Chickens are removed when the resource stops.