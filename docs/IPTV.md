# IPTV

`whellco_iptv` adds working TVs that use an M3U playlist. Players need a TV remote to use the TV and can flick through channels using the channel selection UI.

## Playlist

The TV system uses this M3U playlist:

```text
https://raw.githubusercontent.com/TeamTYHBoss/IPTV/refs/heads/main/IPTV.m3u8
```

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

## TV channels

- The server fetches the M3U playlist.
- The server parses channel names and stream URLs.
- The client receives the channel list.
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
- M3U playlist support.
- Channel switching.
- Channel names.
- Stream playback.
- TV interaction prompt.
- TV close prompt.
- TV remote requirement.
- Channel selection UI.

## Security

- The playlist URL is configured server-side.
- The playlist is fetched server-side.
- The playlist is parsed server-side.
- Channel lists are sent to the client.
- Channel switching is handled client-side.
- Remote ownership is validated server-side.