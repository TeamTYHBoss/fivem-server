# Dynamic Radio Static

`whellco_dynamic_radio_static` adds distance-based radio static effects that increase as players move away from others.

## Startup order

```cfg
ensure qb-core
ensure pma-voice
ensure whellco_voice_audio
ensure whellco_dynamic_radio_static
```

## Static rules

- Update interval: 1 second.
- Static starts at 10m distance.
- Static reaches maximum at 50m distance.
- Maximum static volume: 0.5.
- Minimum static volume: 0.0.
- Radio channels are mapped by job.

## Commands

Toggle dynamic static:

```text
/dynamicstatic
```

View static information:

```text
/dynamicstaticinfo
```

## Security

- Static calculation is client-side only.
- Radio channel assignment is handled by the voice system.
- Static volume is clamped between minimum and maximum values.