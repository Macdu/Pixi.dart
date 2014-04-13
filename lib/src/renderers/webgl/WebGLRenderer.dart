part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

List<RenderingContext> glContexts = [];
    // this is where we store the webGL contexts for easy access.

/**
 * the WebGLRenderer draws the stage and all its content onto a webGL enabled canvas. This renderer
 * should be used for browsers that support webGL. This Render works by automatically managing webGLBatch's.
 * So no need for Sprite Batch's or Sprite Cloud's
 * Dont forget to add the view to your DOM or you will not see anything :)
 */
class WebGLRenderer extends Renderer{


  // do a catch.. only 1 webGL renderer..
  /**
       * Whether the render view is transparent
       *
       * @property transparent
       * @type Boolean
       */
  bool transparent;

  bool antialias;

  /**
       * The width of the canvas view
       *
       * @property width
       * @type Number
       * @default 800
       */
  int width;

  /**
       * The height of the canvas view
       *
       * @property height
       * @type Number
       * @default 600
       */
  int height;


  Map<String, bool> options = {};

  RenderingContext gl;

  int glContextId;

  static int _globalGlContextId = 0;

  Point projection = new Point();

  Point offset = new Point(0.0, 0.0);

  bool contextLost = false;

  // time to create the render managers! each one focuses on managine a state in webGL
  WebGLShaderManager shaderManager;
      // deals with managing the shader programs and their attribs
  WebGLSpriteBatch spriteBatch; // manages the rendering of sprites
  WebGLMaskManager maskManager; // manages the masks using the stencil buffer
  WebGLFilterManager filterManager; // manages the filters


  RenderSession renderSession = new RenderSession();

  Stage _stage;


