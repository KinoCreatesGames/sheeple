package scn;

import h3d.Vector;
import GameTypes.LvlState;
import en3d.collectibles.Collectible;
import en3d.blocks.Block;
import en3d.Player3D;

class Level3D extends Process3D {
  /** Level grid-based width**/
  public var cWid(get, never):Int;

  inline function get_cWid()
    return 16;

  /** Level grid-based height **/
  public var cHei(get, never):Int;

  inline function get_cHei()
    return 16;

  /** Level pixel width**/
  public var pxWid(get, never):Int;

  inline function get_pxWid()
    return cWid * Const.GRID;

  /** Level pixel height**/
  public var pxHei(get, never):Int;

  inline function get_pxHei()
    return cHei * Const.GRID;

  var invalidated = true;

  public var player:en3d.Player3D;

  public var blockGroup:Group<Block>;
  public var collectibles:Group<Collectible>;

  /**
   * Stack used for holding all of the level information.
   * Maximum size of 10.
   */
  public var stateStack:Array<LvlState>;

  /**
   * Score for the current level.
   * Gets updated as time goes on during the level.
   * Initialized at 0.
   */
  public var score:Int = 0;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    create3Root(Game.ME.root3D);
    // Create level root
    createTest();
    createGroups();
    createEntities();

    // On level Creation setup camera controller
    new h3d.scene.CameraController(null, root3).loadFromCamera();
  }

  /**
   * Creates the groups of 
   * elements that will appear within the game.
   */
  public function createGroups() {
    stateStack = [];
    blockGroup = new Group<Block>();
    collectibles = new Group<Collectible>();
  }

  public function createTest() {
    // Create Cube
    var prim = new h3d.prim.Cube();
    prim.translate(-0.5, -0.5, -0.5);
    prim.unindex();
    prim.addNormals();
    prim.addUVs();
    // Create second cube
    var mesh = new h3d.scene.Mesh(prim, root3);
    mesh.material.color.setColor(0xff00ff);
    mesh.material.shadows = false;
    // mesh.z = 0.7;
    // mesh.y = 2;
    // adds a directional light to the scene
    var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0.5, 0.5, -0.5),
      root3);
    light.enableSpecular = true;

    // set the ambient light to 30%
    // s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);

    // Boot.ME.s3d.lightSystem..set(0.3, 0.3, 0.3);
  }

  public function createEntities() {
    player = new en3d.Player3D(0, 11, 6, root3);

    // base primitive for all blocks
    var prim = new h3d.prim.Cube();
    prim.translate(-0.5, -0.5, -0.5);
    prim.unindex();
    prim.addNormals();
    prim.addUVs();

    // Create test blocks for collision checks
    for (z in 0...5) {
      for (i in 0...20) {
        for (y in 0...20) {
          var block = new Block(i, y - z, z);
          block.setBody(prim, root3);
          blockGroup.add(block);
        }
      }
    }

    for (z in 5...9) {
      for (i in 0...10) {
        for (y in 0...10) {
          var block = new Block(i, y, z);
          block.setBody(prim, root3);
          blockGroup.add(block);
        }
      }
    }
  }

  /** TRUE if given coords are in level bounds **/
  public inline function isValid(cx, cy)
    return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

  /** Gets the integer ID of a given level grid coord **/
  public inline function coordId(cx, cy)
    return cx + cy * cWid;

  /** Ask for a level render that will only happen at the end of the current frame. **/
  public inline function invalidate() {
    invalidated = true;
  }

  // Level Collissions

  /**
   * Collects the entity that we collided with using the 
   * 3D grid coordinates to locate them.
   * @param x 
   * @param y 
   * @param z 
   */
  public function levelCollided(x:Int, y:Int, z:Int) {
    return blockGroup.members.filter((block) -> block.isAlive()
      && block.cx == x
      && block.cy == y
      && block.cz == z)
      .first();
  }

  /**
   * Returns the first collectible that is collided with on the current
   * level. Only Collides with the ones that are currently alive.
   * @param x 
   * @param y 
   * @param z 
   */
  public function collectibleCollided(x:Int, y:Int, z:Int) {
    return collectibles.members.filter((collectible) -> collectible.isAlive()
      && collectible.cx == x && collectible.cy == y && collectible.cz == z)
      .first();
  }

  function render() {
    // Placeholder level render
    root.removeChildren();
    // for (cx in 0...cWid)
    //   for (cy in 0...cHei) {
    //     var g = new h2d.Graphics(root);
    //     if (cx == 0
    //       || cy == 0
    //       || cx == cWid - 1
    //       || cy == cHei - 1) g.beginFill(0xffcc00); else
    //       g.beginFill(Color.randomColor(rnd(0, 1), 0.5, 0.4));
    //     g.drawRect(cx * Const.GRID, cy * Const.GRID, Const.GRID, Const.GRID);
    //   }
  }

  /**
   * Triggers an undo within the game
   * and puts you back to the last state of the game
   * that we have access to.
   */
  public function triggerUndo() {
    var oldState = stateStack.pop();
    // Update all positions after getting previous state
    if (oldState != null) {
      var oldP = oldState.playerPos;
      player.cx = Std.int(oldP.x);
      player.cy = Std.int(oldP.y);
      player.cz = Std.int(oldP.z);

      // Update the position of all the blocks to their
      // previous versions
      for (i in 0...oldState.blockPositions.length) {
        var block = blockGroup.members[i];
        var bPos = oldState.blockPositions[i];
        block.cx = Std.int(bPos.x);
        block.cy = Std.int(bPos.y);
        block.cz = Std.int(bPos.z);
      }
    }
  }

  /**
   * Creates a new state when the player makes 
   * some move within the game.
   */
  public function pushState() {
    var state:LvlState = {
      playerPos: new Vector(player.cx, player.cy, player.cz),
      blockPositions: blockGroup.members.map((block) -> new Vector(block.cx,
        block.cy, block.cz))
    }
    stateStack.push(state);
  }

  override function update() {
    super.update();
    handleGameOver();
  }

  public function handleGameOver() {
    if (!player.isAlive()) {
      // Start Game Over Scene and conditions
    }
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  override function onDispose() {
    // Remove all entities
    player.destroy();

    // Destroy blocks
    for (block in blockGroup) {
      block.destroy();
    }

    // Destroy Collectibles
    for (collectible in collectibles) {
      collectible.destroy();
    }
    super.onDispose();
  }
}