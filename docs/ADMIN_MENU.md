# Interactive Admin Menu UI

`whellco_admin_menu` provides an interactive admin menu UI for authorised staff.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_admin_menu
```

## Database

Run:

```sql
source database/whellco_admin_menu_actions.sql
source database/whellco_temp_bans.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Admin eligibility uses `Config.AdminJobs`.
- Action cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Menu features

- God mode toggle.
- Invisibility toggle.
- Noclip toggle.
- Teleport to player.
- Heal player.
- Revive player.
- Freeze player.
- View player inventory.
- Warn player with reason.
- Kick player with reason.
- Temporary ban player with reason and duration.

## Moderation tools

- Warn sends an in-game warning and records the reason.
- Kick disconnects the target and records the reason.
- Temporary ban creates a database ban record and disconnects the target.
- Temporary ban duration must be between 1 and 720 hours.
- All moderation actions require a valid target player ID.
- All moderation actions are logged with admin, target, action, reason, and timestamp.

## Commands

Open the admin menu:

```text
/adminmenu
```

View menu information:

```text
/adminmenuinfo
```

## Security

- Admin eligibility is validated server-side.
- Action cooldowns are validated server-side.
- Temporary ban duration is validated server-side.
- All admin actions are logged with admin, target, action, and timestamp.
- Inventory access is read-only in this implementation.
- NUI actions are routed through server-side permission checks.