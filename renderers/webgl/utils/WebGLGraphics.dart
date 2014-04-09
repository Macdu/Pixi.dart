part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

class WebGLGraphics {
  /**
 * A set of functions used by the webGL renderer to draw the primitive graphics data
 *
 * @class WebGLGraphics
 */

  /**
 * Renders the graphics object
 *
 * @static
 * @private
 * @method renderGraphics
 * @param graphics {Graphics}
 * @param renderSession {Object}
 */
  static void renderGraphics(Graphics graphics, RenderSession renderSession) //projection, offset)
  {
    RenderingContext gl = renderSession.gl;
    Point projection = renderSession.projection,
        offset = renderSession.offset;
    PrimitiveShader shader = renderSession.shaderManager.primitiveShader;

    int id = WebGLRenderer._getIndexFirst(gl);

    if (graphics._webGL[id] == null) graphics._webGL[id] = {
      'points': [],
      'indices': [],
      'lastIndex': 0,
      'buffer': gl.createBuffer(),
      'indexBuffer': gl.createBuffer()
    };

    Map webGL = graphics._webGL[id];

    if (graphics.dirty) {
      graphics.dirty = false;

      if (graphics.clearDirty) {
        graphics.clearDirty = false;

        webGL['lastIndex'] = 0;
        webGL['points'] = [];
        webGL['indices'] = [];

      }

      WebGLGraphics.updateGraphics(graphics, gl);
    }

    renderSession.shaderManager.activatePrimitiveShader();

    // This  could be speeded up for sure!

    // set the matrix transform
    gl.blendFunc(ONE, ONE_MINUS_SRC_ALPHA);

    gl.uniformMatrix3fv(shader.translationMatrix, false, graphics.worldTransform.toList(true));

    gl.uniform2f(shader.projectionVector, projection.x, -projection.y);
    gl.uniform2f(shader.offsetVector, -offset.x, -offset.y);

    gl.uniform3fv(shader.tintColor, new Float32List.fromList(hex2rgb(graphics.tint).fold(
        new List<double>(), 
          (List<double> liste, int value)=>liste..add(value.toDouble())
          )));

    gl.uniform1f(shader.alpha, graphics.worldAlpha);
    gl.bindBuffer(ARRAY_BUFFER, webGL['buffer']);

    gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 4 * 6, 0);
    gl.vertexAttribPointer(shader.colorAttribute, 4, FLOAT, false, 4 * 6, 2 * 4);

