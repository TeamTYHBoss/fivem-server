# Jail & Prison System

`whellco_jail` provides QBCore-compatible jail and prison management, sentences, jobs, release handling, and facility teleports.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_jail
```

## Database

Run:

```sql
source database/whellco_jail.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police permission uses `Player.PlayerData.job.name`.
- Sentences use `Player.PlayerData.citizenid`.
- Job rewards use `Player.Functions.AddMoney('cash', amount, reason)`.
- XP uses `Player.Functions.SetMetaData('whellco_xp', value)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Commands

Jail a player:

```text
/jail [source] [minutes] [reason]
/jail 12 10 Disturbing the peace
```

Send a player to prison:

```text
/prison [source] [minutes] [reason]
/prison 12 30 Robbery
```

Release a player:

```text
/release 12
```

Complete an incarceration job:

```text
/jailjob 1
/jailjob 2
/jailjob 3
```

## Facilities

| Facility | Jobs | Rewards |
|---|---|---|
| Jail | Clean cells, sort mail, laundry duty | $40-$50 and 2 XP |
| Prison | Yard patrol, kitchen duty, workshop duty | $55-$70 and 3-4 XP |

## Security

- Only QBCore police jobs can jail, imprison, or release players.
- Sentences are limited between 1 and 120 minutes.
- Active sentences are tracked in MySQL.
- A player cannot receive a second active sentence.
- Job rewards are validated server-side.
- Release locations are determined by the active facility.