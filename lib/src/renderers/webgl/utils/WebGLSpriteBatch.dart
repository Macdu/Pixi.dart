part of pixi;
/**
 * @author Mat Groves
 * 
 * Big thanks to the very clever Matt DesLauriers <mattdesl> https://github.com/mattdesl/
 * for creating the original pixi version!
 *
 * Heavily inspired by LibGDX's WebGLSpriteBatch:
 * https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/WebGLSpriteBatch.java
 */

class WebGLSpriteBatch {


  /**
       * 
       *
       * @property vertSize
       * @type Number
       */
  int vertSize = 6;

  /**
       * The number of images in the SpriteBatch before it flushes
       * @property size
       * @type Number
       */
  int size = 10000;//Math.pow(2, 16) /  this.vertSize;


  /**
      * Holds the vertices
      *
      * @property vertices
      * @type Float32Array
      */
  Float32List vertices;

  //index data
  /**
       * Holds the indices
       *
       * @property indices
       * @type Uint16Array
       */
  Uint16List indices;

  int lastIndexCount = 0;


  bool drawing = false;
  int currentBatchSize = 0;
  BaseTexture currentBaseTexture = null;

  RenderingContext gl;

  // create a couple of buffers
  Buffer vertexBuffer;
  Buffer indexBuffer;

  int currentBlendMode = 99999;

  RenderSession renderSession;

  var shader;


  /**
 *
 * @class WebGLSpriteBatch
 * @private
 * @constructor
 * @param gl {WebGLContext} the current WebGL drawing context
 *
 */
  WebGLSpriteBatch(RenderingContext gl) {


    //the total number of floats in our batch
    var numVerts = this.size * 4 * this.vertSize;
    //the total number of indices in our batch
    var numIndices = this.size * 6;

    //vertex data

    /**
    * Holds the vertices
    *
    * @property vertices
    * @type Float32Array
    */
    this.vertices = new Float32List(numVerts);

    //index data
    /**
     * Holds the indices
     *
     * @property indices
     * @type Uint16Array
     */
    this.indices = new Uint16List(numIndices);

    this.lastIndexCount = 0;

    for (int i = 0,
        j = 0; i < numIndices; i += 6, j += 4) {
      this.indices[i + 0] = j + 0;
      this.indices[i + 1] = j + 1;
      this.indices[i + 2] = j + 2;
      this.indices[i + 3] = j + 0;
      this.indices[i + 4] = j + 2;
      this.indices[i + 5] = j + 3;
    }



    this.setContext(gl);
  }

  /**
* 
* @method setContext
*
* @param gl {WebGLContext} the current WebGL drawing context
*/
  void setContext(RenderingContext gl) {
    this.gl = gl;

    // create a couple of buffers
    this.vertexBuffer = gl.createBuffer();
    this.indexBuffer = gl.createBuffer();

    // 65535 is max index, so 65535 / 6 = 10922.


    //upload the index data
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, this.indices, STATIC_DRAW);

    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.bufferData(ARRAY_BUFFER, this.vertices, DYNAMIC_DRAW);

