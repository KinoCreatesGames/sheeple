package en3d.collectibles;

import shaders.FrameShader;
import en3d.Billboard;
import h3d.scene.Object;
import h3d.prim.Primitive;

class Shard extends Collectible {
  public var billB:Billboard;

  override function setBody(prim:Primitive, root:Object) {
    billB = new Billboard(root, cx, cy, cz);
    body = billB.mesh;
    var tex = hxd.Res.img.shard_Sheet.toTexture();
    var totalFrames = 5;
    var frameShader = new FrameShader(tex, totalFrames, 6.56);

    billB.mesh.material.mainPass.addShader(frameShader);
  }

  override function update() {
    super.update();
  }
}