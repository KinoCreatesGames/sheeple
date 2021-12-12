/**
  This class is the entry point for the app.
  It doesn't do much, except creating Main and taking care of app speed ()
**/

import particles.Snow2D;
import shaders.SnowShader;
import shaders.VignetteRadialShader;
import h3d.Vector;
import renderer.CustomRenderer;
import h3d.scene.fwd.Renderer;
import h3d.scene.fwd.Renderer.DepthPass;
import h3d.scene.Object;
import h3d.scene.Scene;
import h3d.pass.ScreenFx;
import h3d.mat.DepthBuffer;
import h3d.mat.Texture;
import shaders.PixelationShader;
import shaders.TransitionShader;
import shaders.ColorShader;
import h3d.Engine;
import dn.heaps.Controller;
import dn.heaps.Controller.ControllerAccess;

class Boot extends hxd.App {
  public static var ME:Boot;

  public var renderer:CustomRenderer;

  public var pass:h3d.pass.ScreenFx<PixelationShader>;
  public var transPass:h3d.pass.ScreenFx<TransitionShader>;
  public var s3dDepthTarget:Scene;
  public var s3dEntityTarget:Scene;
  public var s3dBlockTarget:Scene;

  public var depthTarget:Texture;
  public var entityTarget:Texture;
  public var blockTarget:Texture;

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
    transPass = new ScreenFx<TransitionShader>(new TransitionShader());
    createTargets();
    setupScenes();
    ME = this;
    new Main(s2d);
    new Snow2D(s2d, hxd.Res.textures.SnowTex.toTexture());
    onResize();
  }

  public function setupScenes() {
    s3dDepthTarget = new h3d.scene.Scene();
    s3dDepthTarget.renderer = new CustomRenderer();
    s3dEntityTarget = new h3d.scene.Scene();
    s3dEntityTarget.renderer = new CustomRenderer();
  }

  public function createTargets() {
    depthTarget = new Texture(engine.width, engine.height, [Target]);
    depthTarget.depthBuffer = new DepthBuffer(engine.width, engine.height);
    blockTarget = new Texture(engine.width, engine.height, [Target]);
    blockTarget.depthBuffer = new DepthBuffer(engine.width, engine.height);
    entityTarget = new Texture(engine.width, engine.height, [Target]);
    entityTarget.depthBuffer = new DepthBuffer(engine.width, engine.height);
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
  @:access(h3d.scene.Scene, h3d.scene.RenderContext, h3d.scene.Renderer,
    CustomRenderer)
  override function render(e:Engine) {
    if (Game.ME != null && Game.ME.level != null) {
      var entRenderer:CustomRenderer = cast s3dEntityTarget.renderer;
      var level = Game.ME.level;
      pass.shader.texture = blockTarget;
      pass.shader.depthTexture = renderer.depthTex;
      engine.pushTarget(blockTarget);
      engine.clear(0, 1);
      s3d.render(e);
      engine.popTarget();
      engine.pushTarget(entityTarget);
      s3dEntityTarget.removeChildren();
      s3dEntityTarget.camera.load(s3d.camera);
      s3dEntityTarget.addChild(level.entityParent.clone());
      engine.clear(0, 1);
      s3dEntityTarget.render(e);
      engine.popTarget();
      var tex = new Texture(engine.width, engine.height, [Target]);
      tex.depthBuffer = new DepthBuffer(engine.width, engine.height);
      var texTest = new Texture(engine.width, engine.height, [Target]);
      tex.depthBuffer = new DepthBuffer(engine.width, engine.height);
      // Push target will render to to the target rather than the screen
      // Without successive render calls to handle the case
      engine.pushTarget(tex);
      pass.shader.exemptDepthTexture = entRenderer.depthTex.clone();
      pass.shader.exemptTexture = entityTarget;
      pass.render();
      engine.popTarget();
      var noiseTex = hxd.Res.textures.NoiseTex.toTexture();

      // Works as expected, except rendering to target and not screen
      // var shader = new VignetteRadialShader(.45, Vector.fromColor(0x00aafa),
      //   tex);
      // shader.addDistortion = true;
      // shader.noiseTex = noiseTex;
      // shader.time = renderer.ctx.time;
      // var shaderTwo = new SnowShader(Vector.fromColor(0xffffff), tex, noiseTex);
      // shaderTwo.time = renderer.ctx.time;
      new ScreenFx(new ColorShader(Vector.fromColor(0xa0a0ff), tex)).render();

      // Trans Pass Render using previous pass render texture
      // transPass.shader.endTime = 10.;
      // transPass.shader.time = renderer.ctx.time;
      // transPass.shader.texture = texTest;
      // transPass.shader.cutColor = Vector.fromColor(0xffaabb);
      // transPass.shader.cutOut = true;
      // transPass.shader.cutOutTexture = hxd.Res.textures.CutOutTexture.toTexture();
      // transPass.shader.transitionTexture = hxd.Res.textures.TransitionOne.toTexture();
      // transPass.render();
    } else {
      s3d.render(e);
    }

    s2d.render(e);
  }
}