package shaders;

import h3d.shader.BaseMesh;

// Only applies to blocks / meshes
class PixelShader extends BaseMesh {
  static var SRC = {
    @param var pixels:Int;
    function fragment() {
      pixelColor = floor((pixelColor * pixels)) / pixels;
      // pixelColor = vec4(1.);
    }
  }

  public function new() {
    super();
    this.pixels = 256;
  }
}