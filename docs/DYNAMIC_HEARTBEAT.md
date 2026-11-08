# Dynamic Heartbeat Audio

`whellco_dynamic_heartbeat` makes the heartbeat sound beat faster as player health decreases.

## Startup order

```cfg
ensure qb-core
ensure whellco_low_health_audio
ensure whellco_dynamic_heartbeat
```

## Heartbeat rules

- Maximum health: 200.
- Low health threshold: 30.
- Slow beat interval: 1200ms.
- Fast beat interval: 350ms.
- Heartbeat sound: `Heartbeat`.
- Heartbeat volume: 0.6.
- Heartbeat speeds up as health decreases.

## Commands

View heartbeat information:

```text
/dynamicheartbeatinfo
```

## Security

- Heartbeat audio is client-side only.
- Health checks are client-side only.
- Beat interval is clamped between fast and slow limits.