package shaders;

import h3d.shader.BaseMesh;

/**
 * Outline 3D Shader
 */
class Outline3D extends BaseMesh {
  static var SRC = {
    var minSeparation:Float;
    var maxSeparation:Float;
    var minDistance:Float;
    var maxDistance:Float;
    var originalPosition:Vec4;
    @param var outlineWidth:Float;
    @param var outlineColor:Vec4;
    // Update the vertex of the tris and scale up
    function vertex() {
      var expand = 1.1;
      originalPosition = projectedPosition * vec4(1, camera.projFlip, 1, 1);
      output.position *= expand;
    }
    function fragment() {
      minSeparation = 1.0;
      maxSeparation = 3.0;
      minDistance = 0.5;
      maxDistance = 1.0;
      var size = 1.;
      var mx = 0.0;
      screenUV = screenToUv(projectedPosition.xy / projectedPosition.w);
      var fragPosition = transformedPosition;
      // for (i in -100...100) {
      //   for (j in -100...100) {
      //     mx = max(abs(fragPosition.y - (i / 100)), mx);
      //   }
      // }

      // outlineColor.rgb = vec3(mx);
      var last = vec3(outlineColor.rgb);
      mx = fragPosition.x;
      var diff = smoothstep(minDistance, maxDistance, mx);
      last.rgb = vec3(mx);
      output.color = vec4(last, diff);
    }
  }
}