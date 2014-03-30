part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */


/**
 * The Graphics class contains a set of methods that you can use to create primitive shapes and lines.
 * It is important to know that with the webGL renderer only simple polygons can be filled at this stage
 * Complex polygons will not be filled. Heres an example of a complex polygon: http://www.goodboydigital.com/wp-content/uploads/2013/06/complexPolygon.png
 *
 * @class Graphics
 * @extends DisplayObjectContainer
 * @constructor
 */
class Graphics extends DisplayObjectContainer {

  /**
       * The alpha of the fill of this graphics object
       *
       * @property fillAlpha
       * @type Number
       */
  double fillAlpha = 1.0;

  double lineAlpha;

  bool filling = false;

  bool clearDirty;

  var fillColor;

  /**
       * The width of any lines drawn
       *
       * @property lineWidth
       * @type Number
       */
  int lineWidth = 0;

  /**
       * The color of any lines drawn
       *
       * @property lineColor
       * @type String
       */
  String lineColor = "black";

  /**
       * Graphics data
       *
       * @property graphicsData
       * @type Array
       * @private
       */
  List graphicsData = [];


  /**
       * The tint applied to the graphic shape. This is a hex value
       *
       * @property tint
       * @type Number
       * @default 0xFFFFFF
       */
  int tint = 0xFFFFFF;// * Math.random();

  /**
       * The blend mode to be applied to the graphic shape
       *
       * @property blendMode
       * @type Number
       * @default PIXI.blendModes.NORMAL;
       */
  int blendMode = blendModes['NORMAL'];

  /**
       * Current path
       *
       * @property currentPath
       * @type Object
       * @private
       */
  Map currentPath = {
    'points': []
  };

  /**
       * Array containing some WebGL-related properties used by the WebGL renderer
       *
       * @property _webGL
       * @type Array
       * @private
       */
  List _webGL = [];

  /**
       * Whether this shape is being used as a mask
       *
       * @property isMask
       * @type isMask
       */
  bool isMask = false;

  /**
       * The bounds of the graphic shape as rectangle object
       *
       * @property bounds
       * @type Rectangle
       */
  Rectangle bounds = null;

  /**
       * the bounds' padding used for bounds calculation
       *
       * @property bounds
       * @type Number
       */
  int boundsPadding = 10;

  bool _cacheAsBitmap = false;

  bool dirty = false;

  Sprite _cachedSprite;

  Graphics() {

    this.renderable = true;


  }

  /**
 * If cacheAsBitmap is true the graphics object will then be rendered as if it was a sprite.
 * This is useful if your graphics element does not change often as it will speed up the rendering of the object
 * It is also usful as the graphics object will always be antialiased because it will be rendered using canvas
 * Not recommended if you are constanly redrawing the graphics element.
 *
 * @property cacheAsBitmap
 * @default false
 * @type Boolean
 * @private
 */
  bool get cacheAsBitmap => this._cacheAsBitmap;
  set cacheAsBitmap(bool value) {
    this._cacheAsBitmap = value;

    if (this._cacheAsBitmap) {
      this._generateCachedSprite();
    } else {
      this.destroyCachedSprite();
      this.dirty = true;
    }
  }


  /**
 * Specifies the line style used for subsequent calls to Graphics methods such as the lineTo() method or the drawCircle() method.
 *
 * @method lineStyle
 * @param lineWidth {Number} width of the line to draw, will update the object's stored style
 * @param color {Number} color of the line to draw, will update the object's stored style
 * @param alpha {Number} alpha of the line to draw, will update the object's stored style
 */
  void lineStyle([int lineWidth = 0, String color = "black", double alpha = 1.0]) {
    if (this.currentPath['points'].length == 0) this.graphicsData.removeLast();

    this.lineWidth = lineWidth;
    this.lineColor = color;
    this.lineAlpha = alpha;

    this.currentPath = {
      'lineWidth': this.lineWidth,
      'lineColor': this.lineColor,
      'lineAlpha': this.lineAlpha,
      'fillColor': this.fillColor,
      'fillAlpha': this.fillAlpha,
      'fill': this.filling,
      'points': [],
      'type': Graphics.POLY
    };

    this.graphicsData.add(this.currentPath);

  }

