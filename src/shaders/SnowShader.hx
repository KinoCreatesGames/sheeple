package shaders;

import h3d.shader.ScreenShader;
import h3d.Vector;

// WIP
class SnowShader extends ScreenShader {
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
     * Color of the snow when it appears on screen.
     */
    @param var color:Vec4;

    /**
     * Speed of the snow fall within the game.
     */
    @param var speed:Float;

    function fragment() {
      var texColor = texture.get(input.uv);
      var rand = noiseTex.get(input.uv).r;
      var PI = 3.14;
      var rads = (180 - ((time * speed) % 90)) * PI / 180;
      var yPos = sin(rads);
      var snowVec = vec2(input.uv.x, yPos + (rand * 0.4));
      if (distance(input.uv, snowVec) < 0.1) {
        texColor += (color * (1 - input.uv.y));
      }
      pixelColor = texColor;
    }
  }

  public function new(snowColor:Vector, renderTexture:h3d.mat.Texture,
      noiseTexture:h3d.mat.Texture) {
    super();
    this.speed = 5.;
    this.color = snowColor;
    this.texture = renderTexture;
    this.noiseTex = noiseTexture;
  }
}