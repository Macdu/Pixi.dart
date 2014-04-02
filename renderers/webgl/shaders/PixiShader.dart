part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 * @author Richard Davey http://www.photonstorm.com @photonstorm
 */
class PixiShader {
  /**
* @class PixiShader
* @constructor
*/

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
      * @property {list} fragmentSrc - The fragment shader.
      */
  List fragmentSrc = ['precision lowp float;', 'varying vec2 vTextureCoord;',
      'varying vec4 vColor;', 'uniform sampler2D uSampler;', 'void main(void) {',
      '   gl_FragColor = texture2D(uSampler, vTextureCoord) * vColor ;', '}'];

  List vertexSrc = null;


  /**
      * @property {number} textureCount - A local texture counter for multi-texture shaders.
      */
  int textureCount = 0;

  List attributes = [];

  List uniforms;

  // get and store the uniforms for the shader
  UniformLocation uSampler, projectionVector, offsetVector, dimensions;

  // get and store the attributes
  int aVertexPosition, aTextureCoord, colorAttribute;

  PixiShader(RenderingContext gl) {
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

    Program program = compileProgram(gl, (this.vertexSrc != null) ?
        this.VertexSrc : PixiShader.defaultVertexSrc, this.fragmentSrc);

    gl.useProgram(program);

    // get and store the uniforms for the shader
    this.uSampler = gl.getUniformLocation(program, 'uSampler');
    this.projectionVector = gl.getUniformLocation(program, 'projectionVector');
    this.offsetVector = gl.getUniformLocation(program, 'offsetVector');
    this.dimensions = gl.getUniformLocation(program, 'dimensions');

    // get and store the attributes
    this.aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
    this.aTextureCoord = gl.getAttribLocation(program, 'aTextureCoord');
    this.colorAttribute = gl.getAttribLocation(program, 'aColor');


    // Begin worst hack eva //

    // WHY??? ONLY on my chrome pixel the line above returns -1 when using filters?
    // maybe its something to do with the current state of the gl context.
    // Im convinced this is a bug in the chrome browser as there is NO reason why this should be returning -1 especially as it only manifests on my chrome pixel
    // If theres any webGL people that know why could happen please help :)
    if (this.colorAttribute == -1) {
      this.colorAttribute = 2;
    }

    this.attributes = [this.aVertexPosition, this.aTextureCoord,
        this.colorAttribute];

    // End worst hack eva //

    // add those custom shaders!
    for (PixiUniform key in this.uniforms) {
      // get the uniform locations..
      key.uniformLocation = gl.getUniformLocation(program, key);
    }

    this.initUniforms();

    this.program = program;
  }

  /**
* Initialises the shader uniform values.
* Uniforms are specified in the GLSL_ES Specification: http://www.khronos.org/registry/webgl/specs/latest/1.0/
* http://www.khronos.org/registry/gles/specs/2.0/GLSL_ES_Specification_1.0.17.pdf
*
* @method initUniforms
*/
  void initUniforms() {
    this.textureCount = 1;
    RenderingContext gl = this.gl;
    PixiUniform uniform;

    for (PixiUniform key in this.uniforms) {
      uniform = key;

      int type = uniform.type;

      if (type == "sampler2D") {
        uniform._init = false;

        if (uniform.value != null) {
          this.initSampler2D(uniform);
        }
      } else if (type == "mat2" || type == "mat3" || type == "mat4") {
        //  These require special handling
        uniform.glMatrix = true;
        uniform.glValueLength = 1;

        if (type == "mat2") {
          uniform.glFunc = gl.uniformMatrix2fv;
        } else if (type == "mat3") {
          uniform.glFunc = gl.uniformMatrix3fv;
        } else if (type == "mat4") {
          uniform.glFunc = gl.uniformMatrix4fv;
        }
      } else {
        //  GL function reference
        uniform.setReferenceGLFunction();

        if (type == '2f' || type == '2i') {
          uniform.glValueLength = 2;
        } else if (type == '3f' || type == '3i') {
          uniform.glValueLength = 3;
        } else if (type == '4f' || type == '4i') {
          uniform.glValueLength = 4;
        } else {
          uniform.glValueLength = 1;
        }
      }
    }

  }

