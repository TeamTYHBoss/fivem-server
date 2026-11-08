# FiveM Server

This repository contains the FiveM server resources and documentation.

## Bugs and errors squashed

The following bugs, errors, and reliability issues have been fixed and pushed to the repository.

### Computer

- Fixed a regression that replaced the complete computer server script with a patch/instruction file.
- Restored the full computer server implementation for banking, shopping, marketplace, transfers, social posts, comments, and notifications.
- Fixed invalid Lua `content:trim()` calls that could cause runtime errors when creating posts or comments.
- Added a safe local `trim()` helper for post and comment input.
- Added server-side inventory metadata validation for marketplace listings.
- Prevented clients from injecting arbitrary marketplace listing metadata.
- Added `/computerrecovery` to list unresolved recovery records.
- Added `/computerresolve <id>` to resolve recovery records.
- Added cooldown cleanup when players disconnect.
- Preserved recovery states and rollback behavior for failed transfers and marketplace purchases.

### Fast food

- Added the missing `oxmysql` integration to the fast-food server script.
- Fixed purchases so the food item is added before the player is charged.
- Added rollback so a failed payment removes the item that was added.
- Added checks for `AddItem`, `RemoveMoney`, and `RemoveItem` results.
- Added a two-second per-player purchase cooldown.
- Changed the cooldown so failed purchase attempts do not consume it.
- Added cooldown cleanup when a player disconnects.
- Added validation for restaurant IDs, item IDs, menu availability, and purchase price.
- Added asynchronous purchase logging.
- Added logging for failed purchase-database inserts.
- Preserved cashier handovers, player food bags, and eating food from the bag.

### IPTV

- Added the missing `oxmysql` integration to the IPTV server script.
- Added validation for playlist URLs, including HTTP/HTTPS checks and URL-length limits.
- Added a 10-second callback timeout for external playlist requests.
- Added a response-size limit of 1 MB.
- Limited parsed playlists to 500 channels.
- Added validation for saved channel values from 1 through 1,000.
- Added checks for remote `AddItem` and `RemoveItem` results.
- Replaced blocking last-channel database lookups with asynchronous callbacks.
- Added private/internal address filtering for playlist and channel URLs.
- Added IPv6 loopback, link-local, and unique-local address checks.
- Ensured only channels with both a name and a valid URL are returned.
- Preserved TV remote ownership, channel selection, and last-channel saving.

### Weather

- Fixed the weather scheduler so `Config.SyncInterval` controls the actual time-sync interval.
- Removed overlapping weather and time-update loops.
- Added safe defaults for invalid, zero, or negative sync and weather-change intervals.
- Added guarded access to seasonal and realistic weather configuration.
- Preserved seasonal weather, real-time clock sync, night detection, and `/weatherinfo`.

## Server updates

- Added a computer resource with banking, shopping, marketplace, transfers, social posts, comments, and notifications.
- Added fast-food restaurants with menus, purchases, cashier NPCs, customer NPCs, food bags, and eating animations.
- Added IPTV with working TVs, channel switching, channel selection UI, remote requirement, and last-channel saving.
- Added realistic weather, real-time clock sync, streetlights, house windows, TV-style window flicker, curtains, silhouettes, swimming pools, water effects, and dive ripples.
- Added server-side validation, cooldowns, rollback handling, recovery states, and asynchronous database operations across affected resources.
- Added documentation for computer metadata, recovery tools, IPTV timeout behavior, fast-food cooldowns, and weather intervals.

## Computer resource

`whellco_computer` adds an in-game computer with banking, shopping, a player marketplace, bank transfers, social posts, comments, and notifications.

## Computer marketplace metadata

Marketplace listings now use server-side inventory metadata. When a player creates a listing, the server reads metadata from that player’s actual inventory item rather than trusting metadata sent by the client.

If the item has no metadata, an empty metadata table is stored. This preserves useful metadata while preventing clients from injecting arbitrary listing metadata.

## Computer recovery tools

Failed or interrupted marketplace operations can be marked as `recovery`. Administrators can inspect and resolve these records without directly editing the database.

| Command | Permission | Purpose |
|---|---|---|
| `/computerrecovery` | Admin | Lists the latest unresolved recovery records. |
| `/computerresolve <id>` | Admin | Marks a recovery record as resolved. |

## IPTV request timeout

The IPTV resource uses a 10-second callback timeout. If an external playlist host is slow or unreachable, the TV returns an empty channel list after 10 seconds.

FiveM’s `PerformHttpRequest` does not provide a reliable way to cancel an in-progress request. The timeout therefore prevents the UI callback from hanging, but the underlying request may still complete later. For production servers, use trusted playlist sources or an allowlist of playlist domains.

## Fast food cooldowns

Fast-food purchases use a two-second per-player cooldown. The cooldown is recorded only after the restaurant, item, price, inventory, and payment checks succeed, so failed purchase attempts do not consume the cooldown.

Cooldown entries are removed when a player disconnects.

## Weather intervals

`Config.SyncInterval` controls how often the server sends time and weather updates, in seconds. `Config.WeatherChangeInterval` controls how often a new weather type is selected, also in seconds.

Both values must be at least 1. Invalid or non-positive values fall back to safe defaults.

## Security

- Restaurant and item availability are validated server-side.
- Purchases are validated server-side.
- Purchase prices are validated server-side.
- Purchases are logged server-side.
- Food items are added server-side.
- Food items are removed server-side when eaten.
- TV channel sources are handled server-side.
- TV remote ownership is validated server-side.
- Last watched channel is saved server-side.
- Weather is selected server-side.
- Weather is synced server-side.
- Time is synced server-side.
- Night time is synced server-side.
- Weather changes are validated server-side.
- Computer purchases, listings, transfers, posts, comments, and notifications are validated server-side.
- Marketplace purchases claim listings before item delivery and payment.
- Marketplace listing metadata is read from the seller’s server-side inventory item.
- Bank transfers create durable records before debiting senders.
- Notification ownership is validated server-side.