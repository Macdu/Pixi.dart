part of pixi;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * The Sprite object is the base for all textured objects that are rendered to the screen
 *
 * @class Sprite
 * @extends DisplayObjectContainer
 * @param texture {Texture} The texture for this sprite
 * 
 * A sprite can be created directly from an image like this : 
 * var sprite = nex PIXI.Sprite.FromImage('assets/image.png');
 * yourStage.addChild(sprite);
 * then obviously don't forget to add it to the stage you have already created
 */
class Sprite extends DisplayObjectContainer{

    /**
     * The anchor sets the origin point of the texture.
     * The default is 0,0 this means the texture's origin is the top left
     * Setting than anchor to 0.5,0.5 means the textures origin is centred
     * Setting the anchor to 1,1 would mean the textures origin points will be the bottom right corner
     *
     * @property anchor
     * @type Point
     */
    Point anchor = new Point();

    /**
     * The texture that the sprite is using
     *
     * @property texture
     * @type Texture
     */
    Texture texture;

    /**
     * The width of the sprite (this is initially set by the texture)
     *
     * @property _width
     * @type Number
     * @private
     */
    double _width = 0.0;

    /**
     * The height of the sprite (this is initially set by the texture)
     *
     * @property _height
     * @type Number
     * @private
     */
    double _height = 0.0;


    /**
     * The tint applied to the sprite. This is a hex value
     *
     * @property tint
     * @type Number
     * @default 0xFFFFFF
     */
    int tint = 0xFFFFFF;// * Math.random();
    
    int cachedTint;
    
    /**
     * The blend mode to be applied to the sprite
     *
     * @property blendMode
     * @type Number
     * @default PIXI.blendModes.NORMAL;
     */
    
    int blendMode = blendModes['NORMAL'];
    
    bool textureChange;
    
    bool updateFrame;

    bool renderable = true;
    
    CanvasBuffer buffer;
    
    var tintedTexture;

    Sprite(Texture texture){
    
      this.texture = texture;
      
      if(texture.baseTexture.hasLoaded)
      {
          this.onTextureUpdate();
      }
      else
      {
          this.texture.stream('update').listen( this.onTextureUpdate );
      }
      
  }
  
  /**
   * The width of the sprite, setting this will actually modify the scale to achieve the value set
   *
   * @property width
   * @type Number
   */
    
  double get width => this.scale.x * this.texture.frame.width;
      set width(double value){
        this.scale.x = value / this.texture.frame.width;
             this._width = value;
      }
  
  /**
   * The height of the sprite, setting this will actually modify the scale to achieve the value set
   *
   * @property height
   * @type Number
   */
      
   double get height => this.scale.y * this.texture.frame.height;
       set height(double value){
          this.scale.y = value / this.texture.frame.height;
               this._height = value;
        }
  
  /**
   * Sets the texture of the sprite
   *
   * @method setTexture
   * @param texture {Texture} The PIXI texture that is displayed by the sprite
   */
  void setTexture(Texture texture)
  {
      // stop current texture;
      if(this.texture.baseTexture != texture.baseTexture)
      {
          this.textureChange = true;
          this.texture = texture;
      }
      else
      {
          this.texture = texture;
      }
  
      this.cachedTint = 0xFFFFFF;
      this.updateFrame = true;
  }
  
  /**
   * When the texture is updated, this event will fire to update the scale and frame
   *
   * @method onTextureUpdate
   * @param event
   * @private
   */
  void onTextureUpdate(_)
  {
      // so if _width is 0 then width was not set..
      if(this._width != 0)this.scale.x = this._width / this.texture.frame.width;
      if(this._height != 0)this.scale.y = this._height / this.texture.frame.height;
  
  
      this.updateFrame = true;
  }
  
