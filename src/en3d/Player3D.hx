package en3d;

import en3d.collectibles.Shard;
import en3d.collectibles.Checkpoint;
import en3d.blocks.Spike;
import en3d.blocks.BlackHole;
import en3d.blocks.Bounce;
import en3d.blocks.IceBlock;
import en3d.blocks.Goal;
import en3d.blocks.Block;
import h3d.scene.Object;
import h3d.prim.Cube;
import dn.heaps.Controller.ControllerAccess;

enum abstract PState(String) from String to String {
  var HANG = 'hanging';
  var STAND = 'standing';
  var PULL = 'pull';
  var PUSH = 'push';
  var FALL = 'fall';
}

enum abstract BDir(String) from String to String {
  var LEFT = 'left';
  var RIGHT = 'right';
  var DOWN = 'down';
  var UP = 'up';
}

class Player3D extends IsoEntity3D {
  public var ct:ControllerAccess;
  public var stepCount:Int = 0;

  /**
   * The amount of steps you've gone up without stopping.
   * Based on the step combo timer.
   */
  public var stepCombo:Int = 0;

  public var pstate:PState;
  public var blockDir:BDir;
  public var moveComplete:Bool;

  public static inline var MOVE_SPD:Int = 1;

  /**
   * The amount to lerp by when the player moves to the next
   * tile.
   */
  public static inline var MOVE_DT:Float = 0.1;

  public static inline var BOUNCE_HEIGHT:Int = 4;

  /**
   * The shard score amount. 
   * The amount you get for collecting a 
   * shard.
   */
  public static inline var SHARD_SCORE:Int = 100;

  /**
   * Amount of time to wait before resetting the 
   * combo to 0.
   */
  public static inline var STEP_TIMER:Int = 3;

  /**
   * The amount to move in the Z aspect.
   */
  public var moveZ:Int = 0;

  /**
   * The current block that is being grabbed currently
   */
  public var heldBlock:Block;

  public var mvTween:Tweenie;

  public function new(x:Int, y:Int, z:Int, root) {
    super(x, y, z);
    pstate = STAND;
    moveComplete = true;
    mvTween = new Tweenie(Const.FPS);
    setup();
    hud.invalidate();
    setBody(root);
  }

  public function setup() {
    ct = Main.ME.controller.createAccess('player');
  }

  public function setBody(root:Object) {
    var prim = new Cube();
    prim.translate(-0.5, -0.5, -0.5);
    prim.unindex();
    prim.addNormals();
    prim.addUVs();

    var mesh = new h3d.scene.Mesh(prim, null, root);
    mesh.material.color.setColor(0xffffff);
    mesh.material.shadows = false;
    body = mesh;
  }

  override function update() {
    super.update();
    mvTween.update();
    handleUndo();
    updateControls();
    handleBlockCollision();
    handleCollectibleCollision();
    handleHanging();
    processFall();
  }

  public function handleUndo() {
    if (level != null && ct.bPressed()) {
      level.triggerUndo();
    }
  }

  /**
   * Handles block collisions beneath your feet.
   * If you encounter a bounce block for example,
   * you will be boosted into the air.
   */
  public function handleBlockCollision() {
    if (level != null) {
      // Handle collided with certain blocks
      var block = level.levelCollided(cx, cy, cz - 1);
      if (block != null) {
        var blockType = Type.getClass(block);
        switch (blockType) {
          case Goal:
            level.completeLevel();
          case IceBlock:
          // Player will slip and
          // continue moving in the current direction
          case Bounce:
            // Start  player bouncing by adding velocity
            this.cz += BOUNCE_HEIGHT;
          case BlackHole:
            // Delete the player aka kill the player
            this.kill(block);
          case Spike:
            // Start spike activation
            var spike:Spike = cast block;
            spike.startSpike();
          case _:
            // Do nothing
        }
      }
    }
  }

  public function handleCollectibleCollision() {
    if (level != null) {
      var collectible = level.collectibleCollided(cx, cy, cz);
      if (collectible != null) {
        var collectibleType = Type.getClass(collectible);
        switch (collectibleType) {
          case Checkpoint:
            // Save Position
            if (level != null) {
              // Let player checkpoint being marked.
              level.checkpointPosition.set(collectible.cx, collectible.cy,
                collectible.cz);
              level.reachedCheckPos = true;
              level.saveCheckpoint();
            }
            hxd.Res.sound.Level_Up.play(false, 0.7);
            collectible.kill(this);
          case Shard:
            // Update the level score
            level.score += SHARD_SCORE;
            collectible.kill(this);
          case _:
            // Kill the collectible
            collectible.kill(this);
        }
      }
    }
  }

