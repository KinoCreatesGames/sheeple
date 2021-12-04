package ui;

import h2d.Bitmap;
import h3d.Vector;
import h2d.Flow.FlowAlign;
import scn.Level3D;

class Hud extends dn.Process {
  public var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  public var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  public var level(get, never):Level3D;

  inline function get_level()
    return Game.ME.level;

  var flow:h2d.Flow;
  var invalidated = true;

  public var livesText:h2d.Text;
  public var scoreText:h2d.Text;
  public var scoreBG:h2d.Bitmap;
  public var highScoreText:h2d.Text;
  public var highScoreBG:Bitmap;
  public var stepComboText:h2d.Text;
  public var stepCountText:h2d.Text;
  public var tempScore:Int = 0;
  public var levelRadar:Bitmap;

  public var hudTween:Tweenie;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    hudTween = new Tweenie(Const.FPS);
    setupUIElements();
    dn.Process.resizeAll();
  }

  /**
   * Sets up the UI elements within the game and how they 
   * will be rendered.
   */
  public function setupUIElements() {
    // Update Flow Settings
    flow.layout = Horizontal;
    flow.verticalAlign = FlowAlign.Middle;
    flow.horizontalSpacing = 12;
    setupLives();
    setupScore();
    setupHighScore();
    setupStepCount();
    setupStepCombo();
    setupRadar();
  }

  public function setupLives() {
    livesText = new h2d.Text(Assets.fontMedium, flow);
    livesText.textColor = 0xffffff;
    livesText.text = 'Lives 3';
  }

  public function setupScore() {
    scoreBG = new h2d.Bitmap(hxd.Res.img.ScoreBoardPNG.toTile(), flow);
    scoreText = new h2d.Text(Assets.fontSmall, scoreBG);
    var offset = scoreBG.tile.width / 8;
    scoreText.y += offset;
    scoreText.x += offset;
    scoreText.textColor = 0xffffff;
    scoreText.text = '0';
  }

  public function setupHighScore() {
    highScoreBG = new h2d.Bitmap(hxd.Res.img.HighScoreBoardPNG.toTile(), flow);
    highScoreText = new h2d.Text(Assets.fontSmall, highScoreBG);
    var offset = highScoreBG.tile.width / 8;
    highScoreText.y += offset;
    highScoreText.x += offset;
    highScoreText.textColor = 0xffffff;
    highScoreText.text = '0';
  }

  public function setupStepCombo() {
    stepComboText = new h2d.Text(Assets.fontMedium, flow);
    stepComboText.textColor = 0xffffff;
    stepComboText.text = 'Step Combo 0';
  }

  public function setupStepCount() {
    stepCountText = new h2d.Text(Assets.fontMedium, flow);
    stepCountText.textColor = 0xffffff;
    stepCountText.text = 'Steps 0';
  }

  public function setupRadar() {
    levelRadar = new h2d.Bitmap(hxd.Res.img.LevelRadarPNG.toTile(), root);
    resizeRadar();
  }

  public function resizeRadar() {
    var offset = 32;
    var y = ((h() / Const.UI_SCALE) - (levelRadar.tile.height + offset));
    levelRadar.setPosition(offset, y);
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
    resizeRadar();
  }

  public inline function invalidate() {
    invalidated = true;
  }

  function render() {
    if (level != null) {
      if (level.player != null) {
        renderLives();
        renderScore();
        renderHighScore();
        renderStepCount();
        renderStepCombo();
      }
    }
  }

  public function renderLives() {
    livesText.text = 'Lives ${Game.ME.playerLives}';
  }

  public function renderScore() {
    scoreText.text = '${level.score}';
  }

  public function renderHighScore() {
    highScoreText.text = '${level.highScore}';
  }

  public function renderStepCount() {
    stepCountText.text = 'Steps ${level.player.stepCount}';
  }

  public function renderStepCombo() {
    stepComboText.text = 'Step Combo ${level.player.stepCombo}';
  }

  public function updateScore(delta:Int) {
    tempScore += delta;
    var t = hudTween.createS(level.score, tempScore, TEase, 0.3);
    t.end(() -> {
      // level
      trace('Complete score tween');
    });
  }

  override function update() {
    super.update();
    hudTween.update();
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  public function hide() {
    flow.visible = false;
  }

  public function show() {
    flow.visible = true;
  }
}