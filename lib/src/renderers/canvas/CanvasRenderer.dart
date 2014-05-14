part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * the CanvasRenderer draws the stage and all its content onto a 2d canvas. This renderer should be used for browsers that do not support webGL.
 * Dont forget to add the view to your DOM or you will not see anything :)
 */
class CanvasRenderer extends Renderer{

  int type = CANVAS_RENDERER;

  /**
       * This sets if the CanvasRenderer will clear the canvas or not before the new render pass.
       * If the Stage is NOT transparent Pixi will use a canvas sized fillRect operation every frame to set the canvas background color.
       * If the Stage is transparent Pixi will use clearRect to clear the canvas every frame.
       * Disable this by setting this to false. For example if your game has a canvas filling background image you often don't need this set.
       *
       * @property clearBeforeRender
       * @type Boolean
       * @default
       */
  bool clearBeforeRender = true;

  /**
       * If true Pixi will Math.floor() x/y values when rendering, stopping pixel interpolation.
       * Handy for crisp pixel art and speed on legacy devices.
       *
       * @property roundPixels
       * @type Boolean
       * @default
       */
  bool roundPixels = false;

  /**
       * Whether the render view is transparent
       *
       * @property transparent
       * @type Boolean
       */
  bool transparent;

  /**
           * The width of the canvas view
           *
           * @property width
           * @type Number
           * @default 800
           */
  int width;

  /**
           * The height of the canvas view
           *
           * @property height
           * @type Number
           * @default 600
           */
  int height;


  /**
           * The canvas 2d context that everything is drawn with
           * @property context
           * @type HTMLCanvasElement 2d Context
           */
  CanvasRenderingContext2D context;

  bool refresh = true;
  // hack to enable some hardware acceleration!
  //this.view.style["transform"] = "translatez(0)";

  int count = 0;

  /**
           * Instance of a PIXI.CanvasMaskManager, handles masking when using the canvas renderer
           * @property CanvasMaskManager
           * @type CanvasMaskManager
           */
  CanvasMaskManager maskManager = new CanvasMaskManager();

  /**
           * The render session is just a bunch of parameter used for rendering
           * @property renderSession
           * @type Object
           */
  RenderSession renderSession = new RenderSession();

