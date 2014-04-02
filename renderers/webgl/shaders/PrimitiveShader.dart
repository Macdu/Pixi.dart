part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

class PrimitiveShader {


  /**
       * @property gl
       * @type WebGLContext
       */
  RenderingContext gl;

  /**
      * @property {any} program - The WebGL program.
      */
  Program program = null;

  /**
       * @property fragmentSrc
       * @type Array
       */
  List fragmentSrc = ['precision mediump float;', 'varying vec4 vColor;',
      'void main(void) {', '   gl_FragColor = vColor;', '}'];

  /**
       * @property vertexSrc
       * @type Array
       */
  List vertexSrc = ['attribute vec2 aVertexPosition;', 'attribute vec4 aColor;',
      'uniform mat3 translationMatrix;', 'uniform vec2 projectionVector;',
      'uniform vec2 offsetVector;', 'uniform float alpha;', 'uniform vec3 tint;',
      'varying vec4 vColor;', 'void main(void) {',
      '   vec3 v = translationMatrix * vec3(aVertexPosition , 1.0);',
      '   v -= offsetVector.xyx;',
      '   gl_Position = vec4( v.x / projectionVector.x -1.0, v.y / -projectionVector.y + 1.0 , 0.0, 1.0);',
      '   vColor = aColor * vec4(tint * alpha, alpha);', '}'];

  // get and store the uniforms for the shader
  UniformLocation projectionVector, offsetVector, tintColor;


  // get and store the attributes
  int aVertexPosition, colorAttribute;

  List<int> attributes;

  List uniforms;

  UniformLocation translationMatrix, alpha;


  /**
* @class PrimitiveShader
* @constructor
* @param gl {WebGLContext} the current WebGL drawing context
*/
  PrimitiveShader(RenderingContext gl) {
    /**
     * @property gl
     * @type WebGLContext
     */
    this.gl = gl;



    this.init();
  }

  /**
* Initialises the shader
* @method init
*
*/
  void init() {

    RenderingContext gl = this.gl;

    Program program = compileProgram(gl, this.vertexSrc, this.fragmentSrc);
    gl.useProgram(program);

    // get and store the uniforms for the shader
    this.projectionVector = gl.getUniformLocation(program, 'projectionVector');
    this.offsetVector = gl.getUniformLocation(program, 'offsetVector');
    this.tintColor = gl.getUniformLocation(program, 'tint');


    // get and store the attributes
    this.aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
    this.colorAttribute = gl.getAttribLocation(program, 'aColor');

    this.attributes = [this.aVertexPosition, this.colorAttribute];

    this.translationMatrix = gl.getUniformLocation(program, 'translationMatrix'
        );
    this.alpha = gl.getUniformLocation(program, 'alpha');

    this.program = program;
  }

  /**
* Destroys the shader
* @method destroy
*
*/
  void destroy() {
    this.gl.deleteProgram(this.program);
    this.uniforms = null;
    this.gl = null;

    this.attributes = null;
  }

}
