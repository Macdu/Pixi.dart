part of pixi;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The Point object represents a location in a two-dimensional coordinate system, where x represents the horizontal axis and y represents the vertical axis.
 *
 * @class Point
 * @constructor
 * @param x {Number} position of the point on the x axis
 * @param y {Number} position of the point on the y axis
 */
class Point {

  /**
  * @property x
  * @type Number
  * @default 0
  */
  double x;

  /**
  * @property y
  * @type Number
  * @default 0
  */
  double y;

  Point([this.x = 0.0, this.y = 0.0]);

  /**
   * Creates a clone of this point
   *
   * @method clone
   * @return {Point} a copy of the point
   */
  Point clone() {
    return new Point(this.x, this.y);
  }

  set([double x = 0.0, double y = null]) {
    this.x = x;
    if (y != null) this.y = y; else this.y = x;
  }

}
