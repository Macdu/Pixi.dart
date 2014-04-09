part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */
class StripShader {

  /**
      * @property {any} program - The WebGL program.
      */
  Program program = null;

  /**
       * @property {array} fragmentSrc - The fragment shader.
       */
  List fragmentSrc = ['precision mediump float;', 'varying vec2 vTextureCoord;',
      'varying float vColor;', 'uniform float alpha;', 'uniform sampler2D uSampler;',
      'void main(void) {',
      '   gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.x, vTextureCoord.y));',
      '   gl_FragColor = gl_FragColor * alpha;', '}'];

  /**
      * @property {list} fragmentSrc - The fragment shader.
      */
  List vertexSrc = ['attribute vec2 aVertexPosition;',
      'attribute vec2 aTextureCoord;', 'attribute float aColor;',
      'uniform mat3 translationMatrix;', 'uniform vec2 projectionVector;',
      'varying vec2 vTextureCoord;', 'uniform vec2 offsetVector;',
      'varying float vColor;', 'void main(void) {',
      '   vec3 v = translationMatrix * vec3(aVertexPosition, 1.0);',
      '   v -= offsetVector.xyx;',
      '   gl_Position = vec4( v.x / projectionVector.x -1.0, v.y / projectionVector.y + 1.0 , 0.0, 1.0);',
      '   vTextureCoord = aTextureCoord;', '   vColor = aColor;', '}'];

  // get and store the uniforms for the shader
  UniformLocation uSampler, projectionVector, offsetVector;
  int colorAttribute;
  //this.dimensions = gl.getUniformLocation(this.program, 'dimensions');

  // get and store the attributes
  int aVertexPosition, aTextureCoord;

  UniformLocation translationMatrix, alpha;

  /**
* Initialises the shader
* @method init
*
*/
  void init() {

    //TODO: not sure;
    RenderingContext gl = glContexts.last;

    Program program = compileProgram(gl, this.vertexSrc, this.fragmentSrc);
    gl.useProgram(program);

    // get and store the uniforms for the shader
    this.uSampler = gl.getUniformLocation(program, 'uSampler');
    this.projectionVector = gl.getUniformLocation(program, 'projectionVector');
    this.offsetVector = gl.getUniformLocation(program, 'offsetVector');
    this.colorAttribute = gl.getAttribLocation(program, 'aColor');
    //this.dimensions = gl.getUniformLocation(this.program, 'dimensions');

    // get and store the attributes
    this.aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
    this.aTextureCoord = gl.getAttribLocation(program, 'aTextureCoord');

    this.translationMatrix = gl.getUniformLocation(program, 'translationMatrix'
        );
    this.alpha = gl.getUniformLocation(program, 'alpha');

    this.program = program;
  }

}
