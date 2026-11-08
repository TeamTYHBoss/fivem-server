# Low Health Heartbeat Audio

`whellco_low_health_audio` plays a heartbeat audio cue when player health is low.

## Startup order

```cfg
ensure qb-core
ensure whellco_low_health_audio
```

## Audio rules

- Low health threshold: 30 health.
- Heartbeat interval: 900ms.
- Heartbeat sound: `Heartbeat`.
- Heartbeat volume: 0.6.
- Heartbeat stops when health recovers above the threshold.

## Commands

View heartbeat information:

```text
/heartbeatinfo
```

## Security

- Heartbeat audio is client-side only.
- Health checks are client-side only.
- Heartbeat stops automatically when health recovers.