  /**
 * @class CanvasRenderer
 * @constructor
 * @param width=800 {Number} the width of the canvas view
 * @param height=600 {Number} the height of the canvas view
 * @param [view] {HTMLCanvasElement} the canvas to use as a view, optional
 * @param [transparent=false] {Boolean} the transparency of the render view, default false
 */
  CanvasRenderer([int width = 800, int height = 600, CanvasElement view = null, bool this.transparent = false]) {
    defaultRenderer = (defaultRenderer != null) ? defaultRenderer : this;

    if(view == null)view = new CanvasElement();

    if (blendModesCanvas.isEmpty) {

      if (canUseNewCanvasBlendModes()) {
        /*
          blendModesCanvas[blendModes['NORMAL']] = "source-over";
          blendModesCanvas[blendModes['ADD']] = "lighter"; //IS THIS OK???
          blendModesCanvas[blendModes['MULTIPLY']] = "multiply";
          blendModesCanvas[blendModes['SCREEN']] = "screen";
          blendModesCanvas[blendModes['OVERLAY']] = "overlay";
          blendModesCanvas[blendModes['DARKEN']] = "darken";
          blendModesCanvas[blendModes['LIGHTEN']] = "lighten";
          blendModesCanvas[blendModes['COLOR_DODGE']] = "color-dodge";
          blendModesCanvas[blendModes['COLOR_BURN']] = "color-burn";
          blendModesCanvas[blendModes['HARD_LIGHT']] = "hard-light";
          blendModesCanvas[blendModes['SOFT_LIGHT']] = "soft-light";
          blendModesCanvas[blendModes['DIFFERENCE']] = "difference";
          blendModesCanvas[blendModes['EXCLUSION']] = "exclusion";
          blendModesCanvas[blendModes['HUE']] = "hue";
          blendModesCanvas[blendModes['SATURATION']] = "saturation";
          blendModesCanvas[blendModes['COLOR']] = "color";
          blendModesCanvas[blendModes['LUMINOSITY']] = "luminosity";
        */
        
        blendModesCanvas.addAll(["source-over",
                "lighter", //IS THIS OK???
                "multiply",
                "screen",
                "overlay",
                "darken",
                "lighten",
                "color-dodge",
                "color-burn",
                "hard-light",
                "soft-light",
                "difference",
                "exclusion",
                "hue",
                "saturation",
                "color",
                "luminosity"]);       
      } else {
        /*
          // this means that the browser does not support the cool new blend modes in canvas "cough" ie "cough"
          blendModesCanvas[blendModes['NORMAL']] = "source-over";
          blendModesCanvas[blendModes['ADD']] = "lighter"; //IS THIS OK???
          blendModesCanvas[blendModes['MULTIPLY']] = "source-over";
          blendModesCanvas[blendModes['SCREEN']] = "source-over";
          blendModesCanvas[blendModes['OVERLAY']] = "source-over";
          blendModesCanvas[blendModes['DARKEN']] = "source-over";
          blendModesCanvas[blendModes['LIGHTEN']] = "source-over";
          blendModesCanvas[blendModes['COLOR_DODGE']] = "source-over";
          blendModesCanvas[blendModes['COLOR_BURN']] = "source-over";
          blendModesCanvas[blendModes['HARD_LIGHT']] = "source-over";
          blendModesCanvas[blendModes['SOFT_LIGHT']] = "source-over";
          blendModesCanvas[blendModes['DIFFERENCE']] = "source-over";
          blendModesCanvas[blendModes['EXCLUSION']] = "source-over";
          blendModesCanvas[blendModes['HUE']] = "source-over";
          blendModesCanvas[blendModes['SATURATION']] = "source-over";
          blendModesCanvas[blendModes['COLOR']] = "source-over";
          blendModesCanvas[blendModes['LUMINOSITY']] = "source-over";
        */
        
        blendModesCanvas.addAll(["source-over",
                "lighter", //IS THIS OK???
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over",
                "source-over"]);     
      }
    }
    this.width = width;

    this.height = height;

    this.view = view;

    this.context = this.view.getContext("2d", {
      'alpha': this.transparent
    });


    this.view.width = this.width;
    this.view.height = this.height;

    this.renderSession
      ..context = this.context
      ..maskManager = this.maskManager;
    

    this.renderSession.smoothProperty = "imageSmoothingEnabled";
  }


  /**
 * Renders the stage to its canvas view
 *
 * @method render
 * @param stage {Stage} the Stage element to be rendered
 */
  void render(Stage stage) {
    // update textures if need be
    texturesToUpdate.length = 0;
    texturesToDestroy.length = 0;

    stage.updateTransform();

    this.context.setTransform(1, 0, 0, 1, 0, 0);
    this.context.globalAlpha = 1;

    if (!this.transparent && this.clearBeforeRender) {
      this.context.fillStyle = stage.backgroundColorString;
      this.context.fillRect(0, 0, this.width, this.height);
    } else if (this.transparent && this.clearBeforeRender) {
      this.context.clearRect(0, 0, this.width, this.height);
    }

    this.renderDisplayObject(stage , this.context);

    // run interaction!
    if (stage.interactive) {
      //need to add some events!
      if (!stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = true;
        stage.interactionManager.setTarget(this);
      }
    }

    // remove frame updates..
    if (Texture.frameUpdates.length > 0) {
      Texture.frameUpdates.length = 0;
    }
  }

  /**
 * Resizes the canvas view to the specified width and height
 *
 * @method resize
 * @param width {Number} the new width of the canvas view
 * @param height {Number} the new height of the canvas view
 */
  void resize(int width, int height) {
    this.width = width;
    this.height = height;

    this.view.width = width;
    this.view.height = height;
  }

  /**
 * Renders a display object
 *
 * @method renderDisplayObject
 * @param displayObject {DisplayObject} The displayObject to render
 * @param context {Context2D} the context 2d method of the canvas
 * @private
 */
  void renderDisplayObject(DisplayObject displayObject, CanvasRenderingContext2D context) {
    // no longer recursive!
    //var transform;
    //var context = this.context;

    this.renderSession.context = (context != null) ? context : this.context;
    displayObject._renderCanvas(this.renderSession);
  }

