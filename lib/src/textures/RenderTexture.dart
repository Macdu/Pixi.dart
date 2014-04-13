part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 A RenderTexture is a special texture that allows any pixi displayObject to be rendered to it.

 __Hint__: All DisplayObjects (exmpl. Sprites) that render on RenderTexture should be preloaded.
 Otherwise black rectangles will be drawn instead.

 RenderTexture takes snapshot of DisplayObject passed to render method. If DisplayObject is passed to render method, position and rotation of it will be ignored. For example:

    var renderTexture = new PIXI.RenderTexture(800, 600);
    var sprite = PIXI.Sprite.fromImage("spinObj_01.png");
    sprite.position.x = 800/2;
    sprite.position.y = 600/2;
    sprite.anchor.x = 0.5;
    sprite.anchor.y = 0.5;
    renderTexture.render(sprite);

 Sprite in this case will be rendered to 0,0 position. To render this sprite at center DisplayObjectContainer should be used:

    var doc = new PIXI.DisplayObjectContainer();
    doc.addChild(sprite);
    renderTexture.render(doc);  // Renders to center of renderTexture
**/
class RenderTexture extends EventTarget {

  /**
       * The with of the render texture
       *
       * @property width
       * @type Number
       */
  int width;
  /**
       * The height of the render texture
       *
       * @property height
       * @type Number
       */
  int height;

  /**
       * The framing rectangle of the render texture
       *
       * @property frame
       * @type Rectangle
       */
  Rectangle frame;

  /**
       * The base texture object that this texture uses
       *
       * @property baseTexture
       * @type BaseTexture
       */
  BaseTexture baseTexture = new BaseTexture();

  // each render texture can only belong to one renderer at the moment if its webGL
  Renderer renderer;

  var textureBuffer;

  Function render;
  Point projection;

  /**
 * @class RenderTexture
 * @extends Texture
 * @constructor
 * @param width {Number} The width of the render texture
 * @param height {Number} The height of the render texture
 */
  RenderTexture([int width = 100, int height = 100,Renderer renderer = null]) {

    /**
     * The with of the render texture
     *
     * @property width
     * @type Number
     */
    this.width = width;
    /**
     * The height of the render texture
     *
     * @property height
     * @type Number
     */
    this.height = height;

    /**
     * The framing rectangle of the render texture
     *
     * @property frame
     * @type Rectangle
     */
    this.frame = new Rectangle(0.0, 0.0, this.width.toDouble(), this.height.toDouble());

    /**
     * The base texture object that this texture uses
     *
     * @property baseTexture
     * @type BaseTexture
     */
    this.baseTexture = new BaseTexture();
    this.baseTexture.width = this.width;
    this.baseTexture.height = this.height;
    this.baseTexture._glTextures = [];

    this.baseTexture.hasLoaded = true;

    // each render texture can only belong to one renderer at the moment if its webGL
    this.renderer = (renderer != null) ? renderer : defaultRenderer;

    if (this.renderer is WebGLRenderer) {
      RenderingContext gl = this.renderer.gl;

      this.textureBuffer = new FilterTexture(gl, this.width, this.height);
      this.baseTexture._glTextures[WebGLRenderer._getIndexFirst(gl)] = this.textureBuffer.texture;

      this.render = this.renderWebGL;
      this.projection = new Point(this.width / 2, -this.height / 2);
    } else {
      this.render = this.renderCanvas;
      this.textureBuffer = new CanvasBuffer(this.width, this.height);
      this.baseTexture.source = this.textureBuffer.canvas;
    }

    Texture.frameUpdates.add(this);


  }

  void resize(int width, int height) {
    this.width = width;
    this.height = height;

    this.frame.width = this.width.toDouble();
    this.frame.height = this.height.toDouble();

    if (this.renderer is WebGLRenderer) {
      this.projection.x = this.width / 2;
      this.projection.y = -this.height / 2;

      RenderingContext gl = this.renderer.gl;
      gl.bindTexture(TEXTURE_2D, this.baseTexture._glTextures[WebGLRenderer._getIndexFirst(gl)]);
      gl.texImage2D(TEXTURE_2D, 0, RGBA, this.width, this.height, 0, RGBA, UNSIGNED_BYTE, null);
    } else {
      this.textureBuffer.resize(this.width, this.height);
    }

    Texture.frameUpdates.add(this);
  }

  /**
 * This function will draw the display object to the texture.
 *
 * @method renderWebGL
 * @param displayObject {DisplayObject} The display object to render this texture on
 * @param clear {Boolean} If true the texture will be cleared before the displayObject is drawn
 * @private
 */
  void renderWebGL(DisplayObjectContainer displayObject, [Point position = null, bool clear = false]) {
    //TODO replace position with matrix..
    RenderingContext gl = (this.renderer as WebGLRenderer).gl;

    gl.colorMask(true, true, true, true);

    gl.viewport(0, 0, this.width, this.height);

    gl.bindFramebuffer(FRAMEBUFFER, this.textureBuffer.frameBuffer);

    if (clear) this.textureBuffer.clear();

    // THIS WILL MESS WITH HIT TESTING!
    List<DisplayObject> children = displayObject.children;

    //TODO -? create a new one??? dont think so!
    Matrix originalWorldTransform = displayObject.worldTransform;
    displayObject.worldTransform = RenderTexture.tempMatrix;
    // modify to flip...
    displayObject.worldTransform.d = -1.toDouble();
    displayObject.worldTransform.ty = this.projection.y * -2;

    if (position != null) {
      displayObject.worldTransform.tx = position.x;
      displayObject.worldTransform.ty -= position.y;
    }

    for (int i = 0,
        j = children.length; i < j; i++) {
      children[i].updateTransform();
    }

    // update the textures!
    WebGLRenderer.updateTextures();

    //
    (this.renderer as WebGLRenderer).renderDisplayObject(displayObject, this.projection, this.textureBuffer.frameBuffer);

    displayObject.worldTransform = originalWorldTransform;
  }


  /**
 * This function will draw the display object to the texture.
 *
 * @method renderCanvas
 * @param displayObject {DisplayObject} The display object to render this texture on
 * @param clear {Boolean} If true the texture will be cleared before the displayObject is drawn
 * @private
 */
  void renderCanvas(DisplayObjectContainer displayObject, [Point position = null, bool clear = false]) {
    List<DisplayObject> children = displayObject.children;

    displayObject.worldTransform = RenderTexture.tempMatrix;

    if (position != null) {
      displayObject.worldTransform.tx = position.x;
      displayObject.worldTransform.ty = position.y;
    }

    for (int i = 0,
        j = children.length; i < j; i++) {
      children[i].updateTransform();
    }

    if (clear) this.textureBuffer.clear();

    CanvasRenderingContext2D context = this.textureBuffer.context;

    (this.renderer as CanvasRenderer).renderDisplayObject(displayObject, context);

    context.setTransform(1, 0, 0, 1, 0, 0);
  }

  static Matrix tempMatrix = new Matrix();


}
