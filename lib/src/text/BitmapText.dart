part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A Text Object will create a line(s) of text using bitmap font. To split a line you can use '\n', '\r' or '\r\n'
 * You can generate the fnt files using
 * http://www.angelcode.com/products/bmfont/ for windows or
 * http://www.bmglyph.com/ for mac.
 */
class BitmapText extends DisplayObjectContainer {

  List _pool = [];

  bool dirty;

  String _text;

  CssStyleDeclaration _style;

  String fontName;

  int fontSize;

  int tint;

  /**
       * [read-only] The width of the overall text, different from fontSize,
       * which is defined in the style object
       *
       * @property textWidth
       * @type Number
       */
  double textWidth;

  /**
       * [read-only] The height of the overall text, different from fontSize,
       * which is defined in the style object
       *
       * @property textHeight
       * @type Number
       */
  double textHeight;


  /**
 * @class BitmapText
 * @extends DisplayObjectContainer
 * @constructor
 * @param text {String} The copy that you would like the text to display
 * @param style {Object} The style parameters
 * @param style.font {String} The size (optional) and bitmap font id (required) eq 'Arial' or '20px Arial' (must have loaded previously)
 * @param [style.align='left'] {String} Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text
 */
  BitmapText([String text = "", CssStyleDeclaration style = null, int color = 0xFFFFFF]) {
    this.tint = color;
    this.text = text;
    this.style = style;
    this.updateText();
    this.dirty = false;
  }

  /**
 * Set the copy for the text object
 *
 * @method setText
 * @param text {String} The copy that you would like the text to display
 */
  set text(String text) {
    this._text = text;
    this.dirty = true;
  }
  String get text => this._text;

  /**
 * Set the style of the text
 * style.font {String} The size (optional) and bitmap font id (required) eq 'Arial' or '20px Arial' (must have loaded previously)
 * [style.align='left'] {String} Alignment for multiline text ('left', 'center' or 'right'), does not affect single line text
 *
 * @method setStyle
 * @param style {Object} The style parameters, contained as properties of an object
 */
  set style(CssStyleDeclaration style) {

    if (style == null) style = new CssStyleDeclaration();
    if (style.textAlign.isEmpty) style.textAlign = 'left';
    this._style = style;

    List<String> font = style.font.split(' ');
    this.fontName = font[font.length - 1];
    this.fontSize = font.length >= 2 ? int.parse(font[font.length - 2], radix: 10) : BitmapText.fonts[this.fontName].size;

    this.dirty = true;
  }
  CssStyleDeclaration get style => this._style;

  /**
 * Renders text and updates it when needed
 *
 * @method updateText
 * @private
 */
  void updateText() {
    var data = BitmapText.fonts[this.fontName];
    Point pos = new Point();
    var prevCharCode = null;
    List<Map> chars = [];
    int maxLineWidth = 0;
    List lineWidths = [];
    int line = 0;
    double scale = this.fontSize / data.size;


    for (int i = 0; i < this.text.length; i++) {
      String charCode = this.text[i];
      if (charCode.trim() == "") {
        lineWidths.add(pos.x);
        maxLineWidth = Math.max(maxLineWidth, pos.x);
        line++;

        pos.x = 0.0;
        pos.y += data.lineHeight;
        prevCharCode = null;
        continue;
      }

      var charData = data.chars[charCode];
      if (charData == null) continue;

      if (prevCharCode && charData[prevCharCode]) {
        pos.x += charData.kerning[prevCharCode];
      }
      chars.add({
        'texture': charData.texture,
        'line': line,
        'charCode': charCode,
        'position': new Point(pos.x + charData.xOffset, pos.y + charData.yOffset)
      });
      pos.x += charData.xAdvance;

      prevCharCode = charCode;
    }

    lineWidths.add(pos.x);
    maxLineWidth = Math.max(maxLineWidth, pos.x);

    List<num> lineAlignOffsets = [];
    for (int i = 0; i <= line; i++) {
      double alignOffset = 0.0;
      if (this.style.textAlign == 'right') {
        alignOffset = maxLineWidth - lineWidths[i];
      } else if (this.style.textAlign == 'center') {
        alignOffset = (maxLineWidth - lineWidths[i]) / 2;
      }
      lineAlignOffsets.add(alignOffset);
    }

    int lenChildren = this.children.length;
    int lenChars = chars.length;
    int tint = this.tint;
    for (int i = 0; i < lenChars; i++) {
      Sprite c = i < lenChildren ? this.children[i] : this._pool.removeLast(); // get old child if have. if not - take from pool.

      if (c != null) c.setTexture(chars[i]['texture']); // check if got one before.
      else c = new Sprite(chars[i]['texture']); // if no create new one.

      c.position.x = (chars[i]['position'].x + lineAlignOffsets[chars[i]['line']]) * scale;
      c.position.y = chars[i]['position'].y * scale;
      c.scale.x = c.scale.y = scale;
      c.tint = tint;
      if (c.parent == null) this.addChild(c);
    }

    // remove unnecessary children.
    // and put their into the pool.
    while (this.children.length > lenChars) {
      var child = this.getChildAt(this.children.length - 1);
      this._pool.add(child);
      this.removeChild(child);
    }


    /**
     * [read-only] The width of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textWidth
     * @type Number
     */
    this.textWidth = maxLineWidth * scale;

    /**
     * [read-only] The height of the overall text, different from fontSize,
     * which is defined in the style object
     *
     * @property textHeight
     * @type Number
     */
    this.textHeight = (pos.y + data.lineHeight) * scale;
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

  static Map fonts = {};

}
