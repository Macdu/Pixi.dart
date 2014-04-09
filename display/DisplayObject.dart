part of pixi;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The base class for all objects that are rendered on the screen.
 *
 * @class DisplayObject
 */
abstract class DisplayObject {
  /**
     * The coordinate of the object relative to the local coordinates of the parent.
     *
     * @property position
     * @type Point
     */
  Point position = new Point();

  /**
     * The scale factor of the object.
     *
     * @property scale
     * @type Point
     */
  Point scale = new Point(1.0, 1.0);//{x:1, y:1};

  /**
     * The pivot point of the displayObject that it rotates around
     *
     * @property pivot
     * @type Point
     */
  Point pivot = new Point(0.0, 0.0);

  /**
     * The rotation of the object in radians.
     *
     * @property rotation
     * @type Number
     */
  double rotation = 0.0;

  /**
     * The opacity of the object.
     *
     * @property alpha
     * @type Number
     */
  double alpha = 1.0;

  /**
     * The visibility of the object.
     *
     * @property visible
     * @type Boolean
     */
  bool visible = true;

  /**
     * This is the defined area that will pick up mouse / touch events. It is null by default.
     * Setting it is a neat way of optimising the hitTest function that the interactionManager will use (as it will not need to hit test all the children)
     *
     * @property hitArea
     * @type Rectangle|Circle|Ellipse|Polygon
     */
  var hitArea = null;

  /**
     * This is used to indicate if the displayObject should display a mouse hand cursor on rollover
     *
     * @property buttonMode
     * @type Boolean
     */
  bool buttonMode = false;

  /**
     * Can this object be rendered
     *
     * @property renderable
     * @type Boolean
     */
  bool renderable = false;

  /**
     * [read-only] The display object container that contains this display object.
     *
     * @property parent
     * @type DisplayObjectContainer
     * @readOnly
     */
  DisplayObjectContainer parent = null;

  /**
     * [read-only] The stage the display object is connected to, or undefined if it is not connected to the stage.
     *
     * @property stage
     * @type Stage
     * @readOnly
     */
  Stage stage = null;

  /**
     * [read-only] The multiplied alpha of the displayObject
     *
     * @property worldAlpha
     * @type Number
     * @readOnly
     */
  double worldAlpha = 1.0;

  /**
     * [read-only] Whether or not the object is interactive, do not toggle directly! use the `interactive` property
     *
     * @property _interactive
     * @type Boolean
     * @readOnly
     * @private
     */
  bool _interactive = false;

  /**
     * This is the cursor that will be used when the mouse is over this object. To enable this the element must have interaction = true and buttonMode = true
     * 
     * @property defaultCursor
     * @type String
     *
    */
  String defaultCursor = 'pointer';

  /**
     * [read-only] Current transform of the object based on world (parent) factors
     *
     * @property worldTransform
     * @type Mat3
     * @readOnly
     * @private
     */
  Matrix worldTransform = new Matrix();

  /**
     * [NYI] Unknown
     *
     * @property color
     * @type Array<>
     * @private
     */
  List color = [];

  /**
     * [NYI] Holds whether or not this object is dynamic, for rendering optimization
     *
     * @property dynamic
     * @type Boolean
     * @private
     */
  bool dynamic = true;

  // cached sin rotation and cos rotation
  double _sr = 0.0;
  double _cr = 1.0;

  /**
     * The area the filter is applied to 
     *
     * @property filterArea
     * @type Rectangle
     */
  Rectangle filterArea = new Rectangle(0.0, 0.0, 1.0, 1.0);

  /**
     * The original, cached bounds of the object
     *
     * @property _bounds
     * @type Rectangle
     * @private
     */
  Rectangle _bounds = new Rectangle(0.0, 0.0, 1.0, 1.0);
  /**
     * The most up-to-date bounds of the object
     *
     * @property _currentBounds
     * @type Rectangle
     * @private
     */
  Rectangle _currentBounds = null;
  /**
     * The original, cached mask of the object
     *
     * @property _currentBounds
     * @type Rectangle
     * @private
     */
  Graphics _mask = null;

  bool interactiveChildren = false;

  DisplayObject _iParent;

  /*
     * MOUSE Callbacks
     */

