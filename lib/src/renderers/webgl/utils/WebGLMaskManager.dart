part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

class WebGLMaskManager {

  RenderingContext gl;

  List<Graphics> maskStack = [];

  int maskPosition = 0;

  /**
* @class WebGLMaskManager
* @constructor
* @param gl {WebGLContext} the current WebGL drawing context
* @private
*/
  WebGLMaskManager(RenderingContext gl) {
    this.setContext(gl);
  }

  /**
* Sets the drawing context to the one given in parameter
* @method setContext 
* @param gl {WebGLContext} the current WebGL drawing context
*/
  void setContext(RenderingContext gl) {
    this.gl = gl;
  }

  /**
* Applies the Mask and adds it to the current filter stack
* @method pushMask
* @param maskData {Array}
* @param renderSession {RenderSession}
*/
  void pushMask(Graphics maskData, RenderSession renderSession) {
    RenderingContext gl = this.gl;

    if (this.maskStack.length == 0) {
      gl.enable(STENCIL_TEST);
      gl.stencilFunc(ALWAYS, 1, 1);
    }

    //  maskData.visible = false;

    this.maskStack.add(maskData);

    gl.colorMask(false, false, false, true);
    gl.stencilOp(KEEP, KEEP, INCR);

    WebGLGraphics.renderGraphics(maskData, renderSession);

    gl.colorMask(true, true, true, true);
    gl.stencilFunc(NOTEQUAL, 0, this.maskStack.length);
    gl.stencilOp(KEEP, KEEP, KEEP);
  }

  /**
* Removes the last filter from the filter stack and doesn't return it
* @method popMask
*
* @param renderSession {RenderSession} an object containing all the useful parameters
*/
  void popMask(RenderSession renderSession) {
    RenderingContext gl = this.gl;

    Graphics maskData = this.maskStack.removeLast();

    if (maskData != null) {
      gl.colorMask(false, false, false, false);

      //gl.stencilFunc(gl.ALWAYS,1,1);
      gl.stencilOp(KEEP, KEEP, DECR);

      WebGLGraphics.renderGraphics(maskData, renderSession);

      gl.colorMask(true, true, true, true);
      gl.stencilFunc(NOTEQUAL, 0, this.maskStack.length);
      gl.stencilOp(KEEP, KEEP, KEEP);
    }

    if (this.maskStack.length == 0) gl.disable(STENCIL_TEST);
  }

  /**
* Destroys the mask stack
* @method destroy
*/
  void destroy() {
    this.maskStack = null;
    this.gl = null;
  }

}
