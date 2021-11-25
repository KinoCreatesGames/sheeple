package tools;

import h3d.scene.RenderContext;
import h3d.scene.Object;

class OrthoCamController extends h3d.scene.Object {
  public var distance(get, never):Float;
  public var targetDistance(get, never):Float;
  public var theta(get, never):Float;
  public var phi(get, never):Float;
  public var fovY(get, never):Float;
  public var target(get, never):h3d.col.Point;

  /**
   * Friction applied to the camera.
   */
  public var friction = 0.4;

  /**
   * Rotation speed of the camera.
   */
  public var rotateSpeed = 1.;

  /**
   * The amount of zoom applied to the camera.
   */
  public var zoomAmount = 1.15;

  /**
   * Field of view amount of zoom applied to the
   * camera.
   */
  public var fovZoomAmount = 1.1;

  /**
   * Panning speed of the camera.
   */
  public var panSpeed = 1.;

  /**
   * Camera smoothing amount.
   */
  public var smooth:Float = 0.6;

  /**
   * Minimum distance of the camera.
   */
  public var minDistance:Float = 0.;

  /**
   * Maximum distance for the camera.
   */
  public var maxDistance:Float = 1e20;

  /**
   * Whether to lock Z Planes or not 
   * for the camera. (Research this.)
   */
  public var lockZPlanes = false;

  /**
   * Current 3d scene that the camera
   * controllers belongs to at this point in time.
   */
  var scene:h3d.scene.Scene;

  var pushing = -1;
  var pushX = 0.;
  var pushY = 0.;
  var pushStartX = 0.;
  var pushStartY = 0.;
  var moveX = 0.;
  var moveY = 0.;
  var pushTime:Float;
  var curPos = new h3d.Vector();
  var curOffset = new h3d.Vector();
  var targetPos = new h3d.Vector(10. / 25., Math.PI / 4, Math.PI * 5 / 13);
  var targetOffset = new h3d.Vector(0, 0, 0, 0);

  /**
   * Target to follow within the game
   * during an update.
   */
  public var followTarget:Object;

  inline function get_distance() {
    return curPos.x / curOffset.w;
  }

  inline function get_targetDistance() {
    return targetPos.x / targetOffset.w;
  }

  inline function get_theta() {
    return curPos.y;
  }

  inline function get_phi() {
    return curPos.z;
  }

  inline function get_fovY() {
    return curOffset.w;
  }

  inline function get_target() {
    return curOffset.toPoint();
  }

  /**
   * Creates a new orthographic camera controller.
   * You can set the parent and the starting
   * distance of the camera from the subject.
   * @param distance 
   * @param parent 
   */
  public function new(?distance, ?parent:Object) {
    super(parent);
    name = 'OrthoCamController';
    followTarget = null;
    set(distance);
  }

  /**
    Set the controller parameters.
    Distance is ray distance from target.
    Theta and Phi are the two spherical angles
    Target is the target position
  **/
  public function set(?distance:Float, ?theta:Float, ?phi:Float,
      ?target:h3d.col.Point, ?fovY:Float) {
    if (theta != null) {
      targetPos.y = theta;
    }
    if (phi != null) {
      targetPos.z = phi;
    }
    if (target != null) {
      targetOffset.set(target.x, target.y, target.z, targetOffset.w);
    }
    if (fovY != null) {
      targetOffset.w = fovY;
    }
    if (distance != null) {
      targetPos.x = distance * (targetOffset.w == 0 ? 1 : targetOffset.w);
    }
  }

  /**
    Load current position from current camera position and target.
    Call if you want to modify manually the camera.
  **/
  public function loadFromCamera(animate = false) {
    var scene = if (scene == null) getScene() else scene;
    if (scene == null) {
      throw "Not in scene";
    }
    targetOffset.load(scene.camera.target);
    targetOffset.w = scene.camera.fovY;

    var pos = scene.camera.pos.sub(scene.camera.target);
    var r = pos.length();
    targetPos.set(r, Math.atan2(pos.y, pos.x), Math.acos(pos.z / r));
    targetPos.x *= targetOffset.w;

    curOffset.w = scene.camera.fovY;

    if (!animate) {
      toTarget();
    } else {
      syncCamera(); // reset camera to current
    }
  }

  /**
    Initialize to look at the whole scene, based on reported scene bounds.
  **/
  public function initFromScene() {
    var scene = getScene();
    if (scene == null) throw "Not in scene";
    var bounds = scene.getBounds();
    var center = bounds.getCenter();
    scene.camera.target.load(center.toVector());
    var d = bounds.getMax().sub(center);
    d.scale(5);
    d.z *= 0.5;
    d = d.add(center);
    scene.camera.pos.load(d.toVector());
    loadFromCamera();
  }

  /**
    Stop animation by directly moving to end position.
    Call after set() if you don't want to animate the change
  **/
  public function toTarget() {
    curPos.load(targetPos);
    curOffset.load(targetOffset);
    syncCamera();
  }

  override function onAdd() {
    super.onAdd();
    scene = getScene();
    scene.addEventListener(onEvent);
    if (curOffset.w == 0) {
      // Vertical Field of view
      // Usually doesn't change
      curPos.x *= scene.camera.fovY;
    }
    curOffset.w = scene.camera.fovY; // Vertical field of view
    targetPos.load(curPos); // assigns the curPos to the target Pos
    targetOffset.load(curOffset); // assigns the curOffset to targetOffset
  }

