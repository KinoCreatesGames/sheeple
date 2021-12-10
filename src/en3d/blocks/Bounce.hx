package en3d.blocks;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

class Bounce extends Block {
  override function setBody(prim:Primitive, root:Object, ?lightDir) {
    super.setBody(prim, root);
    var mesh:Mesh = cast body;
    mesh.material.color.setColor(0xff00aa);
  }
}