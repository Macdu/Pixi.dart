part of pixi;
/**
 * @author Mat Groves
 * 
 * 
 */

/**
 * @class CanvasTinter
 * @constructor
 * @static
 */
class CanvasTinter {

  //PIXI.CanvasTinter.cachTint = true;


  /**
 * Basically this method just needs a sprite and a color and tints the sprite 
 * with the given color
 * 
 * @method getTintedTexture 
 * @param sprite {Sprite} the sprite to tint
 * @param color {Number} the color to use to tint the sprite with
 */
  static CanvasImageSource getTintedTexture(Sprite sprite, int color) {

    Texture texture = sprite.texture;

    color = CanvasTinter.roundColor(color);

    String stringColor = "#" + ("00000" + (color | 0).toString()).substring(-6);

    if (texture.tintCache[stringColor] != null) return texture.tintCache[stringColor];

    // clone texture..
    CanvasElement canvas = (CanvasTinter.canvas != null) ? CanvasTinter.canvas : new CanvasElement();

    //PIXI.CanvasTinter.tintWithPerPixel(texture, stringColor, canvas);


    CanvasTinter.tintMethod(texture, color, canvas);

    if (CanvasTinter.convertTintToImage) {
      // is this better?
      ImageElement tintImage = new ImageElement();
      tintImage.src = canvas.toDataUrl();

      texture.tintCache[stringColor] = tintImage;
    } else {

      texture.tintCache[stringColor] = canvas;
      // if we are not converting the texture to an image then we need to lose the reference to the canvas
      CanvasTinter.canvas = null;

    }

    return canvas;
  }

  /**
 * Tint a texture using the "multiply" operation
 * @method tintWithMultiply
 * @param texture {texture} the texture to tint
 * @param color {Number} the color to use to tint the sprite with
 * @param canvas {HTMLCanvasElement} the current canvas
 */
  static void tintWithMultiply(Texture texture, int color, CanvasElement canvas) {
    CanvasRenderingContext2D context = canvas.getContext("2d");

    var frame = texture.frame;

    canvas.width = frame.width;
    canvas.height = frame.height;

    context.fillStyle = "#" + ("00000" + color.toString()).substring(-6);

    context.fillRect(0, 0, frame.width, frame.height);

    context.globalCompositeOperation = "multiply";

    context.drawImageScaledFromSource(texture.baseTexture.source as CanvasImageSource, frame.x, frame.y, frame.width, frame.height, 0, 0, frame.width, frame.height);

    context.globalCompositeOperation = "destination-atop";

    context.drawImageScaledFromSource(texture.baseTexture.source as CanvasImageSource, frame.x, frame.y, frame.width, frame.height, 0, 0, frame.width, frame.height);
  }

  /**
 * Tint a texture using the "overlay" operation
 * @method tintWithOverlay
 * @param texture {texture} the texture to tint
 * @param color {Number} the color to use to tint the sprite with
 * @param canvas {HTMLCanvasElement} the current canvas
 */
  static void tintWithOverlay(Texture texture, int color, CanvasElement canvas) {
    CanvasRenderingContext2D context = canvas.getContext("2d");

    var frame = texture.frame;

    canvas.width = frame.width;
    canvas.height = frame.height;



    context.globalCompositeOperation = "copy";
    context.fillStyle = "#" + ("00000" + (color).toString()).substring(-6);
    context.fillRect(0, 0, frame.width, frame.height);

    context.globalCompositeOperation = "destination-atop";
    context.drawImageScaledFromSource(texture.baseTexture.source as CanvasImageSource, frame.x, frame.y, frame.width, frame.height, 0, 0, frame.width, frame.height);


    //context.globalCompositeOperation = "copy";

  }

  /**
 * Tint a texture pixel per pixel
 * @method tintPerPixel
 * @param texture {texture} the texture to tint
 * @param color {Number} the color to use to tint the sprite with
 * @param canvas {HTMLCanvasElement} the current canvas
 */
  static void tintWithPerPixel(Texture texture, int color, CanvasElement canvas) {
    CanvasRenderingContext2D context = canvas.getContext("2d");

    Rectangle frame = texture.frame;

    canvas.width = frame.width.toInt();
    canvas.height = frame.height.toInt();

    context.globalCompositeOperation = "copy";
    context.drawImageScaledFromSource(texture.baseTexture.source as CanvasImageSource, frame.x, frame.y, frame.width, frame.height, 0, 0, frame.width, frame.height);

    List<int> rgbValues = hex2rgb(color);
    int r = rgbValues[0],
        g = rgbValues[1],
        b = rgbValues[2];

    ImageData pixelData = context.getImageData(0, 0, frame.width, frame.height);

    List<int> pixels = pixelData.data;

    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i + 0] *= r;
      pixels[i + 1] *= g;
      pixels[i + 2] *= b;
    }

    context.putImageData(pixelData, 0, 0);
  }

  /**
 * Rounds the specified color according to the PIXI.CanvasTinter.cacheStepsPerColorChannel
 * @method roundColor
 * @param color {number} the color to round, should be a hex color
 */
  static num roundColor(int color) {
    var step = CanvasTinter.cacheStepsPerColorChannel;

    var rgbValues = hex2rgb(color);

    rgbValues[0] = Math.min(255, (rgbValues[0] / step) * step);
    rgbValues[1] = Math.min(255, (rgbValues[1] / step) * step);
    rgbValues[2] = Math.min(255, (rgbValues[2] / step) * step);

    return rgb2hex(rgbValues);
  }

  /**
 * 
 * Number of steps which will be used as a cap when rounding colors
 *
 * @property cacheStepsPerColorChannel
 * @type Number
 */
  static int cacheStepsPerColorChannel = 8;
  /**
 * 
 * Number of steps which will be used as a cap when rounding colors
 *
 * @property convertTintToImage
 * @type Boolean
 */
  static bool convertTintToImage = false;

  /**
 * Whether or not the Canvas BlendModes are supported, consequently the ability to tint using the multiply method
 *
 * @property canUseMultiply
 * @type Boolean
 */
  static bool canUseMultiply = canUseNewCanvasBlendModes();

  static Function tintMethod = CanvasTinter.canUseMultiply ? CanvasTinter.tintWithMultiply : CanvasTinter.tintWithPerPixel;
  
  static CanvasElement canvas = null;

}
