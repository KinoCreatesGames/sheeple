package shaders;

import h3d.Vector;
import h3d.shader.ScreenShader;

class VignetteRadialShader extends ScreenShader {
  static var SRC = {
    @param var time:Float;

    /**
     * A 2D texture from the screen
     * used to show the screen with 
     * the shader effect.
     */
    @param var texture:Sampler2D;

    /**
     * Noise Texture
     * to add randomness to the distortion
     * effect.
     */
    @param var noiseTex:Sampler2D;

    /**
     * Vignette outer edges color
     * during the blending process.
     */
    @param var vignetteColor:Vec4;

    /**
     * The radius of the circle used
     * to create the vignette effect.
     */
    @param var radius:Float;

    /**
     * Adds a distortion to the shader
     * around the edges outside of the vignette effect radius.
     */
    @const @param var addDistortion:Bool;

    /**
     * The strength of the distortion effect within the game.
     */
    @param var distortionStrength:Float;

    function fragment() {
      // Center Point
      var texColor = texture.get(input.uv);
      var center = vec2(.5, .5);

      // if (distance(input.uv, center) > radius) {
      var pct = distance(input.uv, center);
      texColor.rgb *= (1 - pct);
      // If distortion is added, we will move around the uv coordinates  xy
      if (addDistortion) {
        var noise = noiseTex.get(input.uv).r;
        var str = distortionStrength * (smoothstep(0.3, 0.7, pct));
        var x = input.uv.x + (cos(noise * time * 3) * str);
        var y = input.uv.y + (sin(noise * time * 3) * str);
        var distortColor = texture.get(vec2(x, y));
        texColor = distortColor;
      }
      // }
      pixelColor = texColor;
    }
  }

  public function new(radius:Float, color:Vector, ?texture:h3d.mat.Texture) {
    super();
    this.radius = radius;
    this.vignetteColor = color;
    this.addDistortion = false;
    this.distortionStrength = .05;
    if (texture != null) {
      this.texture = texture;
    }
  }
}