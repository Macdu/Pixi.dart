part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A Text Object will create a line(s) of text. To split a line you can use '\n' 
 * or add a wordWrap property set to true and and wordWrapWidth property with a value
 * in the style object
 */
class Text extends Sprite {

  /**
       * The canvas element that everything is drawn to
       *
       * @property canvas
       * @type HTMLCanvasElement
       */
  CanvasElement canvas = new CanvasElement();

  /**
       * The canvas 2d context that everything is drawn with
       * @property context
       * @type HTMLCanvasElement 2d Context
       */
  CanvasRenderingContext2D context;


  bool dirty = false;

  Map _style;

  String _text;

  bool requiresUpdate = false;

  /**
 * @class Text
 * @extends Sprite
 * @constructor
 * @param text {String} The copy that you would like the text to display
 * @param [style] {Object} The style parameters
 * @param [style.font] {String} default 'bold 20px Arial' The style and size of the font
 * @param [style.fill='black'] {String|Number} A canvas fillstyle that will be used on the text e.g 'red', '#00FF00'
 * @param [style.align='left'] {String} Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text
 * @param [style.stroke] {String|Number} A canvas fillstyle that will be used on the text stroke e.g 'blue', '#FCFF00'
 * @param [style.strokeThickness=0] {Number} A number that represents the thickness of the stroke. Default is 0 (no stroke)
 * @param [style.wordWrap=false] {Boolean} Indicates if word wrap should be used
 * @param [style.wordWrapWidth=100] {Number} The width at which text will wrap, it needs wordWrap to be set to true
 */
  Text(String text, [Map style = null]): super(null) {
    this.texture = new Texture.fromCanvas(this.canvas);

    if (texture.baseTexture.hasLoaded) {
      this.onTextureUpdate();
    } else {
      this.texture.listen('update', this.onTextureUpdate);
    }

    /**
     * The canvas 2d context that everything is drawn with
     * @property context
     * @type HTMLCanvasElement 2d Context
     */
    this.context = this.canvas.getContext('2d');

    this.text = text;
    if (style == null) style = {};
    this.style = style;

    this.updateText();
    this.dirty = false;
  }

  /**
 * Set the style of the text
 *
 * @method setStyle
 * @param [style] {Object} The style parameters
 * @param [style.font='bold 20pt Arial'] {String} The style and size of the font
 * @param [style.fill='black'] {Object} A canvas fillstyle that will be used on the text eg 'red', '#00FF00'
 * @param [style.align='left'] {String} Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text
 * @param [style.stroke='black'] {String} A canvas fillstyle that will be used on the text stroke eg 'blue', '#FCFF00'
 * @param [style.strokeThickness=0] {Number} A number that represents the thickness of the stroke. Default is 0 (no stroke)
 * @param [style.wordWrap=false] {Boolean} Indicates if word wrap should be used
 * @param [style.wordWrapWidth=100] {Number} The width at which text will wrap
 */
  set style(Map style) {
    if (style['font'] == null) style['font'] = 'bold 20pt Arial';
    if (style['fill'] == null) style['fill'] = 'black';
    if (style['align'] == null) style['align'] = 'left';
    if (style['stroke'] == null) style['stroke'] = 'black';
        //provide a default, see: https://github.com/GoodBoyDigital/pixi.js/issues/136
    if (style['strokeThickness'] == null) style['strokeThickness'] = 0;
    if (style['wordWrap'] == null) style['wordWrap'] = false;
    if (style['wordWrapWidth'] == null) style['wordWrapWidth'] = 100;
    this._style = style;
    this.dirty = true;
  }
  Map get style => this._style;

  /**
 * Set the copy for the text object. To split a line you can use '\n'
 *
 * @method setText
 * @param {String} text The copy that you would like the text to display
 */
  set text(String text) {
    this._text = text;
    this.dirty = true;

  }
  String get text => this._text;

