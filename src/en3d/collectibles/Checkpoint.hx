package en3d.collectibles;

import shaders.FrameShader;
import hxsl.ShaderList;
import h3d.mat.Pass;
import h3d.pass.Default;
import h3d.scene.fwd.Renderer.NormalPass;
import h3d.shader.AnimatedTexture;
import shaders.BillboardShader;
import h3d.scene.Mesh;
import h3d.prim.Primitive;
import h3d.scene.Object;
import dn.heaps.assets.Aseprite;

/**
 * Checkpoint, that when the player interacts with it
 * the player will be able to restart the game
 * at their current position.
 */
class Checkpoint extends Collectible {
  public var hspr:HSprite;
  public var billb:Billboard;

  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
    hspr = new HSprite();
  }

  override function setBody(prim:Primitive, root:Object) {
    super.setBody(prim, root);

    var bb = new en3d.Billboard(root, cx, cy, cz);
    billb = bb;
    body = bb.mesh;
    var tex = hxd.Res.img.sprocket.toTexture();
    billb.mesh.material.texture = tex;
    var totalFrames = 3;
    var frameShader = new FrameShader(tex, totalFrames, 12.5);

    billb.mesh.material.mainPass.addShader(frameShader);
    var mesh = body.toMesh();
  }

  override function update() {
    super.update();
  }
}