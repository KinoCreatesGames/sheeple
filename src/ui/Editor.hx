package ui;


import haxe.io.Bytes;
import dn.data.SavedData;
import en3d.blocks.StaticBlock;
import en3d.blocks.IceBlock;
import en3d.blocks.MysteryBlock;
import en3d.blocks.Goal;
import en3d.blocks.CrackedBlock;
import en3d.blocks.HeavyBlock;
import en3d.blocks.BlackHole;
import en3d.blocks.Block;
import en3d.blocks.Bounce;
import en3d.blocks.Spike;
import GameTypes.LvlSave;
import h2d.Flow.FlowAlign;
import h2d.Flow.FlowOverflow;
import GameTypes.BlockType;
import GameTypes.CollectibleTypes;
import h3d.Vector;
import dn.heaps.filter.PixelOutline;
import ui.cmp.TxtBtn;
import scn.Level3D;


class Editor extends dn.Process {
  public var game(get, never):Game;

  public inline function get_game() {
    return Game.ME;
  }

  public var level(get, never):Level3D;

   inline function get_level() {
    return Game.ME.level;
  }

  public var win(get, never):hxd.Window; 

   inline function get_win() {
    return hxd.Window.getInstance();
  } 

  public var visible(get, never):Bool;

   inline function get_visible() {
    return flow.visible;
  }

  //Controller access
   var ct:dn.heaps.Controller.ControllerAccess;

  /**
   * Outer flow for the Editor Elements.
   */
  public var flow:h2d.Flow;

  var menuBar:h2d.Flow;
  var blockPanel:h2d.Flow;
  var collectiblePanel:h2d.Flow;

  var invalidated:Bool = true;

  /**
   * The Vector Position of the block placement coordinates.
   */
  public var plCursor:h3d.Vector;

  public var plCoordText:h2d.Text;

  public var blockThresholdText:h2d.Text;

  public static inline var MOVE_SPD:Int = 1;

  /**
   * The type of block that is currently
   * selected within the editor for use
   * of placing blocks on the screen.
   */
  public var currentBlockType:String;

  /**
   * the current type of collectible selected
   * within the game.
   */
  public var currentCollectibleType:String;

  public function new() {
    super(Game.ME);
     ct = Main.ME.controller.createAccess('editor');
    createRootInLayers(game.root, Const.DP_UI);
    currentBlockType = BlockType.BlockB;
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
    plCursor = new Vector(0, 0, 0 );

    currentBlockType = null;
    setupMenuBar();
    setupCoordinate();
    setupBlockPanel();
    setupCollectiblePanel();
  }


  public function setupMenuBar() {
    menuBar = new h2d.Flow(flow);
    menuBar.layout = Horizontal;
    menuBar.horizontalSpacing = 12;
    menuBar.padding = 8;
    menuBar.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8);
    menuBar.filter = new PixelOutline(0xffffff, 1);  
    menuBar.minWidth = w();
    //File Option
    var file = new TxtBtn(24, Lang.t._('File'), menuBar);
    file.onClick = (event) -> {
      #if debug
      trace('Clicked file');
      #else
      #end
    };

    //Save Option
    var save = new TxtBtn(24, Lang.t._('Save'), menuBar);
    save.onClick = (event) -> {
      #if debug
      trace('Clicked save');
      #else 
      #end
      saveLevel();
    };

    var load = new TxtBtn(24, Lang.t._('Load'), menuBar);
    load.onClick = (event) -> {
      #if debug
      trace('Clicked load');
      #else 
      #end
      loadLevel();
    };

