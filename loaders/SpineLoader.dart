part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 * based on pixi impact spine implementation made by Eemeli Kelokorpi (@ekelokorpi) https://github.com/ekelokorpi
 *
 * Awesome JS run time provided by EsotericSoftware
 * https://github.com/EsotericSoftware/spine-runtimes
 *
 */

/**
 * The Spine loader is used to load in JSON spine data
 * To generate the data you need to use http://esotericsoftware.com/ and export in the "JSON" format
 * Due to a clash of names  You will need to change the extension of the spine file from *.json to *.anim for it to load
 * See example 12 (http://www.goodboydigital.com/pixijs/examples/12/) to see a working example and check out the source
 * You will need to generate a sprite sheet to accompany the spine data
 * When loaded this class will dispatch a "loaded" event
 *
 * @class Spine
 * @uses EventTarget
 * @constructor
 * @param url {String} The url of the JSON file
 * @param crossorigin {Boolean} Whether requests should be treated as crossorigin
 */
class SpineLoader extends EventTarget {

  String url;

  bool crossorigin;

  bool loaded;

  Map json;

  SpineLoader(String url, bool crossorigin) {

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
  void load() {

    var jsonLoader = new JsonLoader(this.url, this.crossorigin);
    jsonLoader.listen("loaded", ([event]) {
      this.json = event['content'].json;
      this.onLoaded(event);
    });
    jsonLoader.load();
  }

  /**
 * Invoke when JSON file is loaded
 *
 * @method onLoaded
 * @private
 */
  void onLoaded([_]) {
    this.loaded = true;
    this.fire({
      'type': "loaded",
      'content': this
    });
  }

}
