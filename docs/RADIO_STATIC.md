# Custom Radio Static Effects

`whellco_radio_static` adds custom radio static sound effects when toggling radio channels.

## Startup order

```cfg
ensure qb-core
ensure pma-voice
ensure whellco_voice_audio
ensure whellco_radio_static
```

## Radio rules

- Toggle key: Y.
- Static sound: `Radio_On`.
- Static volume: 0.4.
- Toggle cooldown: 1 second.
- Radio channels are mapped by job.

## Commands

Toggle radio:

```text
/radiostatic
```

View radio information:

```text
/radiostaticinfo
```

## Security

- Radio toggle is client-side only.
- Radio channel assignment is handled by the voice system.
- Static effects are cosmetic and do not affect server state.