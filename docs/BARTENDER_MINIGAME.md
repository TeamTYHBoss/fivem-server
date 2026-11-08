# Bartender Drink Mixing Minigame

`whellco_bartender_minigame` provides a drink mixing minigame for bartenders.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_bartender_minigame
```

## Database

Run:

```sql
source database/whellco_bartender_mixes.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Bartender eligibility uses `Player.PlayerData.job.name == 'bartender'`.
- Mix cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Minigame rules

- Mix cooldown: 15 seconds.
- Minigame duration: 30 seconds.
- Success threshold: 70.
- Bartender job: `bartender`.
- Successful mixes award a cocktail item.
- Mix records store bartender, drink, score, success, and timestamp.

## Commands

Start the minigame:

```text
/mixdrink 1
/mixdrink 2
```

View minigame information:

```text
/mixdrinkinfo
```

## Security

- Bartender eligibility is validated server-side.
- Mix cooldowns are validated server-side.
- Drink selection is validated server-side.
- Mix records store bartender, drink, score, success, and timestamp.