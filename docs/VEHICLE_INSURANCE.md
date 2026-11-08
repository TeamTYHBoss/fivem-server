# Vehicle Insurance Claims

`whellco_vehicle_insurance` provides QBCore-compatible vehicle insurance policies, crash claims, deductibles, and payouts.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_vehicle_shop
ensure whellco_vehicle_insurance
```

## Database

Run:

```sql
source database/whellco_vehicle_insurance.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Policy ownership uses `Player.PlayerData.citizenid`.
- Policy purchases use `Player.Functions.RemoveMoney('bank', amount, reason)`.
- Claim payouts use `Player.Functions.AddMoney('bank', amount, reason)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Policies

| Policy | Monthly price | Maximum payout |
|---|---:|---:|
| Basic Coverage | $1,000 | $15,000 |
| Standard Coverage | $2,500 | $30,000 |
| Premium Coverage | $5,000 | $50,000 |

## Claim rules

- Claim cooldown: 30 minutes.
- Minimum damage amount: $250.
- Deductible: 15%.
- Maximum payout is based on the policy type.
- Players must own the vehicle being claimed.
- Claims must be approved before payout.

## Commands

View insurance policies:

```text
/insurance
```

Purchase insurance:

```text
/buyinsurance basic
/buyinsurance standard
/buyinsurance premium
```

Submit a claim:

```text
/claiminsurance ABC123 5000 Rear-end collision
/claiminsurance XYZ789 12000 Side impact damage
```

Approve a claim:

```text
/approveclaim 1
/approveclaim 2
```

View insurance information:

```text
/insuranceinfo
```

## Security
- Policy purchases, claim eligibility, and cooldowns are validated server-side.
- Vehicle ownership is validated server-side using QBCore citizen IDs and plates.
- Claim amounts, deductibles, and payouts are validated server-side.
- Claims must be approved before payout.
- Claim records store citizen ID, plate, policy, damage, deductible, payout, and status.