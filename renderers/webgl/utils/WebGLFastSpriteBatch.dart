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
class WebGLFastSpriteBatch {

  RenderingContext gl;

  int vertSize = 10;
  int maxSize = 6000;//Math.pow(2, 16) /  this.vertSize;
  int size;// = this.maxSize


  //vertex data
  Float32List vertices;
  //index data
  Uint16List indices;

  Buffer vertexBuffer = null;
  Buffer indexBuffer = null;

  int lastIndexCount = 0;

  bool drawing = false;
  int currentBatchSize = 0;
  BaseTexture currentBaseTexture = null;

  int currentBlendMode = 0;
  Map renderSession = null;


  WebGLShaderManager shader = null;

  Matrix matrix = null;

  WebGLFastSpriteBatch(RenderingContext gl) {

    this.size = this.maxSize;

    //the total number of floats in our batch
    int numVerts = this.size * 4 * this.vertSize;
    //the total number of indices in our batch
    int numIndices = this.maxSize * 6;

    //vertex data
    this.vertices = new Float32List(numVerts);
    //index data
    this.indices = new Uint16List(numIndices);

    for (int i = 0, j = 0; i < numIndices; i += 6, j += 4) {
      this.indices[i + 0] = j + 0;
      this.indices[i + 1] = j + 1;
      this.indices[i + 2] = j + 2;
      this.indices[i + 3] = j + 0;
      this.indices[i + 4] = j + 2;
      this.indices[i + 5] = j + 3;
    }
    this.setContext(gl);
  }

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

  void begin(SpriteBatch spriteBatch, Map renderSession) {
    this.renderSession = renderSession;
    this.shader = this.renderSession['shaderManager'].fastShader;

    this.matrix = spriteBatch.worldTransform;

    this.start();
  }

  void end() {
    this.flush();
  }

  void render(SpriteBatch spriteBatch) {

    List children = spriteBatch.children;
    Sprite sprite = children[0];

    // if the uvs have not updated then no point rendering just yet!

    // check texture.
    if (sprite.texture._uvs == null) return;

    this.currentBaseTexture = sprite.texture.baseTexture;
    // check blend mode
    if (sprite.blendMode != this.currentBlendMode) {
      this.setBlendMode(sprite.blendMode);
    }

    for (int i = 0, j = children.length; i < j; i++) {
      this.renderSprite(children[i]);
    }

    this.flush();
  }

  void renderSprite(Sprite sprite) {
    //sprite = children[i];

    // TODO trim??
    if (sprite.texture.baseTexture != this.currentBaseTexture) {
      this.flush();
      this.currentBaseTexture = sprite.texture.baseTexture;

      if (sprite.texture._uvs == null) return;
    }

    Float32List uvs, verticies = this.vertices;
    int width, height, index;
    double w0, w1, h0, h1;

    uvs = sprite.texture._uvs;


    width = sprite.texture.frame.width;
    height = sprite.texture.frame.height;

    if (sprite.texture.trim) {
      // if the sprite is trimmed then we need to add the extra space before transforming the sprite coords..
      Rectangle trim = sprite.texture.trim;

      w1 = trim.x - sprite.anchor.x * trim.width;
      w0 = w1 + sprite.texture.frame.width;

      h1 = trim.y - sprite.anchor.y * trim.height;
      h0 = h1 + sprite.texture.frame.height;
    } else {
      w0 = (sprite.texture.frame.width) * (1 - sprite.anchor.x);
      w1 = (sprite.texture.frame.width) * -sprite.anchor.x;

      h0 = sprite.texture.frame.height * (1 - sprite.anchor.y);
      h1 = sprite.texture.frame.height * -sprite.anchor.y;
    }

    index = this.currentBatchSize * 4 * this.vertSize;

    // xy
    verticies[index++] = w1;
    verticies[index++] = h1;

    verticies[index++] = sprite.position.x;
    verticies[index++] = sprite.position.y;

    //scale
    verticies[index++] = sprite.scale.x;
    verticies[index++] = sprite.scale.y;

    //rotation
    verticies[index++] = sprite.rotation;

    // uv
    verticies[index++] = uvs.x0;
    verticies[index++] = uvs.y1;
    // color
    verticies[index++] = sprite.alpha;


    // xy
    verticies[index++] = w0;
    verticies[index++] = h1;

    verticies[index++] = sprite.position.x;
    verticies[index++] = sprite.position.y;

    //scale
    verticies[index++] = sprite.scale.x;
    verticies[index++] = sprite.scale.y;

    //rotation
    verticies[index++] = sprite.rotation;

    // uv
    verticies[index++] = uvs.x1;
    verticies[index++] = uvs.y1;
    // color
    verticies[index++] = sprite.alpha;


    // xy
    verticies[index++] = w0;
    verticies[index++] = h0;

    verticies[index++] = sprite.position.x;
    verticies[index++] = sprite.position.y;

    //scale
    verticies[index++] = sprite.scale.x;
    verticies[index++] = sprite.scale.y;

    //rotation
    verticies[index++] = sprite.rotation;

    // uv
    verticies[index++] = uvs.x2;
    verticies[index++] = uvs.y2;
    // color
    verticies[index++] = sprite.alpha;




    // xy
    verticies[index++] = w1;
    verticies[index++] = h0;

    verticies[index++] = sprite.position.x;
    verticies[index++] = sprite.position.y;

    //scale
    verticies[index++] = sprite.scale.x;
    verticies[index++] = sprite.scale.y;

    //rotation
    verticies[index++] = sprite.rotation;

    // uv
    verticies[index++] = uvs.x3;
    verticies[index++] = uvs.y3;
    // color
    verticies[index++] = sprite.alpha;

    // increment the batchs
    this.currentBatchSize++;

    if (this.currentBatchSize >= this.size) {
      this.flush();
    }
  }