  /**
  * Returns the framing rectangle of the sprite as a PIXI.Rectangle object
  *
  * @method getBounds
  * @param matrix {Matrix} the transformation matrix of the sprite
  * @return {Rectangle} the framing rectangle
  */
  Rectangle getBounds([Matrix matrix = null])
  {
  
      if (matrix == null) matrix = this.worldTransform;  
    
      double width = this.texture.frame.width;
      double height = this.texture.frame.height;
  
      double w0 = width * (1-this.anchor.x);
      double w1 = width * -this.anchor.x;
  
      double h0 = height * (1-this.anchor.y);
      double h1 = height * -this.anchor.y;
  
      Matrix worldTransform = matrix ;
  
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
  * Renders the object using the WebGL renderer
  *
  * @method _renderWebGL
  * @param renderSession {RenderSession} 
  * @private
  */
  void _renderWebGL(RenderSession renderSession)
  {
      // if the sprite is not visible or the alpha is 0 then no need to render this element
      if(!this.visible || this.alpha <= 0)return;
      
      int i,j;
  
      // do a quick check to see if this element has a mask or a filter.
      if(this._mask || this._filters)
      {
          var spriteBatch =  renderSession.spriteBatch;
  
          if(this._mask != null)
          {
              spriteBatch.stop();
              renderSession.maskManager.pushMask(this.mask, renderSession);
              spriteBatch.start();
          }
  
          if(this._filters != null)
          {
              spriteBatch.flush();
              renderSession.filterManager.pushFilter(this._filterBlock);
          }
  
          // add this sprite to the batch
          spriteBatch.render(this);
  
          // now loop through the children and make sure they get rendered
          i = 0;
          for(j=this.children.length; i<j; i++)
          {
              this.children[i]._renderWebGL(renderSession);
          }
  
          // time to stop the sprite batch as either a mask element or a filter draw will happen next
          spriteBatch.stop();
  
          if(this._filters != null)renderSession.filterManager.popFilter();
          if(this._mask != null)renderSession.maskManager.popMask(renderSession);
          
          spriteBatch.start();
      }
      else
      {
          renderSession.spriteBatch.render(this);
  
          // simple render children!
          i = 0;
          for(j=this.children.length; i<j; i++)
          {
              this.children[i]._renderWebGL(renderSession);
          }
      }
  
     
      //TODO check culling  
  }
  
  /**
  * Renders the object using the Canvas renderer
  *
  * @method _renderCanvas
  * @param renderSession {RenderSession} 
  * @private
  */
  void _renderCanvas(RenderSession renderSession)
  {
      // if the sprite is not visible or the alpha is 0 then no need to render this element
      if(this.visible == false || this.alpha == 0)return;
      
      var frame = this.texture.frame;
      var context = renderSession.context;
      Texture texture = this.texture;
  
      if(this.blendMode != renderSession.currentBlendMode)
      {
          renderSession.currentBlendMode = this.blendMode;
          context.globalCompositeOperation = blendModes[renderSession.currentBlendMode];
      }
  
      if(this._mask != null)
      {
          renderSession.maskManager.pushMask(this._mask, renderSession.context);
      }
  
      
  
      //ignore null sources
      if(frame && frame.width && frame.height && texture.baseTexture.source)
      {
          context.globalAlpha = this.worldAlpha;
  
          Matrix transform = this.worldTransform;
  
          // allow for trimming
         
          if (renderSession.roundPixels)
          {
              context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx || 0, transform.ty || 0);
          }
          else
          {
              context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
          }
  
  
          //if smoothingEnabled is supported and we need to change the smoothing property for this texture
          if(renderSession.smoothProperty && renderSession.scaleMode != this.texture.baseTexture.scaleMode) {
              renderSession.scaleMode = this.texture.baseTexture.scaleMode;
              context[renderSession.smoothProperty] = (renderSession.scaleMode == scaleModes['LINEAR']);
          }
  
          if(this.tint != 0xFFFFFF)
          {
              
              if(this.cachedTint != this.tint)
              {
                  // no point tinting an image that has not loaded yet!
                  if(!texture.baseTexture.hasLoaded)return;
  
                  this.cachedTint = this.tint;
                  
                  //TODO clean up caching - how to clean up the caches?
                  this.tintedTexture = CanvasTinter.getTintedTexture(this, this.tint);
                  
              }
  
              context.drawImage(this.tintedTexture,
                                 0,
                                 0,
                                 frame.width,
                                 frame.height,
                                 (this.anchor.x) * -frame.width,
                                 (this.anchor.y) * -frame.height,
                                 frame.width,
                                 frame.height);
          }
          else
          {
  
             
  
              if(texture.trim)
              {
                  var trim =  texture.trim;
  
                  context.drawImage(this.texture.baseTexture.source,
                                 frame.x,
                                 frame.y,
                                 frame.width,
                                 frame.height,
                                 trim.x - this.anchor.x * trim.width,
                                 trim.y - this.anchor.y * trim.height,
                                 frame.width,
                                 frame.height);
              }
              else
              {
                 
                  context.drawImage(this.texture.baseTexture.source,
                                 frame.x,
                                 frame.y,
                                 frame.width,
                                 frame.height,
                                 (this.anchor.x) * -frame.width,
                                 (this.anchor.y) * -frame.height,
                                 frame.width,
                                 frame.height);
              }
              
          }
      }
  
      // OVERWRITE
      for(var i=0,j=this.children.length; i<j; i++)
      {
          var child = this.children[i];
          child._renderCanvas(renderSession);
      }
  
      if(this._mask)
      {
          renderSession.maskManager.popMask(renderSession.context);
      }
  }
  
  
  // some helper functions..
  
  /**
   *
   * Helper function that creates a sprite that will contain a texture from the TextureCache based on the frameId
   * The frame ids are created when a Texture packer file has been loaded
   *
   * @method fromFrame
   * @static
   * @param frameId {String} The frame Id of the texture in the cache
   * @return {Sprite} A new Sprite using a texture from the texture cache matching the frameId
   */
  static Sprite fromFrame(String frameId)
  {
      var texture = TextureCache[frameId];
      if(texture == null) throw new Exception('The frameId "' + frameId + '" does not exist in the texture cache' );
      return new Sprite(texture);
  }
  
  /**
   *
   * Helper function that creates a sprite that will contain a texture based on an image url
   * If the image is not in the texture cache it will be loaded
   *
   * @method fromImage
   * @static
   * @param imageId {String} The image url of the texture
   * @return {Sprite} A new Sprite using a texture from the texture cache matching the image id
   */
  static Sprite fromImage(String imageId, crossorigin, scaleMode)
  {
      var texture = Texture.fromImage(imageId, crossorigin, scaleMode);
      return new Sprite(texture);
  }
  
}