  /**
* Initialises a Sampler2D uniform (which may only be available later on after initUniforms once the texture has loaded)
*
* @method initSampler2D
*/
  void initSampler2D(UniformLocation uniform) {
    if (uniform.value == null || uniform.value.baseTexture == null ||
        !uniform.value.baseTexture.hasLoaded) {
      return;
    }

    RenderingContext gl = this.gl;

    gl.activeTexture(uniform.getTextureFromCount(this.textureCount));
    gl.bindTexture(TEXTURE_2D, uniform.value.baseTexture._glTexture);

    //  Extended texture data
    if (uniform.textureData != null) {
      Map data = uniform.textureData;

      // GLTexture = mag linear, min linear_mipmap_linear, wrap repeat + gl.generateMipmap(gl.TEXTURE_2D);
      // GLTextureLinear = mag/min linear, wrap clamp
      // GLTextureNearestRepeat = mag/min NEAREST, wrap repeat
      // GLTextureNearest = mag/min nearest, wrap clamp
      // AudioTexture = whatever + luminance + width 512, height 2, border 0
      // KeyTexture = whatever + luminance + width 256, height 2, border 0

      //  magFilter can be: gl.LINEAR, gl.LINEAR_MIPMAP_LINEAR or gl.NEAREST
      //  wrapS/T can be: gl.CLAMP_TO_EDGE or gl.REPEAT

      int magFilter = (data.containsKey('magFilter')) ? data['magFilter'] :
          LINEAR;
      int minFilter = (data.containsKey('minFilter')) ? data['minFilter'] :
          LINEAR;
      int wrapS = (data.containsKey('wrapS')) ? data['wrapS'] : CLAMP_TO_EDGE;
      int wrapT = (data.containsKey('wrapT')) ? data['wrapT'] : CLAMP_TO_EDGE;
      int format = (data.containsKey('luminance')) ? LUMINANCE : RGBA;

      if (data.containsKey('repeat') && data['repeat']) {
        wrapS = REPEAT;
        wrapT = REPEAT;
      }

      gl.pixelStorei(UNPACK_FLIP_Y_WEBGL, data['flipY']);

      if (data.containsKey('width')) {
        int width = (data['width'] != null) ? data['width'] : 512;
        int height = (data['height'] != null) ? data['height'] : 2;
        int border = (data['border'] != null) ? data['border'] : 0;

        // void texImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, ArrayBufferView? pixels);
        gl.texImage2D(TEXTURE_2D, 0, format, width, height, border, format,
            UNSIGNED_BYTE, null);
      } else {
        //  void texImage2D(GLenum target, GLint level, GLenum internalformat, GLenum format, GLenum type, ImageData? pixels);
        gl.texImage2D(TEXTURE_2D, 0, format, RGBA, UNSIGNED_BYTE,
            uniform.value.baseTexture.source);
      }

      gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, magFilter);
      gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, minFilter);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, wrapS);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, wrapT);
    }

    gl.uniform1i(uniform.uniformLocation, this.textureCount);

    uniform._init = true;

    this.textureCount++;

  }

  /**
* Updates the shader uniform values.
*
* @method syncUniforms
*/
  void syncUniforms() {
    this.textureCount = 1;
    PixiUniform uniform;
    RenderingContext gl = this.gl;

    //  This would probably be faster in an array and it would guarantee key order
    for (PixiUniform key in this.uniforms) {

      uniform = key;

      if (uniform.glValueLength == 1) {
        if (uniform.glMatrix == true) {
          uniform.glFunc(uniform.uniformLocation, uniform.transpose,
              uniform.value);
        } else {
          uniform.glFunc(uniform.uniformLocation, uniform.value);
        }
      } else if (uniform.glValueLength == 2) {
        uniform.glFunc(uniform.uniformLocation, uniform.value.x, uniform.value.y
            );
      } else if (uniform.glValueLength == 3) {
        uniform.glFunc(uniform.uniformLocation, uniform.value.x,
            uniform.value.y, uniform.value.z);
      } else if (uniform.glValueLength == 4) {
        uniform.glFunc(uniform.uniformLocation, uniform.value.x,
            uniform.value.y, uniform.value.z, uniform.value.w);
      } else if (uniform.type == 'sampler2D') {
        if (uniform._init) {
          gl.activeTexture(uniform.getTextureFromCount(this.textureCount));
          gl.bindTexture(TEXTURE_2D,
              (uniform.value.baseTexture._glTextures[WebGLRenderer._getIndexFirst(gl)] !=
              null) ? uniform.value.baseTexture._glTextures[WebGLRenderer._getIndexFirst(gl)]
              : createWebGLTexture(uniform.value.baseTexture, gl));
          gl.uniform1i(uniform.uniformLocation, this.textureCount);
          this.textureCount++;
        } else {
          this.initSampler2D(uniform);
        }
      }
    }

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

  /**
*
* @property defaultVertexSrc
* @type String
*/
  static List defaultVertexSrc = ['attribute vec2 aVertexPosition;',
      'attribute vec2 aTextureCoord;', 'attribute vec2 aColor;',
      'uniform vec2 projectionVector;', 'uniform vec2 offsetVector;',
      'varying vec2 vTextureCoord;', 'varying vec4 vColor;',
      'const vec2 center = vec2(-1.0, 1.0);', 'void main(void) {',
      '   gl_Position = vec4( ((aVertexPosition + offsetVector) / projectionVector) + center , 0.0, 1.0);',
      '   vTextureCoord = aTextureCoord;',
      '   vec3 color = mod(vec3(aColor.y/65536.0, aColor.y/256.0, aColor.y), 256.0) / 256.0;',
      '   vColor = vec4(color * aColor.x, aColor.x);', '}'];

}
