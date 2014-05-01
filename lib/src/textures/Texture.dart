part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

Map TextureCache = {};
Map FrameCache = {};

int TextureCacheIdGenerator = 0;

/**
 * A texture stores the information that represents an image or part of an image. It cannot be added
 * to the display list directly. To do this use PIXI.Sprite. If no frame is provided then the whole image is used
 */
class Texture extends EventTarget {

  bool noFrame = false;

  /**
       * The base texture of that this texture uses
       *
       * @property baseTexture
       * @type BaseTexture
       */
  BaseTexture baseTexture;

  /**
       * The frame specifies the region of the base texture that this texture uses
       *
       * @property frame
       * @type Rectangle
       */
  Rectangle frame;

  /**
       * The trim point
       *
       * @property trim
       * @type Rectangle
       */
  Rectangle trim = null;

  int width;

  int height;

  bool updateFrame = false;

  TextureUvs _uvs;

  List _glTextures;

  Map<String, CanvasImageSource> tintCache = {};

  /**
 * @class Texture
 * @uses EventTarget
 * @constructor
 * @param baseTexture {BaseTexture} The base texture source to create the texture from
 * @param frame {Rectangle} The rectangle frame of the texture to show
 */
  Texture(BaseTexture baseTexture, [Rectangle frame = null]) {
    this._load(baseTexture, frame);
  }


  /**
 * Helper function that returns a texture based on an image url
 * If the image is not in the texture cache it will be  created and loaded
 *
 * @static
 * @method fromImage
 * @param imageUrl {String} The image url of the texture
 * @param crossorigin {Boolean} Whether requests should be treated as crossorigin
 * @param scaleMode {Number} Should be one of the PIXI.scaleMode consts
 * @return Texture
 */
  factory Texture.fromImage(String imageUrl,[ bool crossorigin = true, int scaleMode = 0]) {

    if (!TextureCache.containsKey(imageUrl) || TextureCache[imageUrl] == null) {
      TextureCache[imageUrl] = new Texture(new BaseTexture.fromImage(imageUrl, crossorigin, scaleMode));
    }

    return TextureCache[imageUrl];
  }

  /**
 * Helper function that returns a texture based on a frame id
 * If the frame id is not in the texture cache an error will be thrown
 *
 * @static
 * @method fromFrame
 * @param frameId {String} The frame id of the texture
 * @return Texture
 */
  factory Texture.fromFrame(String frameId) {
    if (!TextureCache.containsKey(frameId)) throw new Exception('The frameId "' + frameId.toString() + '" does not exist in the texture cache ');
    //TODO change it
    WebGLRenderer.updateTextureFrame(TextureCache[frameId]);
    return TextureCache[frameId];
  }

  /**
 * Helper function that returns a texture based on a canvas element
 * If the canvas is not in the texture cache it will be  created and loaded
 *
 * @static
 * @method fromCanvas
 * @param canvas {Canvas} The canvas element source of the texture
 * @param scaleMode {Number} Should be one of the PIXI.scaleMode consts
 * @return Texture
 */
  Texture.fromCanvas(CanvasElement canvas,[ int scaleMode = 0]) {
    BaseTexture baseTexture = new BaseTexture.fromCanvas(canvas, scaleMode);

    this._load(baseTexture);

  }



  void _load(BaseTexture baseTexture, [Rectangle frame = null]) {

    if (frame == null) {
      this.noFrame = true;
      frame = new Rectangle(0.0, 0.0, 1.0, 1.0);
    }
    /**
       * The base texture of that this texture uses
       *
       * @property baseTexture
       * @type BaseTexture
       */
    this.baseTexture = baseTexture;

    /**
       * The frame specifies the region of the base texture that this texture uses
       *
       * @property frame
       * @type Rectangle
       */
    this.frame = frame;

    if (baseTexture.hasLoaded) {
      if (this.noFrame) frame = new Rectangle(0.0, 0.0, baseTexture.width.toDouble(), baseTexture.height.toDouble());

      this.setFrame(frame);
    } else {
      baseTexture.listen('loaded', this.onBaseTextureLoaded);
    }

  }


  /**
 * Called when the base texture is loaded
 *
 * @method onBaseTextureLoaded
 * @param event
 * @private
 */
  void onBaseTextureLoaded([_]) {
    BaseTexture baseTexture = this.baseTexture;

    if (this.noFrame) this.frame = new Rectangle(0.0, 0.0, baseTexture.width.toDouble(), baseTexture.height.toDouble());

    this.setFrame(this.frame);

    this.fire({
      'type': 'update',
      'content': this
    });
  }

  /**
 * Destroys this texture
 *
 * @method destroy
 * @param destroyBase {Boolean} Whether to destroy the base texture as well
 */
  void destroy([bool destroyBase = false]) {
    if (destroyBase) this.baseTexture.destroy();
  }

  /**
 * Specifies the rectangle region of the baseTexture
 *
 * @method setFrame
 * @param frame {Rectangle} The frame of the texture to set it to
 */
  void setFrame(Rectangle frame) {
    this.frame = frame;
    this.width = frame.width.toInt();
    this.height = frame.height.toInt();

    if (frame.x + frame.width > this.baseTexture.width || frame.y + frame.height > this.baseTexture.height) {
      throw new Exception('Texture Error: frame does not fit inside the base Texture dimensions ' + this.toString());
    }

    this.updateFrame = true;

    Texture.frameUpdates.add(this);


    //this.dispatchEvent( { type: 'update', content: this } );
  }

  void _updateWebGLuvs() {
    if (this._uvs == null) this._uvs = new TextureUvs();

    Rectangle frame = this.frame;
    int tw = this.baseTexture.width;
    int th = this.baseTexture.height;

    this._uvs.x0 = frame.x / tw;
    this._uvs.y0 = frame.y / th;

    this._uvs.x1 = (frame.x + frame.width) / tw;
    this._uvs.y1 = frame.y / th;

    this._uvs.x2 = (frame.x + frame.width) / tw;
    this._uvs.y2 = (frame.y + frame.height) / th;

    this._uvs.x3 = frame.x / tw;
    this._uvs.y3 = (frame.y + frame.height) / th;
  }


  /**
 * Adds a texture to the textureCache.
 *
 * @static
 * @method addTextureToCache
 * @param texture {Texture}
 * @param id {String} the id that the texture will be stored against.
 */
  static void addTextureToCache(Texture texture, String id) {
    TextureCache[id] = texture;
  }

  /**
 * Remove a texture from the textureCache.
 *
 * @static
 * @method removeTextureFromCache
 * @param id {String} the id of the texture to be removed
 * @return {Texture} the texture that was removed
 */
  static Texture removeTextureFromCache(id) {
    Texture texture = TextureCache[id];
    TextureCache.remove(id);
    BaseTextureCache.remove(id);
    return texture;
  }

  // this is more for webGL.. it contains updated frames..
  static List frameUpdates = [];

}

class TextureUvs {
  double x0 = 0.0;
  double y0 = 0.0;

  double x1 = 0.0;
  double y1 = 0.0;

  double x2 = 0.0;
  double y2 = 0.0;

  double x3 = 0.0;
  double y3 = 0.0;


}
