package en3d.collectibles;

import h3d.prim.Primitive;
import h3d.scene.Object;

class Collectible extends IsoEntity3D {
  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }

  /**
   * Sets the body of the 
   * Collectible so that we can collect it and for it to 
   * be visible on screen.
   * @param prim 
   * @param root 
   */
  public function setBody(prim:Primitive, root:Object) {
    var mesh = new h3d.scene.Mesh(prim, null, root);
    mesh.material.color.setColor(0xffaafa);
    mesh.material.shadows = false;
    body = mesh;
  }
}