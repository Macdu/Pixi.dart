part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The interaction manager deals with mouse and touch events. Any DisplayObject can be interactive
 * if its interactive parameter is set to true
 * This manager also supports multitouch.
 */
class InteractionManager {


  /**
     * a reference to the stage
     *
     * @property stage
     * @type Stage
     */
  Stage stage;

  /**
     * the mouse data
     *
     * @property mouse
     * @type InteractionData
     */
  InteractionData mouse = new InteractionData();

  /**
     * an object that stores current touches (InteractionData) by id reference
     *
     * @property touchs
     * @type Object
     */
  List<InteractionData> touchs = [];

  // helpers
  Point tempPoint = new Point();

  /**
     * 
     * @property mouseoverEnabled
     * @type Boolean
     * @default
     */
  bool mouseoverEnabled = true;

  /**
     * tiny little interactiveData pool !
     * 
     * @property pool
     * @type Array
     */
  List<InteractionData> pool = [];

  /**
     * An array containing all the iterative items from the our interactive tree
     * @property interactiveItems
     * @type Array
     * @private
     *
     */
  List<DisplayObject> interactiveItems = [];

  /**
     * Our canvas
     * @property interactionDOMElement
     * @type HTMLCanvasElement
     * @private
     */
  CanvasElement interactionDOMElement = null;

  int last = 0;

  /**
     * The css style of the cursor that is being used
     * @property currentCursorStyle
     * @type String
     *
     */
  String currentCursorStyle = 'inherit';

  /**
     * Is set to true when the mouse is moved out of the canvas
     * @property mouseOut
     * @type Boolean
     *
     */
  bool mouseOut = false;

  var target;

  bool dirty = false;

  /**
 * @class InteractionManager
 * @constructor
 * @param stage {Stage} The stage to handle interactions
 */
  InteractionManager(Stage this.stage);

  /**
 * Collects an interactive sprite recursively to have their interactions managed
 *
 * @method collectInteractiveSprite
 * @param displayObject {DisplayObject} the displayObject to collect
 * @param iParent {DisplayObject} the display object's parent
 * @private
 */
  void collectInteractiveSprite(DisplayObjectContainer displayObject, DisplayObjectContainer iParent) {
    List<DisplayObject> children = displayObject.children;
    int length = children.length;

    // make an interaction tree... {item.__interactiveParent}
    for (int i = length - 1; i >= 0; i--) {
      DisplayObjectContainer child = children[i];

      // push all interactive bits
      if (child.interactive) {
        iParent.interactiveChildren = true;
        //child.__iParent = iParent;
        this.interactiveItems.add(child);

        if (child.children.length > 0) {
          this.collectInteractiveSprite(child, child);
        }
      } else {
        child._iParent = null;

        if (child.children.length > 0) {
          this.collectInteractiveSprite(child, iParent);
        }
      }

    }
  }

  /**
 * Sets the target for event delegation
 *
 * @method setTarget
 * @param target {WebGLRenderer|CanvasRenderer} the renderer to bind events to
 * @private
 */
  void setTarget(target) {
    this.target = target;

    //check if the dom element has been set. If it has don't do anything
    if (this.interactionDOMElement == null) {

      this.setTargetDomElement(target.view);
    }


  }


  /**
 * Sets the DOM element which will receive mouse/touch events. This is useful for when you have other DOM
 * elements on top of the renderers Canvas element. With this you'll be able to delegate another DOM element
 * to receive those events
 *
 * @method setTargetDomElement
 * @param domElement {DOMElement} the DOM element which will receive mouse and touch events
 * @private
 */
  void setTargetDomElement(CanvasElement domElement) {

    this.removeEvents();

    /*
      if (window.navigator.msPointerEnabled)
      {
          // time to remove some of that zoom in ja..
          domElement.style['-ms-content-zooming'] = 'none';
          domElement.style['-ms-touch-action'] = 'none';
  
          // DO some window specific touch!
      }
    */

    this.interactionDOMElement = domElement;

    domElement.onMouseMove.listen(this.onMouseMove);
    domElement.onMouseDown.listen(this.onMouseDown);
    domElement.onMouseOut.listen(this.onMouseOut);

    // aint no multi touch just yet!
    domElement.onTouchStart.listen(this.onTouchStart);
    domElement.onTouchEnd.listen(this.onTouchEnd);
    domElement.onTouchEnd.listen(this.onTouchMove);

    document.body.onMouseUp.listen(this.onMouseUp);
  }


