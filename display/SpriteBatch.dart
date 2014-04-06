part of pixi;
/**
 * @author Mat Groves http://matgroves.com/
 */

/**
 * The SpriteBatch class is a really fast version of the DisplayObjectContainer 
 * built solely for speed, so use when you need a lot of sprites or particles.
 * And it's extremely easy to use : 

    var container = new PIXI.SpriteBatch();
 
    stage.addChild(container);
 
    for(var i  = 0; i < 100; i++)
    {
        var sprite = new PIXI.Sprite.fromImage("myImage.png");
        container.addChild(sprite);
    }
 * And here you have a hundred sprites that will be renderer at the speed of light
 *
 * @class SpriteBatch
 * @constructor
 * @param texture {Texture}
 */
class SpriteBatch extends DisplayObjectContainer {

  Texture textureThing;

  bool ready = false;

  WebGLFastSpriteBatch fastSpriteBatch;

  SpriteBatch(this.textureThing): super();

  /*
   * Initialises the spriteBatch
   *
   * @method initWebGL
   * @param gl {WebGLContext} the current WebGL drawing context
   */
  void initWebGL(RenderingContext gl) {
    // TODO only one needed for the whole engine really?
    this.fastSpriteBatch = new WebGLFastSpriteBatch(gl);

    this.ready = true;
  }


  /**
  * Renders the object using the WebGL renderer
  *
  * @method _renderWebGL
  * @param renderSession {RenderSession} 
  * @private
  */
  void _renderWebGL(RenderSession renderSession) {
    if (!this.visible || this.alpha <= 0 || this.children.length != 0) return;

    if (!this.ready) this.initWebGL(renderSession.gl);

    renderSession.spriteBatch.stop();

    renderSession.shaderManager.activateShader(renderSession.shaderManager.fastShader);

    this.fastSpriteBatch.begin(this, renderSession);
    this.fastSpriteBatch.render(this);

    renderSession.shaderManager.activateShader(renderSession.shaderManager.defaultShader);

    renderSession.spriteBatch.start();

  }

  /**
  * Renders the object using the Canvas renderer
  *
  * @method _renderCanvas
  * @param renderSession {RenderSession} 
  * @private
  */
  _renderCanvas(RenderSession renderSession) {
    var context = renderSession.context;
    context.globalAlpha = this.worldAlpha;

    var transform = this.worldTransform;

    // alow for trimming

    if (renderSession.roundPixels) {
      context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx.floor(), transform.ty.floor());
    } else {
      context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
    }

    context.save();

    for (var i = 0; i < this.children.length; i++) {

      DisplayObject child = this.children[i];
      Texture texture = child.texture;
      var frame = texture.frame;

      context.globalAlpha = this.worldAlpha * child.alpha;

      if (child.rotation % (Math.PI * 2) == 0) {

        // this is the fastest  way to optimise! - if rotation is 0 then we can avoid any kind of setTransform call
        context.drawImage(texture.baseTexture.source, frame.x, frame.y, frame.width, frame.height, ((child.anchor.x) * (-frame.width * child.scale.x) + child.position.x + 0.5) | 0, ((child.anchor.y) * (-frame.height * child.scale.y) + child.position.y + 0.5) | 0, frame.width * child.scale.x, frame.height * child.scale.y);
      } else {
        child.updateTransform();

        transform = child.localTransform;

        if (this.rotation != super.rotationCache) {
          this.rotationCache = this.rotation;
          this._sr = Math.sin(this.rotation);
          this._cr = Math.cos(this.rotation);
        }

        var a = child._cr * child.scale.x,
            b = -child._sr * child.scale.y,
            c = child._sr * child.scale.x,
            d = child._cr * child.scale.y;

        context.setTransform(a, c, b, d, child.position.x, child.position.y);

        context.drawImage(texture.baseTexture.source, frame.x, frame.y, frame.width, frame.height, ((child.anchor.x) * (-frame.width) + 0.5) | 0, ((child.anchor.y) * (-frame.height) + 0.5) | 0, frame.width, frame.height);

      }
    }

    context.restore();
  }

}
