part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * Holds all information related to an Interaction event
 *
 * @class InteractionData
 * @constructor
 */
class InteractionData {


  /**
       * This point stores the global coords of where the touch/mouse event happened
       *
       * @property global
       * @type Point
       */
  Point global = new Point();

  // this is here for legacy... but will remove
  Point local = new Point();

  /**
       * The target Sprite that was interacted with
       *
       * @property target
       * @type Sprite
       */
  Sprite target = null;

  /**
       * When passed to an event handler, this will be the original DOM Event that was captured
       *
       * @property originalEvent
       * @type Event
       */
  Event originalEvent = null;


  /**
 * This will return the local coordinates of the specified displayObject for this InteractionData
 *
 * @method getLocalPosition
 * @param displayObject {DisplayObject} The DisplayObject that you would like the local coords off
 * @return {Point} A point containing the coordinates of the InteractionData position relative to the DisplayObject
 */
  Point getLocalPosition(DisplayObject displayObject) {
    Matrix worldTransform = displayObject.worldTransform;
    Point global = this.global;

    // do a cheeky transform to get the mouse coords;
    double a00 = worldTransform.a,
        a01 = worldTransform.b,
        a02 = worldTransform.tx,
        a10 = worldTransform.c,
        a11 = worldTransform.d,
        a12 = worldTransform.ty,
        id = 1 / (a00 * a11 + a01 * -a10);
    // set the mouse coords...
    return new Point(a11 * id * global.x + -a01 * id * global.y + (a12 * a01 - a02 * a11) * id, a00 * id * global.y + -a10 * id * global.x + (-a12 * a00 + a02 * a10) * id);
  }

}
