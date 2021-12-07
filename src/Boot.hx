/**
  This class is the entry point for the app.
  It doesn't do much, except creating Main and taking care of app speed ()
**/

import renderer.CustomRenderer;
import h3d.scene.fwd.Renderer;
import h3d.scene.fwd.Renderer.DepthPass;
import h3d.scene.Object;
import h3d.scene.Scene;
import h3d.pass.ScreenFx;
import h3d.mat.DepthBuffer;
import h3d.mat.Texture;
import shaders.PixelationShader;
import h3d.Engine;
import dn.heaps.Controller;
import dn.heaps.Controller.ControllerAccess;

class Boot extends hxd.App {
  public static var ME:Boot;

  public var renderer:CustomRenderer;

  public var pass:h3d.pass.ScreenFx<PixelationShader>;
  public var s3dTarget:Scene;

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
    renderer = new CustomRenderer();
    s3d.renderer = renderer;
    var shader = new PixelationShader();
    pass = new ScreenFx<PixelationShader>(shader);
    s3dTarget = new h3d.scene.Scene();
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

  /**
   * Force allow access to the render context
   * and allow for grabbing depth texture.
   * Using the forward renderer.
   */
  @:access(h3d.scene.Scene, h3d.scene.RenderContext, CustomRenderer)
  override function render(e:Engine) {
    engine.backgroundColor = 0xffffff;
    super.render(e);
    var depthTex = renderer.depthTex.clone();
    var renderTarget = new Texture(engine.width, engine.height, [Target]);
    renderTarget.depthBuffer = new DepthBuffer(engine.width, engine.height);
    var renderTargetTwo = new Texture(engine.width, engine.height, [Target]);
    renderTargetTwo.depthBuffer = new DepthBuffer(engine.width, engine.height);

    pass.shader.texture = renderTarget;

    pass.shader.depthMap = renderer.depthTex;
    pass.shader.exemptTexture = renderTargetTwo;

    engine.pushTarget(renderTarget);
    engine.pushTarget(renderTargetTwo);

    // Create Texture with just the player and no other elements
    if (Game.ME != null && Game.ME.level != null) {
      var level = Game.ME.level;
      level.skyMesh.visible = false;
      for (block in level.blockGroup) {
        block.body.visible = false;
      }
    }
    engine.clear(0, 1); // Clear render texture and depth buffer
    s3d.render(e);

    engine.popTarget();

    // Create a texture with just the blocks and no player
    if (Game.ME != null && Game.ME.level != null) {
      var level = Game.ME.level;
      level.player.body.visible = false;
      level.skyMesh.visible = false;
      for (block in level.blockGroup) {
        block.body.visible = true;
      }
    }
    // TODO: Add render passes that capture sky box
    engine.clear(0, 1); // Clear render texture and depth buffer
    s3d.render(e);
    pass.shader.exemptDepthTexture = renderer.depthTex.clone();
    pass.shader.depthTexture = depthTex; // Initial texture
    engine.popTarget();
    // Clean up before pass render
    if (Game.ME != null && Game.ME.level != null) {
      var level = Game.ME.level;
      level.player.body.visible = true;
      // for (block in level.blockGroup) {
      //   block.body.visible = true;
      // }
    }

    // pass.pass.depth(true, Always);
    pass.render();

    s2d.render(e);
  }
}