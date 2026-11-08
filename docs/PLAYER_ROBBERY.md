# Player Robbery Minigame

`whellco_player_robbery` lets players rob other players through a proximity prompt and timing minigame.

## Hands-up requirement

- Players must press X to put their hands up.
- Robbers can only start a robbery if the target has their hands up.
- Hands-up state expires after 10 seconds.
- The hands-up requirement is configurable.
- The hands-up key is configurable.

## Target warning

- The target receives a notification when a robbery starts.
- The notification says: `Someone is attempting to rob you. Keep your hands up!`
- The notification lasts 10 seconds.
- The notification uses an error-style alert.
- A sound effect plays alongside the notification.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_player_robbery
```

## Database

Run:

```sql
source database/whellco_robbery_logs.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Protected jobs use `Config.ProtectedJobs`.
- Cash transfers use `Functions.AddMoney` and `Functions.RemoveMoney`.
- Item transfers use `Functions.RemoveItem`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Robbery rules

- Walk up to another player within 2.5 metres.
- Target must have their hands up.
- Press E to start the robbery.
- Complete the timing minigame within 8 seconds.
- Robbery success chance is 65%.
- Robbery cooldown is 300 seconds.
- Maximum cash stolen is 5000.
- Minimum cash stolen is 100.
- Maximum items stolen is 3.
- Police and ambulance jobs are protected.

## Minigame

- A moving marker travels across the screen.
- Press E when the marker is inside the target zone.
- The minigame ends after 8 seconds.
- Successful attempts transfer cash and items.
- Failed attempts do not transfer cash or items.

## Police alerts

- Police alerts are enabled by default.
- Alert chance is 40%.
- Alert radius is 100 metres.
- Nearby police receive a notification.

## Commands

View robbery information:

```text
/robberyinfo
```

View robbery help:

```text
/robberyhelp
```

## Security

- Robbery initiation is validated server-side.
- Hands-up state is validated server-side.
- Robbery cooldowns are validated server-side.
- Protected jobs are validated server-side.
- Cash transfers are validated server-side.
- Item transfers are validated server-side.
- Robbery actions are logged server-side.