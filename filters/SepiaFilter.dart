part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 *
 * This applies a sepia effect to your displayObjects.
 * @class SepiaFilter
 * @contructor
 */
class SepiaFilter extends AbstractFilter{
    
  SepiaFilter()
  {
  
      this.passes = [this];
  
      // set the uniforms
      this.uniforms = {
          'sepia': {'type': '1f', 'value': 1},
      };
  
      this.fragmentSrc = [
          'precision mediump float;',
          'varying vec2 vTextureCoord;',
          'varying vec4 vColor;',
          'uniform float sepia;',
          'uniform sampler2D uSampler;',
  
          'const mat3 sepiaMatrix = mat3(0.3588, 0.7044, 0.1368, 0.2990, 0.5870, 0.1140, 0.2392, 0.4696, 0.0912);',
  
          'void main(void) {',
          '   gl_FragColor = texture2D(uSampler, vTextureCoord);',
          '   gl_FragColor.rgb = mix( gl_FragColor.rgb, gl_FragColor.rgb * sepiaMatrix, sepia);',
         // '   gl_FragColor = gl_FragColor * vColor;',
          '}'
      ];
  }
  
  
  /**
  The strength of the sepia. 1 will apply the full sepia effect, 0 will make the object its normal color
  @property sepia
  */
  double get sepia => this.uniforms['sepia']['value'];
    set sepia(double value) => this.uniforms['sepia']['value'] = value;
    
}