  /**
 * Renders text and updates it when needed
 *
 * @method updateText
 * @private
 */
  void updateText() {
    this.context.font = this.style['font'];

    String outputText = this.text;

    // word wrap
    // preserve original text
    if (this.style['wordWrap']) outputText = this.wordWrap(this.text);

    //split text into lines
    List<String> lines = outputText.split(new RegExp(r'(?:\r\n|\r|\n)'));

    //calculate text width
    List<double> lineWidths = [];
    double maxLineWidth = 0.0;
    for (int i = 0; i < lines.length; i++) {
      double lineWidth = this.context.measureText(lines[i]).width;
      lineWidths.add(lineWidth);
      maxLineWidth = Math.max(maxLineWidth, lineWidth);
    }
    this.canvas.width = (maxLineWidth + this.style['strokeThickness']).toInt();

    //calculate text height
    var lineHeight = this.determineFontHeight('font: ' + this.style['font'] +
        ';') + this.style['strokeThickness'];
    this.canvas.height = lineHeight * lines.length;

    //set canvas text styles
    this.context.fillStyle = this.style['fill'];
    this.context.font = this.style['font'];

    this.context.strokeStyle = this.style['stroke'];
    this.context.lineWidth = this.style['strokeThickness'];

    this.context.textBaseline = 'top';

    //draw lines line by line
    for (int i = 0; i < lines.length; i++) {
      Point linePosition = new Point(this.style['strokeThickness'] / 2,
          this.style['strokeThickness'] / 2 + i * lineHeight);

      if (this.style['align'] == 'right') {
        linePosition.x += maxLineWidth - lineWidths[i];
      } else if (this.style['align'] == 'center') {
        linePosition.x += (maxLineWidth - lineWidths[i]) / 2;
      }

      if (this.style['stroke'] != null && this.style['strokeThickness'] != null) {
        this.context.strokeText(lines[i], linePosition.x, linePosition.y);
      }

      if (this.style['fill'] != null) {
        this.context.fillText(lines[i], linePosition.x, linePosition.y);
      }
    }

    this.updateTexture();
  }

  /**
 * Updates texture size based on canvas size
 *
 * @method updateTexture
 * @private
 */
  void updateTexture() {
    this.texture.baseTexture.width = this.canvas.width;
    this.texture.baseTexture.height = this.canvas.height;
    this.texture.frame.width = this.canvas.width.toDouble();
    this.texture.frame.height = this.canvas.height.toDouble();

    this._width = this.canvas.width.toDouble();
    this._height = this.canvas.height.toDouble();

    this.requiresUpdate = true;
  }

  /**
* Renders the object using the WebGL renderer
*
* @method _renderWebGL
* @param renderSession {RenderSession} 
* @private
*/
  void _renderWebGL(RenderSession renderSession) {
    if (this.requiresUpdate) {
      this.requiresUpdate = false;
      WebGLRenderer.updateWebGLTexture(this.texture, renderSession.gl);
    }

    super._renderWebGL(renderSession);
  }

  /**
 * Updates the transform of this object
 *
 * @method updateTransform
 * @private
 */
  void updateTransform() {
    if (this.dirty) {
      this.updateText();
      this.dirty = false;
    }

    super.updateTransform();
  }

  /*
 * http://stackoverflow.com/users/34441/ellisbben
 * great solution to the problem!
 * returns the height of the given font
 *
 * @method determineFontHeight
 * @param fontStyle {Object}
 * @private
 */
  int determineFontHeight(String fontStyle) {
    // build a little reference dictionary so if the font style has been used return a
    // cached version...
    int result = Text.heightCache[fontStyle];

    if (result == null) {
      BodyElement body = document.body;
      DivElement dummy = new DivElement();
      String dummyText = 'M';
      dummy.appendText(dummyText);
      dummy.attributes['style'] = fontStyle + ';position:absolute;top:0;left:0';
      body.append(dummy);

      result = dummy.offsetHeight;
      Text.heightCache[fontStyle] = result;

      dummy.remove();
    }

    return result;
  }

  /**
 * Applies newlines to a string to have it optimally fit into the horizontal
 * bounds set by the Text object's wordWrapWidth property.
 *
 * @method wordWrap
 * @param text {String}
 * @private
 */
  String wordWrap(String text) {
    // Greedy wrapping algorithm that will wrap words as the line grows longer
    // than its horizontal bounds.
    String result = '';
    List<String> lines = text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      int spaceLeft = this.style['wordWrapWidth'];
      List<String> words = lines[i].split(' ');
      for (int j = 0; j < words.length; j++) {
        double wordWidth = this.context.measureText(words[j]).width;
        double wordWidthWithSpace = wordWidth + this.context.measureText(' '
            ).width;
        if (wordWidthWithSpace > spaceLeft) {
          // Skip printing the newline if it's the first word of the line that is
          // greater than the word wrap width.
          if (j > 0) {
            result += '\n';
          }
          result += words[j] + ' ';
          spaceLeft = this.style['wordWrapWidth'] - wordWidth;
        } else {
          spaceLeft -= wordWidthWithSpace;
          result += words[j] + ' ';
        }
      }

      if (i < lines.length - 1) {
        result += '\n';
      }
    }
    return result;
  }

  /**
 * Destroys this text object
 *
 * @method destroy
 * @param destroyTexture {Boolean}
 */
  void destroy(bool destroyTexture) {
    if (destroyTexture) {
      this.texture.destroy();
    }

  }

  static Map<String, int> heightCache = {};

}
