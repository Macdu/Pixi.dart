part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

class WebGLShaderManager {

  int maxAttibs = 10;
  List<bool> attribState = [];
  List<bool> tempAttribState = [];

  RenderingContext gl;

  /// the next one is used for rendering primatives
  PrimitiveShader primitiveShader;

  /// this shader is used for the default sprite rendering
  PixiShader defaultShader;

  /// this shader is used for the fast sprite rendering
  PixiFastShader fastShader;

  var currentShader;

  /**
* @class WebGLShaderManager
* @constructor
* @param gl {WebGLContext} the current WebGL drawing context
* @private
*/
  WebGLShaderManager(RenderingContext gl) {

    for (var i = 0; i < this.maxAttibs; i++) {
      this.attribState[i] = false;
    }

    this.setContext(gl);
    // the final one is used for the rendering strips
    //this.stripShader = new PIXI.StripShader(gl);
  }


  /**
* Initialises the context and the properties
* @method setContext 
* @param gl {WebGLContext} the current WebGL drawing context
* @param transparent {Boolean} Whether or not the drawing context should be transparent
*/
  void setContext(RenderingContext gl) {
    this.gl = gl;

    // the next one is used for rendering primatives
    this.primitiveShader = new PrimitiveShader(gl);

    // this shader is used for the default sprite rendering
    this.defaultShader = new PixiShader(gl);

    // this shader is used for the fast sprite rendering
    this.fastShader = new PixiFastShader(gl);


    this.activateShader(this.defaultShader);
  }


  /**
* Takes the attributes given in parameters 
* @method setAttribs
* @param attribs {Array} attribs 
*/
  void setAttribs(List<int> attribs) {
    // reset temp state

    int i;

    for (i = 0; i < this.tempAttribState.length; i++) {
      this.tempAttribState[i] = false;
    }

    // set the new attribs
    for (i = 0; i < attribs.length; i++) {
      int attribId = attribs[i];
      this.tempAttribState[attribId] = true;
    }

    RenderingContext gl = this.gl;

    for (i = 0; i < this.attribState.length; i++) {

      if (this.attribState[i] != this.tempAttribState[i]) {
        this.attribState[i] = this.tempAttribState[i];

        if (this.tempAttribState[i]) {
          gl.enableVertexAttribArray(i);
        } else {
          gl.disableVertexAttribArray(i);
        }
      }
    }
  }

  /**
* Sets-up the given shader 
*
* @method activateShader
* @param shader {Object} the shader that is going to be activated
*/
  void activateShader(shader) {
    //if(this.currentShader == shader)return;

    this.currentShader = shader;

    this.gl.useProgram(shader.program);
    this.setAttribs(shader.attributes);

  }

  /**
* Triggers the primitive shader
* @method activatePrimitiveShader
*/
  void activatePrimitiveShader() {
    RenderingContext gl = this.gl;

    gl.useProgram(this.primitiveShader.program);

    this.setAttribs(this.primitiveShader.attributes);

  }

  /**
* Disable the primitive shader
* @method deactivatePrimitiveShader
*/
  void deactivatePrimitiveShader() {
    RenderingContext gl = this.gl;

    gl.useProgram(this.defaultShader.program);

    this.setAttribs(this.defaultShader.attributes);
  }

  /**
* Destroys
* @method destroy
*/
  void destroy() {
    this.attribState = null;

    this.tempAttribState = null;

    this.primitiveShader.destroy();

    this.defaultShader.destroy();

    this.fastShader.destroy();

    this.gl = null;
  }

}
