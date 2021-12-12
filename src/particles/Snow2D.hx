package particles;

import h3d.mat.Texture;
import h2d.Particles;

class Snow2D extends Particles {
  public var snow:ParticleGroup;
  public var tex:Texture;

  public function new(parent:h2d.Object, texture:Texture) {
    super(parent);
    this.tex = texture;
    snow = addGroup();
    setupSnow();
  }

  public function setupSnow() {
    // this.x += 200;
    // this.y += 100;
    snow.name = 'snow';
    snow.blendMode = Alpha;
    snow.emitLoop = true;
    snow.texture = tex;
    snow.emitMode = Box;
    isRelative(false);
    nparts(2500);
    emitDist(Boot.ME.engine.width);
    emitDistY(10);
    emitAngle(0);
    gravityAngle((270 * Math.PI) / 180);
    gravity(100);
    speedRand(.8);
    sizeRand(0.2);
    life(5);
    lifeRand(10);
  }

  public function disable() {
    snow.enable = false;
  }

  public function enable() {
    snow.enable = true;
  }

  public function isRelative(enable) {
    snow.isRelative = enable;
  }

  /**
   * Life time of the snow.
   * @param value 
   */
  public function life(value:Float) {
    snow.life = value;
  }

  public function nparts(value:Int) {
    snow.nparts = value;
  }

  public function emitAngle(value:Float) {
    snow.emitAngle = value;
  }

  public function emitDist(value:Float) {
    snow.emitDist = value;
  }

  public function emitDistY(value:Float) {
    snow.emitDistY = value;
  }

  /**
   * Randomized life time of the snow.
   * By default, set to 3.
   * @param value 
   */
  public function lifeRand(value:Float) {
    snow.lifeRand = value;
  }

  public function gravity(value:Float) {
    snow.gravity = value;
  }

  public function gravityAngle(value:Float) {
    snow.gravityAngle = value;
  }

  public function sizeIncr(float) {
    snow.sizeIncr = float;
  }

  public function sizeRand(value:Float) {
    snow.sizeRand = value;
  }

  public function speed(value:Float) {
    snow.speed = value;
  }

  public function speedRand(value:Float) {
    snow.speedRand = value;
  }
}