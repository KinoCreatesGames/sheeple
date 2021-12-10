package en3d.blocks;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * Heavy block, takes a longer time for the 
 * player to pull these blocks out in comparison
 * to the regular block.
 */
class HeavyBlock extends Block {
  override function setBody(prim:Primitive, root:Object, ?lightDir) {
    if (cache != null) {
      var model = cache.loadModel(hxd.Res.models.heavy_block);
      model.getMaterials().iter((mat) -> {
        mat.shadows = false;
      });
      root.addChild(model);
      body = model;
    }
  }
}