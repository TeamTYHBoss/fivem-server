# Wanted Level System

`whellco_wanted_level` creates an escalating response based on crime severity.

## Wanted levels

| Level | Crime category | Police response | Air support | Military response |
|---:|---|---:|---|---|
| 1 | Minor | 2 units | No | No |
| 2 | Moderate | 4 units | No | No |
| 3 | Serious | 6 units | Yes | No |
| 4 | Severe | 8 units | Yes | 2 units |
| 5 | Critical | 12 units | Yes | 4 units |

## Crime categories

- Minor crimes create a 1-star response.
- Moderate crimes create a 2-star response.
- Serious crimes create a 3-star response.
- Severe crimes create a 4-star response.
- Critical crimes create a 5-star response.

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
- Wanted-level changes are broadcast server-side.