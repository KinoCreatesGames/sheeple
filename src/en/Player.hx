package en;

import dn.heaps.Controller.ControllerAccess;

class Player extends IsoEntity {
  public var ct:ControllerAccess;

  public static inline var MOVE_SPD:Int = 1;

  public function new(x:Int, y:Int) {
    super(x, y);
    setup();
    Game.ME.invalidateHud();
  }

  public function setup() {
    ct = Main.ME.controller.createAccess('player');
    setSprite();
  }

  public function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0x0000ff);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    g.x -= 8;
    g.y -= 16;
  }

  override function update() {
    super.update();
    updateControls();
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

  public function canMove(x:Int = 0, y:Int = 0) {
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