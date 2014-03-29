part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 *
 * This filter applies a twist effect making display objects appear twisted in the given direction
 * @class TwistFilter
 * @contructor
 */
class TwistFilter extends AbstractFilter{
    
  TwistFilter()
  {
  
      this.passes = [this];
  
      // set the uniforms
      this.uniforms = {
          'radius': {'type': '1f', 'value':0.5},
          'angle': {'type': '1f', 'value':5},
          'offset': {'type': '2f', 'value':{'x':0.5, 'y':0.5}},
      };
  
      this.fragmentSrc = [
          'precision mediump float;',
          'varying vec2 vTextureCoord;',
          'varying vec4 vColor;',
          'uniform vec4 dimensions;',
          'uniform sampler2D uSampler;',
  
          'uniform float radius;',
          'uniform float angle;',
          'uniform vec2 offset;',
  
          'void main(void) {',
          '   vec2 coord = vTextureCoord - offset;',
          '   float distance = length(coord);',
  
          '   if (distance < radius) {',
          '       float ratio = (radius - distance) / radius;',
          '       float angleMod = ratio * ratio * angle;',
          '       float s = sin(angleMod);',
          '       float c = cos(angleMod);',
          '       coord = vec2(coord.x * c - coord.y * s, coord.x * s + coord.y * c);',
          '   }',
  
          '   gl_FragColor = texture2D(uSampler, coord+offset);',
          '}'
      ];
  }
  
  
  /**
   *
   * This point describes the the offset of the twist
   * @property size
   * @type Point
   */
  Map get offset => this.uniforms['offset']['value'];
    set offset(Map value) => this.uniforms['offset']['value'] = value;
  
  /**
   *
   * This radius describes size of the twist
   * @property size
   * @type Number
   */
    double get radius => this.uniforms['radius']['value'];
      set radius(double value){
        this.uniforms['radius']['value'] = value;
        this.dirty = true;
      }
  
  /**
   *
   * This radius describes angle of the twist
   * @property angle
   * @type Number
   */
      double get angle => this.uniforms['angle']['value'];
        set angle(double value) => this.uniforms['angle']['value'] = value;
        
}