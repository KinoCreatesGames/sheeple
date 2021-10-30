package en3d;

import h3d.scene.Object;
import h3d.prim.Cube;
import dn.heaps.Controller.ControllerAccess;

class Player3D extends IsoEntity3D {
  public var ct:ControllerAccess;
  public var stepCount:Int = 0;

  public static inline var MOVE_SPD:Int = 1;

  public function new(x:Int, y:Int, z:Int, root) {
    super(x, y, z);
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
    updateControls();
    processFall();
  }

  public function processFall() {
    var belowBlock = level.levelCollided(cx, cy, cz - 1);
    if (belowBlock != null) {
      // do nothing
    } else {
      cz -= 1; // Fall
    }
  }

  public function updateControls() {
    var hasInput = (ct.leftPressed()
      || ct.rightPressed()
      || ct.downPressed()
      || ct.upPressed());

    if (hasInput) {
      if (ct.leftPressed() && canMove(cx - MOVE_SPD, cy)) {
        cx -= MOVE_SPD;
      } else if (ct.rightPressed() && canMove(cx + MOVE_SPD, cy)) {
        cx += MOVE_SPD;
      } else if (ct.downPressed() && canMove(cx, cy + MOVE_SPD)) {
        cy += MOVE_SPD;
      } else if (ct.upPressed() && canMove(cx, cy - MOVE_SPD)) {
        cy -= MOVE_SPD;
      } else {
        Game.ME.camera.shakeS(0.5, 1);
      }
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
    // Used for checking if the player should fall later
    var belowBlock = level.levelCollided(x, y, cz - 1);
    // Block at same level  in next cell && one above
    if (block != null) {
      #if debug
      trace('collided with block');
      #else
      #end
      if (topBlock != null) {
        return false;
      } else {
        #if debug
        trace('collided with free space');
        #else
        #end
        cz += 1;
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