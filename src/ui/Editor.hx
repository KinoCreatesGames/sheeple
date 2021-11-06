package ui;

import en3d.blocks.Block;
import ui.cmp.TxtBtn;
import scn.Level3D;
import h2d.Flow.FlowAlign;

class Editor extends dn.Process {
  public var game(get, never):Game;

  public inline function get_game() {
    return Game.ME;
  }

  public var level(get, never):Level3D;

  public inline function get_level() {
    return Game.ME.level;
  }

  //Controller access
   var ct:dn.heaps.Controller.ControllerAccess;

  /**
   * Outer flow for the Editor Elements.
   */
  var flow:h2d.Flow;

  var menuBar:h2d.Flow;
  var blockPanel:h2d.Flow;
  var collectiblePanel:h2d.Flow;

  var invalidated:Bool = true;



  /**
   * The type of block that is currently
   * selected within the editor for use
   * of placing blocks on the screen.
   */
  public var currentBlockType:Null<Block>;

  public function new() {
    super(Game.ME);
     ct = Main.ME.controller.createAccess('pause');
    createRootInLayers(game.root, Const.DP_UI);
    //Pixel Perfect Rendering
    root.filter = new h2d.filter.ColorMatrix();

    flow = new h2d.Flow(root);
    setupEditorElements();
  }

  public function setupEditorElements() {
    // Setup outer flow
    // Separate into vertical layout
    flow.borderHeight = 7;
    flow.borderWidth = 7;
    flow.minWidth = w();
    flow.layout = Vertical;

    currentBlockType = null;
    setupMenuBar();
    setupBlockPanel();
    setupCollectiblePanel();
  }

  public function setupMenuBar() {
    menuBar = new h2d.Flow(flow);
    menuBar.layout = Horizontal;
    menuBar.horizontalSpacing = 12;
    menuBar.padding = 8;
    menuBar.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8);
    menuBar.minWidth = w();
    //File Option
    var file = new TxtBtn(24, Lang.t._('File'), menuBar);
    file.onClick = (event) -> {
      #if debug
      trace('Clicked file');
      #else
      #end
    };

    //Exit Editor Mode
    var file = new TxtBtn(24, Lang.t._('Exit'), menuBar);
    file.onClick = (event) -> {
      #if debug
      trace('Clicked Exit');
      #else
      
      #end 
      exitEditor();
    }; 
  }

  public function setupBlockPanel() {
    blockPanel = new h2d.Flow(flow);
    blockPanel.minHeight = Std.int(h() * 0.3);
    blockPanel.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8);
    //Title
    var title = new h2d.Text(Assets.fontMedium, blockPanel);
    title.text = Lang.t._('Blocks');
    title.textColor = 0xffffff;
    //Block List
    addBlockTypes();
  }

  public function addBlockTypes() {
  }

  public function setupCollectiblePanel() {
     collectiblePanel = new h2d.Flow(flow);
     collectiblePanel.minHeight = Std.int(h() * 0.3);
    collectiblePanel.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8); 
    //Title
    var title = new h2d.Text(Assets.fontMedium, collectiblePanel);
    title.text = Lang.t._('Collectibles');
    title.textColor = 0xffffff;
    //Collectible List
  }

  public inline function invalidate() {
    invalidated = true;
  }


  override function update() {
    super.update();
    if(invalidated) {
      flow.reflow();
      render();
      invalidated = false;
    }
  }


/**
 * Renders anything that needs to be redrawn within the game.
 */
public function render() {
}

  public function startEditor() {
    ct.takeExclusivity();
    show();
    invalidate();
  }

  public function exitEditor() {
    ct.releaseExclusivity();
    hide();
    if (game.level != null) {
      game.level.resume();
    }
  } 

  public function hide() {
    flow.visible = false;
  }

  public function show() {
    flow.visible = true;
  }
}