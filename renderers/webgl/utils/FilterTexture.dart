part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

class FilterTexture {

  RenderingContext gl;

  // next time to create a frame buffer and texture
  Framebuffer frameBuffer;
  Texture texture;

  int width;
  int height;

  /**
* @class FilterTexture
* @constructor
* @param gl {WebGLContext} the current WebGL drawing context
* @param width {Number} the horizontal range of the filter
* @param height {Number} the vertical range of the filter
* @private
*/
  FilterTexture(RenderingContext gl, int width, int height) {
    /**
     * @property gl
     * @type WebGLContext
     */
    this.gl = gl;

    // next time to create a frame buffer and texture
    this.frameBuffer = gl.createFramebuffer();
    this.texture = gl.createTexture();

    gl.bindTexture(TEXTURE_2D, this.texture);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, LINEAR);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR);
    gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE);
    gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
    gl.bindFramebuffer(FRAMEBUFFER, this.frameBuffer);

    gl.bindFramebuffer(FRAMEBUFFER, this.frameBuffer);
    gl.framebufferTexture2D(FRAMEBUFFER, COLOR_ATTACHMENT0, TEXTURE_2D,
        this.texture, 0);

    this.resize(width, height);
  }


  /**
* Clears the filter texture
* @method clear
*/
  void clear() {
    RenderingContext gl = this.gl;

    gl.clearColor(0, 0, 0, 0);
    gl.clear(COLOR_BUFFER_BIT);
  }

  /**
 * Resizes the texture to the specified width and height
 *
 * @method resize
 * @param width {Number} the new width of the texture
 * @param height {Number} the new height of the texture
 */
  void resize(int width, int height) {
    if (this.width == width && this.height == height) return;

    this.width = width;
    this.height = height;

    RenderingContext gl = this.gl;

    gl.bindTexture(TEXTURE_2D, this.texture);
    gl.texImage2D(TEXTURE_2D, 0, RGBA, width, height, 0, RGBA, UNSIGNED_BYTE,
        null);

  }

  /**
* Destroys the filter texture
* @method destroy
*/
  void destroy() {
    RenderingContext gl = this.gl;
    gl.deleteFramebuffer(this.frameBuffer);
    gl.deleteTexture(this.texture);

    this.frameBuffer = null;
    this.texture = null;
  }
}
