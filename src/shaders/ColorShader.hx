package shaders;

import h3d.Vector;
import h3d.mat.Texture;
import h3d.shader.ScreenShader;

class ColorShader extends ScreenShader {
  static var SRC = {
    /**
     * Render texture we use to make
     * screen modifications.
     */
    @param var texture:Sampler2D;

    /**
     * The color vector for tinting
     * the game with that specified color.
     */
    @param var color:Vec4;

    function fragment() {
      var texColor = texture.get(input.uv);
      texColor.rgb *= color.rgb;
      pixelColor = texColor;
    }
  }

  public function new(color:Vector, texture:Texture) {
    super();
    this.texture = texture;
    this.color = color;
  }
}