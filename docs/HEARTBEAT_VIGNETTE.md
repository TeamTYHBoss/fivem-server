# Heartbeat Vignette

`whellco_heartbeat_vignette` adds a fading red vignette effect that pulses with the heartbeat at low health.

## Startup order

```cfg
ensure qb-core
ensure whellco_dynamic_heartbeat
ensure whellco_heartbeat_vignette
```

## Vignette rules

- Low health threshold: 30.
- Pulse interval: 900ms.
- Vignette fades in and out with each heartbeat.
- Vignette hides when health recovers.

## Commands

View vignette information:

```text
/vignetteinfo
```

## Security

- Vignette is client-side only.
- Health checks are client-side only.
- Vignette does not affect server state.