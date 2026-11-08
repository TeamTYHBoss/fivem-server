# Stealth XP Audio Cue

`whellco_stealth_audio` provides an audio cue when gaining stealth XP or leveling up the stealth perk.

## Startup order

```cfg
ensure qb-core
ensure whellco_stealth_leveling
ensure whellco_stealth_audio
```

## Audio cues

| Event | Sound |
|---|---|
| Stealth XP gained | `CHECKPOINT_PERFECT` |
| Stealth level increased | `RANK_UP` |

## Commands

Test the XP audio cue:

```text
/teststealthaudio
```

## Security

- Audio cues are client-side only.
- XP and level events are triggered by the stealth leveling system.
- Audio volume is configurable.