    // set the index buffer!
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGL['indexBuffer']);

    gl.drawElements(TRIANGLE_STRIP, webGL['indices'].length, UNSIGNED_SHORT, 0);

    renderSession.shaderManager.deactivatePrimitiveShader();

    // return to default shader...
    //  PIXI.activateShader(PIXI.defaultShader);
  }

  /**
 * Updates the graphics object
 *
 * @static
 * @private
 * @method updateGraphics
 * @param graphicsData {Graphics} The graphics object to update
 * @param gl {WebGLContext} the current WebGL drawing context
 */
  static void updateGraphics(Graphics graphics, RenderingContext gl) {
    Map webGL = graphics._webGL[WebGLRenderer._getIndexFirst(gl)];

    for (int i = webGL['lastIndex']; i < graphics.graphicsData.length; i++) {
      Map data = graphics.graphicsData[i];

      if (data['type'] == Graphics.POLY) {
        if (data['fill']) {
          if (data['points'].length > 3) WebGLGraphics.buildPoly(data, webGL);
        }

        if (data['lineWidth'] > 0) {
          WebGLGraphics.buildLine(data, webGL);
        }
      } else if (data['type'] == Graphics.RECT) {
        WebGLGraphics.buildRectangle(data, webGL);
      } else if (data['type'] = Graphics.CIRC || data['type'] == Graphics.ELIP) {
        WebGLGraphics.buildCircle(data, webGL);
      }
    }

    webGL['lastIndex'] = graphics.graphicsData.length;



    webGL['glPoints'] = new Float32List.fromList(webGL['points']);

    gl.bindBuffer(ARRAY_BUFFER, webGL['buffer']);
    gl.bufferData(ARRAY_BUFFER, webGL['glPoints'], STATIC_DRAW);

    webGL['glIndicies'] = new Uint16List.fromList(webGL['indices']);

    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, webGL['indexBuffer']);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, webGL['glIndicies'], STATIC_DRAW);
  }

  /**
 * Builds a rectangle to draw
 *
 * @static
 * @private
 * @method buildRectangle
 * @param graphicsData {Graphics} The graphics object containing all the necessary properties
 * @param webGLData {Object}
 */
  static void buildRectangle(Map graphicsData, Map webGLData) {
    // --- //
    // need to convert points to a nice regular data
    //
    List<int> rectData = graphicsData['points'];
    int x = rectData[0];
    int y = rectData[1];
    int width = rectData[2];
    int height = rectData[3];


    if (graphicsData.containsKey('fill')) {
      List<int> color = hex2rgb(graphicsData['fillColor']);
      double alpha = graphicsData['fillAlpha'];

      double r = color[0] * alpha;
      double g = color[1] * alpha;
      double b = color[2] * alpha;

      List verts = webGLData['points'];
      List indices = webGLData['indices'];

      double vertPos = verts.length / 6;

      // start
      verts.addAll([x, y]);
      verts.addAll([r, g, b, alpha]);

      verts.addAll([x + width, y]);
      verts.addAll([r, g, b, alpha]);

      verts.add([x, y + height]);
      verts.add([r, g, b, alpha]);

      verts.add([x + width, y + height]);
      verts.add([r, g, b, alpha]);

      // insert 2 dead triangles..
      indices.addAll([vertPos, vertPos, vertPos + 1, vertPos + 2, vertPos + 3, vertPos + 3]);
    }

    if (graphicsData.containsKey('lineWidth')) {
      List tempPoints = graphicsData['points'];

      graphicsData['points'] = [x, y, x + width, y, x + width, y + height, x, y + height, x, y];


      WebGLGraphics.buildLine(graphicsData, webGLData);

      graphicsData['points'] = tempPoints;
    }
  }

  /**
 * Builds a circle to draw
 *
 * @static
 * @private
 * @method buildCircle
 * @param graphicsData {Graphics} The graphics object to draw
 * @param webGLData {Object}
 */
  static void buildCircle(Map graphicsData, Map webGLData) {

    // need to convert points to a nice regular data
    List rectData = graphicsData['points'];
    int x = rectData[0];
    int y = rectData[1];
    int width = rectData[2];
    int height = rectData[3];

    int totalSegs = 40;
    double seg = (Math.PI * 2) / totalSegs;

    int i = 0;

    if (graphicsData.containsKey('fill')) {
      List color = hex2rgb(graphicsData['fillColor']);
      double alpha = graphicsData['fillAlpha'];

      double r = color[0] * alpha;
      double g = color[1] * alpha;
      double b = color[2] * alpha;

      List verts = webGLData['points'];
      List indices = webGLData['indices'];

      double vecPos = verts.length / 6;

      indices.add(vecPos);

      for (i = 0; i < totalSegs + 1; i++) {
        verts.addAll([x, y, r, g, b, alpha]);

        verts.addAll([x + Math.sin(seg * i) * width, y + Math.cos(seg * i) * height, r, g, b, alpha]);

        indices.add([vecPos++, vecPos++]);
      }

      indices.add(vecPos - 1);
    }

    if (graphicsData.containsKey('lineWidth')) {
      List tempPoints = graphicsData['points'];

      graphicsData['points'] = [];

      for (i = 0; i < totalSegs + 1; i++) {
        graphicsData['points'].addAll([x + Math.sin(seg * i) * width, y + Math.cos(seg * i) * height]);
      }

      WebGLGraphics.buildLine(graphicsData, webGLData);

      graphicsData['points'] = tempPoints;
    }
  }

  /**
 * Builds a line to draw
 *
 * @static
 * @private
 * @method buildLine
 * @param graphicsData {Graphics} The graphics object containing all the necessary properties
 * @param webGLData {Object}
 */
  static void buildLine(Map graphicsData, Map webGLData) {
    // TODO OPTIMISE!
    int i = 0;

    List points = graphicsData['points'];
    if (points.length == 0) return;

    // if the line width is an odd number add 0.5 to align to a whole pixel
    if (graphicsData['lineWidth'] % 2 == 1) {
      for (i = 0; i < points.length; i++) {
        points[i] += 0.5;
      }
    }

    // get first and last point.. figure out the middle!
    Point firstPoint = new Point(points[0], points[1]);
    Point lastPoint = new Point(points[points.length - 2], points.last);

    // if the first point is the last point - gonna have issues :)
    if (firstPoint.x == lastPoint.x && firstPoint.y == lastPoint.y) {
      points.removeLast();
      points.removeLast();

      lastPoint = new Point(points[points.length - 2], points[points.length - 1]);

      double midPointX = lastPoint.x + (firstPoint.x - lastPoint.x) * 0.5;
      double midPointY = lastPoint.y + (firstPoint.y - lastPoint.y) * 0.5;

      points.insertAll(0, [midPointX, midPointY]);
      points.addAll([midPointX, midPointY]);
    }

    List verts = webGLData['points'];
    List indices = webGLData['indices'];
    double length = points.length / 2;
    double indexCount = points.length.toDouble();
    double indexStart = verts.length / 6;

    // DRAW the Line
    double width = graphicsData['lineWidth'] / 2;

    // sort color
    List color = hex2rgb(graphicsData['lineColor']);
    double alpha = graphicsData['lineAlpha'];
    double r = color[0] * alpha;
    double g = color[1] * alpha;
    double b = color[2] * alpha;

    num px, py, p1x, p1y, p2x, p2y, p3x, p3y;
    num perpx, perpy, perp2x, perp2y, perp3x, perp3y;
    num a1, b1, c1, a2, b2, c2;
    num denom, pdist, dist;

    p1x = points[0];
    p1y = points[1];

    p2x = points[2];
    p2y = points[3];

    perpx = -(p1y - p2y);
    perpy = p1x - p2x;

    dist = Math.sqrt(perpx * perpx + perpy * perpy);

    perpx /= dist;
    perpy /= dist;
    perpx *= width;
    perpy *= width;

    // start
    verts.addAll([p1x - perpx, p1y - perpy, r, g, b, alpha]);

    verts.addAll([p1x + perpx, p1y + perpy, r, g, b, alpha]);

    for (i = 1; i < length - 1; i++) {
      p1x = points[(i - 1) * 2];
      p1y = points[(i - 1) * 2 + 1];

      p2x = points[(i) * 2];
      p2y = points[(i) * 2 + 1];

      p3x = points[(i + 1) * 2];
      p3y = points[(i + 1) * 2 + 1];

      perpx = -(p1y - p2y);
      perpy = p1x - p2x;

      dist = Math.sqrt(perpx * perpx + perpy * perpy);
      perpx /= dist;
      perpy /= dist;
      perpx *= width;
      perpy *= width;

      perp2x = -(p2y - p3y);
      perp2y = p2x - p3x;

      dist = Math.sqrt(perp2x * perp2x + perp2y * perp2y);
      perp2x /= dist;
      perp2y /= dist;
      perp2x *= width;
      perp2y *= width;

      a1 = (-perpy + p1y) - (-perpy + p2y);
      b1 = (-perpx + p2x) - (-perpx + p1x);
      c1 = (-perpx + p1x) * (-perpy + p2y) - (-perpx + p2x) * (-perpy + p1y);
      a2 = (-perp2y + p3y) - (-perp2y + p2y);
      b2 = (-perp2x + p2x) - (-perp2x + p3x);
      c2 = (-perp2x + p3x) * (-perp2y + p2y) - (-perp2x + p2x) * (-perp2y + p3y);

      denom = a1 * b2 - a2 * b1;

      if ((denom).abs() < 0.1) {

        denom += 10.1;
        verts.addAll([p2x - perpx, p2y - perpy, r, g, b, alpha]);

        verts.addAll([p2x + perpx, p2y + perpy, r, g, b, alpha]);

        continue;
      }

      px = (b1 * c2 - b2 * c1) / denom;
      py = (a2 * c1 - a1 * c2) / denom;


      pdist = (px - p2x) * (px - p2x) + (py - p2y) + (py - p2y);


      if (pdist > 140 * 140) {
        perp3x = perpx - perp2x;
        perp3y = perpy - perp2y;

        dist = Math.sqrt(perp3x * perp3x + perp3y * perp3y);
        perp3x /= dist;
        perp3y /= dist;
        perp3x *= width;
        perp3y *= width;

        verts.addAll([p2x - perp3x, p2y - perp3y]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x + perp3x, p2y + perp3y]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x - perp3x, p2y - perp3y]);
        verts.addAll([r, g, b, alpha]);

        indexCount++;
      } else {

        verts.addAll([px, py]);
        verts.addAll([r, g, b, alpha]);

        verts.addAll([p2x - (px - p2x), p2y - (py - p2y)]);
        verts.addAll([r, g, b, alpha]);
      }
    }

    p1x = points[((length - 2) * 2).toInt()];
    p1y = points[((length - 2) * 2 + 1).toInt()];

    p2x = points[((length - 1) * 2).toInt()];
    p2y = points[((length - 1) * 2 + 1).toInt()];

    perpx = -(p1y - p2y);
    perpy = p1x - p2x;

    dist = Math.sqrt(perpx * perpx + perpy * perpy);
    perpx /= dist;
    perpy /= dist;
    perpx *= width;
    perpy *= width;

    verts.addAll([p2x - perpx, p2y - perpy]);
    verts.addAll([r, g, b, alpha]);

    verts.addAll([p2x + perpx, p2y + perpy]);
    verts.addAll([r, g, b, alpha]);

    indices.add(indexStart);

    for (i = 0; i < indexCount; i++) {
      indices.add(indexStart++);
    }

    indices.add(indexStart - 1);
  }

  /**
 * Builds a polygon to draw
 *
 * @static
 * @private
 * @method buildPoly
 * @param graphicsData {Graphics} The graphics object containing all the necessary properties
 * @param webGLData {Object}
 */
  static void buildPoly(Map graphicsData, Map webGLData) {
    List points = graphicsData['points'];
    if (points.length < 6) return;

    // get first and last point.. figure out the middle!
    List verts = webGLData['points'];
    List indices = webGLData['indices'];

    double length = points.length / 2;

    // sort color
    List color = hex2rgb(graphicsData['fillColor']);
    double alpha = graphicsData['fillAlpha'];
    double r = color[0] * alpha;
    double g = color[1] * alpha;
    double b = color[2] * alpha;

    List triangles = Polyk.Triangulate(points);

    double vertPos = verts.length / 6;

    int i = 0;

    for (i = 0; i < triangles.length; i += 3) {
      indices.add(triangles[i] + vertPos);
      indices.add(triangles[i] + vertPos);
      indices.add(triangles[i + 1] + vertPos);
      indices.add(triangles[i + 2] + vertPos);
      indices.add(triangles[i + 2] + vertPos);
    }

    for (i = 0; i < length; i++) {
      verts.addAll([points[i * 2], points[i * 2 + 1], r, g, b, alpha]);
    }
  }

}
