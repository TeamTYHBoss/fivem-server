# Disguised Entry for Restricted Areas

`whellco_disguise_entry` lets players use disguise kits to enter restricted areas with a suspicion meter, guard challenges, crowd blending, and detection risk.

## Suspicion meter

- Suspicion rises by 2 points per second while disguised.
- Suspicion maximum is 100.
- Reaching 100 suspicion triggers detection.
- The meter changes colour as suspicion rises.
- Blue indicates low suspicion.
- Orange indicates medium suspicion.
- Red indicates high suspicion.
- Passing a guard challenge reduces suspicion by 25 points.

## Crowd blending

- Players can blend into crowds to pause suspicion growth.
- Crowd blending requires at least 3 nearby NPC peds.
- Crowd blend radius is 8 metres.
- Fast movement breaks the crowd blend state.
- Crowd blend maximum speed is 2.0.
- While blending, suspicion does not increase.
- Leaving the crowd or moving too fast resumes suspicion growth.
- The crowd requirements and speed limit are configurable.

## Guard challenges

- Guards can challenge disguised players.
- Guard challenge chance is 35% per detection check.
- Guard challenge cooldown is 20 seconds.
- The guard prompt says: `Guard: "State your business." Press [E] to convince them.`
- Players have 5 seconds to respond.
- Pressing E convinces the guard and reduces suspicion.
- Failing to respond removes the disguise and marks the entry as detected.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_disguise_entry
```

## Database

Run:

```sql
source database/whellco_disguise_entries.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Disguise kits use `Player.Functions.GetItemByName`.
- Item removal uses `Player.Functions.RemoveItem`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Disguise rules

- Required item: `disguise_kit`.
- Entry duration: 120 seconds.
- Cooldown: 300 seconds.
- Suspicion rises by 2 points per second.
- Suspicion maximum is 100.
- Maximum active disguises: 1.
- Leaving the area triggers detection.
- Expiring disguise triggers detection.

## Restricted areas

| Area | Required disguise | Radius |
|---|---|---:|
| Mission Row Police Station | Police | 50 metres |
| Pillbox Medical Centre | Medical | 50 metres |

## Detection

- Reaching 100 suspicion triggers detection.
- Detection removes the disguise.
- Detection logs the entry as detected.
- Nearby police receive an alert.

## Commands

View disguise information:

```text
/disguiseinfo
```

View disguise help:

```text
/disguisehelp
```

## Security

- Disguise eligibility is validated server-side.
- Disguise cooldowns are validated server-side.
- Guard challenge cooldowns are validated server-side.
- Guard responses are validated server-side.
- Disguise items are validated server-side.
- Restricted-area access is validated server-side.
- Disguise entries are logged server-side.