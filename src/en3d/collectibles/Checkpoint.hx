package en3d.collectibles;

import shaders.FrameShader;
import h3d.prim.Primitive;
import h3d.scene.Object;
import en3d.Billboard;

/**
 * Checkpoint, that when the player interacts with it
 * the player will be able to restart the game
 * at their current position.
 */
class Checkpoint extends Collectible {
  public var billb:Billboard;

  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }

  override function setBody(prim:Primitive, root:Object) {
    super.setBody(prim, root);

    var bb = new Billboard(root, cx, cy, cz);
    billb = bb;
    body = bb.mesh;
    var tex = hxd.Res.img.check_point_Sheet.toTexture();
    billb.mesh.material.texture = tex;
    var totalFrames = 1;
    var frameShader = new FrameShader(tex, totalFrames, 12.5);

    billb.mesh.material.mainPass.addShader(frameShader);
    var mesh = body.toMesh();
  }

  override function update() {
    super.update();
  }
}