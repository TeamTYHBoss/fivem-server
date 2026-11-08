# Admin Toolkit

`whellco_admin_toolkit` provides moderated admin commands for staff.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_admin_toolkit
```

## Database

Run:

```sql
source database/whellco_admin_actions.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Permissions use `Config.AdminPermissions`.
- Admin eligibility uses `Config.AdminJobs`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Admin commands

- `/adminmode on|off`: enable or disable god mode.
- `/admininvisible on|off`: enable or disable invisibility.
- `/admintp x y z`: teleport to coordinates.
- `/admininv [player_id]`: view a player inventory.
- `/adminheal [player_id]`: heal a player.
- `/adminrevive [player_id]`: revive a player.
- `/adminfreeze [player_id] on|off`: freeze or unfreeze a player.
- `/adminhelp`: view available admin commands.

## Security

- Admin permissions are validated server-side.
- Command cooldowns prevent spam.
- All admin actions are logged with admin, target, action, and timestamp.
- Inventory access is read-only in this implementation.
- God mode and invisibility require the `admin` job.