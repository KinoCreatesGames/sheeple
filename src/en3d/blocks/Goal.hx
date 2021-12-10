package en3d.blocks;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * Goal that when the player is on top of this block,
 * the current level is over and we can move on
 * to the next level.
 */
class Goal extends Block {
  override function setBody(prim:Primitive, root:Object, ?lightDir) {
    super.setBody(prim, root);
    var mesh:Mesh = cast body;
    mesh.material.color.setColor(0x00ff00);
  }
}