  void removeEvents() {
    if (this.interactionDOMElement == null) return;

    this.interactionDOMElement.style.setProperty('-ms-content-zooming', '');
    this.interactionDOMElement.style.setProperty('-ms-touch-action', '');

    this.interactionDOMElement.removeEventListener('mousemove', this.onMouseMove);
    this.interactionDOMElement.removeEventListener('mousedown', this.onMouseDown);
    this.interactionDOMElement.removeEventListener('mouseout', this.onMouseOut);

    // aint no multi touch just yet!
    this.interactionDOMElement.removeEventListener('touchstart', this.onTouchStart);
    this.interactionDOMElement.removeEventListener('touchend', this.onTouchEnd);
    this.interactionDOMElement.removeEventListener('touchmove', this.onTouchMove);

    this.interactionDOMElement = null;

    document.body.removeEventListener('mouseup', this.onMouseUp);
  }

  /**
 * updates the state of interactive objects
 *
 * @method update
 * @private
 */
  void update() {
    if (this.target == null) return;

    // frequency of 30fps??
    int now = new DateTime.now().millisecondsSinceEpoch;
    double diff = (now - this.last).toDouble();
    diff = (diff * INTERACTION_FREQUENCY) / 1000;
    if (diff < 1) return;
    this.last = now;

    int i = 0;

    // ok.. so mouse events??
    // yes for now :)
    // OPTIMISE - how often to check??
    if (this.dirty) {
      this.dirty = false;

      int len = this.interactiveItems.length;

      for (i = 0; i < len; i++) {
        this.interactiveItems[i].interactiveChildren = false;
      }

      this.interactiveItems = [];

      if (this.stage.interactive) this.interactiveItems.add(this.stage);
      // go through and collect all the objects that are interactive..
      this.collectInteractiveSprite(this.stage, this.stage);
    }

    // loop through interactive objects!
    int length = this.interactiveItems.length;
    String cursor = 'inherit';
    bool over = false;

    for (i = 0; i < length; i++) {
      var item = this.interactiveItems[i];

      // OPTIMISATION - only calculate every time if the mousemove function exists..
      // OK so.. does the object have any other interactive functions?
      // hit-test the clip!
      // if(item.mouseover || item.mouseout || item.buttonMode)
      // {
      // ok so there are some functions so lets hit test it..
      item._hit = this.hitTest(item, this.mouse);
      this.mouse.target = item;
      // ok so deal with interactions..
      // looks like there was a hit!
      if (item._hit && !over) {
        if (item.buttonMode) cursor = item.defaultCursor;

        if (!item.interactiveChildren) over = true;

        if (!item._isOver) {
          item.mouseover(this.mouse);
          item._isOver = true;
        }
      } else {
        if (item._isOver) {
          // roll out!
          if (item.mouseout) item.mouseout(this.mouse);
          item._isOver = false;
        }
      }
    }

    if (this.currentCursorStyle != cursor) {
      this.currentCursorStyle = cursor;
      this.interactionDOMElement.style.cursor = cursor;
    }
  }

