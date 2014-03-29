part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The xml loader is used to load in XML bitmap font data ('xml' or 'fnt')
 * To generate the data you can use http://www.angelcode.com/products/bmfont/
 * This loader will also load the image file as the data.
 * When loaded this class will dispatch a 'loaded' event
 *
 * @class BitmapFontLoader
 * @uses EventTarget
 * @constructor
 * @param url {String} The url of the sprite sheet JSON file
 * @param crossorigin {Boolean} Whether requests should be treated as crossorigin
 */
class BitmapFontLoader extends EventTarget {

  String url;

  bool crossorigin;

  String baseUrl;

  String texture;

  HttpRequest ajaxRequest;

  BitmapFontLoader(String url, bool crossorigin) {
    /*
       * I use texture packer to load the assets..
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
       * [read-only] The texture of the bitmap font
       *
       * @property baseUrl
       * @type String
       */
    this.texture = null;
  }


  /**
   * Loads the XML font data
   *
   * @method load
   */
  void load() {
    this.ajaxRequest = new HttpRequest();
    var scope = this;
    this.ajaxRequest.onReadyStateChange.listen(this.onXMLLoaded);

    this.ajaxRequest.open('GET', this.url, async: true);
    this.ajaxRequest.overrideMimeType('application/xml');
    this.ajaxRequest.send(null);
  }

  /**
   * Invoked when the XML file is loaded, parses the data
   *
   * @method onXMLLoaded
   * @private
   */
  void onXMLLoaded([_]) {
    if (this.ajaxRequest.readyState == 4) {
      if (this.ajaxRequest.status == 200 || window.location.protocol.indexOf('http') == -1) {
        Document responseXML = this.ajaxRequest.responseXml;

        String textureUrl = this.baseUrl + (responseXML.getElementsByTagName('page')[0] as Element).attributes['file'];
        ImageLoader image = new ImageLoader(textureUrl, this.crossorigin);
        this.texture = image.texture.baseTexture;

        Map data = {};
        Element info = responseXML.getElementsByTagName('info')[0];
        Element common = responseXML.getElementsByTagName('common')[0];
        data['font'] = info.attributes['face'];
        data['size'] = int.parse(info.attributes['size'], radix: 10);
        data['lineHeight'] = int.parse(common.attributes['lineHeight'], radix: 10);
        data['chars'] = {};

        //parse letters
        HtmlCollection letters = responseXML.getElementsByTagName('char');

        for (int i = 0; i < letters.length; i++) {
          int charCode = int.parse(letters[i].attributes['id'], radix: 10);

          Rectangle textureRect = new Rectangle(double.parse(letters[i].attributes['x'], radix: 10), double.parse(letters[i].attributes['y'], radix: 10), double.parse(letters[i].attributes['width'], radix: 10), double.parse(letters[i].attributes['height'], radix: 10));

          data['chars'][charCode] = {
            'xOffset': int.parse(letters[i].attributes['xoffset'], radix: 10),
            'yOffset': int.parse(letters[i].attributes['yoffset'], radix: 10),
            'xAdvance': int.parse(letters[i].attributes['xadvance'], radix: 10),
            'kerning': {},
            'texture': TextureCache[charCode] = new Texture(this.texture, textureRect)

          };
        }

        //parse kernings
        HtmlCollection kernings = responseXML.getElementsByTagName('kerning');
        for (int i = 0; i < kernings.length; i++) {
          var first = int.parse(kernings[i].attributes['first'], radix: 10);
          var second = int.parse(kernings[i].attributes['second'], radix: 10);
          var amount = int.parse(kernings[i].attributes['amount'], radix: 10);

          data['chars'][second].kerning[first] = amount;

        }

        BitmapText.fonts[data['font']] = data;

        image.listen('loaded', this.onLoaded);
        image.load();
      }
    }
  }

  /**
   * Invoked when all files are loaded (xml/fnt and texture)
   *
   * @method onLoaded
   * @private
   */
  onLoaded([_]) {
    this.fire({
      'type': 'loaded',
      'content': this
    });
  }
}
