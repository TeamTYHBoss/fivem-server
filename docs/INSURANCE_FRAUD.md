# Insurance Fraud Investigation

`whellco_insurance_fraud` provides QBCore-compatible insurance fraud investigations for police, fraud flags, case resolution, and penalties.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_insurance
ensure whellco_insurance_fraud
```

## Database

Run:

```sql
source database/whellco_insurance_fraud.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Police eligibility uses `Player.PlayerData.job.name == 'police'`.
- Fraud fines use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Fraud penalties use `Player.Functions.SetMetaData('whellco_xp', value)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_vehicle_insurance` as dependencies.

## Investigation rules

- Investigation cooldown: 30 seconds.
- High-damage threshold: $20,000.
- Frequent-claim threshold: 3 claims in 24 hours.
- Fraud fine: $5,000.
- Fraud XP penalty: 6 points.
- Fraudulent claims are denied automatically.

## Commands

Investigate a claim:

```text
/investigateclaim 1
/investigateclaim 2
```

Resolve a fraud case:

```text
/resolvefraud 1 guilty
/resolvefraud 2 innocent
```

## Security

- Police eligibility is validated server-side.
- Claim IDs, cooldowns, and fraud thresholds are validated server-side.
- Fraud cases are stored in MySQL.
- Fraudulent claims are denied automatically.
- Fraud penalties are applied server-side.