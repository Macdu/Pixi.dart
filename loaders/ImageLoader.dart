part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The image loader class is responsible for loading images file formats ('jpeg', 'jpg', 'png' and 'gif')
 * Once the image has been loaded it is stored in the PIXI texture cache and can be accessed though PIXI.Texture.fromFrameId() and PIXI.Sprite.fromFrameId()
 * When loaded this class will dispatch a 'loaded' event
 *
 * @class ImageLoader
 * @uses EventTarget
 * @constructor
 * @param url {String} The url of the image
 * @param crossorigin {Boolean} Whether requests should be treated as crossorigin
 */
class ImageLoader extends EventTarget {

  Texture texture;

  List frames;

  ImageLoader(String url, bool crossorigin) {

    /**
       * The texture being loaded
       *
       * @property texture
       * @type Texture
       */
    this.texture = new Texture.fromImage(url, crossorigin);

    /**
       * if the image is loaded with loadFramedSpriteSheet
       * frames will contain the sprite sheet frames
       *
       */
    this.frames = [];
  }


  /**
   * Loads image or takes it from cache
   *
   * @method load
   */
  void load() {
    if (!this.texture.baseTexture.hasLoaded) {
      this.texture.baseTexture.listen('loaded', this.onLoaded);
    } else {
      this.onLoaded();
    }
  }

  /**
   * Invoked when image file is loaded or it is already cached and ready to use
   *
   * @method onLoaded
   * @private
   */
  void onLoaded([_]) {
    this.fire({
      'type': 'loaded',
      'content': this
    });
  }

  /**
   * Loads image and split it to uniform sized frames
   *
   *
   * @method loadFramedSpriteSheet
   * @param frameWidth {Number} width of each frame
   * @param frameHeight {Number} height of each frame
   * @param textureName {String} if given, the frames will be cached in <textureName>-<ord> format
   */
  void loadFramedSpriteSheet(int frameWidth, int frameHeight, String textureName) {
    this.frames = [];
    int cols = (this.texture.width / frameWidth).floor();
    int rows = (this.texture.height / frameHeight).floor();

    int i = 0;
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++, i++) {
        Texture texture = new Texture(this.texture.baseTexture,new Rectangle(
            (x * frameWidth).toDouble(), (y * frameHeight).toDouble(),
            frameWidth.toDouble(),  frameHeight.toDouble())
        );

        this.frames.add(texture);
        if (textureName != null) TextureCache[textureName + '-' + i.toString()] = texture;
      }
    }

    if (!this.texture.baseTexture.hasLoaded) {
      this.texture.baseTexture.listen('loaded', this.onLoaded);
    } else {
      this.onLoaded();
    }
  }
}
