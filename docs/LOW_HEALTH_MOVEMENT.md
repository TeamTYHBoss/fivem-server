# Low Health Movement

`whellco_low_health_movement` makes player movement slower as health decreases.

## Startup order

```cfg
ensure qb-core
ensure whellco_critical_audio
ensure whellco_low_health_movement
```

## Movement rules

- Low health threshold: 30 health.
- Critical health threshold: 15 health.
- Normal movement rate: 1.0.
- Injured movement rate: 0.7.
- Critical movement rate: 0.45.
- Check interval: 250ms.

## Commands

View movement information:

```text
/movementinfo
```

## Security

- Movement scaling is client-side only.
- Health checks are client-side only.
- Movement rate returns to normal when health recovers.