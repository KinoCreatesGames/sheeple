package en3d.blocks;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * Static block
 * within the game.
 * Player can't move these blocks.
 */
class StaticBlock extends Block {
  override function setBody(prim:Primitive, root:Object) {
    if (cache != null) {
      var model = cache.loadModel(hxd.Res.models.static_block);
      model.getMaterials().iter((mat) -> {
        mat.shadows = false;
      });
      root.addChild(model);
      body = model;
    }
  }
}