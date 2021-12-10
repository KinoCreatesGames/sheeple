package en3d.blocks;

import shaders.ToonShader;
import shaders.PixelShader;
import shaders.Outline3D;
import h3d.prim.Cube;
import h3d.mat.Pass;
import dn.heaps.filter.PixelOutline;
import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * A block in the game for the player to stand on
 * or push around using a unit length cube.
 */
class StdBlock extends Block {
  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }

  override public function setBody(prim:Primitive, root:Object, ?lightDir) {
    var model = cache.loadModel(hxd.Res.models.block);
    // var mesh = new h3d.scene.Mesh(prim, null, root);
    // var obj = lib.makeObject();
    // lib.loadAnimation();
    // mesh.material.color.setColor(0xaaaaaa);
    // mesh.material.shadows = false;
    model.getMaterials().iter((mat) -> {
      mat.shadows = false;
      if (lightDir != null) {
        // trace('add shader');
        var shader = new ToonShader(mat.texture, lightDir);
        shader.depthT = untyped Boot.ME.s3d.renderer.depthTex;
        mat.mainPass.addShader(shader);
      }
    });
    root.addChild(model);
    body = model;
    // var shader = new Outline3D();
    // mesh.material.blendMode = Alpha;
    // shader.outlineColor = hxsl.Types.Vec.fromColor(0xaa);

    // mesh.material.mainPass.addShader(shader);
  }

  override function update() {
    super.update();
    if (!cd.has('checkEdges')) {
      handleEdges();
    }
  }
}