package shaders;

import h3d.shader.BaseMesh;

class OutlineShader extends BaseMesh {
  @param var outlineSize:Float;

  static var SRC = {
    function fragment() {
      pixelColor = pixelColor;
    }
  }

  public function new() {
    super();
    this.outlineSize = 0.2;
  }
}