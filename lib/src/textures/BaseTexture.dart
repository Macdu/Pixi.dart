part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

Map BaseTextureCache = {};
List texturesToUpdate = [];
List texturesToDestroy = [];

int BaseTextureCacheIdGenerator = 0;

/**
 * A texture stores the information that represents an image. All textures have a base texture
 */
class BaseTexture extends EventTarget {


  /**
       * [read-only] The width of the base texture set when the image has loaded
       *
       * @property width
       * @type Number
       * @readOnly
       */
  int width = 100;

  /**
       * [read-only] The height of the base texture set when the image has loaded
       *
       * @property height
       * @type Number
       * @readOnly
       */
  int height = 100;

  /**
       * The scale mode to apply when scaling this texture
       * @property scaleMode
       * @type PIXI.scaleModes
       * @default PIXI.scaleModes.LINEAR
       */
  int scaleMode;

  /**
       * [read-only] Describes if the base texture has loaded or not
       *
       * @property hasLoaded
       * @type Boolean
       * @readOnly
       */
  bool hasLoaded;

  /**
       * The source that is loaded to create the texture
       *
       * @property source
       * @type Image
       */
  Element source;

  String imageUrl = null;

  bool _powerOf2 = false;

  //TODO will be used for futer pixi 1.5...
  int id = BaseTextureCacheIdGenerator++;

  // used for webGL
  List _glTextures = [];

  /**
 * @class BaseTexture
 * @uses EventTarget
 * @constructor
 * @param source {String} the source object (image or canvas)
 * @param scaleMode {Number} Should be one of the PIXI.scaleMode consts
 */
  BaseTexture([HtmlElement source = null, int scaleMode = 0]) {

    this._load(source, scaleMode);

  }

  void _load(Element source, int scaleMode) {

    /**
       * [read-only] The width of the base texture set when the image has loaded
       *
       * @property width
       * @type Number
       * @readOnly
       */
    this.width = 100;

    /**
       * [read-only] The height of the base texture set when the image has loaded
       *
       * @property height
       * @type Number
       * @readOnly
       */
    this.height = 100;

    /**
       * The scale mode to apply when scaling this texture
       * @property scaleMode
       * @type PIXI.scaleModes
       * @default PIXI.scaleModes.LINEAR
       */
    this.scaleMode = scaleMode;

    /**
       * [read-only] Describes if the base texture has loaded or not
       *
       * @property hasLoaded
       * @type Boolean
       * @readOnly
       */
    this.hasLoaded = false;

    /**
       * The source that is loaded to create the texture
       *
       * @property source
       * @type Image
       */
    this.source = source;

    if (source == null) return;

    if (source is ImageElement && source.complete) {
      this.hasLoaded = true;
      this.width = source.width;
      this.height = source.height;

      texturesToUpdate.add(this);
    } else if (source is CanvasElement) {
      this.hasLoaded = true;
      this.width = source.width;
      this.height = source.height;

      texturesToUpdate.add(this);
    } else {
      this.source.onLoad.listen(([_]) {

        if (source is ImageElement) {
          this.hasLoaded = true;
          this.width = source.width;
          this.height = source.height;

          texturesToUpdate.add(this);
        } else if (source is CanvasElement) {
          this.hasLoaded = true;
          this.width = source.width;
          this.height = source.height;

          texturesToUpdate.add(this);
        }

        // add it to somewhere...
        this.fire({
          'type': 'loaded',
          'content': this
        });
      });
    }

  }


  /**
 * Destroys this base texture
 *
 * @method destroy
 */
  void destroy() {
    if (this.imageUrl != null) {
      BaseTextureCache.remove(this.imageUrl);
      this.imageUrl = null;
      if (this.source is ImageElement) this.source.src = null; else if (this.source is CanvasElement) this.source.src = null;
    }
    this.source = null;
    texturesToDestroy.add(this);
  }

  /**
 * Changes the source image of the texture
 *
 * @method updateSourceImage
 * @param newSrc {String} the path of the image
 */
  void updateSourceImage(String newSrc) {
    this.hasLoaded = false;
    this.source.src = null;
    this.source.src = newSrc;
  }


  /**
 * Helper function that returns a base texture based on an image url
 * If the image is not in the base texture cache it will be created and loaded
 *
 * @static
 * @method fromImage
 * @param imageUrl {String} The image url of the texture
 * @param crossorigin {Boolean} 
 * @param scaleMode {Number} Should be one of the PIXI.scaleMode consts
 * @return BaseTexture
 */
  factory BaseTexture.fromImage(String imageUrl,[ bool crossorigin = true, int scaleMode = 0]) {
    BaseTexture baseTexture = BaseTextureCache[imageUrl];

    //if(crossorigin === undefined)crossorigin = true;

    if (baseTexture == null) {
      // new Image() breaks tex loading in some versions of Chrome.
      // See https://code.google.com/p/chromium/issues/detail?id=238071
      ImageElement image = new ImageElement();//document.createElement('img');
      if (crossorigin) {
        image.crossOrigin = '';
      }
      image.src = imageUrl;
      baseTexture = new BaseTexture(image, scaleMode);
      baseTexture.imageUrl = imageUrl;
      BaseTextureCache[imageUrl] = baseTexture;
    }

    return baseTexture;
  }

  /**
 * Helper function that returns a base texture based on a canvas element
 * If the image is not in the base texture cache it will be created and loaded
 *
 * @static
 * @method fromCanvas
 * @param canvas {Canvas} The canvas element source of the texture
 * @param scaleMode {Number} Should be one of the PIXI.scaleMode consts
 * @return BaseTexture
 */
  factory BaseTexture.fromCanvas(CanvasElement canvas,[ int scaleMode = 0]) {
    if (!canvas.attributes.containsKey("_pixiId")) {
      canvas.attributes['_pixiId'] = 'canvas_${TextureCacheIdGenerator++}';
    }

    BaseTexture baseTexture = BaseTextureCache[canvas.attributes['_pixiId']];

    if (baseTexture == null) {
      baseTexture = new BaseTexture(canvas, scaleMode);
      BaseTextureCache[canvas.attributes['_pixiId']] = baseTexture;
    }

    return baseTexture;
  }


}
