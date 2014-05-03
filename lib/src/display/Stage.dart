part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A Stage represents the root of the display tree. Everything connected to the stage is rendered
 *
 * @class Stage
 * @extends DisplayObjectContainer
 * @constructor
 * @param backgroundColor {Number} the background color of the stage, you have to pass this in is in hex format
 *      like: 0xFFFFFF for white
 * 
 * Creating a stage is a mandatory process when you use Pixi, which is as simple as this : 
 * var stage = new PIXI.Stage(0xFFFFFF);
 * where the parameter given is the background colour of the stage, in hex
 * you will use this stage instance to add your sprites to it and therefore to the renderer
 * Here is how to add a sprite to the stage : 
 * stage.addChild(sprite);
 */
class Stage extends DisplayObjectContainer {



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
     * Whether or not the stage is interactive
     *
     * @property interactive
     * @type Boolean
     */
  bool interactive;

  /**
     * The interaction manage for this stage, manages all interactive activity on the stage
     *
     * @property interactive
     * @type InteractionManager
     */
  InteractionManager interactionManager;

  /**
     * Whether the stage is dirty and needs to have interactions updated
     *
     * @property dirty
     * @type Boolean
     * @private
     */
  bool dirty = true;

  int backgroundColor;

  var backgroundColorSplit;

  String backgroundColorString;
  
  bool _interactiveEventsAdded = false;
  

  //optimize hit detection a bit

  Stage([int backgroundColor = 0x000000, bool this.interactive = false]): super() {

    if(interactive){
      this.interactionManager = new InteractionManager(this);
    }

    this.hitArea = new Rectangle(0.0, 0.0, 100000.0, 100000.0);

    this.setBackgroundColor(backgroundColor);

  }

  /**
   * Sets another DOM element which can receive mouse/touch interactions instead of the default Canvas element.
   * This is useful for when you have other DOM elements on top of the Canvas element.
   *
   * @method setInteractionDelegate
   * @param domElement {DOMElement} This new domElement which will receive mouse/touch events
   */
  void setInteractionDelegate(Element domElement) {
    this.interactionManager.setTargetDomElement(domElement);
  }

  /*
   * Updates the object transform for rendering
   *
   * @method updateTransform
   * @private
   */
  void updateTransform() {
    this.worldAlpha = 1.0;

    for (int i = 0,
        j = this.children.length; i < j; i++) {
      this.children[i].updateTransform();
    }

    if (this.dirty) {
      this.dirty = false;
      // update interactive!
      if(interactive)this.interactionManager.dirty = true;
    }

    if (this.interactive) this.interactionManager.update();
  }

  /**
   * Sets the background color for the stage
   *
   * @method setBackgroundColor
   * @param backgroundColor {Number} the color of the background, easiest way to pass this in is in hex format
   *      like: 0xFFFFFF for white
   */
  void setBackgroundColor(int backgroundColor) {
    this.backgroundColor = backgroundColor;
    this.backgroundColorSplit = hex2rgb(this.backgroundColor);
    var hex = this.backgroundColor.toRadixString(16);
    hex = '000000'.substring(0, 6 - hex.length) + hex;
    this.backgroundColorString = '#' + hex;
  }

  /**
   * This will return the point containing global coords of the mouse.
   *
   * @method getMousePosition
   * @return {Point} The point containing the coords of the global InteractionData position.
   */
  Point getMousePosition() {
    return this.interactionManager.mouse.global;
  }

}