  /**
   * Field of view calculation
   * that will update the target 
   * offset field of view.
   * @param delta 
   */
  public function fov(delta) {
    targetOffset.w += delta;
    if (targetOffset.w >= 179) {
      targetOffset.w = 179;
    }
    if (targetOffset.w < 1) {
      targetOffset.w = 1;
    }
  }

  public dynamic function onClick(e:hxd.Event) {}

  /**
   * Handles any events for the camera from the
   * current scene the 3D Object is on.
   * This handles the controls for when you want to 
   * move the camera in some direction.
   * @param e 
   */
  public function onEvent(e:hxd.Event) {
    var p:Object = this;
    while (p != null) {
      // If p isn't visible, propagate the event.
      if (!p.visible) {
        e.propagate = true;
        return;
      }
      // If p is visible and assign p as the highest
      // object in the tree that is not null (most likely the scene)
      p = p.parent;
    }

    // Matches what to do based on the kind of the event
    switch (e.kind) {
      case EPush:
        @:privateAccess scene.events.startCapture(onEvent,
          function() pushing = -1, e.touchId);
        pushing = e.button;
        pushTime = haxe.Timer.stamp();
        pushStartX = pushX = e.relX;
        pushStartY = pushY = e.relY;
      // Handling when the mouse button is released
      case ERelease, EReleaseOutside:
        if (pushing == e.button) {
          pushing = -1;
          @:privateAccess scene.events.stopCapture();
          if (e.kind == ERelease
            && haxe.Timer.stamp() - pushTime < 0.2
            && hxd.Math.distance(e.relX - pushStartX,
              e.relY - pushStartY) < 5) {
            onClick(e);
          }
        }
      case EMove:
        switch (pushing) {
          // Right Mouse Button
          case 2:
            rot(e.relX - pushX, e.relY - pushY);
            pushX = e.relX;
            pushY = e.relY;
          case _:
            // Do nothing
        }

      case _:
    }
  }

  /**
   * Camera zoom calculation.
   * Will increase or decrease the zoom.
   * @param delta 
   */
  public function zoom(delta:Float) {
    var dist = targetDistance;
    if ((dist > minDistance && delta < 0) || (dist < maxDistance && delta > 0)) {
      // TODO: Add additional camera zoom calculation
      // CameraController
      targetPos.x += Math.pow(zoomAmount, delta);
    } else {
      // By default we use the pan to zoom the camera
      // aka move in on the z access by the  delta
      pan(0, 0, dist * (1 - Math.pow(zoomAmount, delta)));
    }
  }

  /**
   * Rotate the camera.
   * @param dx 
   * @param dy 
   */
  public function rot(dx, dy) {
    moveX += dx;
    moveY += dy;
  }

  /**
   * Pans the camera around the area.
   * @param dx 
   * @param dy 
   * @param dz = 0. 
   */
  public function pan(dx, dy, dz = 0.) {
    var v = new h3d.Vector(dx, dy, dz);
    scene.camera.update();
    // Get camera inverse view(not visible to player)
    // apply the view matrix to the pan vector to create
    // a new offset for the camera
    v.transform3x3(scene.camera.getInverseView());
    // set w to 0 to prevent the camera field of view to be changed.
    v.w = 0;
    targetOffset = targetOffset.add(v);
  }

  /**
   * Camera sync(update loop)
   */
  function syncCamera() {
    var cam = getScene().camera;
    var distance = distance;
    cam.target.load(curOffset);
    cam.target.w = 1;
    cam.pos.set(distance * Math.cos(theta) * Math.sin(phi)
      + cam.target.x,
      distance * Math.sin(theta) * Math.sin(phi)
      + cam.target.y,
      distance * Math.cos(phi)
      + cam.target.z);
    if (!lockZPlanes) {
      cam.zNear = distance * 0.01;
      cam.zFar = distance * 100;
    }
    cam.fovY = curOffset.w;
    cam.update();
  }

  /**
   * Sync update that disables the 
   * camera syncing during the render
   * context baking process.
   * @param ctx 
   */
  override function sync(ctx:RenderContext) {
    // Disable Camera Sync during bake
    if (ctx.scene.renderer.renderMode == LightProbe) {
      return;
    }

    if (!ctx.visibleFlag && !alwaysSync) {
      super.sync(ctx);
      return;
    }

    /**
     * Adds following to the game via the camera.
     */
    if (followTarget != null) {
      targetOffset.x = followTarget.x;
      targetOffset.y = followTarget.y;
      targetOffset.z = followTarget.z;
    }

    if (moveX != 0) {
      targetPos.y += moveX * 0.003 * rotateSpeed;
      moveX *= 1 - friction;
      if (Math.abs(moveX) < 1) {
        moveX = 0;
      }
    }

    if (moveY != 0) {
      targetPos.z -= moveY * 0.003 * rotateSpeed;
      var E = 2e-5;
      var bound = Math.PI - E;
      if (targetPos.z < E) {
        targetPos.z = E;
      }
      if (targetPos.z > bound) {
        targetPos.z = bound;
      }
      moveY *= 1 - friction;
      if (Math.abs(moveY) < 1) {
        moveY = 0;
      }
    }

    var dt = hxd.Math.min(1, 1 - Math.pow(smooth, ctx.elapsedTime * 60));

    var cam = scene.camera;
    curOffset.lerp(curOffset, targetOffset, dt);
    curPos.lerp(curPos, targetPos, dt);

    syncCamera();
    super.sync(ctx);
  }
}