  /**
       * @class WebGLRenderer
       * @constructor
       * @param width=0 {Number} the width of the canvas view
       * @param height=0 {Number} the height of the canvas view
       * @param view {HTMLCanvasElement} the canvas to use as a view, optional
       * @param transparent=false {Boolean} If the render view is transparent, default false
       * @param antialias=false {Boolean} sets antialias (only applicable in chrome at the moment)
       *
       */
  WebGLRenderer([int width = 800, int height = 600, CanvasElement view =
      null, bool transparent = false, bool antialias = false]) {
    if (defaultRenderer == null) defaultRenderer = this;

    if (view == null) view = new CanvasElement();


    // do a catch.. only 1 webGL renderer..
    /**
     * Whether the render view is transparent
     *
     * @property transparent
     * @type Boolean
     */
    this.transparent = transparent;

    this.antialias = antialias;

    /**
     * The width of the canvas view
     *
     * @property width
     * @type Number
     * @default 800
     */
    this.width = width;

    /**
     * The height of the canvas view
     *
     * @property height
     * @type Number
     * @default 600
     */
    this.height = height;

    /**
     * The canvas element that everything is drawn to
     *
     * @property view
     * @type HTMLCanvasElement
     */
    this.view = view;
    this.view.width = this.width;
    this.view.height = this.height;

    Map<String, bool> options = {
      'alpha': this.transparent,
      'antialias': this.antialias, // SPEED UP??
      'remultipliedAlpha': this.transparent,
      'stencil': true
    };

    this.view.onWebGlContextLost.listen(this.handleContextLost);
    this.view.onWebGlContextRestored.listen(this.handleContextRestored);

    try {
      this.gl = this.view.getContext('experimental-webgl', this.options);
    } catch (e) {
      //try 'webgl'
      try {
        this.gl = this.view.getContext('webgl', this.options);
      } catch (e2) {
        // fail, not able to get a context
        throw new Exception(
            ' This browser does not support webGL. Try using the canvas renderer' + this.toString());
      }
    }

    RenderingContext gl = this.gl;
    this.glContextId = WebGLRenderer._globalGlContextId++;

    glContexts.add(gl);

    if (blendModesWebGL.isEmpty) {
      blendModesWebGL = [];
      /*
      blendModesWebGL[blendModes['NORMAL']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['ADD']] = [RenderingContext.SRC_ALPHA,
          RenderingContext.DST_ALPHA];
      blendModesWebGL[blendModes['MULTIPLY']] = [RenderingContext.DST_COLOR,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['SCREEN']] = [RenderingContext.SRC_ALPHA,
          RenderingContext.ONE];
      blendModesWebGL[blendModes['OVERLAY']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['DARKEN']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['LIGHTEN']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['COLOR_DODGE']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['COLOR_BURN']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['HARD_LIGHT']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['SOFT_LIGHT']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['DIFFERENCE']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['EXCLUSION']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['HUE']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['SATURATION']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['COLOR']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes['LUMINOSITY']] = [RenderingContext.ONE,
          RenderingContext.ONE_MINUS_SRC_ALPHA];
          */
      
      blendModesWebGL.addAll([[RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
               [RenderingContext.SRC_ALPHA,
                RenderingContext.DST_ALPHA],
              [RenderingContext.DST_COLOR,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.SRC_ALPHA,
                RenderingContext.ONE],
             [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA],
              [RenderingContext.ONE,
                RenderingContext.ONE_MINUS_SRC_ALPHA]]);
    }




    this.projection.x = this.width / 2;
    this.projection.y = -this.height / 2;


    // time to create the render managers! each one focuses on managine a state in webGL
    this.shaderManager = new WebGLShaderManager(gl);
        // deals with managing the shader programs and their attribs
    this.spriteBatch = new WebGLSpriteBatch(gl);
        // manages the rendering of sprites
    this.maskManager = new WebGLMaskManager(gl);
        // manages the masks using the stencil buffer
    this.filterManager = new WebGLFilterManager(gl, this.transparent);
        // manages the filters


    this.resize(this.width, this.height);

    this.renderSession
      ..gl = this.gl
      ..shaderManager = this.shaderManager
      ..maskManager = this.maskManager
      ..filterManager = this.filterManager
      ..spriteBatch = this.spriteBatch;


    gl.useProgram(this.shaderManager.defaultShader.program);

    gl.disable(RenderingContext.DEPTH_TEST);
    gl.disable(RenderingContext.CULL_FACE);

    gl.enable(RenderingContext.BLEND);
    gl.colorMask(true, true, true, this.transparent);
  }


  /**
 * Renders the stage to its webGL view
 *
 * @method render
 * @param stage {Stage} the Stage element to be rendered
 */
  void render(Stage stage) {
    if (this.contextLost) return;


    // if rendering a new stage clear the batches..
    if (this._stage != stage) {
      if (stage.interactive) stage.interactionManager.removeEvents();

      // TODO make this work
      // dont think this is needed any more?
      this._stage = stage;
    }

    // update any textures this includes uvs and uploading them to the gpu
    WebGLRenderer.updateTextures();

    // update the scene graph
    stage.updateTransform();

    RenderingContext gl = this.gl;

    // -- Does this need to be set every frame? -- //
    //gl.colorMask(true, true, true, this.transparent);
    gl.viewport(0, 0, this.width, this.height);

    // make sure we are bound to the main frame buffer
    gl.bindFramebuffer(RenderingContext.FRAMEBUFFER, null);

    if (this.transparent) {
      gl.clearColor(0, 0, 0, 0);
    } else {
      gl.clearColor(stage.backgroundColorSplit[0],
          stage.backgroundColorSplit[1], stage.backgroundColorSplit[2], 1);
    }


    gl.clear(RenderingContext.COLOR_BUFFER_BIT);

    this.renderDisplayObject(stage, this.projection);

    // interaction
    if (stage.interactive) {
      //need to add some events!
      if (!stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = true;
        stage.interactionManager.setTarget(this);
      }
    } else {
      if (stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = false;
        stage.interactionManager.setTarget(this);
      }
    }

    /*
    //can simulate context loss in Chrome like so:
     this.view.onmousedown = function(ev) {
     console.dir(this.gl.getSupportedExtensions());
        var ext = (
            gl.getExtension("WEBGL_scompressed_texture_s3tc")
       // gl.getExtension("WEBGL_compressed_texture_s3tc") ||
       // gl.getExtension("MOZ_WEBGL_compressed_texture_s3tc") ||
       // gl.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc")
     );
     console.dir(ext);
     var loseCtx = this.gl.getExtension("WEBGL_lose_context");
      console.log("killing context");
      loseCtx.loseContext();
     setTimeout(function() {
          console.log("restoring context...");
          loseCtx.restoreContext();
      }.bind(this), 1000);
     }.bind(this);
     */
  }

  /**
 * Renders a display Object
 *
 * @method renderDIsplayObject
 * @param displayObject {DisplayObject} The DisplayObject to render
 * @param projection {Point} The projection
 * @param buffer {List} a standard WebGL buffer 
 */
  void renderDisplayObject(DisplayObject displayObject, Point
      projection, [Framebuffer buffer = null]) {
    // reset the render session data..
    this.renderSession.drawCount = 0;
    this.renderSession.currentBlendMode = 9999;

    this.renderSession.projection = projection;
    this.renderSession.offset = this.offset;

    // start the sprite batch
    this.spriteBatch.begin(this.renderSession);

    // start the filter manager
    this.filterManager.begin(this.renderSession, buffer);

    // render the scene!
    displayObject._renderWebGL(this.renderSession);

    // finish the sprite batch
    this.spriteBatch.end();
  }

  /**
 * Updates the textures loaded into this webgl renderer
 *
 * @static
 * @method updateTextures
 * @private
 */
  static void updateTextures() {
    int i = 0;

    //TODO break this out into a texture manager...
    //for (i = 0; i < PIXI.texturesToUpdate.length; i++)
    //    PIXI.WebGLRenderer.updateTexture(PIXI.texturesToUpdate[i]);


    for (i = 0; i < Texture.frameUpdates.length; i++)
        WebGLRenderer.updateTextureFrame(Texture.frameUpdates[i]);

    for (i = 0; i < texturesToDestroy.length; i++) WebGLRenderer.destroyTexture(
        texturesToDestroy[i]);

    texturesToUpdate.length = 0;
    texturesToDestroy.length = 0;
    Texture.frameUpdates.length = 0;
  }

  /**
 * Destroys a loaded webgl texture
 *
 * @method destroyTexture
 * @param texture {Texture} The texture to update
 * @private
 */
  static void destroyTexture(Texture texture) {
    //TODO break this out into a texture manager...

    for (int i = texture._glTextures.length - 1; i >= 0; i--) {
      var glTexture = texture._glTextures[i];
      RenderingContext gl = glContexts[i];

      if (gl && glTexture) {
        gl.deleteTexture(glTexture);
      }
    }

    texture._glTextures.length = 0;
  }

  /**
 *
 * @method updateTextureFrame
 * @param texture {Texture} The texture to update the frame from
 * @private
 */
  static void updateTextureFrame(Texture texture) {
    texture.updateFrame = false;

    // now set the uvs. Figured that the uv data sits with a texture rather than a sprite.
    // so uv data is stored on the texture itself
    texture._updateWebGLuvs();
  }

  /**
 * resizes the webGL view to the specified width and height
 *
 * @method resize
 * @param width {Number} the new width of the webGL view
 * @param height {Number} the new height of the webGL view
 */
  void resize(int width, int height) {
    this.width = width;
    this.height = height;

    this.view.width = width;
    this.view.height = height;

    this.gl.viewport(0, 0, this.width, this.height);

    this.projection.x = this.width / 2;
    this.projection.y = -this.height / 2;
  }

  static int _getIndexFirst(RenderingContext context) {

    for (int i = 0; i < glContexts.length; i++) {
      if (glContexts[i] == context) return i;
    }
    return null;

  }

  /**
 * Creates a WebGL texture
 *
 * @method createWebGLTexture
 * @param texture {Texture} the texture to render
 * @param gl {webglContext} the WebGL context
 * @static
 */
  static createWebGLTexture(Texture texture, RenderingContext gl) => createWebGLTextureFromBaseTexture(texture.baseTexture, gl);
  
  
      
  static createWebGLTextureFromBaseTexture(BaseTexture texture, RenderingContext gl){
    
    int id = _getIndexFirst(gl);

        if (texture.hasLoaded) {

          texture._glTextures.insert(id, gl.createTexture());

          gl.bindTexture(RenderingContext.TEXTURE_2D, texture._glTextures[id]);
          gl.pixelStorei(RenderingContext.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);

          gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA,
              RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, texture.source);
          gl.texParameteri(RenderingContext.TEXTURE_2D,
              RenderingContext.TEXTURE_MAG_FILTER, texture.scaleMode == scaleModes['LINEAR'] ?
              RenderingContext.LINEAR : RenderingContext.NEAREST);
          gl.texParameteri(RenderingContext.TEXTURE_2D,
              RenderingContext.TEXTURE_MIN_FILTER, texture.scaleMode == scaleModes['LINEAR'] ?
              RenderingContext.LINEAR : RenderingContext.NEAREST);

          // reguler...

          if (!texture._powerOf2) {
            gl.texParameteri(RenderingContext.TEXTURE_2D,
                RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
            gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
          } else {
            gl.texParameteri(RenderingContext.TEXTURE_2D,
                RenderingContext.TEXTURE_WRAP_S, RenderingContext.REPEAT);
            gl.texParameteri(RenderingContext.TEXTURE_2D,
                RenderingContext.TEXTURE_WRAP_T, RenderingContext.REPEAT);
          }

          gl.bindTexture(RenderingContext.TEXTURE_2D, null);
        }

        return texture._glTextures[id];
    
  }

  /**
 * Updates a WebGL texture
 *
 * @method updateWebGLTexture
 * @param texture {Texture} the texture to update
 * @param gl {webglContext} the WebGL context
 * @private
 */
  static void updateWebGLTexture(Texture texture1, RenderingContext gl) {
    
    BaseTexture texture = texture1.baseTexture;

    int id = _getIndexFirst(gl);

    if (texture._glTextures[id]) {
      gl.bindTexture(RenderingContext.TEXTURE_2D, texture._glTextures[id]);
      gl.pixelStorei(RenderingContext.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);

      gl.texImage2D(RenderingContext.TEXTURE_2D, 0, RenderingContext.RGBA,
          RenderingContext.RGBA, RenderingContext.UNSIGNED_BYTE, texture.source);
      gl.texParameteri(RenderingContext.TEXTURE_2D,
          RenderingContext.TEXTURE_MAG_FILTER, texture.scaleMode == scaleModes['LINEAR'] ?
          RenderingContext.LINEAR : RenderingContext.NEAREST);
      gl.texParameteri(RenderingContext.TEXTURE_2D,
          RenderingContext.TEXTURE_MIN_FILTER, texture.scaleMode == scaleModes['LINEAR'] ?
          RenderingContext.LINEAR : RenderingContext.NEAREST);

      // reguler...

      if (!texture._powerOf2) {
        gl.texParameteri(RenderingContext.TEXTURE_2D,
            RenderingContext.TEXTURE_WRAP_S, RenderingContext.CLAMP_TO_EDGE);
        gl.texParameteri(RenderingContext.TEXTURE_2D,
            RenderingContext.TEXTURE_WRAP_T, RenderingContext.CLAMP_TO_EDGE);
      } else {
        gl.texParameteri(RenderingContext.TEXTURE_2D,
            RenderingContext.TEXTURE_WRAP_S, RenderingContext.REPEAT);
        gl.texParameteri(RenderingContext.TEXTURE_2D,
            RenderingContext.TEXTURE_WRAP_T, RenderingContext.REPEAT);
      }

      gl.bindTexture(RenderingContext.TEXTURE_2D, null);
    }

  }

  /**
 * Handles a lost webgl context
 *
 * @method handleContextLost
 * @param event {Event}
 * @private
 */
  void handleContextLost(Event event) {
    event.preventDefault();
    this.contextLost = true;
  }

  /**
 * Handles a restored webgl context
 *
 * @method handleContextRestored
 * @param event {Event}
 * @private
 */
  void handleContextRestored(Event event) {

    //try 'experimental-webgl'
    try {
      this.gl = this.view.getContext('experimental-webgl', this.options);
    } catch (e) {
      //try 'webgl'
      try {
        this.gl = this.view.getContext('webgl', this.options);
      } catch (e2) {
        // fail, not able to get a context
        throw new Exception(
            ' This browser does not support webGL. Try using the canvas renderer' + this.toString());
      }
    }

    RenderingContext gl = this.gl;
    glContexts[_getIndexFirst(gl)] = null;
    this.glContextId = WebGLRenderer._globalGlContextId++;
    glContexts.add(gl);



    // need to set the context...
    this.shaderManager.setContext(gl);
    this.spriteBatch.setContext(gl);
    this.maskManager.setContext(gl);
    this.filterManager.setContext(gl);


    this.renderSession.gl = this.gl;

    gl.disable(RenderingContext.DEPTH_TEST);
    gl.disable(RenderingContext.CULL_FACE);

    gl.enable(RenderingContext.BLEND);
    gl.colorMask(true, true, true, this.transparent);

    this.gl.viewport(0, 0, this.width, this.height);

    for (Texture key in TextureCache) {
      BaseTexture texture = key.baseTexture;
      texture._glTextures = [];
    }

    /**
     * Whether the context was lost 
     * @property contextLost
     * @type Boolean
     */
    this.contextLost = false;

  }

  /**
 * Removes everything from the renderer (event listeners, spritebatch, etc...)
 *
 * @method destroy
 */
  void destroy() {

    // deal with losing context..

    // remove listeners
    //TODO: remove the listeners
    //this.view.removeEventListener('webglcontextlost', this.contextLost);
    //this.view.removeEventListener('webglcontextrestored', this.contextRestoredLost);

    glContexts[this.glContextId] = null;

    this.projection = null;
    this.offset = null;

    // time to create the render managers! each one focuses on managine a state in webGL
    this.shaderManager.destroy();
    this.spriteBatch.destroy();
    this.maskManager.destroy();
    this.filterManager.destroy();

    this.shaderManager = null;
    this.spriteBatch = null;
    this.maskManager = null;
    this.filterManager = null;

    this.gl = null;
    //
    this.renderSession = null;
  }
}