  void flush() {

    // If the batch is length 0 then return as there is nothing to draw
    if (this.currentBatchSize == 0) return;

    RenderingContext gl = this.gl;

    int id = WebGLRenderer._getIndexFirst(gl);

    // bind the current texture

    if (!this.currentBaseTexture._glTextures[id]) PIXI.createWebGLTexture(
        this.currentBaseTexture, gl);

    gl.bindTexture(TEXTURE_2D, this.currentBaseTexture._glTextures[id]
        );// || PIXI.createWebGLTexture(this.currentBaseTexture, gl));

    // upload the verts to the buffer


    if (this.currentBatchSize > (this.size * 0.5)) {
      gl.bufferSubData(ARRAY_BUFFER, 0, this.vertices);
    } else {
      Float32List view = new Float32List.fromList(this.vertices.getRange(0,
          this.currentBatchSize * 4 * this.vertSize));

      gl.bufferSubData(ARRAY_BUFFER, 0, view);
    }


    // now draw those suckas!
    gl.drawElements(TRIANGLES, this.currentBatchSize * 6, UNSIGNED_SHORT, 0);

    // then reset the batch!
    this.currentBatchSize = 0;

    // increment the draw count
    this.renderSession['drawCount']++;
  }


  void stop() {
    this.flush();
  }

  void start() {
    RenderingContext gl = this.gl;

    // bind the main texture
    gl.activeTexture(TEXTURE0);

    // bind the buffers
    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);

    // set the projection
    var projection = this.renderSession['projection'];
    gl.uniform2f(this.shader.projectionVector, projection.x, projection.y);

    // set the matrix
    gl.uniformMatrix3fv(this.shader.uMatrix, false, new Float32List.fromList(
        this.matrix.toList()));

    // set the pointers
    var stride = this.vertSize * 4;

    gl.vertexAttribPointer(this.shader.aVertexPosition, 2, FLOAT, false, stride,
        0);
    gl.vertexAttribPointer(this.shader.aPositionCoord, 2, FLOAT, false, stride,
        2 * 4);
    gl.vertexAttribPointer(this.shader.aScale, 2, FLOAT, false, stride, 4 * 4);
    gl.vertexAttribPointer(this.shader.aRotation, 1, FLOAT, false, stride, 6 * 4
        );
    gl.vertexAttribPointer(this.shader.aTextureCoord, 2, FLOAT, false, stride, 7
        * 4);
    gl.vertexAttribPointer(this.shader.colorAttribute, 1, FLOAT, false, stride,
        9 * 4);

    // set the blend mode..
    if (this.currentBlendMode != blendModes['NORMAL']) {
      this.setBlendMode(blendModes['NORMAL']);
    }
  }

  void setBlendMode(int blendMode) {
    this.flush();

    this.currentBlendMode = blendMode;

    var blendModeWebGL = blendModesWebGL[this.currentBlendMode];
    this.gl.blendFunc(blendModeWebGL[0], blendModeWebGL[1]);
  }

}

