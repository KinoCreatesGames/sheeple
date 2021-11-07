package en3d.collectibles;

import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * Checkpoint, that when the player interacts with it
 * the player will be able to restart the game
 * at their current position.
 */
class Checkpoint extends Collectible {
  override function setBody(prim:Primitive, root:Object) {
    super.setBody(prim, root);
    var mesh = body.toMesh();
    mesh.material.blendMode = Alpha;
    mesh.material.color.setColor(0xffaa0f);
  }
}