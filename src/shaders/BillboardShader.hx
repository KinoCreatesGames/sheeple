package shaders;

import hxsl.Shader;

/**
 * uses the BaseMesh shader with this shader; 
 * they are combined together.
 */
class BillboardShader extends Shader {
  static var SRC = {
    @global var camera:{proj:Mat4, view:Mat4};
    @global var global:{@perObject var modelView:Mat4;};
    // https://github.com/HeapsIO/heaps/blob/master/h3d/shader/BaseMesh.hx#L58
    var relativePosition:Vec3;
    var projectedPosition:Vec4;
    var transformedNormal:Vec3;
    function vertex() {
      var _BillboardSize = 1.0;

      var vpos = (relativePosition * global.modelView.mat3()) * vec3(_BillboardSize,
        _BillboardSize, 1.0);
      var worldCoord = vec4(0, 0, 0,
        1) * global.modelView; // modelView is world coordinates, last column is transform
      var viewPos = worldCoord * camera.view + vec4(vpos, 0.0);
      projectedPosition = viewPos * camera.proj;
    }
  };
}