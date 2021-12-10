package en3d.blocks;

import h3d.prim.Primitive;
import h3d.scene.Object;

class IceBlock extends Block {
  override function setBody(prim:Primitive, root:Object, ?lightDir) {
    if (cache != null) {
      var model = cache.loadModel(hxd.Res.models.ice_block);
      model.getMaterials().iter((mat) -> {
        mat.shadows = false;
        mat.blendMode = Alpha;
        mat.color.set(mat.color.x, mat.color.y, mat.color.z, 0.85);
      });
      root.addChild(model);
      body = model;
    }
  }
}