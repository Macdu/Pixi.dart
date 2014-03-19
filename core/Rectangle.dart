part of pixi;

/**
 * @author Mat Groves http://matgroves.com/
 */

/**
 * the Rectangle object is an area defined by its position, as indicated by its top-left corner point (x, y) and by its width and its height.
 *
 * @class Rectangle
 * @constructor
 * @param x {Number} The X coord of the upper-left corner of the rectangle
 * @param y {Number} The Y coord of the upper-left corner of the rectangle
 * @param width {Number} The overall width of this rectangle
 * @param height {Number} The overall height of this rectangle
 */
class Rectangle{
  
  /**
   * @property x
   * @type Number
   * @default 0
   */
  int x;

  /**
   * @property y
   * @type Number
   * @default 0
   */
  int y;

  /**
   * @property width
   * @type Number
   * @default 0
   */
  int width;

  /**
   * @property height
   * @type Number
   * @default 0
   */
  int height;

  Rectangle([this.x = 0 , this.y = 0, this.width = 0 , this.height = 0 ]);
  
  /**
   * Creates a clone of this Rectangle
   *
   * @method clone
   * @return {Rectangle} a copy of the rectangle
   */
  Rectangle clone()
  {
      return new Rectangle(this.x, this.y, this.width, this.height);
  }
  
  /**
   * Checks whether the x and y coordinates passed to this function are contained within this Rectangle
   *
   * @method contains
   * @param x {Number} The X coordinate of the point to test
   * @param y {Number} The Y coordinate of the point to test
   * @return {Boolean} Whether the x/y coords are within this Rectangle
   */
  bool contains(x, y)
  {
      if(this.width <= 0 || this.height <= 0)
          return false;
  
      int x1 = this.x;
      if(x >= x1 && x <= x1 + this.width)
      {
          int y1 = this.y;
  
          if(y >= y1 && y <= y1 + this.height)
          {
              return true;
          }
      }
  
      return false;
  }
}

Rectangle EmptyRectangle = new Rectangle(0,0,0,0);