  /**
 * Moves the current drawing position to (x, y).
 *
 * @method moveTo
 * @param x {Number} the X coordinate to move to
 * @param y {Number} the Y coordinate to move to
 */
  void moveTo(int x, int y) {
    if (this.currentPath['points'].length == 0) this.graphicsData.removeLast();

    this.currentPath = {
      'lineWidth': this.lineWidth,
      'lineColor': this.lineColor,
      'lineAlpha': this.lineAlpha,
      'fillColor': this.fillColor,
      'fillAlpha': this.fillAlpha,
      'fill': this.filling,
      'points': [],
      'type': Graphics.POLY
    };

    this.currentPath['points'].add(x, y);

    this.graphicsData.add(this.currentPath);

  }

  /**
 * Draws a line using the current line style from the current drawing position to (x, y);
 * the current drawing position is then set to (x, y).
 *
 * @method lineTo
 * @param x {Number} the X coordinate to draw to
 * @param y {Number} the Y coordinate to draw to
 */
  void lineTo(int x, int y) {
    this.currentPath['points'].add(x, y);
    this.dirty = true;

  }

  /**
 * Specifies a simple one-color fill that subsequent calls to other Graphics methods
 * (such as lineTo() or drawCircle()) use when drawing.
 *
 * @method beginFill
 * @param color {Number} the color of the fill
 * @param alpha {Number} the alpha of the fill
 */
  beginFill([String color = "black", double alpha = 1.0]) {

    this.filling = true;
    this.fillColor = color;
    this.fillAlpha = alpha;
  }

  /**
 * Applies a fill to the lines and shapes that were added since the last call to the beginFill() method.
 *
 * @method endFill
 */
  void endFill() {
    this.filling = false;
    this.fillColor = null;
    this.fillAlpha = 1.0;

  }

  /**
 * @method drawRect
 *
 * @param x {Number} The X coord of the top-left of the rectangle
 * @param y {Number} The Y coord of the top-left of the rectangle
 * @param width {Number} The width of the rectangle
 * @param height {Number} The height of the rectangle
 */
  void drawRect(int x, int y, int width, int height) {
    if (this.currentPath['points'].length == 0) this.graphicsData.removeLast();

    this.currentPath = {
      'lineWidth': this.lineWidth,
      'lineColor': this.lineColor,
      'lineAlpha': this.lineAlpha,
      'fillColor': this.fillColor,
      'fillAlpha': this.fillAlpha,
      'fill': this.filling,
      'points': [x, y, width, height],
      'type': Graphics.RECT
    };

    this.graphicsData.add(this.currentPath);
    this.dirty = true;

  }

  /**
 * Draws a circle.
 *
 * @method drawCircle
 * @param x {Number} The X coordinate of the center of the circle
 * @param y {Number} The Y coordinate of the center of the circle
 * @param radius {Number} The radius of the circle
 */
  void drawCircle(int x, int y, double radius) {

    if (this.currentPath['points'].length == 0) this.graphicsData.removeLast();

    this.currentPath = {
      'lineWidth': this.lineWidth,
      'lineColor': this.lineColor,
      'lineAlpha': this.lineAlpha,
      'fillColor': this.fillColor,
      'fillAlpha': this.fillAlpha,
      'fill': this.filling,
      'points': [x, y, radius, radius],
      'type': Graphics.CIRC
    };

    this.graphicsData.add(this.currentPath);
    this.dirty = true;

  }

  /**
 * Draws an ellipse.
 *
 * @method drawEllipse
 * @param x {Number} The X coordinate of the upper-left corner of the framing rectangle of this ellipse
 * @param y {Number} The Y coordinate of the upper-left corner of the framing rectangle of this ellipse
 * @param width {Number} The width of the ellipse
 * @param height {Number} The height of the ellipse
 */
  void drawEllipse(int x, int y, int width, int height) {

    if (this.currentPath['points'].length == 0) this.graphicsData.removeLast();

    this.currentPath = {
      'lineWidth': this.lineWidth,
      'lineColor': this.lineColor,
      'lineAlpha': this.lineAlpha,
      'fillColor': this.fillColor,
      'fillAlpha': this.fillAlpha,
      'fill': this.filling,
      'points': [x, y, width, height],
      'type': Graphics.ELIP
    };

    this.graphicsData.add(this.currentPath);
    this.dirty = true;

  }

  /**
 * Clears the graphics that were drawn to this Graphics object, and resets fill and line style settings.
 *
 * @method clear
 */
  void clear() {
    this.lineWidth = 0;
    this.filling = false;

    this.dirty = true;
    this.clearDirty = true;
    this.graphicsData = [];

    this.bounds = null; //new PIXI.Rectangle();

  }

