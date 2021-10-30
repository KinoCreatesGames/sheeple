package en3d.blocks;

import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * A block in the game for the player to stand on
 * or push around using a unit length cube.
 */
class Block extends IsoEntity3D {
  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }

  public function setBody(prim:Primitive, root:Object) {
    var mesh = new h3d.scene.Mesh(prim, null, root);
    mesh.material.color.setColor(0xaaaaaa);
    mesh.material.shadows = false;
    body = mesh;
  }
}