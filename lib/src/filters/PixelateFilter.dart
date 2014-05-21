part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 *
 * This filter applies a pixelate effect making display objects appear 'blocky'
 * @class PixelateFilter
 * @contructor
 */
class PixelateFilter extends AbstractFilter{
  
  
  PixelateFilter()
  {
  
      this.passes = [this];
  
      // set the uniforms
      this.uniforms = {
          'invert': {'type': '1f', 'value': 0},
          'dimensions': {'type': '4fv', 'value':new Float32List.fromList([10000.0, 100.0, 10.0, 10.0])},
          'pixelSize': {'type': '2f', 'value':{'x':10, 'y':10}}
      };
  
      this.fragmentSrc = [
          'precision mediump float;',
          'varying vec2 vTextureCoord;',
          'varying vec4 vColor;',
          'uniform vec2 testDim;',
          'uniform vec4 dimensions;',
          'uniform vec2 pixelSize;',
          'uniform sampler2D uSampler;',
  
          'void main(void) {',
          '   vec2 coord = vTextureCoord;',
  
          '   vec2 size = dimensions.xy/pixelSize;',
  
          '   vec2 color = floor( ( vTextureCoord * size ) ) / size + pixelSize/dimensions.xy * 0.5;',
          '   gl_FragColor = texture2D(uSampler, color);',
          '}'
      ];
  }
  
  /**
   *
   * This a point that describes the size of the blocs. x is the width of the block and y is the the height
   * @property size
   * @type Point
   */
  Map get size => this.uniforms['pixelSize']['value'];
    set size(Map value){
      this.uniforms['pixelSize']['value'] = value;
      this.dirty = true;
    }
    
}