  /**
 * Is called when the mouse moves across the renderer element
 *
 * @method onMouseMove
 * @param event {Event} The DOM event of the mouse moving
 * @private
 */
  void onMouseMove(MouseEvent event) {
    this.mouse.originalEvent = event; //IE uses window.event
    // TODO optimize by not check EVERY TIME! maybe half as often? //
    var rect = this.interactionDOMElement.getBoundingClientRect();

    this.mouse.global.x = (event.client.x - rect.left) * (this.target.width / rect.width);
    this.mouse.global.y = (event.client.y - rect.top) * (this.target.height / rect.height);

    int length = this.interactiveItems.length;

    for (int i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];

      //call the function!
      item.mousemove(this.mouse);
    }
  }

  /**
 * Is called when the mouse button is pressed down on the renderer element
 *
 * @method onMouseDown
 * @param event {Event} The DOM event of a mouse button being pressed down
 * @private
 */
  void onMouseDown(MouseEvent event) {
    this.mouse.originalEvent = event; //IE uses window.event

    if (AUTO_PREVENT_DEFAULT) this.mouse.originalEvent.preventDefault();

    // loop through interaction tree...
    // hit test each item! ->
    // get interactive items under point??
    //stage.__i
    int length = this.interactiveItems.length;

    // while
    // hit test
    for (int i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];

      item._mouseIsDown = true;
      item._hit = this.hitTest(item, this.mouse);

      if (item._hit) {
        //call the function!
        item.mousedown(this.mouse);
        item._isDown = true;

        // just the one!
        if (!item.interactiveChildren) break;
      }
    }

  }

  /**
 * Is called when the mouse button is moved out of the renderer element
 *
 * @method onMouseOut
 * @param event {Event} The DOM event of a mouse button being moved out
 * @private 
 */
  void onMouseOut(MouseEvent event) {
    int length = this.interactiveItems.length;

    this.interactionDOMElement.style.cursor = 'inherit';

    for (int i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];
      if (item._isOver) {
        this.mouse.target = item;
        item.mouseout(this.mouse);
        item._isOver = false;
      }
    }

    this.mouseOut = true;

    // move the mouse to an impossible position
    this.mouse.global.x = -10000.0;
    this.mouse.global.y = -10000.0;
  }

  /**
 * Is called when the mouse button is released on the renderer element
 *
 * @method onMouseUp
 * @param event {Event} The DOM event of a mouse button being released
 * @private
 */
  void onMouseUp(MouseEvent event) {

    this.mouse.originalEvent = event; //IE uses window.event

    int length = this.interactiveItems.length;
    bool up = false;

    for (int i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];

      item._hit = this.hitTest(item, this.mouse);

      if (item._hit && !up) {
        //call the function!
        item.mouseup(this.mouse);
        if (item._isDown) {
          item.click(this.mouse);
        }

        if (!item.interactiveChildren) up = true;
      } else {
        if (item._isDown) {
          item.mouseupoutside(this.mouse);
        }
      }

      item._isDown = false;
      //}
    }
  }

  /**
 * Tests if the current mouse coordinates hit a sprite
 *
 * @method hitTest
 * @param item {DisplayObject} The displayObject to test for a hit
 * @param interactionData {InteractionData} The interactionData object to update in the case there is a hit
 * @private
 */
  bool hitTest(DisplayObject item, InteractionData interactionData) {
    Point global = interactionData.global;

    if (!item.worldVisible) return false;

    // temp fix for if the element is in a non visible

    Matrix worldTransform = item.worldTransform;
    double a00 = worldTransform.a,
        a01 = worldTransform.b,
        a02 = worldTransform.tx,
        a10 = worldTransform.c,
        a11 = worldTransform.d,
        a12 = worldTransform.ty,
        id = 1 / (a00 * a11 + a01 * -a10),
        x = a11 * id * global.x + -a01 * id * global.y + (a12 * a01 - a02 * a11) * id,
        y = a00 * id * global.y + -a10 * id * global.x + (-a12 * a00 + a02 * a10) * id;

    interactionData.target = item;

    //a sprite or display object with a hit area defined
    if (item.hitArea != null) {
      if (item.hitArea.contains(x, y)) {
        //if(isSprite)
        interactionData.target = item;

        return true;
      }

      return false;
    } // a sprite with no hitarea defined
    else if (item is Sprite) {
      double width = item.texture.frame.width,
          height = item.texture.frame.height,
          x1 = -width * item.anchor.x,
          y1;

      if (x > x1 && x < x1 + width) {
        y1 = -height * item.anchor.y;

        if (y > y1 && y < y1 + height) {
          // set the target property if a hit is true!
          interactionData.target = item;
          return true;
        }
      }
    }

    int length = (item as DisplayObjectContainer).children.length;

    for (int i = 0; i < length; i++) {
      DisplayObject tempItem = (item as DisplayObjectContainer).children[i];
      bool hit = this.hitTest(tempItem, interactionData);
      if (hit) {
        // hmm.. TODO SET CORRECT TARGET?
        interactionData.target = item;
        return true;
      }
    }

    return false;
  }

  /**
 * Is called when a touch is moved across the renderer element
 *
 * @method onTouchMove
 * @param event {Event} The DOM event of a touch moving across the renderer view
 * @private
 */
  void onTouchMove(TouchEvent event) {
    var rect = this.interactionDOMElement.getBoundingClientRect();
    TouchList changedTouches = event.changedTouches;
    var touchData;
    int i = 0;

    for (i = 0; i < changedTouches.length; i++) {
      Touch touchEvent = changedTouches[i];
      touchData = this.touchs[touchEvent.identifier];
      touchData.originalEvent = event;

      // update the touch position
      touchData.global.x = (touchEvent.client.x - rect.left) * (this.target.width / rect.width);
      touchData.global.y = (touchEvent.client.y - rect.top) * (this.target.height / rect.height);
      /*
        if(navigator.isCocoonJS) {
            touchData.global.x = touchEvent.clientX;
            touchData.global.y = touchEvent.clientY;
        }
        */
    }

    int length = this.interactiveItems.length;
    for (i = 0; i < length; i++) {
      DisplayObject item = this.interactiveItems[i];
      item.touchmove(touchData);
    }
  }

  /**
 * Is called when a touch is started on the renderer element
 *
 * @method onTouchStart
 * @param event {Event} The DOM event of a touch starting on the renderer view
 * @private
 */
  void onTouchStart(TouchEvent event) {
    var rect = this.interactionDOMElement.getBoundingClientRect();

    if (AUTO_PREVENT_DEFAULT) event.preventDefault();

    TouchList changedTouches = event.changedTouches;
    for (int i = 0; i < changedTouches.length; i++) {
      Touch touchEvent = changedTouches[i];

      var touchData = this.pool.removeLast();
      if (touchData == null) touchData = new InteractionData();

      touchData.originalEvent = event;

      this.touchs[touchEvent.identifier] = touchData;
      touchData.global.x = (touchEvent.client.x - rect.left) * (this.target.width / rect.width);
      touchData.global.y = (touchEvent.client.y - rect.top) * (this.target.height / rect.height);
      /*
        if(navigator.isCocoonJS) {
            touchData.global.x = touchEvent.clientX;
            touchData.global.y = touchEvent.clientY;
        }
        */

      int length = this.interactiveItems.length;

      for (int j = 0; j < length; j++) {
        DisplayObject item = this.interactiveItems[j];

        item._hit = this.hitTest(item, touchData);

        if (item._hit) {
          //call the function!
          item.touchstart(touchData);
          item._isDown = true;
          item._touchData = touchData;

          if (!item.interactiveChildren) break;
        }

      }
    }
  }

  /**
 * Is called when a touch is ended on the renderer element
 *
 * @method onTouchEnd
 * @param event {Event} The DOM event of a touch ending on the renderer view
 * @private
 */
  void onTouchEnd(TouchEvent event) {
    //this.mouse.originalEvent = event || window.event; //IE uses window.event
    var rect = this.interactionDOMElement.getBoundingClientRect();
    TouchList changedTouches = event.changedTouches;

    for (int i = 0; i < changedTouches.length; i++) {
      Touch touchEvent = changedTouches[i];
      InteractionData touchData = this.touchs[touchEvent.identifier];
      bool up = false;
      touchData.global.x = (touchEvent.client.x - rect.left) * (this.target.width / rect.width);
      touchData.global.y = (touchEvent.client.y - rect.top) * (this.target.height / rect.height);
      /*
        if(navigator.isCocoonJS) {
            touchData.global.x = touchEvent.clientX;
            touchData.global.y = touchEvent.clientY;
        }
        */

      int length = this.interactiveItems.length;
      for (int j = 0; j < length; j++) {
        DisplayObject item = this.interactiveItems[j];
        var itemTouchData = item._touchData; // <-- Here!
        item._hit = this.hitTest(item, touchData);

        if (itemTouchData == touchData) {
          // so this one WAS down...
          touchData.originalEvent = event;
          // hitTest??



          if (item._hit && !up) {
            item.touchend(touchData);
            if (item._isDown) {
              item.tap(touchData);
            }

            if (!item.interactiveChildren) up = true;
          } else {
            if (item._isDown) {
              item.touchendoutside(touchData);
            }
          }

          item._isDown = false;


          item._touchData = null;

        }
        /*
            else
            {

            }
            */
      }
      // remove the touch..
      this.pool.add(touchData);
      this.touchs[touchEvent.identifier] = null;
    }
  }

}
