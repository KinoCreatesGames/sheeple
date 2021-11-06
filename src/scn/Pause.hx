package scn;

import hxd.snd.Channel;
import ui.cmp.TxtBtn;

class Pause extends dn.Process {
  var ct:dn.heaps.Controller.ControllerAccess;
  var mask:h2d.Bitmap;

  public var se:Channel;

  var padding:Int;
  var win:h2d.Flow;

  public var titleText:h2d.Text;
  public var elapsed:Float;

  public function new() {
    super(Game.ME);
    ct = Main.ME.controller.createAccess('pause');
    ct.takeExclusivity();
    createRootInLayers(Game.ME.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix();
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);
    root.under(mask);
    elapsed = 0;
    setupPause();
    dn.Process.resizeAll();
  }

  public function setupPause() {
    win = new h2d.Flow(root);
    win.borderHeight = 7;
    win.borderWidth = 7;
    win.minWidth = Std.int(w() * 0.5);

    win.verticalSpacing = 16;
    win.layout = Vertical;
    addOptions();
  }

  public function addOptions() {
    // Title Text
    var title = new h2d.Text(Assets.fontLarge, win);
    title.text = Lang.t._('Pause');
    title.center();
    titleText = title;

    // Add Buttons
    var resume = new TxtBtn(win.outerWidth, Lang.t._('Resume'), win);
    resume.center();
    resume.onClick = (event) -> {
      resumeGame();
    }

    var restart = new TxtBtn(win.outerWidth, Lang.t._('Restart'), win);
    restart.center();
    restart.onClick = (event) -> {
      restartLevel();
    }

    var quit = new TxtBtn(win.outerWidth, Lang.t._('To Title'), win);
    quit.center();
    quit.onClick = (event) -> {
      toTitle();
    }
  }

  public function resumeGame() {
    ct.releaseExclusivity();
    Game.ME.level.resume();
    // se = hxd.Res.sound.pause_out.play();
    this.destroy();
  }

  public function restartLevel() {
    ct.releaseExclusivity();
    Game.ME.level.resume();
    Game.ME.reloadCurrentLevel();
    this.destroy();
  }

  public function toTitle() {
    ct.releaseExclusivity();
    Game.ME.level.resume();
    Game.ME.level.destroy();
    // se = hxd.Res.sound.pause_out.play();
    this.destroy();
    new Title();
  }

  override function update() {
    super.update();
    elapsed = (uftime % 180) * (Math.PI / 180);
    titleText.alpha = M.fclamp(Math.sin(elapsed) + 0.3, 0.3, 1);

    // Escape Leave Method
    if (ct.isKeyboardPressed(K.ESCAPE)) {
      // Return to the previous scene without creating any
      // new instances
      // Play Leave
      resumeGame();
    }
  }

  override function onResize() {
    super.onResize();
    // Resize all elements to be centered on screen

    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
    win.x = (w() * 0.5 - (win.outerWidth * 0.0));
    win.y = (h() * 0.5 - (win.outerHeight * 0.5));
  }

  override function onDispose() {
    super.onDispose();
    se = null;
  }
}