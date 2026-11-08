# DMV Appeals & Community Service

`whellco_dmv_appeals` provides QBCore-compatible traffic-fine appeals, police review, and community service alternatives.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_traffic_fines
ensure whellco_license_suspension
ensure whellco_dmv_appeals
```

## Database

Run:

```sql
source database/whellco_dmv_appeals.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name == 'police'`.
- Appeal ownership uses `Player.PlayerData.citizenid`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, `whellco_traffic_fines`, and `whellco_license_suspension` as dependencies.

## Appeal rules

- Appeal cooldown: 30 minutes.
- Maximum appeal text length: 500 characters.
- Only unpaid fines can be appealed.
- Police can approve or deny appeals.
- Approved appeals dismiss the associated fine.
- Community service requires 5 completed tasks.

## Commands

Submit an appeal:

```text
/appealfine 1 I was not speeding
/appealfine 2 The light was yellow
```

Review an appeal:

```text
/reviewappeal 1 approve
/reviewappeal 2 deny
```

Start community service:

```text
/startservice 1
/startservice 2
```

Complete a community service task:

```text
/doservice
```

View appeal information:

```text
/appealinfo
```

## Security

- Appeal ownership, cooldowns, and fine status are validated server-side.
- Police review eligibility is validated server-side.
- Community service location and task progress are validated server-side.
- Approved appeals dismiss the associated fine.
- Appeal records store citizen ID, fine ID, reason, status, and reviewer.