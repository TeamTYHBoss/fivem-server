# Gang Territory & Turf War

`whellco_gang_territory` provides QBCore-compatible gang territories, turf wars, capture timers, ownership tracking, and rewards.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_gang_territory
```

## Database

Run:

```sql
source database/whellco_gang_territory.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Gang eligibility uses `Player.PlayerData.gang.name`.
- Territory ownership uses `whellco_gang_territories.owner_gang`.
- Rewards use `Player.Functions.AddMoney('bank', amount, reason)`.
- XP uses `Player.Functions.SetMetaData('whellco_xp', value)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## Territories

| Territory | Radius | Default owner |
|---|---:|---|
| Grove Street | 150m | Unclaimed |
| East Side | 175m | Unclaimed |
| Downtown Block | 125m | Unclaimed |

## Turf war rules

- A gang needs at least 2 attackers inside the territory.
- A defending gang needs at least 1 member inside the territory.
- Turf wars last 180 seconds.
- Captured territories have a 30-minute cooldown.
- The attacking gang must remain eligible to claim the territory.
- Rewards are $5,000 and 25 XP.

## Commands

List territories:

```text
/territories
```

Start a turf war:

```text
/startwar grove_street
/startwar east_side
/startwar downtown
```

Claim a territory after the timer ends:

```text
/claimterritory grove_street
/claimterritory east_side
/claimterritory downtown
```

Check war status:

```text
/territorystatus
```

## Security

- Gang eligibility, territory status, cooldowns, and player presence are validated server-side.
- Only the attacking gang can claim a territory after the war timer ends.
- Territory ownership and capture times are stored in MySQL.
- Rewards are issued only after a successful capture.