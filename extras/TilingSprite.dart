part of pixi;
/**
 * @author Mat Groves http://matgroves.com/
 */

/**
 * A tiling sprite is a fast way of rendering a tiling image
 *
 * @class TilingSprite
 * @extends DisplayObjectContainer
 * @constructor
 * @param texture {Texture} the texture of the tiling sprite
 * @param width {Number}  the width of the tiling sprite
 * @param height {Number} the height of the tiling sprite
 */
class TilingSprite extends Sprite{
  
  
  /**
       * The scaling of the image that is being tiled
       *
       * @property tileScale
       * @type Point
       */
      Point tileScale = new Point(1.0,1.0);

      /**
       * A point that represents the scale of the texture object
       *
       * @property tileScaleOffset
       * @type Point
       */
      Point tileScaleOffset = new PIXI.Point(1.0,1.0);
      
      /**
       * The offset position of the image that is being tiled
       *
       * @property tilePosition
       * @type Point
       */
      Point tilePosition = new Point(0.0,0.0);


      /**
       * Whether this sprite is renderable or not
       *
       * @property renderable
       * @type Boolean
       * @default true
       */
      bool renderable = true;

      /**
       * The tint applied to the sprite. This is a hex value
       *
       * @property tint
       * @type Number
       * @default 0xFFFFFF
       */
      int tint = 0xFFFFFF;
      
      /**
       * The blend mode to be applied to the sprite
       *
       * @property blendMode
       * @type Number
       * @default PIXI.blendModes.NORMAL;
       */
      int blendMode = blendModes['NORMAL'];
      
      var tilingTexture;
      
      var __tilePattern;
  
  
  TilingSprite(texture, [width = 100.0, height = 100.0]) : super(texture){
    super.width = width;
    super.height = height;
  }
  
  
  /**
   * The width of the sprite, setting this will actually modify the scale to achieve the value set
   *
   * @property width
   * @type Number
   */
  
  /**
   * The height of the TilingSprite, setting this will actually modify the scale to achieve the value set
   *
   * @property height
   * @type Number
   */
  
  /**
   * When the texture is updated, this event will be fired to update the scale and frame
   *
   * @method onTextureUpdate
   * @param event
   * @private
   */
  void onTextureUpdate(_)
  {
      this.updateFrame = true;
  }
  
  /**
  * Renders the object using the WebGL renderer
  *
  * @method _renderWebGL
  * @param renderSession {RenderSession} 
  * @private
  */
  _renderWebGL(RenderSession renderSession)
  {
  
      if(this.visible == false || this.alpha == 0)return;
      
      int i,j;
  
      if(this.mask != null|| this.filters!= null)
      {
          if(this.mask != null)
          {
              renderSession.spriteBatch.stop();
              renderSession.maskManager.pushMask(this.mask, renderSession);
              renderSession.spriteBatch.start();
          }
  
          if(this.filters != null)
          {
              renderSession.spriteBatch.flush();
              renderSession.filterManager.pushFilter(this._filterBlock);
          }
  
          if(this.tilingTexture == null)this.generateTilingTexture(true);
          else renderSession.spriteBatch.renderTilingSprite(this);
  
          // simple render children!
          i = 0;
          for(j=this.children.length; i<j; i++)
          {
              this.children[i]._renderWebGL(renderSession);
          }
  
          renderSession.spriteBatch.stop();
  
          if(this.filters != null)renderSession.filterManager.popFilter();
          if(this.mask != null)renderSession.maskManager.popMask(renderSession);
          
          renderSession.spriteBatch.start();
      }
      else
      {
          if(this.tilingTexture == null)this.generateTilingTexture(true);
          else renderSession.spriteBatch.renderTilingSprite(this);
          
          // simple render children!
          i = 0;
          for(j=this.children.length; i<j; i++)
          {
              this.children[i]._renderWebGL(renderSession);
          }
      }
  }
  
