package en;

class IsoEntity extends Entity {
  /**
   * Turns a position into iso coordinates
   * to properly represent the position on screen.
   * translate x = x * 1  y * 0.5
   * @param x 
   * @param y 
   */
  public function toIso(x:Float, y:Float) {
    return {
      x: (x * 1) + (y * -1),
      y: (x * 0.5) + (y * 0.5)
    };
  }

  /**
   * Turns a position back into regular coordinates 
   * from the iso coordinates.
   * @param x 
   * @param y 
   */
  public function fromIso(x:Float, y:Float) {}

  override function postUpdate() {
    // Adjusts the sprite coordinates with the iso
    var isoRes = toIso((cx + xr) * Const.GRID, (cy + yr) * Const.GRID);
    spr.x = isoRes.x;
    spr.y = isoRes.y;

    spr.scaleX = dir * sprScaleX * sprSquashX;
    spr.scaleY = sprScaleY * sprSquashY;
    spr.visible = entityVisible;

    // Squash and Stretch snap back in the update loop
    sprSquashX += (1 - sprSquashX) * M.fmin(1, 0.2 * tmod);
    sprSquashY += (1 - sprSquashY) * M.fmin(1, 0.2 * tmod);

    // Blinking Controls
    if (!cd.has('keepBlink')) {
      blinkColor.r *= Math.pow(0.60, tmod);
      blinkColor.g *= Math.pow(0.55, tmod);
      blinkColor.b *= Math.pow(0.50, tmod);
    }

    // Color adds
    spr.colorAdd.load(baseColor);
    spr.colorAdd.r += blinkColor.r;
    spr.colorAdd.g += blinkColor.g;
    spr.colorAdd.b += blinkColor.b;

    if (debugLabel != null) {
      debugLabel.x = Std.int(footX - debugLabel.textWidth * 0.5);
      debugLabel.y = Std.int(footY + 1);
    }
  }

  // override public function update() { // runs at an unknown fps
  //   // X
  //   var steps = M.ceil(M.fabs(dxTotal * tmod));
  //   var step = dxTotal * tmod / steps;
  //   while (steps > 0) {
  //     xr += step;
  //     // [ add X collisions checks here ]
  //     while (xr > 1) {
  //       xr--;
  //       cx++;
  //     }
  //     while (xr < 0) {
  //       xr++;
  //       cx--;
  //     }
  //     steps--;
  //   }
  //   dx *= Math.pow(frictX, tmod);
  //   bdx *= Math.pow(bumpFrict, tmod);
  //   if (M.fabs(dx) <= 0.0005 * tmod) dx = 0;
  //   if (M.fabs(bdx) <= 0.0005 * tmod) bdx = 0;
  //   // Y
  //   var steps = M.ceil(M.fabs(dyTotal * tmod));
  //   var step = dyTotal * tmod / steps;
  //   while (steps > 0) {
  //     yr += step;
  //     // [ add Y collisions checks here ]
  //     while (yr > 1) {
  //       yr--;
  //       cy++;
  //     }
  //     while (yr < 0) {
  //       yr++;
  //       cy--;
  //     }
  //     steps--;
  //   }
  //   dy *= Math.pow(frictY, tmod);
  //   bdy *= Math.pow(bumpFrict, tmod);
  //   if (M.fabs(dy) <= 0.0005 * tmod) dy = 0;
  //   if (M.fabs(bdy) <= 0.0005 * tmod) bdy = 0;
  // }
}