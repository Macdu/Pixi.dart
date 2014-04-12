part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 * original filter: https://github.com/evanw/glfx.js/blob/master/src/filters/fun/dotscreen.js
 */

/**
 *
 * This filter applies a dotscreen effect making display objects appear to be made out of black and white halftone dots like an old printer
 * @class DotScreenFilter
 * @contructor
 */
class DotScreenFilter extends AbstractFilter{
DotScreenFilter(){

    this.passes = [this];

    // set the uniforms
    this.uniforms = {
        'scale': {'type': '1f', 'value':1},
        'angle': {'type': '1f', 'value':5},
        'dimensions':   {'type': '4fv', 'value':[0,0,0,0]}
    };

    this.fragmentSrc = [
        'precision mediump float;',
        'varying vec2 vTextureCoord;',
        'varying vec4 vColor;',
        'uniform vec4 dimensions;',
        'uniform sampler2D uSampler;',

        'uniform float angle;',
        'uniform float scale;',

        'float pattern() {',
        '   float s = sin(angle), c = cos(angle);',
        '   vec2 tex = vTextureCoord * dimensions.xy;',
        '   vec2 point = vec2(',
        '       c * tex.x - s * tex.y,',
        '       s * tex.x + c * tex.y',
        '   ) * scale;',
        '   return (sin(point.x) * sin(point.y)) * 4.0;',
        '}',

        'void main() {',
        '   vec4 color = texture2D(uSampler, vTextureCoord);',
        '   float average = (color.r + color.g + color.b) / 3.0;',
        '   gl_FragColor = vec4(vec3(average * 10.0 - 5.0 + pattern()), color.a);',
        '}'
    ];
}

/**
 *
 * This describes the the scale
 * @property scale
 * @type Number
 */
Map get scale =>  this.uniforms['scale']['value'];
set scale(Map value ){ this.uniforms['scale']['value'] = value;this.dirty = true;}

/**
 *
 * This radius describes angle
 * @property angle
 * @type Number
 */
num get angle =>  this.uniforms['angle']['value'];
set angle(num value ){ this.uniforms['angle']['value'] = value;this.dirty = true;}

}