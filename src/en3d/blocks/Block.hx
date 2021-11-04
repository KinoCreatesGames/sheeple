package en3d.blocks;

import h3d.prim.Primitive;
import h3d.scene.Object;

/**
 * A block in the game for the player to stand on
 * or push around using a unit length cube.
 */
class Block extends IsoEntity3D {
  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }

  public function setBody(prim:Primitive, root:Object) {
    var mesh = new h3d.scene.Mesh(prim, null, root);
    mesh.material.color.setColor(0xaaaaaa);
    mesh.material.shadows = false;
    body = mesh;
  }

  override function update() {
    super.update();
    if (!cd.has('checkEdges')) {
      handleEdges();
    }
  }

  /**
   * Causes huge performance dip
   */
  public function handleEdges() {
    var hasAdjacentBlock = [
      level.levelCollided(cx - 1, cy, cz - 1),
      level.levelCollided(cx + 1, cy, cz - 1),
      level.levelCollided(cx, cy + 1, cz - 1),
      level.levelCollided(cx, cy - 1, cz - 1)
    ].exists(el -> el != null);
    var belowBlock = level.levelCollided(cx, cy, cz - 1);

    if (cz == 0 || belowBlock != null || hasAdjacentBlock) {} else {
      // Fall down
      cz -= 1;
    }
    cd.setF('checkEdges', 120);
  }
}