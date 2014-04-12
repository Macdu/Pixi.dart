part of pixi;

/**
 * @author Chad Engler <chad@pantherdev.com>
 */

/**
 * The Circle object can be used to specify a hit area for displayObjects
 *
 * @class Circle
 * @constructor
 * @param x {Number} The X coordinate of the upper-left corner of the framing rectangle of this circle
 * @param y {Number} The Y coordinate of the upper-left corner of the framing rectangle of this circle
 * @param radius {Number} The radius of the circle
 */
class Circle {

  double x;

  double y;

  double radius;

  Circle([double x = 0.0, double y = 0.0, double radius = 0.0]) {
    /**
       * @property x
       * @type Number
       * @default 0
       */
    this.x = x;

    /**
       * @property y
       * @type Number
       * @default 0
       */
    this.y = y;

    /**
       * @property radius
       * @type Number
       * @default 0
       */
    this.radius = radius;
  }

  /**
   * Creates a clone of this Circle instance
   *
   * @method clone
   * @return {Circle} a copy of the polygon
   */
  Circle clone() {
    return new Circle(this.x, this.y, this.radius);
  }

  /**
   * Checks whether the x, and y coordinates passed to this function are contained within this circle
   *
   * @method contains
   * @param x {Number} The X coordinate of the point to test
   * @param y {Number} The Y coordinate of the point to test
   * @return {Boolean} Whether the x/y coordinates are within this polygon
   */
  bool contains(double x, double y) {
    if (this.radius <= 0) return false;

    double dx = (this.x - x),
        dy = (this.y - y),
        r2 = this.radius * this.radius;

    dx *= dx;
    dy *= dy;

    return (dx + dy <= r2);
  }

}