  /**
 * Renders a flat strip
 *
 * @method renderStripFlat
 * @param strip {Strip} The Strip to render
 * @private
 */
  void renderStripFlat(Strip strip) {
    CanvasRenderingContext2D context = this.context;
    Float32List verticies = strip.verticies;

    int length = verticies.length ~/ 2;
    this.count++;

    context.beginPath();
    for (int i = 1; i < length - 2; i++) {
      // draw some triangles!
      int index = i * 2;

      double x0 = verticies[index],
          x1 = verticies[index + 2],
          x2 = verticies[index + 4];
      double y0 = verticies[index + 1],
          y1 = verticies[index + 3],
          y2 = verticies[index + 5];

      context.moveTo(x0, y0);
      context.lineTo(x1, y1);
      context.lineTo(x2, y2);
    }

    context.fillStyle = "#FF0000";
    context.fill();
    context.closePath();
  }

  /**
 * Renders a strip
 *
 * @method renderStrip
 * @param strip {Strip} The Strip to render
 * @private
 */
  void renderStrip(Strip strip) {
    CanvasRenderingContext2D context = this.context;

    // draw triangles!!
    Float32List verticies = strip.verticies;
    Float32List uvs = strip.uvs;

    int length = verticies.length ~/ 2;
    this.count++;

    for (int i = 1; i < length - 2; i++) {
      // draw some triangles!
      int index = i * 2;

      double x0 = verticies[index],
          x1 = verticies[index + 2],
          x2 = verticies[index + 4];
      double y0 = verticies[index + 1],
          y1 = verticies[index + 3],
          y2 = verticies[index + 5];

      double u0 = uvs[index] * strip.texture.width,
          u1 = uvs[index + 2] * strip.texture.width,
          u2 = uvs[index + 4] * strip.texture.width;
      double v0 = uvs[index + 1] * strip.texture.height,
          v1 = uvs[index + 3] * strip.texture.height,
          v2 = uvs[index + 5] * strip.texture.height;

      context.save();
      context.beginPath();
      context.moveTo(x0, y0);
      context.lineTo(x1, y1);
      context.lineTo(x2, y2);
      context.closePath();

      context.clip();

      // Compute matrix transform
      double delta = u0 * v1 + v0 * u2 + u1 * v2 - v1 * u2 - v0 * u1 - u0 * v2;
      double deltaA = x0 * v1 + v0 * x2 + x1 * v2 - v1 * x2 - v0 * x1 - x0 * v2;
      double deltaB = u0 * x1 + x0 * u2 + u1 * x2 - x1 * u2 - x0 * u1 - u0 * x2;
      double deltaC = u0 * v1 * x2 + v0 * x1 * u2 + x0 * u1 * v2 - x0 * v1 * u2 - v0 * u1 * x2 - u0 * x1 * v2;
      double deltaD = y0 * v1 + v0 * y2 + y1 * v2 - v1 * y2 - v0 * y1 - y0 * v2;
      double deltaE = u0 * y1 + y0 * u2 + u1 * y2 - y1 * u2 - y0 * u1 - u0 * y2;
      double deltaF = u0 * v1 * y2 + v0 * y1 * u2 + y0 * u1 * v2 - y0 * v1 * u2 - v0 * u1 * y2 - u0 * y1 * v2;

      context.transform(deltaA / delta, deltaD / delta, deltaB / delta, deltaE / delta, deltaC / delta, deltaF / delta);

      context.drawImage(strip.texture.baseTexture.source as CanvasImageSource, 0, 0);
      context.restore();
    }
  }
}

/**
 * Creates a Canvas element of the given size
 */
class CanvasBuffer {

  int height;

  int width;

  CanvasElement canvas;

  CanvasRenderingContext2D context;

  /**
 * @method CanvasBuffer
 * @param width {Number} the width for the newly created canvas
 * @param height {Number} the height for the newly created canvas
 * @static
 * @private
 */
  CanvasBuffer(int width, int height) {
    this.width = width;
    this.height = height;

    this.canvas = new CanvasElement();
    this.context = this.canvas.getContext("2d");

    this.canvas.width = width;
    this.canvas.height = height;
  }

  /**
 * Clears the canvas that was created by the CanvasBuffer class
 *
 * @method clear
 * @private
 */
  void clear() {
    this.context.clearRect(0, 0, this.width, this.height);
  }

  /**
 * Resizes the canvas that was created by the CanvasBuffer class to the specified width and height
 *
 * @method resize
 * @param width {Number} the new width of the canvas
 * @param height {Number} the new height of the canvas
 * @private
 */

  void resize(int width, int height) {
    this.width = this.canvas.width = width;
    this.height = this.canvas.height = height;
  }

}
