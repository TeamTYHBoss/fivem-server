# Damage-Based Distortion

`whellco_damage_distortion` makes the radio distortion effect worse when the player takes damage.

## Startup order

```cfg
ensure qb-core
ensure whellco_radio_distortion
ensure whellco_damage_distortion
```

## Damage rules

- Damage threshold: 5 health.
- Damage boost: 0.35 per 100 damage.
- Maximum distortion: 1.0.
- Decay rate: 0.15 per second.
- Update interval: 250ms.

## Commands

View damage distortion information:

```text
/damageinfo
```

## Security

- Damage detection is client-side only.
- Distortion intensity is clamped between 0 and 1.
- Distortion decays over time.
- Distortion does not affect server state.