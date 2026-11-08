# NUI Visual Distortion

`whellco_radio_distortion` adds a visual distortion overlay that scales with radio static volume.

## Startup order

```cfg
ensure qb-core
ensure whellco_dynamic_radio_static
ensure whellco_radio_distortion
```

## Distortion rules

- Distortion intensity follows static volume.
- Maximum static volume: 0.5.
- Maximum distortion intensity: 1.0.
- Distortion overlay uses scanlines and flicker.
- Distortion can be disabled with a command.

## Commands

Disable distortion:

```text
/toggledistortion
```

View distortion information:

```text
/distortioninfo
```

## Security

- Distortion is client-side only.
- Distortion intensity is clamped between 0 and 1.
- Distortion does not affect server state.