  /**
 * Useful function that returns a texture of the graphics object that can then be used to create sprites
 * This can be quite useful if your geometry is complicated and needs to be reused multiple times.
 *
 * @method generateTexture
 * @return {Texture} a texture of the graphics object
 */
  Texture generateTexture() {
    Rectangle bounds = this.getBounds();

    CanvasBuffer canvasBuffer = new CanvasBuffer(bounds.width, bounds.height);
    Texture texture = new Texture.fromCanvas(canvasBuffer.canvas);

    canvasBuffer.context.translate(-bounds.x, -bounds.y);

    CanvasGraphics.renderGraphics(this, canvasBuffer.context);

    return texture;
  }

  /**
* Renders the object using the WebGL renderer
*
* @method _renderWebGL
* @param renderSession {RenderSession} 
* @private
*/
  void _renderWebGL(RenderSession renderSession) {
    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (this.visible == false || this.alpha == 0 || this.isMask == true) return;

    if (this._cacheAsBitmap) {

      if (this.dirty) {
        this._generateCachedSprite();
        // we will also need to update the texture on the gpu too!
        updateWebGLTexture(this._cachedSprite.texture.baseTexture, renderSession.gl);

        this.dirty = false;
      }

      this._cachedSprite._renderWebGL(renderSession);

      return;
    } else {
      renderSession.spriteBatch.stop();

      if (this._mask != null) renderSession.maskManager.pushMask(this.mask, renderSession);
      if (this._filters != null) renderSession.filterManager.pushFilter(this._filterBlock);

      // check blend mode
      if (this.blendMode != renderSession.spriteBatch.currentBlendMode) {
        renderSession.spriteBatch.currentBlendMode = this.blendMode;
        List blendModeWebGL = blendModesWebGL[renderSession.spriteBatch.currentBlendMode];
        renderSession.spriteBatch.gl.blendFunc(blendModeWebGL[0], blendModeWebGL[1]);
      }

      WebGLGraphics.renderGraphics(this, renderSession);

      // only render if it has children!
      if (this.children.length != 0) {
        renderSession.spriteBatch.start();

        // simple render children!
        for (int i = 0,
            j = this.children.length; i < j; i++) {
          this.children[i]._renderWebGL(renderSession);
        }

        renderSession.spriteBatch.stop();
      }

      if (this._filters != null) renderSession.filterManager.popFilter();
      if (this._mask != null) renderSession.maskManager.popMask(renderSession);

      renderSession.drawCount++;

      renderSession.spriteBatch.start();
    }
  }

  /**
* Renders the object using the Canvas renderer
*
* @method _renderCanvas
* @param renderSession {RenderSession} 
* @private
*/
  void _renderCanvas(RenderSession renderSession) {
    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (this.visible == false || this.alpha == 0 || this.isMask == true) return;

    var context = renderSession.context;
    Matrix transform = super.worldTransform;

    if (this.blendMode != renderSession.currentBlendMode) {
      renderSession.currentBlendMode = this.blendMode;
      context.globalCompositeOperation = blendModesCanvas[renderSession.currentBlendMode];
    }

    context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
    CanvasGraphics.renderGraphics(this, context);

    // simple render children!
    for (int i = 0,
        j = this.children.length; i < j; i++) {
      this.children[i]._renderCanvas(renderSession);
    }
  }

  /**
 * Retrieves the bounds of the graphic shape as a rectangle object
 *
 * @method getBounds
 * @return {Rectangle} the rectangular bounding area
 */
  Rectangle getBounds({Matrix matrix: null}) {
    if (this.bounds == null) this.updateBounds();

    double w0 = this.bounds.x;
    double w1 = this.bounds.width + this.bounds.x;

    double h0 = this.bounds.y;
    double h1 = this.bounds.height + this.bounds.y;

    Matrix worldTransform = (matrix != null) ? matrix : this.worldTransform;

    double a = worldTransform.a;
    double b = worldTransform.c;
    double c = worldTransform.b;
    double d = worldTransform.d;
    double tx = worldTransform.tx;
    double ty = worldTransform.ty;

    double x1 = a * w1 + c * h1 + tx;
    double y1 = d * h1 + b * w1 + ty;

    double x2 = a * w0 + c * h1 + tx;
    double y2 = d * h1 + b * w0 + ty;

    double x3 = a * w0 + c * h0 + tx;
    double y3 = d * h0 + b * w0 + ty;

    double x4 = a * w1 + c * h0 + tx;
    double y4 = d * h0 + b * w1 + ty;

    double maxX = double.INFINITY;
    double maxY = double.INFINITY;

    double minX = double.NEGATIVE_INFINITY;
    double minY = double.NEGATIVE_INFINITY;

    minX = x1 < minX ? x1 : minX;
    minX = x2 < minX ? x2 : minX;
    minX = x3 < minX ? x3 : minX;
    minX = x4 < minX ? x4 : minX;

    minY = y1 < minY ? y1 : minY;
    minY = y2 < minY ? y2 : minY;
    minY = y3 < minY ? y3 : minY;
    minY = y4 < minY ? y4 : minY;

    maxX = x1 > maxX ? x1 : maxX;
    maxX = x2 > maxX ? x2 : maxX;
    maxX = x3 > maxX ? x3 : maxX;
    maxX = x4 > maxX ? x4 : maxX;

    maxY = y1 > maxY ? y1 : maxY;
    maxY = y2 > maxY ? y2 : maxY;
    maxY = y3 > maxY ? y3 : maxY;
    maxY = y4 > maxY ? y4 : maxY;

    Rectangle bounds = this._bounds;

    bounds.x = minX;
    bounds.width = maxX - minX;

    bounds.y = minY;
    bounds.height = maxY - minY;

    return bounds;
  }

