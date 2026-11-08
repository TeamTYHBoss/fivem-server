# Parked Vehicle Alarm System

`whellco_vehicle_alarm` provides QBCore-compatible vehicle alarms, owner alerts, police alerts, and alarm persistence.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_theft
ensure whellco_vehicle_alarm
```

## Database

Run:

```sql
source database/whellco_vehicle_alarm.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name == 'police'`.
- Alarm purchases use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Alarm types

| Alarm | Price | Duration |
|---|---:|---:|
| Basic | $2,500 | 20 seconds |
| Advanced | $5,000 | 35 seconds |
| Premium | $10,000 | 60 seconds |

## Alert rules

- Owner alert radius: 100m.
- Police alert radius: 150m.
- Alarm cooldown: 20 seconds.
- Alarms must be armed.
- Police alerts are sent only to eligible police players.

## Commands

Install an alarm:

```text
/installalarm basic
/installalarm advanced
/installalarm premium
```

Trigger an alarm:

```text
/triggeralarm
```

View alarm information:

```text
/alarminfo
```

## Security

- Alarm purchases, cooldowns, and alert radii are validated server-side.
- Alarms must be armed before triggering.
- Owner and police alerts are sent only to players within range.
- Alarm records store plate, type, and armed status.