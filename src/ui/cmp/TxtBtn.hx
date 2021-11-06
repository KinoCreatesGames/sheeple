package ui.cmp;

import h2d.Object;

/**
 * Text Button class for convenience
 * when creating UI elements within the game.
 * OnClick is not set by default.
 * Access it via Btn.int.OnClick = ...;
 */
class TxtBtn extends BaseBtn {
  public var text:h2d.Text;

  public function new(width:Float = 0, height:Float = 0, str:String = '',
      ?parent:Object) {
    super(width, height, parent);
    text = new h2d.Text(Assets.fontMedium, this);
    setColor();
    text.text = str;
    if (width == 0) {
      int.width = text.textWidth;
    }
    if (height == 0) {
      // Update the interactive height to the text height
      int.height = text.textHeight;
    }
    setupEvents();
  }

  /**
   * Centers the text button in the proper area.
   */
  public inline function center() {
    this.text.center();
    int.x = text.alignCalcX();
  }

  public inline function setupEvents() {
    int.onOut = (event) -> {
      text.alpha = 1;
    }

    int.onOver = (event) -> {
      text.alpha = 0.5;
    }
    int.x = text.alignCalcX();
  }

  public inline function setColor(color:Int = 0xffffff) {
    text.textColor = color;
  }

  public inline function setFont(?font:h2d.Font) {
    var defaultFont = font == null ? Assets.fontMedium : font;
    text.font = defaultFont;
  }
}