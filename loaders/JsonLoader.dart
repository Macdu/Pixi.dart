part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The json file loader is used to load in JSON data and parse it
 * When loaded this class will dispatch a 'loaded' event
 * If loading fails this class will dispatch an 'error' event
 *
 * @class JsonLoader
 * @uses EventTarget
 * @constructor
 * @param url {String} The url of the JSON file
 * @param crossorigin {Boolean} Whether requests should be treated as crossorigin
 */
class JsonLoader extends EventTarget {

  String url;

  bool crossorigin;

  String baseUrl;

  bool loaded;

  HttpRequest ajaxRequest;

  Map json;

  Texture texture;

  JsonLoader(String url, bool crossorigin) {

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
     * [read-only] Whether the data has loaded yet
     *
     * @property loaded
     * @type Boolean
     * @readOnly
     */
    this.loaded = false;

  }

  /**
 * Loads the JSON data
 *
 * @method load
 */
  void load([_]) {
    this.ajaxRequest = new HttpRequest();
    this.ajaxRequest.onReadyStateChange.listen(this.onJSONLoaded);

    this.ajaxRequest.open('GET', this.url, async: true);
    this.ajaxRequest.overrideMimeType('application/json');
    this.ajaxRequest.send(null);
  }

  /**
 * Invoke when JSON file is loaded
 *
 * @method onJSONLoaded
 * @private
 */
  void onJSONLoaded([_]) {
    if (this.ajaxRequest.readyState == 4) {
      if (this.ajaxRequest.status == 200 || window.location.protocol.indexOf('http') == -1) {
        this.json = JSON.decode(this.ajaxRequest.responseText);

        if (this.json.containsKey('frames')) {
          // sprite sheet
          String textureUrl = this.baseUrl + this.json['meta']['image'];
          ImageLoader image = new ImageLoader(textureUrl, this.crossorigin);
          Map frameData = this.json['frames'];

          this.texture = image.texture;
          image.listen('loaded', this.onLoaded);

          frameData.forEach((String key, Map element){
            Map<String,int> rect = element['frame'];
            if (rect != null) {
              TextureCache[key] = new Texture(this.texture.baseTexture, new Rectangle(
                  rect['x'].toDouble(), rect['y'].toDouble(), rect['w'].toDouble(), rect['h'].toDouble()
              ));

              // check to see if the sprite has been trimmed..
              if (frameData[key]['trimmed']) {

                Texture texture = TextureCache[key];

                Map actualSize = element['sourceSize'];
                Map realSize = element['spriteSourceSize'];

                texture.trim = new Rectangle(realSize['x'], realSize['y'], actualSize['w'], actualSize['h']);
              }
            }
          });

          image.load();

        } /*else if (this.json['bones']) {
          // spine animation
          Spine.SkeletonJson spineJsonParser = new Spine.SkeletonJson();
          Spine.SkeletonData skeletonData = spineJsonParser.readSkeletonData(this.json);
          AnimCache[this.url] = skeletonData;
          this.onLoaded();
        } else {
          this.onLoaded();
        }
      }*/ else {
        this.onError();
        }
      }
    }
  }

  /**
 * Invoke when json file loaded
 *
 * @method onLoaded
 * @private
 */
  void onLoaded([_]) {
    this.loaded = true;
    this.fire({
      'type': 'loaded',
      'content': this
    });
  }

  /**
 * Invoke when error occured
 *
 * @method onError
 * @private
 */
  void onError() {
    this.fire({
      'type': 'error',
      'content': this
    });
  }

}
