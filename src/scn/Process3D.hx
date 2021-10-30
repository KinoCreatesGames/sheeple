package scn;

class Process3D extends dn.Process {
  public var game(get, never):Game;

  public inline function get_game() {
    return Game.ME;
  }

  var fx(get, never):Fx;

  public inline function get_fx() {
    return Game.ME.fx;
  }

  /**
   * 3D Scene root in Heaps that allows you to
   * add 3d elements to the scene.
   * If the s3d (main root) hasn't been setup, 
   * we use this root in our scene.
   */
  public var root3:h3d.scene.Object;

  public var parent3:Process3D;

  public function new(process:dn.Process) {
    super(Game.ME);
    // Initializes the basic 2DRoot
    // createRootInLayers(Game.ME.scroller, Const.DP_BG);
  }

  /**
   * Creates a 3D Root for the process.
   * If the top most root is not initialized, we 
   * set the top most root to the s3d node.
   */
  public function create3Root(?ctx:h3d.scene.Object) {
    // Sanity Checks
    if (root3 != null) {
      throw this + ': root already created!';
    }

    if (ctx == null) {
      if (parent3 == null || parent3.root3 == null) {
        throw this + ': context required';
      }
      ctx = parent3.root3;
    }
    // // Make the ctx used for this scene the parent 3d context
    // if (ctx == null) {
    //   ctx = parent3.root3;
    // }

    // If there is a context assign it as the root
    root3 = ctx;
    root3.name = getDisplayName();
  }
}