  /**
     * A callback that is used when the users clicks on the displayObject with their mouse
     * @method click
     * @param interactionData {InteractionData}
     */
  void click(InteractionData interactionData) {}

  /**
     * A callback that is used when the user clicks the mouse down over the sprite
     * @method mousedown
     * @param interactionData {InteractionData}
     */
  void mousedown(InteractionData interactionData) {}

  /**
     * A callback that is used when the user releases the mouse that was over the displayObject
     * for this callback to be fired the mouse must have been pressed down over the displayObject
     * @method mouseup
     * @param interactionData {InteractionData}
     */
  void mouseup(InteractionData interactionData) {}

  /**
     * A callback that is used when the user releases the mouse that was over the displayObject but is no longer over the displayObject
     * for this callback to be fired, The touch must have started over the displayObject
     * @method mouseupoutside
     * @param interactionData {InteractionData}
     */
  void mouseupoutside(InteractionData interactionData) {}

  /**
     * A callback that is used when the users mouse rolls over the displayObject
     * @method mouseover
     * @param interactionData {InteractionData}
     */
  void mouseover(InteractionData interactionData) {}

  /**
     * A callback that is used when the users mouse leaves the displayObject
     * @method mouseout
     * @param interactionData {InteractionData}
     */
  void mouseout(InteractionData interactionData) {}

  /**
     * A callback that is used when the users mouse moves
     */
  void mousemove(InteractionData interactionData) {}


  /*
     * TOUCH Callbacks
     */

  /**
     * A callback that is used when the users taps on the sprite with their finger
     * basically a touch version of click
     * @method tap
     * @param interactionData {InteractionData}
     */
  void tap(InteractionData interactionData) {}

  /**
     * A callback that is used when the user touches over the displayObject
     * @method touchstart
     * @param interactionData {InteractionData}
     */
  void touchstart(InteractionData interactionData) {}

  /**
     * A callback that is used when the user releases a touch over the displayObject
     * @method touchend
     * @param interactionData {InteractionData}
     */
  void touchend(InteractionData interactionData) {}

  /**
     * A callback that is used when the user releases the touch that was over the displayObject
     * for this callback to be fired, The touch must have started over the sprite
     * @method touchendoutside
     * @param interactionData {InteractionData}
     */
  void touchendoutside(InteractionData interactionData) {}

  void touchmove(InteractionData interactionData) {}

  List _filters;

  Map _filterBlock;


  double _rotationCache = null;

  bool _mouseIsDown = false;

  bool _hit = false;

  bool _isDown = false;

  bool _isOver = false;

  InteractionData _touchData;


  // constructor
  DisplayObject();

  /**
   * [Deprecated] Indicates if the sprite will have touch and mouse interactivity. It is false by default
   * Instead of using this function you can now simply set the interactive property to true or false
   *
   * @method setInteractive
   * @param interactive {Boolean}
   * @deprecated Simply set the `interactive` property directly
   */
  @deprecated
  void setInteractive(bool interactive) {
    this.interactive = interactive;
  }

  /**
   * Indicates if the sprite will have touch and mouse interactivity. It is false by default
   *
   * @property interactive
   * @type Boolean
   * @default false
   */

  bool get interactive => this._interactive;
  set interactive(bool value) {
    this._interactive = value;

    // TODO more to be done here..
    // need to sort out a re-crawl!
    if (this.stage != null) this.stage.dirty = true;
  }

  /**
   * [read-only] Indicates if the sprite is globaly visible.
   *
   * @property worldVisible
   * @type Boolean
   */

  bool get worldVisible {
    DisplayObject item = this;

    do {
      if (!item.visible) return false;
      item = item.parent;
    } while (item != null);

    return true;
  }

  /**
   * Sets a mask for the displayObject. A mask is an object that limits the visibility of an object to the shape of the mask applied to it.
   * In PIXI a regular mask must be a PIXI.Graphics object. This allows for much faster masking in canvas as it utilises shape clipping.
   * To remove a mask, set this property to null.
   *
   * @property mask
   * @type Graphics
   */

