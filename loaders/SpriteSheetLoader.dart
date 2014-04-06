part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The sprite sheet loader is used to load in JSON sprite sheet data
 * To generate the data you can use http://www.codeandweb.com/texturepacker and publish in the 'JSON' format
 * There is a free version so thats nice, although the paid version is great value for money.
 * It is highly recommended to use Sprite sheets (also know as a 'texture atlas') as it means sprites can be batched and drawn together for highly increased rendering speed.
 * Once the data has been loaded the frames are stored in the PIXI texture cache and can be accessed though PIXI.Texture.fromFrameId() and PIXI.Sprite.fromFrameId()
 * This loader will load the image file that the Spritesheet points to as well as the data.
 * When loaded this class will dispatch a 'loaded' event
 *
 * @class SpriteSheetLoader
 * @uses EventTarget
 * @constructor
 * @param url {String} The url of the sprite sheet JSON file
 * @param crossorigin {Boolean} Whether requests should be treated as crossorigin
 */
class SpriteSheetLoader extends EventTarget {


  String url;

  bool crossorigin;

  String baseUrl;

  Texture texture;

  Map frames;

  Map json;

  SpriteSheetLoader(String url, bool crossorigin) {
    /*
     * i use texture packer to load the assets..
     * http://www.codeandweb.com/texturepacker
     * make sure to set the format as 'JSON'
     */

    /**
     * The url of the bitmap font data
     *
     * @property url
     * @type String
     */
    this.url = url;

    /**
     * Whether the requests should be treated as cross origin
     *
     * @property crossorigin
     * @type Boolean
     */
    this.crossorigin = crossorigin;

    /**
     * [read-only] The base url of the bitmap font data
     *
     * @property baseUrl
     * @type String
     * @readOnly
     */
    this.baseUrl = url.replaceAll(new RegExp(r'[^\/]*$'), '');

    /**
     * The texture being loaded
     *
     * @property texture
     * @type Texture
     */
    this.texture = null;

    /**
     * The frames of the sprite sheet
     *
     * @property frames
     * @type Object
     */
    this.frames = {};
  }


  /**
 * This will begin loading the JSON file
 *
 * @method load
 */
  void load([_]) {
    JsonLoader jsonLoader = new JsonLoader(this.url, this.crossorigin);
    jsonLoader.listen('loaded', (Map event) {
      this.json = event['content'].json;
      this.onLoaded();
    });
    jsonLoader.load();
  }

  /**
 * Invoke when all files are loaded (json and texture)
 *
 * @method onLoaded
 * @private
 */
  void onLoaded() {
    this.fire({
      'type': 'loaded',
      'content': this
    });
  }

}
