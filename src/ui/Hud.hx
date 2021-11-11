package ui;

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
  public var highScoreText:h2d.Text;
  public var stepComboText:h2d.Text;
  public var stepCountText:h2d.Text;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    setupUIElements();
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
  }

  public function setupLives() {
    livesText = new h2d.Text(Assets.fontMedium, flow);
    livesText.textColor = 0xffffff;
    livesText.text = 'Lives 3';
  }

  public function setupScore() {
    scoreText = new h2d.Text(Assets.fontMedium, flow);
    scoreText.textColor = 0xffffff;
    scoreText.text = 'Score 0';
  }

  public function setupHighScore() {
    highScoreText = new h2d.Text(Assets.fontMedium, flow);
    highScoreText.textColor = 0xffffff;
    highScoreText.text = 'High Score 0';
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

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
  }

  public inline function invalidate()
    invalidated = true;

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
    scoreText.text = 'Score ${level.score}';
  }

  public function renderHighScore() {
    highScoreText.text = 'Score ${level.highScore}';
  }

  public function renderStepCount() {
    stepCountText.text = 'Steps ${level.player.stepCount}';
  }

  public function renderStepCombo() {
    stepCountText.text = 'Step Combo ${level.player.stepCombo}';
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