# Banking & ATM Management

`whellco_banking_atm` provides QBCore-compatible bank accounts, ATM withdrawals, deposits, transfers, transaction history, and ATM locations.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_banking_atm
```

## Database

Run:

```sql
source database/whellco_banking_atm.sql
```

The system creates:

- `whellco_bank_accounts`
- `whellco_bank_transactions`

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Cash withdrawals use `Player.Functions.AddMoney('cash', amount, reason)`.
- Cash deposits use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Account records use `Player.PlayerData.citizenid`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Accounts

Supported account types:

- `checking`
- `savings`
- `business`

Accounts are automatically created when first accessed.

## Commands

Open a bank account:

```text
/bank
```

Open an ATM interface:

```text
/atm
```

List ATM locations:

```text
/atmlocations
```

## Limits

| Setting | Default |
|---|---:|
| Maximum transaction | $1,000,000 |
| ATM withdrawal limit | $5,000 |
| Daily ATM limit | $25,000 |
| Transfer fee | 0% |

## Security

- All deposits, withdrawals, and transfers are validated server-side.
- Account balances are stored in MySQL, not client-side.
- Transactions are recorded with type, amount, resulting balance, and details.
- Account ownership is tied to QBCore citizen IDs.
- Transfer recipients must exist in the QBCore players table.
- ATM withdrawal limits prevent uncontrolled cash extraction.