part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 *
 * The AlphaMaskFilter class uses the pixel values from the specified texture (called the displacement map) to perform a displacement of an object.
 * You can use this filter to apply all manor of crazy warping effects
 * Currently the r property of the texture is used to offset the x and the g propery of the texture is used to offset the y.
 * @class AlphaMaskFilter
 * @contructor
 * @param texture {Texture} The texture used for the displacemtent map * must be power of 2 texture at the moment
 */
class AlphaMaskFilter extends AbstractFilter{
  
  AlphaMaskFilter(Texture texture) : super()
  {

    this.passes = [this];
    texture.baseTexture._powerOf2 = true;

    // set the uniforms
    this.uniforms = {
        'mask': {'type': 'sampler2D', 'value':texture},
        'mapDimensions':   {'type': '2f', 'value':{'x':1, 'y':5112}},
        'dimensions':   {'type': '4fv', 'value':[0,0,0,0]}
    };

    if(texture.baseTexture.hasLoaded)
    {
        this.uniforms['mask']['value']['x'] = texture.width;
        this.uniforms['mask']['value']['y'] = texture.height;
    }
    else
    {
        texture.baseTexture.listen('loaded', this.onTextureLoaded);
    }

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform sampler2D mask;',
        'uniform sampler2D uSampler;',
        'uniform vec2 offset;',
        'uniform vec4 dimensions;',
        'uniform vec2 mapDimensions;',

        'void main(void) {',
        '   vec2 mapCords = vTextureCoord.xy;',
        '   mapCords += (dimensions.zw + offset)/ dimensions.xy ;',
        '   mapCords.y *= -1.0;',
        '   mapCords.y += 1.0;',
        '   mapCords *= dimensions.xy / mapDimensions;',

        '   vec4 original =  texture2D(uSampler, vTextureCoord);',
        '   float maskAlpha =  texture2D(mask, mapCords).r;',
        '   original *= maskAlpha;',
        //'   original.rgb *= maskAlpha;',
        '   gl_FragColor =  original;',
        //'   gl_FragColor = gl_FragColor;',
        '}'
    ];
}

  
  void onTextureLoaded (_)
  {
      this.uniforms['mapDimensions']['value']['x'] = this.uniforms['mask']['value'].width;
      this.uniforms['mapDimensions']['value']['y'] = this.uniforms['mask']['value'].height;
  
      this.uniforms['mask']['value'].baseTexture.off('loaded', this.onTextureLoaded);
  }
  
  /**
   * The texture used for the displacemtent map * must be power of 2 texture at the moment
   *
   * @property map
   * @type Texture
   */
  Texture get map => this.uniforms['mask']['value'];
    set map(Texture texture) => this.uniforms['mask']['value'] = texture;
    
}
  