  public function handleHanging() {
    var belowBlock = level.levelCollided(cx, cy, cz - 2);
    // Block at same level  in next cell && one above
    // check adjacent blocks as well
    var hasAdjacentBlock = [
      level.levelCollided(cx - 1, cy, cz),
      level.levelCollided(cx + 1, cy, cz),
      level.levelCollided(cx, cy + 1, cz),
      level.levelCollided(cx, cy - 1, cz)
    ].exists((el) -> el != null);
    if (belowBlock == null && hasAdjacentBlock) {
      // Nothing below you on moving to the next area
      // Set the user to hang at this point

      pstate = HANG;
    } else if (belowBlock == null && !hasAdjacentBlock) {
      pstate = FALL;
    }
  }

  public function processFall() {
    var belowBlock = level.levelCollided(cx, cy, cz - 1);
    if (belowBlock != null) {
      // do nothing
    } else {
      if (pstate != HANG) {
        cz -= 1; // Fall
      }
    }
  }

  public function updateControls() {
    var hasInput = (ct.leftDown()
      || ct.rightDown()
      || ct.downDown()
      || ct.upDown()
      || ct.aDown())
      && moveComplete;
    var xAxis = false;
    var yAxis = false;

    if (hasInput) {
      var tempCX = cx * 1;
      var tempCY = cy * 1;
      // Block Push / Pull Button
      if (ct.aDown()) {
        // Grab adjacent block for push / pull

        var dirX = getDirX();
        var dirY = getDirY();

        var adjacentBlock = level.levelCollided(cx + dirX, cy + dirY, cz);
        if (adjacentBlock == null) {
          adjacentBlock = [
            level.levelCollided(cx - 1, cy, cz),
            level.levelCollided(cx + 1, cy, cz),
            level.levelCollided(cx, cy + 1, cz),
            level.levelCollided(cx, cy - 1, cz)
          ].filter((el) -> el != null).first();
        }

        if (adjacentBlock != null) {
          heldBlock = adjacentBlock;
        }
      }

      if (heldBlock == null) {
        if (ct.leftPressed()) {
          blockDir = LEFT;
        } else if (ct.rightPressed()) {
          blockDir = RIGHT;
        } else if (ct.downPressed()) {
          blockDir = DOWN;
        } else if (ct.upPressed()) {
          blockDir = UP;
        }
      }
      if (ct.leftDown() && canMove(cx - MOVE_SPD, cy)) {
        // cx -= MOVE_SPD;
        moveComplete = false;
        var t = mvTween.createS(xr, -0.5, TEase, MOVE_DT);
        t.end(() -> {
          setPosCase(M.floor(cx + xr), cy, cz + moveZ);
          moveComplete = true;
        });
      } else if (ct.rightDown() && canMove(cx + MOVE_SPD, cy)) {
        // cx += MOVE_SPD;
        moveComplete = false;
        var t = mvTween.createS(xr, 1.5, TEase, MOVE_DT);
        t.end(() -> {
          setPosCase(cx + 1, cy, cz + moveZ);
          moveComplete = true;
        });
      } else if (ct.downDown() && canMove(cx, cy + MOVE_SPD)) {
        moveComplete = false;
        var t = mvTween.createS(yr, 2, TEase, MOVE_DT);
        t.end(() -> {
          setPosCase(cx, cy + 1, cz + moveZ);
          moveComplete = true;
        });
      } else if (ct.upDown() && canMove(cx, cy - MOVE_SPD)) {
        // cy -= MOVE_SPD;

        moveComplete = false;
        var t = mvTween.createS(yr, 0, TEase, MOVE_DT);
        t.end(() -> {
          setPosCase(cx, cy - 1, cz + moveZ);
          moveComplete = true;
        });
      } else {
        Game.ME.camera.shakeS(0.5, 1);
      }
      // Update block Pull
      if (heldBlock != null) {
        var xAxis = heldBlock.cx == cx;
        var yAxis = heldBlock.cy == cy;
        var movedBlock = false;
        var tweenBlock = heldBlock;
        if (yAxis) {
          if (ct.leftPressed()) {
            // heldBlock.cx -= MOVE_SPD;
            var t = mvTween.createS(tweenBlock.xr, -0.5, TEase, MOVE_DT);
            t.end(() -> {
              tweenBlock.setPosCase(tweenBlock.cx - 1, tweenBlock.cy,
                tweenBlock.cz);
            });
            movedBlock = true;
          } else if (ct.rightPressed()) {
            // heldBlock.cx += MOVE_SPD;
            var t = mvTween.createS(tweenBlock.xr, 1.5, TEase, MOVE_DT);
            t.end(() -> {
              tweenBlock.setPosCase(tweenBlock.cx + 1, tweenBlock.cy,
                tweenBlock.cz);
            });
            movedBlock = true;
          }
        }
        if (xAxis) {
          if (ct.downPressed()) {
            // heldBlock.cy += MOVE_SPD;
            var t = mvTween.createS(tweenBlock.yr, 2, TEase, MOVE_DT);
            t.end(() -> {
              tweenBlock.setPosCase(tweenBlock.cx, tweenBlock.cy + 1,
                tweenBlock.cz);
            });
            movedBlock = true;
          } else if (ct.upPressed()) {
            // heldBlock.cy -= MOVE_SPD;
            var t = mvTween.createS(tweenBlock.yr, 0, TEase, MOVE_DT);
            t.end(() -> {
              tweenBlock.setPosCase(tweenBlock.cx, tweenBlock.cy - 1,
                tweenBlock.cz);
            });
            movedBlock = true;
          }
        }
        if (movedBlock && level != null) {
          level.pushState();
        }
        // block.cx += cx - tempCX;
        // block.cy += cy - tempCY;

        heldBlock = null;
      }
      // Updates the step count only during the input of the game.
    }
  }

