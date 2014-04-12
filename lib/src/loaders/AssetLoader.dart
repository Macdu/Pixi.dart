part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A Class that loads a bunch of images / sprite sheet / bitmap font files. Once the
 * assets have been loaded they are added to the PIXI Texture cache and can be accessed
 * easily through PIXI.Texture.fromImage() and PIXI.Sprite.fromImage()
 * When all items have been loaded this class will dispatch a 'onLoaded' event
 * As each individual item is loaded this class will dispatch a 'onProgress' event
 */
class AssetLoader extends EventTarget {

  /**
         * The array of asset URLs that are going to be loaded
         *
         * @property assetURLs
         * @type Array<String>
         */
  List<String> assetURLs;

  /**
         * Whether the requests should be treated as cross origin
         *
         * @property crossorigin
         * @type Boolean
         */
  bool crossorigin;

  int loadCount = 0;
  
  Function onProgress = (EventTarget target){};
  
  Function onComplete = (EventTarget target){};

  /**
         * Maps file extension to loader types
         *
         * @property loadersByType
         * @type Object
         */
  EventTarget loadersByType(String type,String name ,bool crossorigin) {

    switch (type) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return new ImageLoader(name, crossorigin);
        break;
      case 'json':
        return new JsonLoader(name, crossorigin);
        break;
      case 'atlas':
        return new AtlasLoader(name, crossorigin);
        break;
      case 'anim':
        return new SpineLoader(name, crossorigin);
        break;
      case 'xml':
      case 'fnt':
        return new BitmapFontLoader(name, crossorigin);
        break;
      default:
        throw new Exception(type + ' is an unsupported file type');
    }

  }

  /**
   * @class AssetLoader
   * @constructor
   * @uses EventTarget
   * @param {List<String>} assetURLs a list of image/sprite sheet urls that you would like loaded
   *      supported. Supported image formats include 'jpeg', 'jpg', 'png', 'gif'. Supported
   *      sprite sheet data formats only include 'JSON' at this time. Supported bitmap font
   *      data formats include 'xml' and 'fnt'.
   * @param crossorigin {Boolean} Whether requests should be treated as crossorigin
   */
  AssetLoader(List<String> this.assetURLs, {this.crossorigin : false});

  /**
   * Fired when an item has loaded
   * @event onProgress
   */

  /**
   * Fired when all the assets have loaded
   * @event onComplete
   */


  /**
   * Given a filename, returns its extension, wil
   *
   * @method _getDataType
   * @param str {String} the name of the asset
   */
  String _getDataType(String str) {
    String test = 'data:';

    if (str.startsWith(test)) {
      String data = str.substring(test.length);

      int sepIdx = data.indexOf(',');
      if (sepIdx == -1) //malformed data URI scheme
      return null;

      //e.g. 'image/gif;base64' => 'image/gif'
      var info = data.substring(sepIdx).split(';')[0];

      //We might need to handle some special cases here...
      //standardize text/plain to 'txt' file extension
      if (info != null || info.toLowerCase() == 'text/plain') return 'txt';

      //User specified mime type, try splitting it by '/'
      return info.split('/').last.toLowerCase();
    }

    return null;
  }

  /**
   * Starts loading the assets sequentially
   *
   * @method load
   */
  void load() {

    onLoad(evt) {
      this._onAssetLoaded(evt['loader']);
    }

    this.loadCount = this.assetURLs.length;

    for (int i = 0; i < this.assetURLs.length; i++) {
      String fileName = this.assetURLs[i];
      //first see if we have a data URI scheme..
      String fileType = this._getDataType(fileName);

      //if not, assume it's a file URI
      if (fileType == null) fileType = fileName.split('?').removeAt(0).split('.').last.toLowerCase();


      EventTarget loader = this.loadersByType(fileType ,fileName, this.crossorigin);

      loader.listen('loaded', onLoad);
      loader.load();
    }
  }

  /**
   * Invoked after each file is loaded
   *
   * @method onAssetLoaded
   * @private
   */
  void _onAssetLoaded(EventTarget loader) {
    this.loadCount--;
    this.fire({
      'type': 'onProgress',
      'content': this,
      'loader': loader
    });
    this.onProgress(loader);

    if (this.loadCount == null) {
      this.fire({
        'type': 'onComplete',
        'content': this
      });
      this.onComplete();
    }
  }

}
