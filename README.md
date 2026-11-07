# FiveM Server Starter

A clean starting point for a FiveM GTA V roleplay or freeroam server.

## What is included

- `server.cfg` — core FiveM server configuration
- `resources/my_first_resource` — a minimal client/server Lua resource
- `.gitignore` — excludes server binaries, caches, logs, and secrets

## Requirements

- A legal copy of Grand Theft Auto V
- FiveM client
- FiveM server artifacts

## Setup

1. Install the FiveM server artifacts in a folder such as `C:\FiveM\server`.
2. Place this repository beside or inside that server folder.
3. Set your MySQL connection details in `server.cfg` only if you add a database-dependent resource.
4. Start the server with:

```bat
FXServer.exe +exec server.cfg
```

On Linux:

```bash
./run.sh +exec server.cfg
```

## Important

Do **not** commit:

- Your FiveM license key
- Database passwords
- Server artifacts
- GTA V game files
- Paid or leaked resources

## Adding resources

Add a resource folder under `resources/`, then ensure it in `server.cfg`:

```cfg
ensure my_new_resource
```
