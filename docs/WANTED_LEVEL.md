# Wanted Level System

`whellco_wanted_level` creates an escalating response based on crime severity, with search cones and last known position tracking.

## Wanted levels

| Level | Crime category | Police response | Air support | Military response |
|---:|---|---:|---|---|
| 1 | Minor | 2 units | No | No |
| 2 | Moderate | 4 units | No | No |
| 3 | Serious | 6 units | Yes | No |
| 4 | Severe | 8 units | Yes | 2 units |
| 5 | Critical | 12 units | Yes | 4 units |

## Search cones

- Police create a search area around the suspect’s last known position.
- Search cone radius is 150 metres.
- Search cones last 120 seconds.
- Search cones appear as map blips labelled `Last Known Position`.
- Search cones update as the suspect moves.
- Search cones clear when wanted level reaches 0.

## Last known position tracking

- The server records the suspect’s position when a wanted level is set.
- The server updates the last known position every 5 seconds.
- Police receive updated search areas.
- Search areas expire automatically.
- Search areas clear when the wanted level clears.

## Response escalation

- Higher wanted levels send more police units.
- Level 3 enables air support.
- Level 4 adds military units.
- Level 5 sends maximum police and military response.
- Higher levels use aggressive pursuit behaviour.

## Wanted decay

- Wanted level decays by 1 star every 30 seconds.
- Reaching 0 clears the wanted status.
- Decay interval and decay amount are configurable.

## Commands

View wanted-level information:

```text
/wantedinfo
```

View wanted-level help:

```text
/wantedhelp
```

## Security

- Wanted levels are validated server-side.
- Wanted levels cannot exceed 5.
- Wanted levels cannot be manually lowered by clients.
- Police and military alerts are validated server-side.
- Last known positions are tracked server-side.
- Search areas are broadcast server-side.