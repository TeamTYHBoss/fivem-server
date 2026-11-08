# Hitman Contract Job

`whellco_hitman` adds a hitman job with escalating NPC contracts, a hitman appearance, and contract payouts.

## Important design note

This system uses NPC contract targets. It does **not** reward killing other players or encourage mass violence against players. PvP can remain governed by your server’s existing consent, roleplay, and moderation rules.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_hitman
```

## Database

Run:

```sql
source database/whellco_hitman_contracts.sql
```

## QBCore integration

- Hitman job name: `hitman`.
- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Contract progression uses `Player.PlayerData.metadata['hitman_contracts']`.
- Payouts use `Player.Functions.AddMoney`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Appearance

- Hitman skin uses `mp_m_freemode_01`.
- Hitman outfit uses drawable 11 and texture 0.
- Neck barcode uses a configurable tattoo collection and tattoo name.
- Appearance is applied only to players with the hitman job.

## Contract tiers

| Tier | Label | Payout | Targets | Target armour | Target weapon |
|---|---|---:|---:|---:|---|
| 1 | Low-profile target | $2,500 | 1 | 0 | Unarmed |
| 2 | Protected target | $5,000 | 2 | 25 | Pistol |
| 3 | High-value target | $10,000 | 3 | 50 | Pistol |
| 4 | High-risk operation | $20,000 | 4 | 75 | SMG |
| 5 | Maximum-risk operation | $40,000 | 5 | 100 | SMG |

## Contract rules

- Contract time limit: 10 minutes.
- Maximum active contracts: 1.
- Contract cooldown: 60 seconds.
- Contracts escalate by completed-contract count.
- Payouts increase with contract tier.
- Contract time remains constant across tiers.
- Targets are NPC peds, not players.
- Targets have configurable health, armour, weapons, and accuracy.

## Commands

Accept a contract:

```text
/hitman
```

View hitman information:

```text
/hitmaninfo
```

View hitman help:

```text
/hitmanhelp
```

## Security

- Hitman eligibility is validated server-side.
- Contract cooldowns are validated server-side.
- Contract expiry is validated server-side.
- Contract payouts are validated server-side.
- Contract progression is validated server-side.
- Contract actions are logged server-side.