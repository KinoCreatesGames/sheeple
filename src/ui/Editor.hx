package ui;

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

  /**
   * Outer flow for the Editor Elements.
   */
  var flow:h2d.Flow;

  var invalidated:Bool = true;

  public function new() {
    super(Game.ME);
    createRootInLayers(game.root, Const.DP_UI);

    flow = new h2d.Flow(root);
    setupEditorElements();
  }

  public function setupEditorElements() {}

  public function hide() {
    flow.visible = false;
  }

  public function show() {
    flow.visible = true;
  }
}