  public function updateStepCount() {
    if (game.hud != null) {
      // Check if the player  step increases step count
      var playerStep = Std.int(cz - Std.int(game.level.playerStartPos.z));
      if (stepCount < (playerStep)) {
        stepCount = playerStep;
        stepCombo++;
        cd.setS('stepCombo', STEP_TIMER, () -> {
          stepCombo = 0;
        });
      }
      game.invalidateHud();
    }
  }

  override function postUpdate() {
    super.postUpdate();
    updateStepCount();
    // if (xr > 1 || zr > 1 || yr > 1) {

    //   trace('${cx}, ${cy} ${cz}');
    // }
  }

  public function getDirX() {
    switch (blockDir) {
      case LEFT:
        return -1;
      case RIGHT:
        return 1;
      case _:
        return 0;
    }
  }

  public function getDirY() {
    switch (blockDir) {
      case UP:
        return -1;
      case DOWN:
        return 1;
      case _:
        return 0;
    }
  }

  /**
   * Checks if the player can move to that square.
   * Internally z is handled as it's based on the position
   * of other blocks in the area.
   * @param x 
   * @param y 
   */
  public function canMove(x:Int = 0, y:Int = 0) {
    // Blocks
    var block = level.levelCollided(x, y, cz);
    var topBlock = level.levelCollided(x, y, cz + 1);
    var pushBlock = heldBlock;
    moveZ = 0;
    // Used for checking if the player should fall later

    if (pushBlock != null && pushBlock.cx == x && pushBlock.cy == y) {
      return false;
    }

    if (block != null) {
      #if debug
      // trace('collided with block');
      #else
      #end
      if (topBlock != null) {
        return false;
      } else {
        #if debug
        // trace('collided with free space');
        #else
        #end
        // press the Z
        moveZ = 1;
        // This means we also updated the z access
        return true;
      }
    }
    // Obstacles
    // var obstacle = level.collidedObstacle(x, y);
    // if (obstacle != null) {
    //   var obstacleType = Type.getClass(obstacle);
    //   switch (obstacleType) {
    //     case en.obstacles.Tree:
    //       // check
    //       return talents.contains(CUT);
    //     case en.obstacles.Gate:
    //       return talents.contains(LOCKPICK);
    //     case _:
    //       return true;
    //   }
    // }

    // if (level.hasAnyCollision(x, y)) {
    //   hxd.Res.sound.hit_wall.play();
    //   return false;
    // }

    // if (level.hasAnyWaterCollision(x, y) && !talents.contains(SWIM)) {
    //   hxd.Res.sound.hit_wall.play();
    //   return false;
    // }

    return true;
  }
}