# Patron Blacklist System

`whellco_patron_blacklist` provides QBCore-compatible blacklisting for banned patrons at the strip club.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_patron_blacklist
```

## Database

Run:

```sql
source database/whellco_patron_blacklist.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Security eligibility uses `Player.PlayerData.job.name == 'security'`.
- Blacklist status uses `whellco_patron_blacklist.active`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Blacklist rules

- Blacklist cooldown: 10 seconds.
- Security job: `security`.
- Blacklisted patrons are ejected from the club.
- Blacklist entries can be removed by security.

## Commands

Blacklist a patron:

```text
/blacklist 2 Disruptive behaviour
/blacklist 3 Fake ID
```

Remove a patron from blacklist:

```text
/unblacklist 2
/unblacklist 3
```

View blacklist information:

```text
/blacklistinfo
```

## Security

- Security eligibility is validated server-side.
- Blacklist cooldowns are validated server-side.
- Blacklist status is stored in MySQL.
- Blacklisted patrons are ejected client-side after server validation.