package shaders;

import h3d.shader.ScreenShader;

class PixelationShader extends ScreenShader {
  static var SRC = {
    @param var texture:Sampler2D;
    @param var pixels:Int;
    function fragment() {
      var uv = input.uv;

      var pxColor = texture.get(vec2(floor(input.uv * pixels) / pixels));
      //   pxColor.r = 1.0;
      //   pxColor.a = 1.0;
      pixelColor = pxColor;
    }
  }

  public function new() {
    super();
    this.pixels = 256;
  }
}