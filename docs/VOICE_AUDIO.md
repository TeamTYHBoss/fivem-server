# Real-time Voice & Audio Enhancements

`whellco_voice_audio` provides QBCore-compatible directional VoIP integration, job radio channels, megaphone effects, and noise suppression settings.

## Startup order

```cfg
ensure qb-core
ensure pma-voice
ensure whellco_voice_audio
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Job radio channels use `Player.PlayerData.job.name`.
- Radio channels are mapped by job.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `pma-voice` as dependencies.

## Radio channels

| Job | Channel |
|---|---:|
| Police | 1 |
| EMS | 2 |
| Mechanic | 3 |
| Tow | 4 |
| Gang | 5 |

## Voice ranges

| Range | Distance |
|---|---:|
| Whisper | 3m |
| Normal | 12m |
| Shout | 25m |

## Commands

Join job radio:

```text
/joinradio
```

Leave radio:

```text
/leaveradio
```

Use megaphone:

```text
/megaphone
```

View voice information:

```text
/voiceinfo
```

## Security

- Radio channel assignment is validated server-side.
- Megaphone cooldowns prevent spam.
- Megaphone effects are range-based.
- Noise suppression settings are configurable.