  /**
  * Renders the object using the Canvas renderer
  *
  * @method _renderCanvas
  * @param renderSession {RenderSession} 
  * @private
  */
  _renderCanvas(RenderSession renderSession)
  {
      if(this.visible == false || this.alpha == 0)return;
      
      var context = renderSession.context;
  
      if(this._mask != null)
      {
          renderSession.maskManager.pushMask(this._mask, context);
      }
  
      context.globalAlpha = this.worldAlpha;
  
      
      var transform = this.worldTransform;
  
      // allow for trimming
  
      context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
  
  
      if(!this.__tilePattern)
      {
          this.generateTilingTexture(false);
          
          if(this.tilingTexture)
          {
              this.__tilePattern = context.createPattern(this.tilingTexture.baseTexture.source, 'repeat');
          }
  
      }
  
      // check blend mode
      if(this.blendMode != renderSession.currentBlendMode)
      {
          renderSession.currentBlendMode = this.blendMode;
          context.globalCompositeOperation = blendModes[renderSession.currentBlendMode];
      }
  
      context.beginPath();
  
      Point tilePosition = this.tilePosition;
      Point tileScale = this.tileScale;
  
      tilePosition.x %= this.tilingTexture.baseTexture.width;
      tilePosition.y %= this.tilingTexture.baseTexture.height;
  
      // offset
      context.scale(tileScale.x,tileScale.y);
      context.translate(tilePosition.x, tilePosition.y);
  
      context.fillStyle = this.__tilePattern;
      context.fillRect(-tilePosition.x,-tilePosition.y,this.width / tileScale.x, this.height / tileScale.y);
  
      context.scale(1/tileScale.x, 1/tileScale.y);
      context.translate(-tilePosition.x, -tilePosition.y);
  
      context.closePath();
  
      if(this._mask != null)
      {
          renderSession.maskManager.popMask(renderSession.context);
      }
  }
  
  
  /**
  * Returns the framing rectangle of the sprite as a PIXI.Rectangle object
  *
  * @method getBounds
  * @return {Rectangle} the framing rectangle
  */
  Rectangle getBounds([_])
  {
  
      double width = this.width;
      double height = this.height;
  
      double w0 = width * (1-this.anchor.x);
      double w1 = width * -this.anchor.x;
  
      double h0 = height * (1-this.anchor.y);
      double h1 = height * -this.anchor.y;
  
      Matrix worldTransform = this.worldTransform;
  
      double a = worldTransform.a;
      double b = worldTransform.c;
      double c = worldTransform.b;
      double d = worldTransform.d;
      double tx = worldTransform.tx;
      double ty = worldTransform.ty;
      
      double x1 = a * w1 + c * h1 + tx;
      double y1 = d * h1 + b * w1 + ty;
  
      double x2 = a * w0 + c * h1 + tx;
      double y2 = d * h1 + b * w0 + ty;
  
      double x3 = a * w0 + c * h0 + tx;
      double y3 = d * h0 + b * w0 + ty;
  
      double x4 =  a * w1 + c * h0 + tx;
      double y4 =  d * h0 + b * w1 + ty;
  
      double maxX = double.NEGATIVE_INFINITY;
      double maxY = double.NEGATIVE_INFINITY;
  
      double minX = double.INFINITY;
      double minY = double.INFINITY;
  
      minX = x1 < minX ? x1 : minX;
      minX = x2 < minX ? x2 : minX;
      minX = x3 < minX ? x3 : minX;
      minX = x4 < minX ? x4 : minX;
  
      minY = y1 < minY ? y1 : minY;
      minY = y2 < minY ? y2 : minY;
      minY = y3 < minY ? y3 : minY;
      minY = y4 < minY ? y4 : minY;
  
      maxX = x1 > maxX ? x1 : maxX;
      maxX = x2 > maxX ? x2 : maxX;
      maxX = x3 > maxX ? x3 : maxX;
      maxX = x4 > maxX ? x4 : maxX;
  
      maxY = y1 > maxY ? y1 : maxY;
      maxY = y2 > maxY ? y2 : maxY;
      maxY = y3 > maxY ? y3 : maxY;
      maxY = y4 > maxY ? y4 : maxY;
  
      Rectangle bounds = this._bounds;
  
      bounds.x = minX;
      bounds.width = maxX - minX;
  
      bounds.y = minY;
      bounds.height = maxY - minY;
  
      // store a reference so that if this function gets called again in the render cycle we do not have to recalculate
      this._currentBounds = bounds;
  
      return bounds;
  }
  
  /**
  * 
  * @method generateTilingTexture
  * 
  * @param forcePowerOfTwo {Boolean} Whether we want to force the texture to be a power of two
  */
  void generateTilingTexture(bool forcePowerOfTwo)
  {
      Texture texture = this.texture;
  
      if(!texture.baseTexture.hasLoaded)return;
  
      var baseTexture = texture.baseTexture;
      var frame = texture.frame;
  
      double targetWidth, targetHeight;
  
      // check that the frame is the same size as the base texture.
      
      var isFrame = frame.width != baseTexture.width || frame.height != baseTexture.height;
  
      this.tilingTexture = texture;
  
      bool newTextureRequired = false;
  
      if(!forcePowerOfTwo)
      {
          if(isFrame)
          {
              targetWidth = frame.width;
              targetHeight = frame.height;
              
              newTextureRequired = true;
          }
      }
      else
      {
          targetWidth = getNextPowerOfTwo(texture.frame.width);
          targetHeight = getNextPowerOfTwo(texture.frame.height);
  
          if(frame.width != targetWidth && frame.height != targetHeight)newTextureRequired = true;
      }
  
      if(newTextureRequired)
      {
          var canvasBuffer = new CanvasBuffer(targetWidth, targetHeight);
          
          canvasBuffer.context.drawImage(texture.baseTexture.source,
                                         frame.x,
                                         frame.y,
                                         frame.width,
                                         frame.height,
                                         0,
                                         0,
                                         targetWidth,
                                         targetHeight);
  
          this.tilingTexture = Texture.fromCanvas(canvasBuffer.canvas);
  
          this.tileScaleOffset.x = frame.width / targetWidth;
          this.tileScaleOffset.y = frame.height / targetHeight;
      }
  
     
      this.tilingTexture.baseTexture._powerOf2 = true;
  }
  
}