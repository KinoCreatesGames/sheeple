package en3d.blocks;

class EditorBlock extends Block {
  /**
   * Causes huge performance dip
   */
  override public function handleEdges() {
    var hasAdjacentBlock = [
      level.levelCollided(cx - 1, cy, cz - 1),
      level.levelCollided(cx + 1, cy, cz - 1),
      level.levelCollided(cx, cy + 1, cz - 1),
      level.levelCollided(cx, cy - 1, cz - 1)
    ].exists(el -> el != null);
    var belowBlock = level.levelCollided(cx, cy, cz - 1);

    if (cz == 0 || belowBlock != null || hasAdjacentBlock) {} else {
      // Fall down
      //   cz -= 1;
    }
    cd.setF('checkEdges', 120);
  }
}