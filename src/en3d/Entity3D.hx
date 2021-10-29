package en3d;

import scn.Level3D;

/**
 * A entity class for making 3D elements in
 * Heaps for the next game.
 */
class Entity3D {
  /**
   * All 3d entities in the game.
   */
  public static var ALL:Array<Entity3D> = [];

  /**
   * All garbage collected 3d entities in the game.
   */
  public static var GC:Array<Entity3D> = [];

  // Various getters to access all important stuff easily
  public var game(get, never):Game;

  public inline function get_game() {
    return Game.ME;
  }

  public var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  public var level(get, never):Level3D;

  public inline function get_level() {
    return Game.ME.level;
  }

  public var destroyed(default, null) = false;
  public var ftime(get, never):Float;

  public inline function get_ftime() {
    return game.ftime;
  }

  /**
   * Fractional element of the amount of time
   * between frames. 
   * If the game is running at 60 fps then this would
   * be 1, but if the game is running at 120 FPS this would be
   * 0.5.
   */
  public var tmod(get, never):Float;

  public inline function get_tmod() {
    return Game.ME.tmod;
  }

  /**
   * In game HUD element available through the UI.
   */
  public var hud(get, never):ui.Hud;

  public inline function get_hud() {
    return Game.ME.hud;
  }

  /** Cooldowns **/
  public var cd:dn.Cooldown;

  /** Unique identifier **/
  public var uid(default, null):Int;

  // Physics and World Positions
  // Position in the game world
  public var cx = 0;
  public var cy = 0;
  public var cz = 0;
  public var xr = 0.5;
  public var yr = 1.0;
  public var zr = 0.5;

  // Velocities
  public var dx = 0.;
  public var dy = 0.;
  public var dz = 0.;

  // Uncontrollable bump velocities, usually applied by external
  // factors (think of a bumper in Sonic for example)
  public var bdx = 0.;
  public var bdy = 0.;
  public var bdz = 0.;

  // Frictions
  // Multipliers applied on each frame to normal velocities
  public var frictX = 0.82;
  public var frictY = 0.82;
  public var frictZ = 0.82;

  // Actions
  var actions:Array<{id:String, cb:Void -> Void, t:Float}> = [];

  /**
   * 3D entity class that 
   * @param x 
   * @param y 
   * @param z 
   */
  public function new(x:Int, y:Int, z:Int) {
    // Generates a custom id with a virtual property
    uid = Const.NEXT_UNIQ;
    ALL.push(this);
  }

  /**
   * Kills the entity and destroys it.
   * @param by 
   */
  public function kill(by:Null<Entity3D>) {
    destroy();
  }

  // Velocity and Positional Calculations

  /**
   * Sets the position of the element along with the 
   * approximates for both sides in the game.
   * @param x 
   * @param y 
   * @param z 
   */
  public function setPosCase(x:Int, y:Int, z:Int) {
    cx = x;
    cy = y;
    cz = z;
    xr = 0.5;
    yr = 1;
    zr = 0.5;
  }

  /**
   * Cancels the velocities on all three axis.
   */
  public function cancelVelocities() {
    dx = bdx = 0;
    dy = bdy = 0;
    dz = bdy = 0;
  }

  public inline function destroy() {
    if (!destroyed) {
      destroyed = true;
      GC.push(this);
    }
  }

  /**
   * Disposes the entity and removes it from the list
   * of available entities.
   */
  public function dispose() {
    ALL.remove(this);

    cd.destroy();
    cd = null;
  }

  public inline function isAlive() {
    return !destroyed;
  }

  public function chargeAction(id:String, sec:Float, cb:Void -> Void) {
    if (isChargingAction(id)) cancelAction(id);
    if (sec <= 0) cb(); else
      actions.push({id: id, cb: cb, t: sec});
  }

  public function isChargingAction(?id:String) {
    if (id == null) return actions.length > 0;

    for (a in actions)
      if (a.id == id) return true;

    return false;
  }

  public function cancelAction(?id:String) {
    if (id == null) actions = []; else {
      var i = 0;
      while (i < actions.length) {
        if (actions[i].id == id) actions.splice(i, 1); else
          i++;
      }
    }
  }

  function updateActions() {
    var i = 0;
    while (i < actions.length) {
      var a = actions[i];
      a.t -= tmod / Const.FPS;
      if (a.t <= 0) {
        actions.splice(i, 1);
        if (isAlive()) a.cb();
      } else
        i++;
    }
  }

  public function preUpdate() {
    cd.update(tmod);
    updateActions();
  }

  public function postUpdate() {}

  /**
   * Runs at a guaranteed 30 FPS.
   */
  public function fixedUpdate() {}

  /**
   * Runs at an unknown FPS.
   * Use tmod in order to make sure that your 
   * values are scaled to match the desired FPS.
   */
  public function update() {}
}