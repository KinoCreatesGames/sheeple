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

  public function startSpike() {
    cd.setS('spikeActivate', 0.5, () -> {
      if (level != null) {
        if (level.player != null) {
          var player = level.player;
          if (player.cx == cx && player.cy == cy && player.cz == (cz + 1)) {
            // Kill them
            player.kill(this);
          }
        }
      }
    });
  }
}