package renderer;

class CustomRenderer extends h3d.scene.fwd.Renderer {
  public var depthTex:h3d.mat.Texture;
  public var normalTex:h3d.mat.Texture;

  /** 
   * Multiple Render Targets.
   * Using the output pass.
   * https://en.wikipedia.org/wiki/Multiple_Render_Targets
   */
  public var mrt:h3d.pass.Output;

  public function new() {
    super();
    mrt = new h3d.pass.Output('mrt',
      [PackFloat(Value('output.depth')), PackNormal(Value('output.normal'))]);
    allPasses.push(mrt);
  }

  override function render() {
    var depth = allocTarget('depth');
    var normal = allocTarget('normal');

    setTargets([depth, normal]);
    clear(0, 1); // Clear target textures and depth buffer
    mrt.draw(get('default'));
    resetTarget();
    depthTex = depth;
    normalTex = normal;

    // Render default passes
    renderPass(defaultPass, get('default'));
    renderPass(defaultPass, get('alpha'), backToFront);
    renderPass(defaultPass, get('additive'));
  }
}