    this.currentBlendMode = 99999;
  }

  /**
* 
* @method begin
*
* @param renderSession {RenderSession} the RenderSession
*/
  void begin(RenderSession renderSession) {
    this.renderSession = renderSession;
    this.shader = this.renderSession.shaderManager.defaultShader;

    this.start();
  }

  /**
* 
* @method end
*
*/
  void end() {
    this.flush();
  }

  /**
* 
* @method render
* 
* @param sprite {Sprite} the sprite to render when using this spritebatch
*/
  void render(Sprite sprite) {
    // check texture..
    if (sprite.texture.baseTexture != this.currentBaseTexture || this.currentBatchSize >= this.size) {
      this.flush();
      this.currentBaseTexture = sprite.texture.baseTexture;
    }


    // check blend mode
    if (sprite.blendMode != this.currentBlendMode) {
      this.setBlendMode(sprite.blendMode);
    }

    // get the uvs for the texture
    TextureUvs uvs = (sprite._uvs != null) ? sprite._uvs : sprite.texture._uvs;
    // if the uvs have not updated then no point rendering just yet!
    if (uvs == null) return;

    // get the sprites current alpha
    double alpha = sprite.worldAlpha;
    int tint = sprite.tint;

    Float32List verticies = this.vertices;

    double width = sprite.texture.frame.width;
    double height = sprite.texture.frame.height;

    // TODO trim??
    double aX = sprite.anchor.x;
    double aY = sprite.anchor.y;

    double w0, w1, h0, h1;

    if (sprite.texture.trim != null) {
      // if the sprite is trimmed then we need to add the extra space before transforming the sprite coords..
      Rectangle trim = sprite.texture.trim;

      w1 = trim.x - aX * trim.width;
      w0 = w1 + width;

      h1 = trim.y - aY * trim.height;
      h0 = h1 + height;
    } else {
      w0 = (width) * (1 - aX);
      w1 = (width) * -aX;

      h0 = height * (1 - aY);
      h1 = height * -aY;
    }

    int index = this.currentBatchSize * 4 * this.vertSize;

    Matrix worldTransform = sprite.worldTransform;//.toArray();

    double a = worldTransform.a;//[0];
    double b = worldTransform.c;//[3];
    double c = worldTransform.b;//[1];
    double d = worldTransform.d;//[4];
    double tx = worldTransform.tx;//[2];
    double ty = worldTransform.ty;
    ///[5];

    // xy
    verticies[index++] = a * w1 + c * h1 + tx;
    verticies[index++] = d * h1 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x0;
    verticies[index++] = uvs.y0;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // xy
    verticies[index++] = a * w0 + c * h1 + tx;
    verticies[index++] = d * h1 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x1;
    verticies[index++] = uvs.y1;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // xy
    verticies[index++] = a * w0 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x2;
    verticies[index++] = uvs.y2;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // xy
    verticies[index++] = a * w1 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x3;
    verticies[index++] = uvs.y3;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // increment the batchsize
    this.currentBatchSize++;


  }

  /**
* Renders a tilingSprite using the spriteBatch
* @method renderTilingSprite
* 
* @param sprite {TilingSprite} the tilingSprite to render
*/
  void renderTilingSprite(TilingSprite tilingSprite) {
    Texture texture = tilingSprite.tilingTexture;

    if (texture.baseTexture != this.currentBaseTexture || this.currentBatchSize >= this.size) {
      this.flush();
      this.currentBaseTexture = texture.baseTexture;
    }

    // check blend mode
    if (tilingSprite.blendMode != this.currentBlendMode) {
      this.setBlendMode(tilingSprite.blendMode);
    }

    // set the textures uvs temporarily
    // TODO create a separate texture so that we can tile part of a texture

    if (tilingSprite._uvs == null) tilingSprite._uvs = new TextureUvs();

    TextureUvs uvs = tilingSprite._uvs;

    tilingSprite.tilePosition.x %= texture.baseTexture.width;
    tilingSprite.tilePosition.y %= texture.baseTexture.height;

    double offsetX = tilingSprite.tilePosition.x / texture.baseTexture.width;
    double offsetY = tilingSprite.tilePosition.y / texture.baseTexture.height;

    double scaleX = (tilingSprite.width / texture.baseTexture.width) / (tilingSprite.tileScale.x * tilingSprite.tileScaleOffset.x);
    double scaleY = (tilingSprite.height / texture.baseTexture.height) / (tilingSprite.tileScale.y * tilingSprite.tileScaleOffset.y);

    uvs.x0 = (0 - offsetX).toDouble();
    uvs.y0 = (0 - offsetY).toDouble();

    uvs.x1 = (1 * scaleX) - offsetX;
    uvs.y1 = (0 - offsetY).toDouble();

    uvs.x2 = (1 * scaleX) - offsetX;
    uvs.y2 = (1 * scaleY) - offsetY;

    uvs.x3 = (0 - offsetX).toDouble();
    uvs.y3 = (1 * scaleY) - offsetY;

    // get the tilingSprites current alpha
    double alpha = tilingSprite.worldAlpha;
    int tint = tilingSprite.tint;

    Float32List verticies = this.vertices;

    double width = tilingSprite.width;
    double height = tilingSprite.height;

    // TODO trim??
    double aX = tilingSprite.anchor.x; // - tilingSprite.texture.trim.x
    double aY = tilingSprite.anchor.y; //- tilingSprite.texture.trim.y
    double w0 = width * (1 - aX);
    double w1 = width * -aX;

    double h0 = height * (1 - aY);
    double h1 = height * -aY;

    int index = this.currentBatchSize * 4 * this.vertSize;

    Matrix worldTransform = tilingSprite.worldTransform;

    double a = worldTransform.a;//[0];
    double b = worldTransform.c;//[3];
    double c = worldTransform.b;//[1];
    double d = worldTransform.d;//[4];
    double tx = worldTransform.tx;//[2];
    double ty = worldTransform.ty;
    ///[5];

    // xy
    verticies[index++] = a * w1 + c * h1 + tx;
    verticies[index++] = d * h1 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x0;
    verticies[index++] = uvs.y0;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // xy
    verticies[index++] = a * w0 + c * h1 + tx;
    verticies[index++] = d * h1 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x1;
    verticies[index++] = uvs.y1;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // xy
    verticies[index++] = a * w0 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x2;
    verticies[index++] = uvs.y2;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // xy
    verticies[index++] = a * w1 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x3;
    verticies[index++] = uvs.y3;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint.toDouble();

    // increment the batchs
    this.currentBatchSize++;
  }


  /**
* Renders the content and empties the current batch
*
* @method flush
* 
*/
  void flush() {
    // If the batch is length 0 then return as there is nothing to draw
    if (this.currentBatchSize == 0) return;

    RenderingContext gl = this.gl;

    int id = WebGLRenderer._getIndexFirst(gl);

    // bind the current texture
    gl.bindTexture(TEXTURE_2D, (this.currentBaseTexture._glTextures.contains(id)) ? this.currentBaseTexture._glTextures[id] : WebGLRenderer.createWebGLTextureFromBaseTexture(this.currentBaseTexture, gl));

    // upload the verts to the buffer

    if (this.currentBatchSize > (this.size * 0.5)) {
      gl.bufferSubData(ARRAY_BUFFER, 0, this.vertices);
    } else {
      Float32List view = new Float32List.fromList(this.vertices.getRange(0, this.currentBatchSize * 4 * this.vertSize).toList());

      gl.bufferSubData(ARRAY_BUFFER, 0, view);
    }

    // var view = this.vertices.subarray(0, this.currentBatchSize * 4 * this.vertSize);
    //gl.bufferSubData(gl.ARRAY_BUFFER, 0, view);

    // now draw those suckas!
    gl.drawElements(TRIANGLES, this.currentBatchSize * 6, UNSIGNED_SHORT, 0);

    // then reset the batch!
    this.currentBatchSize = 0;

    // increment the draw count
    this.renderSession.drawCount++;
  }

  /**
* 
* @method stop
*
*/
  void stop() {
    this.flush();
  }

  /**
* 
* @method start
*
*/
  void start() {
    RenderingContext gl = this.gl;

    // bind the main texture
    gl.activeTexture(TEXTURE0);

    // bind the buffers
    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);

    // set the projection
    Point projection = this.renderSession.projection;
    gl.uniform2f(this.shader.projectionVector, projection.x, projection.y);

    // set the pointers
    int stride = this.vertSize * 4;
    gl.vertexAttribPointer(this.shader.aVertexPosition, 2, FLOAT, false, stride, 0);
    gl.vertexAttribPointer(this.shader.aTextureCoord, 2, FLOAT, false, stride, 2 * 4);
    gl.vertexAttribPointer(this.shader.colorAttribute, 2, FLOAT, false, stride, 4 * 4);

    // set the blend mode..
    if (this.currentBlendMode != blendModes['NORMAL']) {
      this.setBlendMode(blendModes['NORMAL']);
    }
  }

  /**
* Sets-up the given blendMode from WebGL's point of view
* @method setBlendMode 
*
* @param blendMode {Number} the blendMode, should be a Pixi const, such as PIXI.BlendModes.ADD
*/
  void setBlendMode(int blendMode) {
    this.flush();

    this.currentBlendMode = blendMode;

    List blendModeWebGL = blendModesWebGL[this.currentBlendMode];
    this.gl.blendFunc(blendModeWebGL[0], blendModeWebGL[1]);
  }

  /**
* Destroys the SpriteBatch
* @method destroy
*/
  void destroy() {

    this.vertices = null;
    this.indices = null;

    this.gl.deleteBuffer(this.vertexBuffer);
    this.gl.deleteBuffer(this.indexBuffer);

    this.currentBaseTexture = null;

    this.gl = null;
  }

}
