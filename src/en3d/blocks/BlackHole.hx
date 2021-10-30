package en3d.blocks;

import h3d.prim.Primitive;
import h3d.scene.Object;

class BlackHole extends Block {
  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }

  override function setBody(prim:Primitive, root:Object) {
    super.setBody(prim, root);
  }
}