    // Clear the blocks on the current level
    var clear = new TxtBtn(24, Lang.t._('Clear'), menuBar);
    clear.onClick = (event) -> {
      #if debug
      trace('Clicked Clear level');
      #else 
      #end
      clearLevel(); 
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



  public function saveLevel() { 
    //Create Save Data
    var lvlSave:LvlSave = {
      playerStart: {
        x:Std.int(level.playerStartPos.x),
        y:Std.int(level.playerStartPos.y),
        z:Std.int(level.playerStartPos.y)
      },
      blocks:[]
    }
    for (block in level.blockGroup) {
      lvlSave.blocks.push({
        blockType: blockTypeToString(block),
        pos: {
          x: block.cx,
          y: block.cy,
          z: block.cz
        }
      });
    }
    
    var lvJson = haxe.Json.stringify(lvlSave);
    hxd.File.saveAs(Bytes.ofString(lvJson));
    // SavedData.save('Level', lvlSave);
  }

  public function loadLevel() {
    hxd.File.browse((browseSelect) -> {
      browseSelect.load((fileBytes) -> {
        var lvDataStr =  fileBytes.getString(0, fileBytes.length);
        var lvData:LvlSave = cast haxe.Json.parse(lvDataStr);
        var player = lvData.playerStart;
        trace(lvData);
        //Add blocks using the data
        for(block in lvData.blocks) {
          var pos = block.pos;
          level.createBlock(block.blockType, pos.x, pos.y, pos.z);
        }
        level.player.setPosCase(player.x, player.y, player.z);
      });
    });
    // var data :LvlSave = cast SavedData.load('Level', {
    //    playerStart: {
    //     x:0,
    //     y:0,
    //     z:0
    //   },
    //   blocks:[]
    // });
    #if debug
    // trace('Level Data loaded ${data}');
    #else
    #end
  }

  public function clearLevel() {
    #if debug
    trace('Cleared the level data.');
    #else  
    #end
    if(level != null) {
      level.clearLevel();
    }
  }

  public function blockTypeToString(block:Block):BlockType {
    var blockType = Type.getClass(block);
    return switch(blockType) {
      case Bounce:
        BounceB;
      case Spike:
        SpikeB;
      case BlackHole:
        BlackHoleB;
      case HeavyBlock:
        HeavyB;
      case Block:
        BlockB;
      case CrackedBlock:
        CrackedB;
      case Goal:
        GoalB;
      case MysteryBlock:
        MysteryB;
      case IceBlock:
        IceB;
      case StaticBlock:
        StaticB;
      case _:
        BlockB;
    }
  }

  public function setupCoordinate() {
    var panel = new h2d.Flow(flow);
    panel.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8);
    panel.filter = new PixelOutline(0xffffff, 1);
    panel.horizontalAlign = FlowAlign.Middle;
    panel.layout = Vertical;
    panel.minWidth = Std.int(w() * 0.25);

    plCoordText = new h2d.Text(Assets.fontMedium, panel);
    plCoordText.text = 'x: 0, y: 0, z: 0';
    plCoordText.textColor = 0xffffff;

    blockThresholdText = new h2d.Text(Assets.fontMedium, panel);
    blockThresholdText.text = '';
    blockThresholdText.textColor = 0xffffff;

  }

