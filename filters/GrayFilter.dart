part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 *
 * This turns your displayObjects to black and white.
 * @class GrayFilter
 * @contructor
 */
class GrayFilter extends AbstractFilter{
  
  GrayFilter(){

    this.passes = [this];

    // set the uniforms
    this.uniforms = {
        'gray': {'type': '1f', 'value': 1.0},
    };

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform sampler2D uSampler;',
        'uniform float gray;',

        'void main(void) {',
        '   gl_FragColor = texture2D(uSampler, vTextureCoord);',
        '   gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0.2126*gl_FragColor.r + 0.7152*gl_FragColor.g + 0.0722*gl_FragColor.b), gray);',
     //   '   gl_FragColor = gl_FragColor;',
        '}'
    ];
  }

  /**
  The strength of the gray. 1 will make the object black and white, 0 will make the object its normal color
  @property gray
  */
  double get gray => this.uniforms['gray']['value'];
    set gray(double value) => this.uniforms['gray']['value'] = value;
    
}
