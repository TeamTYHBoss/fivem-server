# Player Reporting System

`whellco_player_reports` provides an in-game reporting system for cheating, harassment, bugs, griefing, and other staff assistance.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_player_reports
```

## Discord webhook

Add this to `server.cfg`:

```cfg
set whellco_report_webhook "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

Keep the webhook secret. Do not commit it to GitHub.

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Staff eligibility uses `Config.StaffJobs`.
- Report cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Report fields

- Report type: cheating, harassment, bug, griefing, or other.
- Reported player ID: optional.
- Title: required, up to 100 characters.
- Description: required, up to 2,000 characters.
- Reporter identity, target identity, location, and timestamp are attached automatically.

## Staff notifications

- Reports are stored in MySQL.
- Staff receive an in-game notification.
- Reports are sent to the configured Discord webhook.
- Reports include reporter, target, title, description, location, and timestamp.

## Commands

Open the report menu:

```text
/report
```

View report information:

```text
/reportinfo
```

## Security

- Report cooldowns are validated server-side.
- Report types are validated server-side.
- Report text is sanitised and length-limited.
- Reports are stored server-side.
- Discord webhook URL is stored in server configuration, not in source code.