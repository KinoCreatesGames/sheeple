package shaders;

import h3d.Vector;
import h3d.shader.ScreenShader;
import hxsl.Types.Sampler2D;

class TransitionShader extends ScreenShader {
  static var SRC = {
    @param var time:Float;

    /**
     * Screen render texture.
     */
    @param var texture:Sampler2D;

    /**
     * Texture for the transition.
     */
    @param var transitionTexture:Sampler2D;

    /**
     * Black and white texture.
     * When provided, used as a cut out 
     * for the transition. 
     * White is the cut out color, black is ignored.
     */
    @param var cutOutTexture:Sampler2D;

    /**
     * Whether the  cut out will be used in the shader or not.
     */
    @const @param var cutOut:Bool;

    /**
     * The color that the transition change to when the
     * time increases within the shader.
     */
    @param var cutColor:Vec4;

    /**
     * The end time of the transition.
     */
    @param var endTime:Float;

    function fragment() {
      var texColor = texture.get(input.uv);
      var transTexColor = transitionTexture.get(input.uv);
      var perc = (time / endTime);
      if (transTexColor.r < perc) {
        pixelColor = cutColor;
      } else {
        pixelColor = texColor;
      }
      if (cutOut == true) {
        // Pretty Close To White
        var cutOutColor = cutOutTexture.get(input.uv);
        if (cutOutColor.r > .9) {
          pixelColor = texColor;
        }
      }
    }
  }

  public function new(?color:Vector, endTime:Float = 3.0) {
    super();
    this.cutColor = color == null ? new Vector(0, 0, 0, 1) : color;
    this.cutOut = false;
  }
}