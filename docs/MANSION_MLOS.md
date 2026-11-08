# Custom Mansion MLO Assets

Custom mansion interiors require separate FiveM MLO mapping assets.

## What can be automated

The server can automate:

- Mansion ownership.
- Mansion purchases.
- Mansion access control.
- Interior teleportation.
- Customisation settings.
- Guest lists.
- Private events.
- CCTV placement.
- Staff hiring.

## What requires mapping tools

The following require 3D modelling and GTA V asset-export tools:

- Custom walls, floors, ceilings, and stairs.
- Custom furniture and props.
- Custom textures and materials.
- Interior rooms and portals.
- Collision meshes.
- `.ydr`, `.ytd`, `.ytyp`, and `.ymap` assets.

## Recommended tools

- CodeWalker for map editing and asset inspection.
- 3ds Max with GIMS Evo for GTA V asset creation.
- Blender with a GTA V export workflow for modelling.
- FiveM asset streaming for deployment.

## Integration

The mansion resource expects each mansion to have a unique `mloInterior` identifier:

```lua
mloInterior = 'vinewood_hills_mansion'
```

or:

```lua
mloInterior = 'pacific_bluffs_mansion'
```

The MLO mapping scaffold is located at:

```text
resources/whellco_mansion_mlos/
```

## Deployment

1. Create and export the custom MLO assets.
2. Place the compiled assets in `resources/whellco_mansion_mlos/STREAM/`.
3. Update `resources/whellco_mansion_mlos/fxmanifest.lua`.
4. Ensure the mansion resource is started after the MLO mapping resource.
5. Set the matching `mloInterior` value in the mansion configuration.
6. Restart the server.