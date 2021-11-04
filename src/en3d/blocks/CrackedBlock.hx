package en3d.blocks;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * Blocks that can be destroyed after
 * a certain amount of time in game. 
 */
class CrackedBlock extends Block {
  /**
   * Amount of times this block can
   * be stepped on before it is destroyed.
   */
  public var stepCount:Int = 3;

  override function setBody(prim:Primitive, root:Object) {
    super.setBody(prim, root);
    var mesh:Mesh = cast body;
    mesh.material.color.setColor(0x3f0f0f);
  }
}