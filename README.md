# FiveM Server

This repository contains the FiveM server resources and documentation.

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