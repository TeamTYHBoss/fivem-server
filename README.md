# FiveM Server

A FiveM server project with custom resources for characters, housing, economy, jobs, vehicles, phone, police, medical, mechanic, real estate, banking, admin, Discord, performance, security, testing, documentation, reports, anti-lag, auto-cleanup, and player robbery.

## Features

- Character creation and selection
- Spawn selector
- Wardrobe
- Housing
- Economy, XP, levels, shops and receipts
- Jobs, shops, transport and services
- Vehicle ownership
- Phone system
- Job center
- Police system
- Medical system
- Mechanic system
- Real-estate system
- Banking system
- Admin system
- Discord integration
- Unified economy hub
- Performance system
- Security system
- Testing system
- Documentation system
- Player report system
- Report teleport system
- Report sound alerts and staff dashboard
- Anti-lag monitoring and rate limiting
- Auto-cleanup for abandoned vehicles and peds
- Player robbery minigame

## Recently Added Systems

### Player Reports

Players can submit reports with a type, title, description, target player, and location.

- Reports are stored in `whellco_player_reports`.
- Reports support `open`, `claimed`, and `closed` statuses.
- Staff can claim and close reports.
- Report locations are recorded for staff response.
- Report actions are logged.

### Report Teleport

Staff can teleport to the recorded location of an open or claimed report.

- Command: `/gotoreport [report_id]`.
- Only `admin` and `manager` jobs can teleport.
- Teleports have a 5-second cooldown.
- Teleports are logged with staff ID, report ID, and timestamp.
- Resource: `whellco_report_teleport`.

### Report Sound Alerts and Dashboard

Staff receive sound alerts for new reports and can manage reports through an in-game dashboard.

- New reports trigger a sound alert and notification.
- Staff can open the dashboard with `/reportdashboard`.
- Staff can view, refresh, claim, close, and teleport to reports.
- Reports are paginated.
- Dashboard actions are validated server-side.
- Resource: `whellco_report_dashboard`.

### Anti-Lag System

The anti-lag system monitors client performance and limits lag-inducing activity.

- Client frame time is sampled every 5 seconds.
- Peds, vehicles, and objects are monitored.
- High tick rates and excessive entity counts create lag scores.
- Event, vehicle, ped, and object spam is rate-limited.
- Warnings begin at 20 lag points.
- Automatic kicks begin at 50 lag points.
- Lag events are logged in `whellco_anti_lag_events`.
- Resource: `whellco_anti_lag`.

### Auto-Cleanup

Abandoned vehicles and idle peds are cleaned automatically on a configurable schedule.

- Cleanup interval: 5 minutes.
- Vehicle idle threshold: 15 minutes.
- Ped idle threshold: 10 minutes.
- Maximum cleanup per cycle: 50 entities.
- Player vehicles and mission entities are skipped by default.
- Exempt models and zones are supported.
- Cleanup actions are logged in `whellco_cleanup_logs`.
- Resource: `whellco_auto_cleanup`.

### Player Robbery Minigame

Players can rob other players through a proximity prompt and timing minigame.

- Walk within 2.5 metres of another player.
- Press `E` to start a robbery.
- The target must have their hands up.
- The target receives a warning when a robbery starts.
- The robber must complete an 8-second timing minigame.
- Successful robberies can transfer cash and up to 3 items.
- Robberies have a 300-second cooldown.
- Police and ambulance jobs cannot be robbed.
- Resource: `whellco_player_robbery`.

### Robbery Fail States

A robbery fails immediately if:

- The target lowers their hands.
- The robber moves more than 5 metres away.
- The robber leaves the server.
- The minigame timer expires.
- The robber fails the timing minigame.

No cash or items are transferred after a failed robbery.

## Requirements

- FiveM server
- MySQL or MariaDB
- oxmysql
- QBCore

## Setup

1. Clone this repository.
2. Install the required resources.
3. Create a MySQL database.
4. Update `server.cfg` with your database connection string.
5. Run the SQL files in each resource's `sql` folder.
6. Run the SQL files in the `database` folder.
7. Start the server.

See `docs/SETUP.md` for detailed setup instructions.

## Commands

### Core Systems

- `/characters` — Open the character system.
- `/spawn` — Open the spawn selector.
- `/wardrobe` — Open the wardrobe.
- `/housing` — Open the housing system.
- `/economy` — Open the economy hub.
- `/phone` — Open the phone.
- `/jobcenter` — Open the job center.
- `/police` — Open the police system.
- `/medical` — Open the medical system.
- `/mechanic` — Open the mechanic system.
- `/realestate` — Open the real-estate system.
- `/bank` — Open the banking system.
- `/admin` — Open the admin panel.
- `/discord` — Open the Discord integration.
- `/performance` — Open the performance system.
- `/security` — Open the security system.
- `/testing` — Open the testing system.
- `/docs` — Open the documentation system.

### Reports and Staff Tools

- `/gotoreport [report_id]` — Teleport to an open report location.
- `/reportdashboard` — Open the staff report dashboard.
- `/dashboardinfo` — View report-dashboard information.

### Anti-Lag and Cleanup

- `/antistutter` — View anti-lag monitoring status.
- `/antilaginfo` — View anti-lag information.
- `/cleanupnow` — Run an immediate cleanup.
- `/cleanupinfo` — View auto-cleanup information.

### Player Robbery

- `/robberyinfo` — View robbery information.
- `/robberyhelp` — View robbery help.

## Documentation

- `docs/REPORT_TELEPORT.md` — Report teleport setup and rules.
- `docs/REPORT_DASHBOARD.md` — Report sound alerts and dashboard setup.
- `docs/ANTI_LAG.md` — Anti-lag monitoring and enforcement.
- `docs/AUTO_CLEANUP.md` — Abandoned vehicle and ped cleanup.
- `docs/PLAYER_ROBBERY.md` — Player robbery minigame and fail states.
- `docs/SETUP.md` — General server setup.
- `docs/COMMANDS.md` — Full command list.
