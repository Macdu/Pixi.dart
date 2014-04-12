part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */
class CrossHatchFilter extends BlurYFilter{
  
  
  CrossHatchFilter()
  {
  
      this.passes = [this];
  
      // set the uniforms
      this.uniforms = {
          'blur': {'type': '1f', 'value': 1 / 512},
      };
  
      this.fragmentSrc = [
          'precision mediump float;',
          'varying vec2 vTextureCoord;',
          'varying vec4 vColor;',
          'uniform float blur;',
          'uniform sampler2D uSampler;',
  
          'void main(void) {',
          '    float lum = length(texture2D(uSampler, vTextureCoord.xy).rgb);',
  
          '    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);',
  
          '    if (lum < 1.00) {',
          '        if (mod(gl_FragCoord.x + gl_FragCoord.y, 10.0) == 0.0) {',
          '            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);',
          '        }',
          '    }',
  
          '    if (lum < 0.75) {',
          '        if (mod(gl_FragCoord.x - gl_FragCoord.y, 10.0) == 0.0) {',
          '            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);',
          '        }',
          '    }',
  
          '    if (lum < 0.50) {',
          '        if (mod(gl_FragCoord.x + gl_FragCoord.y - 5.0, 10.0) == 0.0) {',
          '            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);',
          '        }',
          '    }',
  
          '    if (lum < 0.3) {',
          '        if (mod(gl_FragCoord.x - gl_FragCoord.y - 5.0, 10.0) == 0.0) {',
          '            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);',
          '        }',
          '    }',
          '}'
      ];
  }
  
  double get blur => this.uniforms['blur']['value'] / (1/7000);
    set blur (double value){
      this.uniforms['blur']['value'] = (1/7000) * value;
    }
}
