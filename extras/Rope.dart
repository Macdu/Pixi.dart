part of pixi;
/* @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * 
 * @class Rope
 * @constructor
 * @param texture {Texture} The texture to use
 * @param points {Array}
 * 
 */
class Rope extends Strip {

  Float32List verticies, uvs, colors;
  Uint16List indices;

  List<Point> points;

  double count;



  Rope(Texture texture, List<Point> this.points): super(texture) {

    this.verticies = new Float32List(points.length * 4);
    this.uvs = new Float32List(points.length * 4);
    this.colors = new Float32List(points.length * 2);

    this.indices = new Uint16List(points.length * 2);

    this.refresh();
  }


  /*
   * Refreshes 
   *
   * @method refresh
   */
  void refresh() {
    List<Point> points = this.points;
    if (points.length < 1) return;

    Float32List uvs = this.uvs;

    Point lastPoint = points[0];
    Uint16List indices = this.indices;
    Float32List colors = this.colors;

    this.count -= 0.2;


    uvs[0] = 0.0;
    uvs[1] = 1.0;
    uvs[2] = 0.0;
    uvs[3] = 1.0;

    colors[0] = 1.0;
    colors[1] = 1.0;

    indices[0] = 0;
    indices[1] = 1;

    int total = points.length,
        index;
    double amount;
    Point point;

    for (int i = 1; i < total; i++) {

      point = points[i];
      index = i * 4;
      // time to do some smart drawing!
      amount = i / (total - 1);

      if (i % 2 == 1) {
        uvs[index] = amount;
        uvs[index + 1] = 0.0;

        uvs[index + 2] = amount;
        uvs[index + 3] = 1.0;

      } else {
        uvs[index] = amount;
        uvs[index + 1] = 0.0;

        uvs[index + 2] = amount;
        uvs[index + 3] = 1.0;
      }

      index = i * 2;
      colors[index] = 1.0;
      colors[index + 1] = 1.0;

      index = i * 2;
      indices[index] = index;
      indices[index + 1] = index + 1;

      lastPoint = point;
    }
  }

  /*
   * Updates the object transform for rendering
   *
   * @method updateTransform
   * @private
   */
  void updateTransform() {

    List<Point> points = this.points;
    if (points.length < 1) return;

    Point lastPoint = points[0];
    Point nextPoint;
    Map<String, double> perp = {
      'x': 0.0,
      'y': 0.0
    };

    this.count -= 0.2;

    Float32List verticies = this.verticies;
    verticies[0] = lastPoint.x + perp['x'];
    verticies[1] = lastPoint.y + perp['y']; //+ 200
    verticies[2] = lastPoint.x - perp['x'];
    verticies[3] = lastPoint.y - perp['y'];//+200
    // time to do some smart drawing!

    int total = points.length,
        index,
        num;
    double ratio, perpLength;
    Point point;

    for (int i = 1; i < total; i++) {
      point = points[i];
      index = i * 4;

      if (i < points.length - 1) {
        nextPoint = points[i + 1];
      } else {
        nextPoint = point;
      }

      perp['y'] = -(nextPoint.x - lastPoint.x);
      perp['x'] = nextPoint.y - lastPoint.y;

      ratio = (1 - (i / (total - 1))) * 10;

      if (ratio > 1) ratio = 1;

      perpLength = Math.sqrt(perp['x'] * perp['x'] + perp['y'] * perp['y']);
      num = this.texture.height / 2; //(20 + Math.abs(Math.sin((i + this.count) * 0.3) * 50) )* ratio;
      perp['x'] /= perpLength;
      perp['y'] /= perpLength;

      perp['x'] *= num;
      perp['y'] *= num;

      verticies[index] = point.x + perp['x'];
      verticies[index + 1] = point.y + perp['y'];
      verticies[index + 2] = point.x - perp['x'];
      verticies[index + 3] = point.y - perp['y'];

      lastPoint = point;
    }

    super.updateTransform();
  }
  /*
   * Sets the texture that the Rope will use 
   *
   * @method setTexture
   * @param texture {Texture} the texture that will be used
   */
  void setTexture(Texture texture) {
    // stop current texture
    this.texture = texture;
    this.updateFrame = true;
  }

}