  public function setupBlockPanel() {
    var blockPanelTitle = new h2d.Flow(flow);
    blockPanelTitle.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8);
    blockPanelTitle.filter = new PixelOutline(0xffffff, 1);  
    blockPanelTitle.minWidth = Std.int(w() * 0.25);
    blockPanelTitle.horizontalAlign = FlowAlign.Middle;
    //Panel
    blockPanel = new h2d.Flow(flow); 
    blockPanel.minWidth = Std.int(w() * 0.25);
    blockPanel.maxHeight = Std.int(h() * 0.3);
    blockPanel.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8);
    blockPanel.filter = new PixelOutline(0xffffff, 1);  
    blockPanel.layout = Vertical;
    blockPanel.overflow = FlowOverflow.Scroll;
    //Title
    var title = new h2d.Text(Assets.fontMedium, blockPanelTitle);
    title.text = Lang.t._('Blocks');
    title.textColor = 0xffffff;
    //Block List
    addBlockTypes();
  }

  public function addBlockTypes() {
    var types = [BlockB, BounceB, IceB, StaticB, GoalB, SpikeB, BlackHoleB, HeavyB, MysteryB, CrackedB];

    for(blocktype in types) {
       var btn = new TxtBtn(blocktype, blockPanel);
      btn.onClick = (event) -> {
        currentBlockType = blocktype;
      }; 
    }
  }

  public function setupCollectiblePanel() {
     var cPanelTitle = new h2d.Flow(flow);
    cPanelTitle.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8);
    cPanelTitle.filter = new PixelOutline(0xffffff, 1);  
    cPanelTitle.minWidth = Std.int(w() * 0.25);
    cPanelTitle.horizontalAlign = FlowAlign.Middle;

     collectiblePanel = new h2d.Flow(flow);
     collectiblePanel.minWidth = Std.int(w() * 0.25);
     collectiblePanel.minHeight = Std.int(h() * 0.3);
     collectiblePanel.backgroundTile = h2d.Tile.fromColor(0x0, 1, 1, 0.8); 
     collectiblePanel.filter = new PixelOutline(0xffffff, 1);
     collectiblePanel.layout = Vertical;
     collectiblePanel.overflow = FlowOverflow.Scroll;
    //Title
    var title = new h2d.Text(Assets.fontMedium, cPanelTitle);
    title.text = Lang.t._('Collectibles');
    title.textColor = 0xffffff;
    //Collectible List
    addCollectibleTypes();
  }

  public function addCollectibleTypes() {
    var types = [ShardR, CheckpointR];

    for (collectible in types) {
       var btn = new TxtBtn(collectible, collectiblePanel);
      btn.onClick = (event) -> {
        currentCollectibleType = collectible;
      }; 
    }
  }

  public inline function invalidate() {
    invalidated = true;
  }

  override function update() {
    super.update();
    if (flow.visible) {
      handleControls();
    } 
    if (invalidated) {
      flow.reflow();
      render();
      invalidated = false;
    }

    if (!cd.has('mouse Test') && flow.visible) {
      cd.setS('mouse Test', 2, () -> {
        
        // trace('Mouse Pos ${win.mouseX}, ${win.mouseY}'); 
        //unproject transforms 2D screen position into a 3d one.
        var ray = level.s3d.camera.rayFromScreen(win.mouseX, win.mouseY);
        // trace(ray.collide(level.player.body.getBounds()));
        // trace(level.s3d.camera.unproject(win.mouseX, win.mouseY, level.camera.pos.z));
      });
    } 
  }

  public function handleControls() {
    var left = ct.leftPressed();
    var right = ct.rightPressed();
    var up = ct.upPressed(); 
    var down = ct.downPressed();
    var action = ct.aPressed();
    var actionC = ct.bPressed();
    var delete = ct.isKeyboardPressed(K.DELETE);
    var hasInput = [left, right, up, down, action, actionC, delete].exists((el) -> el  );

    if (hasInput) {
      //Move the block placement
      if (left) {
        plCursor.x -= MOVE_SPD;
      }
      else if (right) {
        plCursor.x  += MOVE_SPD;
      } else if (ct.xDown() && up) {
        plCursor.z += MOVE_SPD;
      }
      else if (ct.xDown() && down) {
        plCursor.z -= MOVE_SPD;
      }
       else if (up) {
        plCursor.y -= MOVE_SPD;
      } else if (down) {
        plCursor.y += MOVE_SPD;
      } else if (action) { 
        var lvlBlock = level.levelCollided(Std.int(plCursor.x), Std.int(plCursor.y), Std.int(plCursor.z));
        if (lvlBlock == null) {
          level.createBlock(currentBlockType,Std.int(plCursor.x), Std.int(plCursor.y), Std.int(plCursor.z));
        }
      } else if(actionC) {
         var lvlBlock = level.levelCollided(Std.int(plCursor.x), Std.int(plCursor.y), Std.int(plCursor.z));
        if (lvlBlock == null) {
          level.createCollectible(currentCollectibleType,Std.int(plCursor.x), Std.int(plCursor.y), Std.int(plCursor.z));
        } 
      } else if (delete) {
         var lvlBlock = level.levelCollided(Std.int(plCursor.x), Std.int(plCursor.y), Std.int(plCursor.z));
         if (lvlBlock != null) {
           lvlBlock.destroy();
         }
      }
      level.editorBlock.cx = Std.int(plCursor.x); 
      level.editorBlock.cy = Std.int(plCursor.y); 
      level.editorBlock.cz = Std.int(plCursor.z);
      render();
    }
  }

  /**
  * Renders anything that needs to be redrawn within the game.
  */
  public function render() {
    renderPLCoords();
    renderBlockThreshold();
  }

  public function renderBlockThreshold() {
    var result = 'Fall Threshold - ';
    if(level != null) {
      result += '${level.blockFallThreshold}';
    } else {
      result += 'X';
    }
    blockThresholdText.text = result;
 }

  public function renderPLCoords() {
    plCoordText.text = '${plCursor.x}, ${plCursor.y}, ${plCursor.z}';
  }

  public function startEditor() {
    ct.takeExclusivity();
    show(); 
    //Spawn block at player position
    var eBlock = level.editorBlock;
    eBlock.body.visible = true;
    if (level.player != null) { 
      plCursor.x = level.player.cx;
      plCursor.y = level.player.cy;
      plCursor.z = level.player.cz;
      eBlock.cx = level.player.cx;
      eBlock.cy = level.player.cy;
      eBlock.cz = level.player.cz;
    }
    invalidate();
  }

  public function exitEditor() {
    ct.releaseExclusivity();
    hide();
    level.editorBlock.body.visible = false;
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