  Graphics get mask => this._mask;
  set mask(Graphics value) {

    if (this._mask != null) this._mask.isMask = false;
    this._mask = value;
    if (this._mask != null) this._mask.isMask = true;
  }

  /**
   * Sets the filters for the displayObject.
   * * IMPORTANT: This is a webGL only feature and will be ignored by the canvas renderer.
   * To remove filters simply set this property to 'null'
   * @property filters
   * @type List A list of filters
   */
  List get filters => this._filters;
  set filters(List value) {

    if (value != null) {
      // now put all the passes in one place..
      List passes = [];
      for (int i = 0; i < value.length; i++) {
        var filterPasses = value[i].passes;
        for (int j = 0; j < filterPasses.length; j++) {
          passes.add(filterPasses[j]);
        }
      }

      // TODO change this as it is legacy
      this._filterBlock = {
        'target': this,
        'filterPasses': passes
      };
    }

    this._filters = value;
  }


  /*
   * Updates the object transform for rendering
   *
   * @method updateTransform
   * @private
   */
  void updateTransform() {
    // TODO OPTIMIZE THIS!! with dirty
    if (this.rotation != this._rotationCache) {

      this._rotationCache = this.rotation;
      this._sr = Math.sin(this.rotation);
      this._cr = Math.cos(this.rotation);
    }

    // var localTransform = this.localTransform//.toArray();
    Matrix parentTransform = this.parent.worldTransform;//.toArray();
    Matrix worldTransform = this.worldTransform;//.toArray();
    double px = this.pivot.x;
    double py = this.pivot.y;

    double a00 = this._cr * this.scale.x,
        a01 = -this._sr * this.scale.y,
        a10 = this._sr * this.scale.x,
        a11 = this._cr * this.scale.y,
        a02 = this.position.x - a00 * px - py * a01,
        a12 = this.position.y - a11 * py - px * a10,
        b00 = parentTransform.a,
        b01 = parentTransform.b,
        b10 = parentTransform.c,
        b11 = parentTransform.d;

    worldTransform.a = b00 * a00 + b01 * a10;
    worldTransform.b = b00 * a01 + b01 * a11;
    worldTransform.tx = b00 * a02 + b01 * a12 + parentTransform.tx;

    worldTransform.c = b10 * a00 + b11 * a10;
    worldTransform.d = b10 * a01 + b11 * a11;
    worldTransform.ty = b10 * a02 + b11 * a12 + parentTransform.ty;

    this.worldAlpha = this.alpha * this.parent.worldAlpha;
  }

  /**
   * Retrieves the bounds of the displayObject as a rectangle object
   *
   * @method getBounds
   * @return {Rectangle} the rectangular bounding area
   */
  Rectangle getBounds({Matrix matrix: null}) => EmptyRectangle;

  /**
   * Retrieves the local bounds of the displayObject as a rectangle object
   *
   * @method getLocalBounds
   * @return {Rectangle} the rectangular bounding area
   */
  Rectangle getLocalBounds() {
    //var matrixCache = this.worldTransform;

    return this.getBounds(matrix : identityMatrix);
    ///PIXI.EmptyRectangle();
  }

  /**
   * Sets the object's stage reference, the stage this object is connected to
   *
   * @method setStageReference
   * @param stage {Stage} the stage that the object will have as its current stage reference
   */
  void setStageReference(Stage stage) {
    this.stage = stage;
    if (this._interactive) this.stage.dirty = true;
  }

  /**
  * Renders the object using the WebGL renderer
  *
  * @method _renderWebGL
  * @param renderSession {RenderSession} 
  * @private
  */
  void _renderWebGL(RenderSession renderSession) {}

  /**
  * Renders the object using the Canvas renderer
  *
  * @method _renderCanvas
  * @param renderSession {RenderSession} 
  * @private
  */
  void _renderCanvas(RenderSession renderSession) {}

  /**
   * The position of the displayObject on the x axis relative to the local coordinates of the parent.
   *
   * @property x
   * @type Number
   */
  double get x => this.position.x;
  set x(double value) => this.position.x = value;

  /**
   * The position of the displayObject on the y axis relative to the local coordinates of the parent.
   *
   * @property y
   * @type Number
   */
  double get y => this.position.y;
  set y(double value) => this.position.y = value;

}
