# Custom Bartender Outfit Presets

`whellco_bartender_outfits` provides custom bartender outfit presets.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
ensure whellco_bartender_outfits
```

## Database

Run:

```sql
source database/whellco_bartender_outfits.sql
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Bartender eligibility uses `Player.PlayerData.job.name == 'bartender'`.
- Outfit cooldowns prevent spam.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core`, `oxmysql`, and `whellco_strip_club` as dependencies.

## Outfit rules

- Outfit cooldown: 10 seconds.
- Bartender job: `bartender`.
- Outfits are defined in config.
- Outfit records store bartender, outfit, and timestamp.

## Commands

Apply an outfit:

```text
/bartenderoutfit 1
/bartenderoutfit 2
```

View outfit information:

```text
/bartenderoutfitinfo
```

## Security

- Bartender eligibility is validated server-side.
- Outfit cooldowns are validated server-side.
- Outfit selection is validated server-side.
- Outfit records store bartender, outfit, and timestamp.