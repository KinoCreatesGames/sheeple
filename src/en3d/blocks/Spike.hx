package en3d.blocks;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

class Spike extends Block {
  override function setBody(prim:Primitive, root:Object) {
    super.setBody(prim, root);
    var mesh:Mesh = cast body;
    mesh.material.color.setColor(0xaa0000);
  }
}