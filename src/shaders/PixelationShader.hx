package shaders;

import h3d.shader.ScreenShader;

class PixelationShader extends ScreenShader {
  static var SRC = {
    @param var depthMap:Channel;
    @param var texture:Sampler2D;
    @param var depthTexture:Sampler2D;
    @param var exemptTexture:Sampler2D;
    @param var exemptDepthTexture:Sampler2D;
    @param var pixels:Int;
    function fragment() {
      var pxColor = texture.get(vec2(floor(input.uv * pixels) / pixels));
      var exemptColor = exemptTexture.get(vec2(input.uv));
      var depth = depthMap.get(input.uv);
      var exemptDepthTest = exemptDepthTexture.get(input.uv);
      var depthTest = depthTexture.get(input.uv);
      // var finalColor = mix(exemptColor.rgb, pxColor.rgb, .3);
      // If r is over 0.1, 1.0 will be the alpha
      var alpha = step(exemptColor.r, 0.1);
      var pxAlpha = step(pxColor.r, 0.5);

      // var depth = 1 - step(pxColor.z, 0.5);
      var depthR = vec3(step(exemptDepthTest.y, depthTest.y));

      // exemptColor.rgb *= pxColor.a;
      // pxColor.rgb *= depthColor;

      // exemptColor.rgb *= depthR;
      // pxColor.rgb *= depthR;
      var result = pxColor;
      // Exempt no player and depth has player
      if ((1 - exemptDepthTest.y) < (1 - depthTest.y)) {
        pxColor.rgb *= (alpha);
        // pxColor.rgb /= (alpha);
        // result = pxColor;
      } else {
        if (exemptDepthTest.y > 0.0000001) {
          exemptColor.rgb *= (0.);
        }
      }
      // pxColor.rgb *= (alpha);
      // pxColor.rgb = 1 - vec3(depthTest.y);
      // exemptColor.rgb = 1 - vec3(exemptDepthTest.y);

      result = pxColor + exemptColor;
      // result = min(pxColor, exemptColor);
      pixelColor = result;
      // pixelColor = mix(pxColor, exemptColor, .5);
      // pxColor.rgb = vec3(pxColor.y);
      // pixelColor = pxColor;
    }
  }

  public function new() {
    super();
    this.pixels = 512;
  }
}