package ui.cmp;

import h2d.Interactive;
import h2d.Object;

class BaseBtn extends Object {
  /**
   * Interactable area of the button. 
   */
  public var int:Null<Interactive>;

  /**
   * OnClick function of the button.
   */
  public var onClick(get, set):hxd.Event -> Void;

  public inline function set_onClick(e:hxd.Event -> Void) {
    return int.onClick = e;
  }

  public inline function get_onClick() {
    return int.onClick;
  }

  /**
   * OnOver function of the button.
   */
  public var onOver(get, set):hxd.Event -> Void;

  public inline function set_onOver(e:hxd.Event -> Void) {
    return int.onOver = e;
  }

  public inline function get_onOver() {
    return int.onOver;
  }

  /**
   * OnOut function of the button.
   */
  public var onOut(get, set):hxd.Event -> Void;

  public inline function set_onOut(e:hxd.Event -> Void) {
    return int.onOut = e;
  }

  public inline function get_onOut() {
    return int.onOut;
  }

  public function new(width:Float = 0, height:Float = 0, ?parent:Object) {
    super(parent);
    int = new Interactive(width, height, this);
  }
}