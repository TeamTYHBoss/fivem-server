# FiveM Server

This repository contains the FiveM server resources and documentation.

## Current status

The server resources have been refactored, secured, and documented. The computer system now uses a modular server and UI architecture, shared utilities reduce duplicated logic, and IPTV includes trusted-domain allowlisting and playlist caching.

The computer client callback names and database schema remain unchanged, so existing SQL setups and integrations continue to work.

## Complete changelog

### Computer

#### Bugs and errors fixed

- Fixed a regression that replaced the complete computer server script with a patch or instruction file.
- Restored the full computer server implementation for banking, shopping, marketplace, transfers, social posts, comments, and notifications.
- Fixed invalid Lua `content:trim()` calls that could cause runtime errors when creating posts or comments.
- Added a safe string-trimming helper for post and comment input.
- Fixed invalid JavaScript `elseif` syntax in the modular UI event handler.
- Fixed the modular renderer to use the existing HTML element IDs.
- Wired the modular UI files into `index.html` and removed the legacy `script.js` include.
- Added a status-message element for user feedback.

#### Architecture updates

- Split the computer server into focused modules:
  - `server/main.lua` for shared state, recovery commands, and disconnect cleanup.
  - `server/bank.lua` for balances, transfers, transfer history, and recovery records.
  - `server/shop.lua` for shop data and purchases.
  - `server/marketplace.lua` for listings, cancellations, and purchases.
  - `server/social.lua` for posts and comments.
  - `server/notifications.lua` for notification retrieval and read state.
- Split the UI into:
  - `state.js` for shared client state and state setters.
  - `api.js` for NUI callback wrappers.
  - `render.js` for rendering, HTML escaping, and status messages.
  - `events.js` for all UI event handling and data refreshes.
- Added a shared `whellco_utils` resource for notifications, player lookup, cooldowns, validation, JSON handling, and money formatting.

#### UI features

The modular computer UI now handles:

- Tab switching for Bank, Shop, Marketplace, Social, and Notifications.
- Opening and closing the computer.
- Escape-key closing.
- Bank balance display and refresh.
- Bank transfers and transfer-history refresh.
- Shop item display and purchases.
- Marketplace listing display, creation, cancellation, and purchase.
- Social post display and creation.
- Notification display, refresh, and mark-as-read.
- HTML escaping for user-controlled content.

#### Marketplace security

- Marketplace listing metadata is read from the seller’s server-side inventory item.
- Clients cannot inject arbitrary marketplace listing metadata.
- Listings are claimed before item delivery and payment.
- Failed item delivery or payment rolls the listing back to `active` and clears the buyer.
- Listing quantity and price are validated server-side.

#### Transfer recovery

- Bank transfers create durable records before debiting the sender.
- Transfer records use `pending`, `recovery`, and `resolved` states.
- Failed transfers are marked for recovery when a player disconnects or payment fails.
- Failed receiver payment credits are refunded to the sender where possible.
- `/computerrecovery` lists unresolved recovery records.
- `/computerresolve <id>` marks a recovery record as resolved.
- Cooldown entries are removed when players disconnect.

### Fast food

#### Bugs and errors fixed

- Added the missing `oxmysql` integration to the fast-food server script.
- Fixed purchases so the food item is added before the player is charged.
- Added rollback so a failed payment removes the item that was added.
- Added checks for `AddItem`, `RemoveMoney`, and `RemoveItem` results.
- Changed the cooldown so failed purchase attempts do not consume it.
- Added cooldown cleanup when a player disconnects.

#### Features and reliability

- Added a two-second per-player purchase cooldown.
- Added validation for restaurant IDs, item IDs, menu availability, and purchase price.
- Added asynchronous purchase logging.
- Added logging for failed purchase-database inserts.
- Preserved cashier handovers, player food bags, and eating food from the bag.

### IPTV

#### Bugs and errors fixed

- Added the missing `oxmysql` integration to the IPTV server script.
- Replaced blocking last-channel database lookups with asynchronous callbacks.
- Added checks for remote `AddItem` and `RemoveItem` results.
- Ensured only channels with both a name and a valid URL are returned.
- Preserved TV remote ownership, channel selection, and last-channel saving.

#### Request safety

- Added validation for playlist URLs, including HTTP/HTTPS checks and URL-length limits.
- Added a 10-second callback timeout for external playlist requests.
- Added a response-size limit of 1 MB.
- Limited parsed playlists to 500 channels.
- Added validation for saved channel values from 1 through 1,000.
- Added private/internal address filtering for playlist and channel URLs.
- Added IPv6 loopback, link-local, and unique-local address checks.
- Added trusted-domain allowlisting for playlist hosts.
- Added short-lived playlist caching to reduce repeated external requests.

### Weather

#### Bugs and errors fixed

- Fixed the weather scheduler so `Config.SyncInterval` controls the actual time-sync interval.
- Removed overlapping weather and time-update loops.
- Added safe defaults for invalid, zero, or negative sync and weather-change intervals.
- Added guarded access to seasonal and realistic weather configuration.
- Preserved seasonal weather, real-time clock sync, night detection, and `/weatherinfo`.

## Resource overview

### Computer

`whellco_computer` adds an in-game computer with banking, shopping, a player marketplace, bank transfers, social posts, comments, and notifications.

### Fast food

The fast-food resource adds restaurants with menus, purchases, cashier NPCs, customer NPCs, food bags, and eating animations.

### IPTV

The IPTV resource adds working TVs, channel switching, a channel-selection UI, remote requirement, and last-channel saving.

### Weather

The weather resource adds realistic weather, real-time clock sync, streetlights, house windows, TV-style window flicker, curtains, silhouettes, swimming pools, water effects, and dive ripples.

## Shared utilities

`whellco_utils` provides shared server and client helpers:

- Player lookup by source or citizen ID.
- QBCore notifications.
- Per-player cooldowns.
- Positive-integer validation.
- Safe JSON encoding and decoding.
- Money formatting.
- String trimming.

Ensure `ensure whellco_utils` runs before `ensure whellco_computer` in `server.cfg`.

## Computer recovery tools

Failed or interrupted computer operations can be marked as `recovery`. Administrators can inspect and resolve these records without directly editing the database.

| Command | Permission | Purpose |
|---|---|---|
| `/computerrecovery` | Admin | Lists the latest unresolved recovery records. |
| `/computerresolve <id>` | Admin | Marks a recovery record as resolved. |

## IPTV configuration

IPTV playlist requests are restricted to trusted domains. Add allowed hosts to `Config.TrustedPlaylistDomains`:

```lua
Config.TrustedPlaylistDomains = {
    'raw.githubusercontent.com',
    'gist.githubusercontent.com'
}
```

Parsed playlists are cached for `Config.PlaylistCacheSeconds`. This reduces repeated external requests while keeping channel data reasonably fresh.

## Fast food configuration

Fast-food purchases use a two-second per-player cooldown. The cooldown is recorded only after the restaurant, item, price, inventory, and payment checks succeed, so failed purchase attempts do not consume the cooldown.

Cooldown entries are removed when a player disconnects.

## Weather configuration

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
- IPTV playlist hosts are restricted to the configured trusted-domain allowlist.
- IPTV playlist and channel URLs are checked against private and internal network ranges.
- IPTV external requests have timeout and response-size limits.
