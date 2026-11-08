# Computer upgrade: database foundation

Status: schema only. The new features are not wired into the computer UI or server callbacks yet.

## Setup

Back up the database, then import resources/whellco_computer/sql/upgrade.sql into the server database. This creates tables without dropping existing data. This GitHub change does not execute SQL on the live server.

The upcoming runtime integration must load @oxmysql/lib/MySQL.lua before server.lua, declare oxmysql and qb-core dependencies, and load config.lua as a shared script before client/server scripts. Start oxmysql and qb-core before whellco_computer.

## Planned integration

- Persist posts, comments, messages, notifications, and per-character UI preferences using parameterized queries. Existing in-memory posts need an explicit migration before resource restart if they must be retained.
- Notify recipients of messages and post authors of comments; persist unread state and paginate results.
- Validate transfer recipients and positive integer amounts server-side. Use idempotency keys, balance checks, account locks, and recovery handling. An SQL transaction alone does not make QBCore in-memory money mutations atomic.
- Escrow listed inventory with metadata, serialize purchases, and implement restart-safe settlement and refunds before enabling marketplace purchases.
- Restrict custom browser pages to configured local pages in a sandbox without NUI banking or inventory privileges.
- Fix the existing missing getShop callback, hidden UI CSS specificity, and missing documented command/Escape handlers during runtime integration.

Do not advertise transfers, marketplace, notifications, database persistence, or the browser as working until runtime integration and in-game tests are complete.