  /**
 * Update the bounds of the object
 *
 * @method updateBounds
 */
  void updateBounds() {

    double minX = double.INFINITY;
    double maxX = double.NEGATIVE_INFINITY;

    double minY = double.INFINITY;
    double maxY = double.NEGATIVE_INFINITY;

    List points;
    double x, y, w, h;

    for (int i = 0; i < this.graphicsData.length; i++) {
      Map data = this.graphicsData[i];
      int type = data['type'];
      int lineWidth = data['lineWidth'];

      points = data['points'];

      if (type == Graphics.RECT) {
        x = points[0] - lineWidth / 2;
        y = points[1] - lineWidth / 2;
        w = points[2] + lineWidth;
        h = points[3] + lineWidth;

        minX = x < minX ? x : minX;
        maxX = x + w > maxX ? x + w : maxX;

        minY = y < minY ? x : minY;
        maxY = y + h > maxY ? y + h : maxY;
      } else if (type == Graphics.CIRC || type == Graphics.ELIP) {
        x = points[0];
        y = points[1];
        w = points[2] + lineWidth / 2;
        h = points[3] + lineWidth / 2;

        minX = x - w < minX ? x - w : minX;
        maxX = x + w > maxX ? x + w : maxX;

        minY = y - h < minY ? y - h : minY;
        maxY = y + h > maxY ? y + h : maxY;
      } else {
        // POLY
        for (int j = 0; j < points.length; j += 2) {

          x = points[j];
          y = points[j + 1];
          minX = x - lineWidth < minX ? x - lineWidth : minX;
          maxX = x + lineWidth > maxX ? x + lineWidth : maxX;

          minY = y - lineWidth < minY ? y - lineWidth : minY;
          maxY = y + lineWidth > maxY ? y + lineWidth : maxY;
        }
      }
    }

    int padding = this.boundsPadding;
    this.bounds = new Rectangle(minX - padding, minY - padding, (maxX - minX) + padding * 2, (maxY - minY) + padding * 2);
  }


  /**
 * Generates the cached sprite when the sprite has cacheAsBitmap = true
 *
 * @method _generateCachedSprite
 * @private
 */
  void _generateCachedSprite() {
    Rectangle bounds = this.getLocalBounds();

    if (this._cachedSprite != null) {
      CanvasBuffer canvasBuffer = new CanvasBuffer(bounds.width, bounds.height);
      Texture texture = new Texture.fromCanvas(canvasBuffer.canvas);

      this._cachedSprite = new Sprite(texture);
      this._cachedSprite.buffer = canvasBuffer;

      this._cachedSprite.worldTransform = this.worldTransform;
    } else {
      this._cachedSprite.buffer.resize(bounds.width, bounds.height);
    }

    // leverage the anchor to account for the offset of the element
    this._cachedSprite.anchor.x = -(bounds.x / bounds.width);
    this._cachedSprite.anchor.y = -(bounds.y / bounds.height);

    // this._cachedSprite.buffer.context.save();
    this._cachedSprite.buffer.context.translate(-bounds.x, -bounds.y);

    CanvasGraphics.renderGraphics(this, this._cachedSprite.buffer.context);
    // this._cachedSprite.buffer.context.restore();
  }

  void destroyCachedSprite() {
    this._cachedSprite.texture.destroy(true);

    // let the gc collect the unused sprite
    // TODO could be object pooled!
    this._cachedSprite = null;
  }


  // SOME TYPES:
  static final int POLY = 0;
  static final int RECT = 1;
  static final int CIRC = 2;
  static final int ELIP = 3;

}
