# MeshBaker
Combine Skinned and normal Meshes into a single regular mesh.

How-To:
- Add this script to a GameObject.
- Enter an identifier for the output mesh's filename. (e.g. could be `statue_ethan` when creating a statue of a character model)
- Press the button. All meshes under the GameObject will be combined into one.
  - Set `Apply Scale from Transform Component` if you want the scales set in the scene to be used.
- Mesh Assets will be written to `Assets/BakedMeshes`. Existing meshes will be overwritten as you re-bake them.

To use a Mesh Asset:
- Create a GameObject.
- Add `Mesh Filter` and `Mesh Renderer`.
- Drag the Mesh Asset into the Mesh Filter.

## Known issues
- Only one material slot per mesh.
  - Combining 3 Meshes will output a Mesh with 3 materials, irrespective of how many material slots each mesh had.
- Re-baking a mesh gives it a new GUID, meaning any uses of it will become detached.
  - You can work around this by instead using a symlink that points back to the baked mesh. This way, the symlink has its own GUID that cannot be touched when the mesh data gets updated.

## Resources
- Random posts to figure out how the combiner stuff works.
