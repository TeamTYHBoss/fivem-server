# Stealth Level & XP UI

`whellco_stealth_ui` provides a QBCore-compatible UI element showing current stealth level and XP progress.

## Startup order

```cfg
ensure qb-core
ensure whellco_stealth_leveling
ensure whellco_stealth_ui
```

## UI features

- Shows current stealth level.
- Shows current XP and next-level requirement.
- Shows XP progress bar.
- Updates when stealth XP changes.
- Can be toggled with `/stealthui`.

## Commands

Refresh the stealth UI:

```text
/stealthui
```

## Security

- UI data is read-only.
- XP and level values come from QBCore player metadata.
- UI updates are client-side only.