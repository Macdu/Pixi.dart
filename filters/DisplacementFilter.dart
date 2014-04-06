part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 *
 * The DisplacementFilter class uses the pixel values from the specified texture (called the displacement map) to perform a displacement of an object.
 * You can use this filter to apply all manor of crazy warping effects
 * Currently the r property of the texture is used offset the x and the g propery of the texture is used to offset the y.
 * @class DisplacementFilter
 * @contructor
 * @param texture {Texture} The texture used for the displacemtent map * must be power of 2 texture at the moment
 */
class DisplacementFilter extends AbstractFilter{
  

  DisplacementFilter(Texture texture)
{

    this.passes = [this];
    texture.baseTexture._powerOf2 = true;

    // set the uniforms
    this.uniforms = {
        'displacementMap': {'type': 'sampler2D', 'value':texture},
        'scale':           {'type': '2f', 'value':{'x':30, 'y':30}},
        'offset':          {'type': '2f', 'value':{'x':0, 'y':0}},
        'mapDimensions':   {'type': '2f', 'value':{'x':1, 'y':5112}},
        'dimensions':   {'type': '4fv', 'value':[0,0,0,0]}
    };

    if(texture.baseTexture.hasLoaded)
    {
        this.uniforms['mapDimensions']['value']['x'] = texture.width;
        this.uniforms['mapDimensions']['value']['y'] = texture.height;
    }
    else
    {
        texture.baseTexture.listen('loaded', this.onTextureLoaded);
    }

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform sampler2D displacementMap;',
        'uniform sampler2D uSampler;',
        'uniform vec2 scale;',
        'uniform vec2 offset;',
        'uniform vec4 dimensions;',
        'uniform vec2 mapDimensions;',// = vec2(256.0, 256.0);',
        // 'const vec2 textureDimensions = vec2(750.0, 750.0);',

        'void main(void) {',
        '   vec2 mapCords = vTextureCoord.xy;',
        //'   mapCords -= ;',
        '   mapCords += (dimensions.zw + offset)/ dimensions.xy ;',
        '   mapCords.y *= -1.0;',
        '   mapCords.y += 1.0;',
        '   vec2 matSample = texture2D(displacementMap, mapCords).xy;',
        '   matSample -= 0.5;',
        '   matSample *= scale;',
        '   matSample /= mapDimensions;',
        '   gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.x + matSample.x, vTextureCoord.y + matSample.y));',
        '   gl_FragColor.rgb = mix( gl_FragColor.rgb, gl_FragColor.rgb, 1.0);',
        '   vec2 cord = vTextureCoord;',

        //'   gl_FragColor =  texture2D(displacementMap, cord);',
     //   '   gl_FragColor = gl_FragColor;',
        '}'
    ];
}
  
  onTextureLoaded(_)
  {
      this.uniforms['mapDimensions']['value']['x'] = this.uniforms['displacementMap']['value']['width'];
      this.uniforms['mapDimensions']['value']['y'] = this.uniforms['displacementMap']['value']['height'];
  }
  
  /**
   * The texture used for the displacemtent map * must be power of 2 texture at the moment
   *
   * @property map
   * @type Texture
   */
  Texture get map => this.uniforms['displacementMap']['value'];
    set map(Texture value) => this.uniforms['displacementMap']['value'] = value;
  
  /**
   * The multiplier used to scale the displacement result from the map calculation.
   *
   * @property scale
   * @type Point
   */
   Map get scale =>  this.uniforms['scale']['value'];
   set scale(Map value ) => this.uniforms['scale']['value'] = value;
  
  /**
   * The offset used to move the displacement map.
   *
   * @property offset
   * @type Point
   */
   Map get offset =>  this.uniforms['offset']['value'];
    set offset(Map value ) => this.uniforms['offset']['value'] = value;
    
}
