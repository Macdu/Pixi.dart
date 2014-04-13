part of pixi;
/**
 * @author Martin Kelm http://mkelm.github.com
 */

/**
 * The atlas file loader is used to load in Atlas data and parse it
 * When loaded this class will dispatch a 'loaded' event
 * If loading fails this class will dispatch an 'error' event
 * @class AtlasLoader
 * @extends EventTarget
 * @constructor
 * @param {String} url the url of the JSON file
 * @param {Boolean} crossorigin
 */
class AtlasLoader extends Loader {

  String url;

  String baseUrl;

  bool crossorigin;

  HttpRequest ajaxRequest;

  Map atlas;

  List images;

  int currentImageId;

  bool loaded;

  AtlasLoader(String url, bool crossorigin) {

    this.url = url;
    this.baseUrl = url.replaceAll(new RegExp(r'[^\/]*$'), '');
    this.crossorigin = crossorigin;
    this.loaded = false;

  }


  /**
   * Starts loading the JSON file
   *
   * @method load
   */
  void load() {
    this.ajaxRequest = new HttpRequest();
    this.ajaxRequest.onReadyStateChange.listen(this.onAtlasLoaded);

    this.ajaxRequest.open('GET', this.url, async: true);
    this.ajaxRequest.overrideMimeType('application/json');
    this.ajaxRequest.send(null);
  }

  /**
   * Invoke when JSON file is loaded
   * @method onAtlasLoaded
   * @private
   */
  void onAtlasLoaded([e]) {
    if (this.ajaxRequest.readyState == 4) {
      if (this.ajaxRequest.status == 200 || window.location.href.indexOf('http') == -1) {
        this.atlas = {
          'meta': {
            'image': []
          },
          'frames': []
        };
        List<String> result = this.ajaxRequest.responseText.split(new RegExp(r'\r?\n/'));
        int lineCount = -3;

        int currentImageId = 0;
        Map currentFrame = null;
        int nameInNextLine = 0;

        int i = 0,
            j = 0;

        // parser without rotation support yet!
        for (i = 0; i < result.length; i++) {
          result[i] = result[i].replaceAll(new RegExp(r'/^\s+|\s+$/g'), '');
          if (result[i] == '') {
            nameInNextLine = i + 1;
          }
          if (result[i].length > 0) {
            if (nameInNextLine == i) {
              this.atlas['meta']['image'].add(result[i]);
              currentImageId = this.atlas['meta']['image'].length - 1;
              this.atlas['frames'].add({});
              lineCount = -3;
            } else if (lineCount > 0) {
              if (lineCount % 7 == 1) { // frame name
                if (currentFrame != null) { //jshint ignore:line
                  this.atlas['frames'][currentImageId][currentFrame['name']] = currentFrame;
                }
                currentFrame = {
                  'name': result[i],
                  'frame': {}
                };
              } else {
                List<String> text = result[i].split(' ');
                if (lineCount % 7 == 3) { // position
                  currentFrame['frame']['x'] = int.parse(text[1].replaceAll(',', ''));
                  currentFrame['frame']['x'] = int.parse(text[2]);
                } else if (lineCount % 7 == 4) { // size
                  currentFrame['frame']['w'] = int.parse(text[1].replaceAll(',', ''));
                  currentFrame['frame']['h'] = int.parse(text[2]);
                } else if (lineCount % 7 == 5) { // real size
                  Map realSize = {
                    'x': 0,
                    'y': 0,
                    'w': int.parse(text[1].replaceAll(',', '')),
                    'h': int.parse(text[2])
                  };

                  if (realSize['w'] > currentFrame['frame']['w'] || realSize['h'] > currentFrame['frame']['h']) {
                    currentFrame['trimmed'] = true;
                    currentFrame['realSize'] = realSize;
                  } else {
                    currentFrame['trimmed'] = false;
                  }
                }
              }
            }
            lineCount++;
          }
        }

        if (currentFrame != null) { //jshint ignore:line
          this.atlas['frames'][currentImageId][currentFrame['name']] = currentFrame;
        }

        if (this.atlas['meta']['image'].length > 0) {
          this.images = [];
          for (j = 0; j < this.atlas['meta']['image'].length; j++) {
            // sprite sheet
            String textureUrl = this.baseUrl + this.atlas['meta']['image'].image[j];
            Map frameData = this.atlas['frames'][j];
            this.images.add(new ImageLoader(textureUrl, this.crossorigin));

            for (i in frameData) {
              Map rect = frameData[i].frame;
              if (rect != null) {
                TextureCache[i] = new Texture(this.images[j].texture.baseTexture, new Rectangle(
                    rect['x'], 
                    rect['y'],
                    rect['w'],
                    rect['h'])
                );
                if (frameData[i]['trimmed']) {
                  TextureCache[i].realSize = frameData[i]['realSize'];
                  // trim in pixi not supported yet, todo update trim properties if it is done ...
                  TextureCache[i].trim.x = 0;
                  TextureCache[i].trim.y = 0;
                }
              }
            }
          }

          this.currentImageId = 0;
          for (j = 0; j < this.images.length; j++) {
            this.images[j].listen('loaded', this.onLoaded);
          }
          this.images[this.currentImageId].load();

        } else {
          this.onLoaded();
        }

      } else {
        this.onError();
      }
    }
  }

  /**
   * Invoke when json file has loaded
   * @method onLoaded
   * @private
   */
  void onLoaded() {
    if (this.images.length - 1 > this.currentImageId) {
      this.currentImageId++;
      this.images[this.currentImageId].load();
    } else {
      this.loaded = true;
      this.fire({
        'type': 'loaded',
        'content': this
      });
    }
  }

  /**
   * Invoke when error occured
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
