# IPTV

`whellco_iptv` adds working TVs that players can use to watch channels and flick through them.

## TV remote

- Players need a `tv_remote` item to use the TV.
- The remote is a usable item.
- Using the remote enables TV interaction.
- Without the remote, players cannot open the TV.
- The server validates remote ownership.

## Channel selection UI

- The TV screen includes a channel list.
- Players can click a channel to select it.
- The selected channel is highlighted.
- The selected channel starts playing.
- The channel name is shown above the list.
- Players can still use arrow keys to change channels.

## Last watched channel

- The last watched channel is saved for each TV.
- The channel is saved per player and per TV.
- When a player reopens a TV, it returns to the last watched channel.
- The channel is saved when the TV is closed.
- The channel is saved in `whellco_iptv_last_channel`.

## TV channels

- The server provides the available channels.
- Players can flick through channels.
- Players can watch the selected channel.

## TV controls

| Control | Action |
|---|---|
| E | Watch TV |
| Right arrow | Next channel |
| Left arrow | Previous channel |
| Esc | Close TV |
| Click | Select channel |

## TV locations

| TV | Location |
|---|---|
| Apartment TV | Apartment interior |
| House TV | House interior |

## TV features

- Working TV screens.
- Channel switching.
- Channel names.
- Stream playback.
- TV interaction prompt.
- TV close prompt.
- TV remote requirement.
- Channel selection UI.
- Last watched channel saving.

## Security

- TV channel sources are handled server-side.
- TV remote ownership is validated server-side.
- Last watched channel is saved server-side.