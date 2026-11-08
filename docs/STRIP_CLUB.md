# Strip Club System

`whellco_strip_club` provides a QBCore-compatible furnished strip club with NPC interactions, drinks, and tipping.

## Startup order

```cfg
ensure qb-core
ensure oxmysql
ensure whellco_qbcore
ensure whellco_strip_club
```

## QBCore integration

- Player identity uses `QBCore.Functions.GetPlayer(source)`.
- Drink purchases use `Player.Functions.RemoveMoney('cash', amount, reason)`.
- Drink items use `Player.Functions.AddItem(drinkType, amount)`.
- Notifications use `QBCore.Functions.Notify`.
- The resource declares `qb-core` and `oxmysql` as dependencies.

## NPCs

| NPC | Model | Scenario |
|---|---|---|
| Bartender | `s_m_m_bartender_01` | `WORLD_HUMAN_BARTENDER` |
| Security | `s_m_m_security_01` | `WORLD_HUMAN_GUARD_STAND` |
| Dancer | `a_f_y_hipster_02` | `WORLD_HUMAN_PARTYING` |

## Drinks

| Drink | Price |
|---|---:|
| Water | $25 |
| Beer | $75 |
| Whiskey | $150 |

## Commands

View drinks:

```text
/stripclub
```

Tip a dancer:

```text
/tipdancer
```

View club information:

```text
/stripclubinfo
```

## Security

- Drink purchases and tips are validated server-side.
- Players must be near the strip club.
- Tip cooldowns prevent spam.
- NPC and furniture spawning is client-side only.