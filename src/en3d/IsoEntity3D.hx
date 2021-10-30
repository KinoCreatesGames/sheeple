package en3d;

class IsoEntity3D extends Entity3D {
  /**
   * Turns a position into iso coordinates
   * to properly represent the position on screen.
   * translate x = x * 1  y * 0.5
   * @param x 
   * @param y 
   */
  public function toIso(x:Float, y:Float) {
    return {
      x: (x * 1) + (y * -1),
      y: (x * 0.5) + (y * 0.5)
    };
  }

  /**
   * Turns a position back into regular coordinates 
   * from the iso coordinates.
   * @param x 
   * @param y 
   */
  public function fromIso(x:Float, y:Float) {}

  public function new(x:Int, y:Int, z:Int) {
    super(x, y, z);
  }
}