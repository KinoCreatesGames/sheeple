/**
  This class is the entry point for the app.
  It doesn't do much, except creating Main and taking care of app speed ()
**/

import h3d.pass.ScreenFx;
import h3d.mat.DepthBuffer;
import h3d.mat.Texture;
import shaders.PixelationShader;
import h3d.Engine;
import dn.heaps.Controller;
import dn.heaps.Controller.ControllerAccess;

class Boot extends hxd.App {
  public static var ME:Boot;

  public var pass:h3d.pass.ScreenFx<PixelationShader>;

  #if debug
  var tmodSpeedMul = 1.0;
  var ca(get, never):ControllerAccess;

  inline function get_ca()
    return Main.ME.ca;
  #end

  /**
    App entry point
  **/
  static function main() {
    new Boot();
  }

  /**
    Called when engine is ready, actual app can start
  **/
  override function init() {
    var shader = new PixelationShader();
    pass = new ScreenFx<PixelationShader>(shader);
    ME = this;
    new Main(s2d);
    onResize();
  }

  override function onResize() {
    super.onResize();
    dn.Process.resizeAll();
  }

  /** Main app loop **/
  override function update(deltaTime:Float) {
    super.update(deltaTime);

    // Controller update
    Controller.beforeUpdate();

    var currentTmod = hxd.Timer.tmod;
    #if debug
    if (Main.ME != null && !Main.ME.destroyed) {
      // Slow down app (toggled with a key)
      if (ca.isKeyboardPressed(K.NUMPAD_SUB)
        || ca.isKeyboardPressed(K.HOME) || ca.dpadDownPressed())
        tmodSpeedMul = tmodSpeedMul >= 1 ? 0.2 : 1;
      currentTmod *= tmodSpeedMul;

      // Turbo (by holding a key)
      currentTmod *= ca.isKeyboardDown(K.NUMPAD_ADD)
        || ca.isKeyboardDown(K.END) || ca.ltDown() ? 5 : 1;
    }
    #end

    // Update all dn.Process instances
    dn.Process.updateAll(currentTmod);
  }

  override function render(e:Engine) {
    var scn = Boot.ME.s3d;
    var renderer = scn.renderer;
    var renderTarget = new Texture(engine.width, engine.height, [Target]);
    renderTarget.depthBuffer = new DepthBuffer(engine.width, engine.height);

    pass.shader.texture = renderTarget;
    // renderer.addShader(shader);
    engine.pushTarget(renderTarget);
    engine.clear(0, 1);
    s3d.render(e);
    engine.popTarget();

    pass.render();
    s2d.render(e);
    // super.render(e);
  }
}