package scn;

import h3d.prim.ModelCache;
import en3d.blocks.StdBlock;
import en3d.blocks.CrackedBlock;
import h3d.prim.Sphere;
import h3d.shader.CubeMap;
import h3d.scene.Mesh;
import h3d.mat.Texture;
import en3d.blocks.EditorBlock;
import en3d.blocks.MysteryBlock;
import en3d.blocks.HeavyBlock;
import en3d.blocks.BlackHole;
import en3d.blocks.StaticBlock;
import en3d.blocks.Spike;
import en3d.blocks.Goal;
import en3d.blocks.IceBlock;
import en3d.blocks.Bounce;
import GameTypes.BlockType;
import h3d.prim.Cube;
import h3d.scene.Scene;
import h3d.Vector;
import GameTypes.LvlState;
import en3d.collectibles.Collectible;
import en3d.blocks.Block;

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

  /**
   * The default scene object
   * within the Heaps application.
   */
  public var s3d(get, never):Scene;

  public inline function get_s3d() {
    return Boot.ME.s3d;
  }

  var invalidated = true;

  public var player:en3d.Player3D;

  /**
   * Player starting position.
   * Used to determine where the player
   * has gone compared to the top of the tower.
   */
  public var playerStartPos:Vector;

  public var blockGroup:Group<Block>;
  public var collectibles:Group<Collectible>;

  public var camera(get, never):h3d.Camera;

  // TODO: Add plane for the levels
  public inline function get_camera() {
    return Boot.ME.s3d.camera;
  }

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

  /**
   * High score for the current level.
   * Gets updated as the time goes on during the level.
   * Initialized at 0.
   */
  public var highScore:Int = 0;

  public var blockPrim:Cube;

  public var cache:ModelCache;

  /**
   * A Cube mesh for showing where the 
   * selection cursor is on screen.
   * Strictly for the editor integration.
   */
  public var editorBlock:Block;

  public var editorBlockTween:Tweenie;
  public var eBlockAlpha:Float = 1;
  public var eTween:Tween;

  var skyTexture:h3d.mat.Texture;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    create3Root(Game.ME.root3D);

    blockPrim = new h3d.prim.Cube();
    blockPrim.translate(-0.5, -0.5, -0.5);
    blockPrim.unindex();
    blockPrim.addNormals();
    blockPrim.addUVs();
    // Create level root
    setupLight();
    createSkyBox();
    createGroups();
    createEditorElements();
    createEntities();

    // Update Camera
    camera.target.set(player.body.x, player.body.y, player.body.z);
    camera.pos.set(20, 30, 30);
    camera.zNear = 1;
    camera.zFar = 50;

    // On level Creation setup camera controller
    new h3d.scene.CameraController(null, root3).loadFromCamera();
  }

  public function setupLight() {
    var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0.5, 0.5, -0.5),
      root3);
    light.enableSpecular = true;
  }

  public function createSkyBox() {
    skyTexture = new Texture(2048, 2048, [Cube, MipMapped]);

    // Create the Six Faces
    var tex = hxd.Res.textures;
    var faceTex = [tex.right, tex.left, tex.top, tex.bot, tex.front, tex.back];
    for (i in 0...6) {
      var face = faceTex[i].toBitmap();
      skyTexture.uploadBitmap(face, 0, i);
    }
    skyTexture.mipMap = Linear;
    var sky = new Sphere(30, 128, 128);
    sky.addNormals();
    var skyMesh = new Mesh(sky, root3);
    skyMesh.material.mainPass.culling = Front;
    skyMesh.material.mainPass.addShader(new CubeMap(skyTexture));
    skyMesh.material.shadows = false;
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

  public function createEditorElements() {
    editorBlock = new EditorBlock(0, 0, 0);
    editorBlock.setBody(blockPrim, root3);
    var mesh = editorBlock.body.toMesh();
    mesh.material.color.setColor(0xa1ff01);
    mesh.material.blendMode = Alpha;
    mesh.material.shadows = false;
    editorBlock.body.visible = false;
    editorBlockTween = new Tweenie(Const.FPS);
    eTween = editorBlockTween.createS(eBlockAlpha, 0.5, TLoop, 1.5);
    eTween.plays = -1; // Plays the tween for infinity
  }

  public function createEntities() {
    player = new en3d.Player3D(0, 11, 5, root3);
    playerStartPos = new Vector(player.cx, player.cy, player.cz);

    // base primitive for all blocks
    var prim = new h3d.prim.Cube();
    prim.translate(-0.5, -0.5, -0.5);
    prim.unindex();
    prim.addNormals();
    prim.addUVs();

    // Create test blocks for collision checks
    cache = new h3d.prim.ModelCache();
    for (z in 0...5) {
      for (i in 0...20) {
        for (y in 0...20) {
          var block = new StdBlock(i, y - z, z);
          block.cache = cache;
          block.setBody(prim, root3);
          blockGroup.add(block);
        }
      }
    }

    for (z in 5...9) {
      for (i in 0...10) {
        for (y in 0...10) {
          var block = new StdBlock(i, y, z);
          block.cache = cache;
          block.setBody(prim, root3);
          blockGroup.add(block);
        }
      }
    }
    // cache.dispose();
  }

  public function createBlock(blockType:BlockType, x:Int, y:Int, z:Int) {
    var block:Block = null; // new Block(x, y, z);
    switch (blockType) {
      case BlockB:
        block = new Block(x, y, z);
      case BounceB:
        block = new Bounce(x, y, z);
      case CrackedB:
        block = new CrackedBlock(x, y, z);
      case IceB:
        block = new IceBlock(x, y, z);

      case StaticB:
        block = new StaticBlock(x, y, z);

      case GoalB:
        block = new Goal(x, y, z);

      case SpikeB:
        block = new Spike(x, y, z);

      case BlackHoleB:
        block = new BlackHole(x, y, z);

      case HeavyB:
        block = new HeavyBlock(x, y, z);
      case MysteryB:
        block = new MysteryBlock(x, y, z);
    }
    block.cache = cache;
    // Set body
    block.setBody(blockPrim, root3);
    // block.body.toMesh().material.color.setColor(0xaa00aa);
    blockGroup.add(block);
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
   * some move within the game. Pushes the latest
   * state into the state stack.
   */
  public function pushState() {
    var state:LvlState = {
      playerPos: new Vector(player.cx, player.cy, player.cz),
      blockPositions: blockGroup.members.map((block) -> new Vector(block.cx,
        block.cy, block.cz))
    }
    stateStack.push(state);
  }

  /**
   * Clears all the level elements such
   * as the blocks.
   */
  public function clearLevel() {
    for (block in blockGroup) {
      block.destroy();
    }
    blockGroup.clear();

    for (collectible in collectibles) {
      collectible.destroy();
    }
    collectibles.clear();
  }

  /**
   * Marks the level as complete and starts the level complete
   * transition.
   */
  public function completeLevel() {}

  override function update() {
    super.update();
    handleEditor();
    handlePause();
    handleGameOver();
  }

  public function handleEditor() {
    if (game.ca.isKeyboardPressed(K.E)) {
      // Show the Editor
      game.showEditor();

      // player.paus
      // this.pause();
    }
    if (game.editor.flow.visible) {
      editorBlockTween.update();
      // trace(eBlockAlpha);
      var material = editorBlock.body.toMesh().material;
      // Blend mode needs to be applied for the alpha channel to be used.
      material.color.set(material.color.x, material.color.y, material.color.z,
        eBlockAlpha);
    }
  }

  public function handlePause() {
    // Pause
    if (game.ca.isKeyboardPressed(K.ESCAPE)) {
      // hxd.Res.sound.pause_in.play(); - issue playing sound now
      // bgm.pause = true;
      this.pause();
      new Pause();
    }
  }

  public function handleGameOver() {
    if (!player.isAlive()) {
      // Start Game Over Scene and conditions
      this.pause();
      new GameOver();
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

    // Remove Editor Block
    editorBlock.destroy();

    // Destroy blocks
    for (block in blockGroup) {
      block.destroy();
    }

    // Destroy Collectibles
    for (collectible in collectibles) {
      collectible.destroy();
    }
    cache.dispose();
    super.onDispose();
  }
}