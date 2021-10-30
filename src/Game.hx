import en3d.Entity3D;
import h3d.scene.Object;
import scn.Level3D;
import dn.Process;
import hxd.Key;
import dn.heaps.Controller.ControllerAccess;

class Game extends dn.Process {
  public static var ME:Game;

  /** Game controller (pad or keyboard) **/
  public var ca:ControllerAccess;

  /** Particles **/
  public var fx:Fx;

  /** Basic viewport control **/
  public var camera:Camera;

  /** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
  public var scroller:h2d.Layers;

  /** Level data **/
  public var level:Level3D;

  /**
   * Top most 3D scene in the game aka
   * highest 3D root in Heaps.
   */
  public var root3D:h3d.scene.Object;

  /** UI **/
  public var hud:ui.Hud;

  /**
   * Player lives, defaults to 3 and is incremented.
   */
  public var playerLives:Int = 3;

  public function new() {
    super(Main.ME);
    ME = this;
    ca = Main.ME.controller.createAccess("game");
    ca.setLeftDeadZone(0.2);
    ca.setRightDeadZone(0.2);
    createRootInLayers(Main.ME.root, Const.DP_BG);
    // Create 3D Root
    root3D = new Object();
    Boot.ME.s3d.addChild(root3D);

    scroller = new h2d.Layers();
    root.add(scroller, Const.DP_BG);
    scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

    camera = new Camera();

    fx = new Fx();
    hud = new ui.Hud();
    hud.hide();

    startInitialGame();
    Process.resizeAll();
    trace(Lang.t._("Game is ready."));
  }

  /**
   * Starts initial game when on the Title screen.
   * Pushes to the first level.
   */
  public function startInitialGame() {
    // Play Game Loop Music
    // bgm = hxd.Res.music.juhani_stage.play(true, 0.5);
    // level = new Level(proj.all_levels.Level_0);
    level = new Level3D();

    hud.show();
    fx = new Fx();
  }

  public inline function invalidateHud() {
    if (!hud.destroyed) {
      hud.invalidate();
    }
  }

  /** CDB file changed on disk**/
  public function onCdbReload() {}

  /**
   * Called whenever LDTk file changes on disk
   */
  @:allow(Assets)
  function onLDtkReload() {
    #if debug
    trace('LDTk file reloaded');
    #else
    #end
    // reloadCurrentLevel();
  }

  // Use the below lines when using LDTk for game creation.
  // public function nextLevel(levelId:Int, startX = -1, startY = -1) {
  //   level.destroy();
  //   // var level = proj.levels[levelId];
  //   var level = proj.levels.filter((lLevel) ->
  //     lLevel.identifier.contains('Level_${levelId}'))
  //     .first();
  //   if (level != null) {
  //     startLevel(level, startX, startY);
  //   } else {
  //     #if debug
  //     trace('Cannot find level');
  //     #end
  //   }
  // }
  // public function reloadCurrentLevel() {
  //   if (level != null) {
  //     if (level.data != null) {
  //       startLevel(Assets.projData.getLevel(level.data.uid));
  //     }
  //   }
  // }
  // public function startLevel(ldtkLevel:LDTkProj_Level, startX = -1,
  //     startY = -1) {
  //   if (level != null) {
  //     level.destroy();
  //   }
  //   fx.clear();
  //   for (entity in Entity.ALL) {
  //     entity.destroy();
  //   }
  //   gc();
  //   // Create new level
  //   level = new Level(ldtkLevel, startX, startY);
  //   // Will be using the looping mechanisms
  // }

  /** Window/app resize event **/
  override function onResize() {
    super.onResize();
    scroller.setScale(Const.SCALE);
  }

  /** Garbage collect any Entity marked for destruction **/
  function gc() {
    if (Entity.GC != null) {
      for (e in Entity.GC) {
        e.dispose();
      }
      Entity.GC = [];
    }
    // Handle 3D entities
    if (Entity3D.GC != null) {
      for (e3D in Entity3D.GC) {
        e3D.dispose();
      }
      Entity3D.GC = [];
    }
  }

  /** Called if game is destroyed, but only at the end of the frame **/
  override function onDispose() {
    super.onDispose();

    fx.destroy();
    for (e in Entity.ALL) {
      e.destroy();
    }
    for (e3D in Entity3D.ALL) {
      e3D.destroy();
    }
    gc();
  }

  /** Loop that happens at the beginning of the frame **/
  override function preUpdate() {
    super.preUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.preUpdate();

    for (e3D in Entity3D.ALL) {
      if (!e3D.destroyed) {
        e3D.preUpdate();
      }
    }
  }

  /** Loop that happens at the end of the frame **/
  override function postUpdate() {
    super.postUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.postUpdate();
    for (e3D in Entity3D.ALL) {
      if (!e3D.destroyed) {
        e3D.postUpdate();
      }
    }
    gc();
  }

  /** Main loop but limited to 30fps (so it might not be called during some frames) **/
  override function fixedUpdate() {
    super.fixedUpdate();

    for (e in Entity.ALL)
      if (!e.destroyed) e.fixedUpdate();

    for (e3D in Entity3D.ALL) {
      if (!e3D.destroyed) {
        e3D.fixedUpdate();
      }
    }
  }

  /** Main loop **/
  override function update() {
    super.update();

    for (e in Entity.ALL)
      if (!e.destroyed) e.update();

    for (e3D in Entity3D.ALL) {
      if (!e3D.destroyed) {
        e3D.update();
      }
    }

    if (!ui.Console.ME.isActive() && !ui.Modal.hasAny()) {
      #if hl
      // Exit
      if (ca.isKeyboardPressed(Key.ESCAPE)) if (!cd.hasSetS("exitWarn",
        3)) trace(Lang.t._("Press ESCAPE again to exit.")); else
        hxd.System.exit();
      #end

      // Restart
      if (ca.selectPressed()) Main.ME.startGame();
    }
  }
}