package shaders;

import h3d.Vector;
import h3d.shader.BaseMesh;

class ToonShader extends BaseMesh {
  static var SRC = {
    @param var texture:Sampler2D;
    @param var depthT:Sampler2D;
    @param var lightDir:Vec3;
    // Shared Normals
    // Shared with the texture shader
    // Have access to the  calculatedUVs
    var calculatedUV:Vec2;
    // var transformedNormal:Vec3; //exists in base mesh
    function fragment() {
      var texColor = texture.get(calculatedUV);
      var depthColor = texture.get(screenUV);
      // Toon Shading
      // Light intensity by calculating how light hits
      // the normal vector the mesh
      var zFlipNorm = vec3(transformedNormal.x, transformedNormal.y,
        transformedNormal.z * -1);
      var intensity = clamp(dot(lightDir, (zFlipNorm)), 0., 1.);
      var tooning = clamp(floor(intensity / .25), 0.0, 1.);
      texColor.rgb *= vec3(tooning);
      texColor.b *= 1.55;
      var result = texColor;
      if (intensity > 0.8) {
        result.rgb *= vec3(1, .71, .75);
        // result = vec4(0, 0, 0.3, 1);
      }
      pixelColor = result;
    }
  }

  public function new(tex:h3d.mat.Texture, lightDir:Vector) {
    super();
    this.texture = tex;
    this.lightDir = lightDir;
  }
}