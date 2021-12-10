package shaders;

import h3d.shader.ScreenShader;

class PixelationShader extends ScreenShader {
  static var SRC = {
    @param var texture:Sampler2D;
    @param var depthTexture:Sampler2D;
    @param var exemptTexture:Sampler2D;
    @param var exemptDepthTexture:Sampler2D;
    @param var pixels:Int;
    function fragment() {
      var pxColor = texture.get(vec2(floor(input.uv * pixels) / pixels));
      var color = texture.get(input.uv);
      var exemptColor = exemptTexture.get(vec2(input.uv));
      var exemptDepthTest = exemptDepthTexture.get(input.uv);
      var depthTest = depthTexture.get(input.uv);
      // If r is over 0.1, 1.0 will be the alpha
      var alpha = step(exemptColor.r, 0.1);
      var result = pxColor;

      // Checks Alpha Channels to determine  if we should use
      // the regular color or sampled pixel color
      result = alpha > 0.?pxColor
      :color;
      pixelColor = result;
    }
  }

  public function new() {
    super();
    this.pixels = 312;
  }
}