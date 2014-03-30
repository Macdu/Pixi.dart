part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */


/**
 * A set of functions used by the canvas renderer to draw the primitive graphics data
 *
 * @class CanvasGraphics
 */
class CanvasGraphics {

  /*
 * Renders the graphics object
 *
 * @static
 * @private
 * @method renderGraphics
 * @param graphics {Graphics} the actual graphics object to render
 * @param context {Context2D} the 2d drawing method of the canvas
 */
  void renderGraphics(Graphics graphics, CanvasRenderingContext2D context) {
    double worldAlpha = graphics.worldAlpha;
    String color = '';

    for (int i = 0; i < graphics.graphicsData.length; i++) {
      Map data = graphics.graphicsData[i];
      List points = data['points'];

      context.strokeStyle = color = '#' + ('00000' + (data['lineColor']).toString(16)).substring(-6);

      context.lineWidth = data['lineWidth'];

      if (data['type'] == Graphics.POLY) {
        context.beginPath();

        context.moveTo(points[0], points[1]);

        for (int j = 1; j < points.length / 2; j++) {
          context.lineTo(points[j * 2], points[j * 2 + 1]);
        }

        // if the first and last point are the same close the path - much neater :)
        if (points[0] == points[points.length - 2] && points[1] == points[points.length - 1]) {
          context.closePath();
        }

        if (data['fill']) {
          context.globalAlpha = data['fillAlpha'] * worldAlpha;
          context.fillStyle = color = '#' + ('00000' + (data['fillColor']).toString(16)).substring(-6);
          context.fill();
        }
        if (data['lineWidth'] != null) {
          context.globalAlpha = data['lineAlpha'] * worldAlpha;
          context.stroke();
        }
      } else if (data['type'] == Graphics.RECT) {

        if (data['fillColor'] == null || data['fillColor'] == 0) {
          context.globalAlpha = data['fillAlpha'] * worldAlpha;
          context.fillStyle = color = '#' + ('00000' + (data['fillColor']).toString(16)).substring(-6);
          context.fillRect(points[0], points[1], points[2], points[3]);

        }
        if (data['lineWidth'] != null) {
          context.globalAlpha = data['lineAlpha'] * worldAlpha;
          context.strokeRect(points[0], points[1], points[2], points[3]);
        }

      } else if (data['type'] == Graphics.CIRC) {
        // TODO - need to be Undefined!
        context.beginPath();
        context.arc(points[0], points[1], points[2], 0, 2 * Math.PI);
        context.closePath();

        if (data['fill'] != null) {
          context.globalAlpha = data['fillAlpha'] * worldAlpha;
          context.fillStyle = color = '#' + ('00000' + (data['fillColor']).toString(16)).substring(-6);
          context.fill();
        }
        if (data['lineWidth'] != null) {
          context.globalAlpha = data['lineAlpha'] * worldAlpha;
          context.stroke();
        }
      } else if (data['type'] == Graphics.ELIP) {

        // ellipse code taken from: http://stackoverflow.com/questions/2172798/how-to-draw-an-oval-in-html5-canvas

        List ellipseData = data['points'];

        int w = ellipseData[2] * 2;
        int h = ellipseData[3] * 2;

        int x = ellipseData[0] - w / 2;
        int y = ellipseData[1] - h / 2;

        context.beginPath();

        double kappa = 0.5522848,
            ox = (w / 2) * kappa, // control point offset horizontal
            oy = (h / 2) * kappa, // control point offset vertical
            xe = (x + w).toDouble(), // x-end
            ye = (y + h).toDouble(), // y-end
            xm = x + w / 2, // x-middle
            ym = y + h / 2; // y-middle

        context.moveTo(x, ym);
        context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
        context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
        context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
        context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);

        context.closePath();

        if (data['fill'] != null) {
          context.globalAlpha = data['fillAlpha'] * worldAlpha;
          context.fillStyle = color = '#' + ('00000' + (data['fillColor']).toString(16)).substring(-6);
          context.fill();
        }
        if (data['lineWidth'] != null) {
          context.globalAlpha = data['lineAlpha'] * worldAlpha;
          context.stroke();
        }
      }
    }
  }

  /*
 * Renders a graphics mask
 *
 * @static
 * @private
 * @method renderGraphicsMask
 * @param graphics {Graphics} the graphics which will be used as a mask
 * @param context {Context2D} the context 2d method of the canvas
 */
  void renderGraphicsMask(Graphics graphics, CanvasRenderingContext2D context) {
    int len = graphics.graphicsData.length;

    if (len == 0) return;

    if (len > 1) {
      len = 1;
      print('Pixi.js warning: masks in canvas can only mask using the first path in the graphics object');
    }

    for (int i = 0; i < 1; i++) {
      Map data = graphics.graphicsData[i];
      List points = data['points'];

      if (data['type'] == Graphics.POLY) {
        context.beginPath();
        context.moveTo(points[0], points[1]);

        for (int j = 1; j < points.length / 2; j++) {
          context.lineTo(points[j * 2], points[j * 2 + 1]);
        }

        // if the first and last point are the same close the path - much neater :)
        if (points[0] == points[points.length - 2] && points[1] == points[points.length - 1]) {
          context.closePath();
        }

      } else if (data['type'] == Graphics.RECT) {
        context.beginPath();
        context.rect(points[0], points[1], points[2], points[3]);
        context.closePath();
      } else if (data['type'] == Graphics.CIRC) {
        // TODO - need to be Undefined!
        context.beginPath();
        context.arc(points[0], points[1], points[2], 0, 2 * Math.PI);
        context.closePath();
      } else if (data['type'] == Graphics.ELIP) {

        // ellipse code taken from: http://stackoverflow.com/questions/2172798/how-to-draw-an-oval-in-html5-canvas
        List ellipseData = data['points'];

        int w = ellipseData[2] * 2;
        int h = ellipseData[3] * 2;

        int x = ellipseData[0] - w / 2;
        int y = ellipseData[1] - h / 2;

        context.beginPath();

        double kappa = 0.5522848,
            ox = (w / 2) * kappa, // control point offset horizontal
            oy = (h / 2) * kappa, // control point offset vertical
            xe = (x + w).toDouble(), // x-end
            ye = (y + h).toDouble(), // y-end
            xm = x + w / 2, // x-middle
            ym = y + h / 2; // y-middle

        context.moveTo(x, ym);
        context.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
        context.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
        context.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
        context.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
        context.closePath();
      }
    }
  }
}
