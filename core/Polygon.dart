part of pixi;

/**
 * @author Adrien Brault <adrien.brault@gmail.com>
 */

/**
 * @class Polygon
 * @constructor
 * @param points* {List<Point>|List<Number>|Point...|Number...} This can be a list of Points that form the polygon,
 *      a flat list of numbers that will be interpreted as [x,y, x,y, ...], or the arguments passed can be
 *      all the points of the polygon e.g. `new PIXI.Polygon(new PIXI.Point(), new PIXI.Point(), ...)`, or the
 *      arguments passed can be flat x,y values e.g. `new PIXI.Polygon(x,y, x,y, x,y, ...)` where `x` and `y` are
 *      Numbers.
 */
class Polygon{
  
  List<Point> points; 

  Polygon(List points)
  {
      //if this is a flat list of numbers, convert it to points
      if(points[0] is int) {
          List p = [];
          for(int i = 0, il = points.length; i < il; i+=2) {
              p.add(
                  new Point(points[i], points[i + 1])
              );
          }
  
          points = p;
      }
  
      this.points = points;
  }
  
  /**
   * Creates a clone of this polygon
   *
   * @method clone
   * @return {Polygon} a copy of the polygon
   */
  Polygon clone()
  {
      List<Point> points = [];
      for (int i=0; i<this.points.length; i++) {
          points.add(this.points[i].clone());
      }
  
      return new Polygon(points);
  }
  
  /**
   * Checks whether the x and y coordinates passed to this function are contained within this polygon
   *
   * @method contains
   * @param x {Number} The X coordinate of the point to test
   * @param y {Number} The Y coordinate of the point to test
   * @return {Boolean} Whether the x/y coordinates are within this polygon
   */
  bool contains(int x,int y)
  {
      bool inside = false;
  
      // use some raycasting to test hits
      // https://github.com/substack/point-in-polygon/blob/master/index.js
      for(int i = 0, j = this.points.length - 1; i < this.points.length; j = i++) {
          var xi = this.points[i].x, yi = this.points[i].y,
              xj = this.points[j].x, yj = this.points[j].y,
              intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
  
          if(intersect) inside = !inside;
      }
  
      return inside;
  }
  
}
