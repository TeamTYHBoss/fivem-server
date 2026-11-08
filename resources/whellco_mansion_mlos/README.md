# Luxury Mansion MLO Mapping Scaffold

This folder is a scaffold for custom FiveM MLO mansion interiors. It contains the resource structure, streaming rules, and integration points needed to load custom mansion interiors.

## Important limitation

Compiled FiveM MLO assets require 3D modelling and GTA V asset-export tools. This scaffold does **not** contain generated `.ydr`, `.ytd`, `.ytyp`, or `.ymap` game assets. Use CodeWalker, 3ds Max with GIMS Evo, or Blender with a GTA V export workflow to create and export the actual interior assets.

## Recommended workflow

1. Create the mansion interior geometry in Blender or 3ds Max.
2. UV unwrap and texture the interior.
3. Export models as `.ydr` files.
4. Create texture dictionaries as `.ytd` files.
5. Build the interior archetype and room data in a `.ytyp` file.
6. Place the interior in the world using a `.ymap` file.
7. Import the exported assets into CodeWalker.
8. Copy the compiled assets into `STREAM/`.
9. Update the `fxmanifest.lua` file lists and `data_file` entries.
10. Set the matching `mloInterior` value in `whellco_luxury_mansions/config.lua`.

## Folder structure

```text
whellco_mansion_mlos/
├── fxmanifest.lua
├── README.md
└── STREAM/
    ├── vinewood_hills_mansion.ytyp
    ├── vinewood_hills_mansion.ymap
    ├── pacific_bluffs_mansion.ytyp
    └── pacific_bluffs_mansion.ymap
```

## Mansion interiors

| Mansion | MLO identifier | Suggested rooms |
|---|---|---|
| Vinewood Hills Mansion | `vinewood_hills_mansion` | Grand entrance, living room, dining room, kitchen, master suite, guest suites, office, cinema, pool area, garage |
| Pacific Bluffs Mansion | `pacific_bluffs_mansion` | Ocean-view entrance, lounge, bar, dining room, kitchen, master suite, guest suites, spa, gym, garage |

## Integration

In `resources/whellco_luxury_mansions/config.lua`, set:

```lua
mloInterior = 'vinewood_hills_mansion'
```

or:

```lua
mloInterior = 'pacific_bluffs_mansion'
```

The mansion resource uses `mloInterior` as the identifier linking a purchased mansion to its custom interior.

## Streaming

The `fxmanifest.lua` declares the MLO files and requests them through `DLC_ITYP_REQUEST`. Replace the placeholder entries with the actual compiled asset filenames after exporting your mansion interiors.

## Interior design guidance

- Use separate rooms for entrance, living, dining, kitchen, bedrooms, bathrooms, office, garage, and outdoor areas.
- Add portal and room data so interiors load correctly.
- Use collision meshes for walls, floors, stairs, furniture, and doors.
- Keep texture resolutions appropriate for FiveM streaming.
- Test interiors in CodeWalker before adding them to the live server.
- Ensure spawn points, doors, and furniture do not overlap collision.
