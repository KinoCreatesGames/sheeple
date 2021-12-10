package en3d.blocks;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * Black hole element, sucks in any block below it and deletes it from
 * the game world on impact. Also sucks in the player as well.
 */
class BlackHole extends Block {
  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }

  override function setBody(prim:Primitive, root:Object, ?lightDir) {
    super.setBody(prim, root);
    var mesh:Mesh = cast body;
    mesh.material.color.setColor(0xff00aa);
  }
}