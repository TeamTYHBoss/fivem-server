# Computer

`whellco_computer` adds a working computer system with a bank balance checker, shop, and Facebook-style social media page.

## Computer locations

| Computer | Location |
|---|---|
| Apartment Computer | Apartment interior |

## Computer UI

- Bank tab.
- Shop tab.
- Social tab.
- Close button.
- Computer interaction prompt.

## Bank

- Players can check their bank balance.
- Bank balance is validated server-side.
- Players can refresh their bank balance.

## Shop

- Players can buy items using bank money.
- Shop items are validated server-side.
- Shop purchases remove bank money server-side.
- Shop purchases add inventory items server-side.
- Shop purchases refund bank money if inventory is full.

## Social media

- Players can create posts.
- Players can view posts.
- Players can comment on posts.
- Posts and comments are validated server-side.
- Posts and comments are stored server-side.
- Posts show the author name.
- Comments show the author name.

## Commands

Open the computer:

```text
/computer
```

## Controls

| Control | Action |
|---|---|
| E | Use computer |
| Esc | Close computer |

## Security

- Bank balance is validated server-side.
- Shop items are validated server-side.
- Shop prices are validated server-side.
- Shop purchases are validated server-side.
- Social posts are validated server-side.
- Social comments are validated server-side.