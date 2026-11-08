# Bouncer Security Guards

`whellco_bouncer_security` provides QBCore-compatible bouncer security guards that escort disruptive players out of the strip club.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_bouncer_security
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- Escort cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Security rules

- Security job: `security`.
- Escort cooldown: 15 seconds.
- Escort duration: 10 seconds.
- Players must be near the strip club.
- Disruptive players are moved to the eject location.

## Commands

Escort a player:

```text
/escort 2 Disruptive behaviour
/escort 3 Fighting
```

View security information:

```text
/securityinfo
```

## Security

- Security eligibility is validated server-side.
- Escort cooldowns are validated server-side.
- Escort reasons are validated server-side.
- Escort actions are applied client-side after server validation.