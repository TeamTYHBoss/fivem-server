# Critical Health Audio Muffling

`whellco_critical_audio` muffles other game audio when player health is critical.

## Startup order

```cfg
ensure qb-core
ensure whellco_dynamic_heartbeat
ensure whellco_critical_audio
```

## Audio rules

- Critical health threshold: 20 health.
- Muffled volume: 0.25.
- Normal volume: 1.0.
- Check interval: 250ms.
- Fade duration: 1000ms.
- Audio muffling stops when health recovers.

## Commands

View audio information:

```text
/criticalaudioinfo
```

## Security

- Audio muffling is client-side only.
- Health checks are client-side only.
- Audio muffling stops automatically when health recovers.