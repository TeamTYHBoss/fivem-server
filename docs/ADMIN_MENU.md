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

## Moderation tools

- Warn sends an in-game warning and records the reason.
- Kick disconnects the target and records the reason.
- Warning and kick reasons are limited to 200 characters.
- Both actions require a valid target player ID.
- Both actions are logged with admin, target, action, reason, and timestamp.

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
- All admin actions are logged with admin, target, action, and timestamp.
- Inventory access is read-only in this implementation.
- NUI actions are routed through server-side permission checks.