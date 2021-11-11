package ui;

class Results extends dn.Process {
  public var win:h2d.Flow;
  public var titleText:h2d.Text;
  public var mask:h2d.Bitmap;

  public var ct:dn.heaps.Controller.ControllerAccess;

  public function new() {
    super(Main.ME);
    createRootInLayers(Game.ME.root, Const.DP_UI);

    root.filter = new h2d.filter.ColorMatrix();
    ct = Main.ME.controller.createAccess('Results');
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);
    root.under(mask);
    setupWindow();
    dn.Process.resizeAll();
  }

  public function setupWindow() {
    win = new h2d.Flow(root);
    win.backgroundTile = h2d.Tile.fromColor(0x0f0f0f, 1, 1, 0.5);
    win.layout = Vertical;
    setupTitle();
  }

  public function setupTitle() {
    titleText = new h2d.Text(Assets.fontLarge, win);
    titleText.textColor = 0xffffff;
    titleText.text = Lang.t._('Results');
  }

  override function update() {
    super.update();
    updateControls();
  }

  public function updateControls() {}

  override function onResize() {
    super.onResize();
    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
    // win.x = (w() * 0.5 - (win.outerWidth * 0.2));
    // win.y = (h() * 0.5 - (win.outerHeight * 0.3));
  }

  override function onDispose() {
    super.onDispose();
  }
}