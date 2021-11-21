package shaders;

/**
 * Working with a 2D texture mostly
 * being used on a quad.
 */
class FrameShader extends hxsl.Shader {
  static var SRC = {
    /**
     * Input UV for texture mapped
     * object. Coming from
     * https://github.com/HeapsIO/heaps/blob/master/h3d/shader/Texture.hx
     */
    @input var input:{
      var uv:Vec2;
    };

    /**
     * Consistently updated from the game engine.
     */
    @global var global:{
      var time:Float;
    };

    @param var texture:Sampler2D;
    @perInstance @param var startFrame:Float = 0.0;
    @perInstance @param var startTime:Float;
    @param var speed:Float;
    @param var scaleX:Float;
    @param var scaleY:Float;
    @param var totalFrames:Float;
    @const var loop:Bool;
    var pixelColor:Vec4;
    var textureColor:Vec4;
    function fragment() {
      // Gets pixel coordinate color
      // Take UVs and discard UVs outside the current frmae
      var frameCut = (1. / totalFrames);

      var frame = int((global.time - startTime) * speed) % totalFrames;

      if (loop) {
        frame = frame * frameCut;
      }
      var uv = input.uv;
      // uv.x *= -1; // flips UV to right hand
      var pos = vec2(uv.x * frameCut, uv.y);
      // pos.x *= -1;
      pos = vec2(pos.x + frame, pos.y); // add frame amount to x coordinate

      // textureColor = vec4(frame, frame, frame, frame);
      textureColor = texture.get(pos);
      pixelColor = textureColor;
    }
  }

  public function new(texture, totalFrames = -1, speed = 1.) {
    super();
    this.startTime = 0.0;
    this.texture = texture;
    this.totalFrames = totalFrames;
    this.speed = speed;
    this.loop = true;
  }
}