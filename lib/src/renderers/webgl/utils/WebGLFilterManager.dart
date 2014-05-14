part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

class WebGLFilterManager {


  bool transparent;

  List filterStack = [];

  int offsetX = 0;
  int offsetY = 0;

  RenderingContext gl;
  List<FilterTexture> texturePool;

  RenderSession renderSession;
  var defaultShader;

  double width;
  double height;

  Framebuffer buffer;

  Buffer vertexBuffer;
  Buffer uvBuffer;
  Buffer colorBuffer;
  Buffer indexBuffer;


  // bind and upload the vertexs..
  // keep a reference to the vertexFloatData..
  Float32List vertexArray;


  // bind and upload the uv buffer
  Float32List uvArray;

  Float32List colorArray;

  /**
* @class WebGLFilterManager
* @constructor
* @param gl {WebGLContext} the current WebGL drawing context
* @param transparent {Boolean} Whether or not the drawing context should be transparent
* @private
*/
  WebGLFilterManager(gl, transparent) {
    this.transparent = transparent;

    this.setContext(gl);
  }

  // API
  /**
* Initialises the context and the properties
* @method setContext 
* @param gl {WebGLContext} the current WebGL drawing context
*/
  void setContext(RenderingContext gl) {
    this.gl = gl;
    this.texturePool = [];

    this.initShaderBuffers();
  }

  /**
* 
* @method begin
* @param renderSession {RenderSession} 
* @param buffer {ArrayBuffer} 
*/
  void begin(RenderSession renderSession, Framebuffer buffer) {
    this.renderSession = renderSession;
    this.defaultShader = renderSession.shaderManager.defaultShader;

    Point projection = this.renderSession.projection;

    this.width = projection.x * 2;
    this.height = -projection.y * 2;
    this.buffer = buffer;
  }

  /**
* Applies the filter and adds it to the current filter stack
* @method pushFilter
* @param filterBlock {Object} the filter that will be pushed to the current filter stack
*/
  void pushFilter(Map filterBlock) {
    gl = this.gl;

    Point projection = this.renderSession.projection;
    Point offset = this.renderSession.offset;


    // filter program
    // OPTIMISATION - the first filter is free if its a simple color change?
    this.filterStack.add(filterBlock);

    var filter = filterBlock['filterPasses'][0];

    this.offsetX += filterBlock['target'].filterArea.x.toInt();
    this.offsetY += filterBlock['target'].filterArea.y.toInt();

    FilterTexture texture = (this.texturePool.length > 0) ? this.texturePool.removeLast() : null;
    if (texture == null) {
      texture = new FilterTexture(this.gl, this.width, this.height);
    } else {
      texture.resize(this.width, this.height);
    }

    gl.bindTexture(TEXTURE_2D, texture.texture);

    filterBlock['target'].filterArea = filterBlock['target'].getBounds();

    Rectangle filterArea = filterBlock['target'].filterArea;

    double padding = filter.padding;
    filterArea.x -= padding;
    filterArea.y -= padding;
    filterArea.width += padding * 2;
    filterArea.height += padding * 2;

    // cap filter to screen size..
    if (filterArea.x < 0) filterArea.x = 0.0;
    if (filterArea.width > this.width) filterArea.width = this.width;
    if (filterArea.y < 0) filterArea.y = 0.0;
    if (filterArea.height > this.height) filterArea.height = this.height;

    //gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA,  filterArea.width, filterArea.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.bindFramebuffer(FRAMEBUFFER, texture.frameBuffer);

    // set view port
    gl.viewport(0, 0, filterArea.width.toInt(), filterArea.height.toInt());

    projection.x = filterArea.width / 2;
    projection.y = -filterArea.height / 2;

    offset.x = -filterArea.x;
    offset.y = -filterArea.y;

    // update projection
    gl.uniform2f(this.defaultShader.projectionVector, filterArea.width / 2,
        -filterArea.height / 2);
    gl.uniform2f(this.defaultShader.offsetVector, -filterArea.x, -filterArea.y);

    gl.colorMask(true, true, true, true);
    gl.clearColor(0, 0, 0, 0);
    gl.clear(COLOR_BUFFER_BIT);

    filterBlock['_glFilterTexture'] = texture;

  }


  /**
* Removes the last filter from the filter stack and doesn't return it
* @method popFilter
*/
  void popFilter() {
    RenderingContext gl = this.gl;
    Map filterBlock = this.filterStack.removeLast();
    Rectangle filterArea = filterBlock['target'].filterArea;
    FilterTexture texture = filterBlock['_glFilterTexture'];
    Point projection = this.renderSession.projection;
    Point offset = this.renderSession.offset;

    if (filterBlock['filterPasses'].length > 1) {
      gl.viewport(0, 0, filterArea.width.toInt(), filterArea.height.toInt());

      gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);

      this.vertexArray[0] = 0.0;
      this.vertexArray[1] = filterArea.height;

      this.vertexArray[2] = filterArea.width;
      this.vertexArray[3] = filterArea.height;

      this.vertexArray[4] = 0.0;
      this.vertexArray[5] = 0.0;

      this.vertexArray[6] = filterArea.width;
      this.vertexArray[7] = 0.0;

      gl.bufferSubData(ARRAY_BUFFER, 0, this.vertexArray);

      gl.bindBuffer(ARRAY_BUFFER, this.uvBuffer);
      // now set the uvs..
      this.uvArray[2] = filterArea.width / this.width;
      this.uvArray[5] = filterArea.height / this.height;
      this.uvArray[6] = filterArea.width / this.width;
      this.uvArray[7] = filterArea.height / this.height;

      gl.bufferSubData(ARRAY_BUFFER, 0, this.uvArray);

      FilterTexture inputTexture = texture;
      FilterTexture outputTexture = (this.texturePool.length > 0) ? this.texturePool.removeLast() : null;
      if (outputTexture == null) outputTexture = new FilterTexture(this.gl,
          this.width, this.height);

      // need to clear this FBO as it may have some left over elements from a previous filter.
      gl.bindFramebuffer(FRAMEBUFFER, outputTexture.frameBuffer);
      gl.clear(COLOR_BUFFER_BIT);

      gl.disable(BLEND);

      for (int i = 0; i < filterBlock['filterPasses'].length - 1; i++) {
        var filterPass = filterBlock['filterPasses'][i];

        gl.bindFramebuffer(FRAMEBUFFER, outputTexture.frameBuffer);

        // set texture
        gl.activeTexture(TEXTURE0);
        gl.bindTexture(TEXTURE_2D, inputTexture.texture);

        // draw texture..
        //filterPass.applyFilterPass(filterArea.width, filterArea.height);
        this.applyFilterPass(filterPass, filterArea, filterArea.width.toInt(),
            filterArea.height.toInt());

        // swap the textures..
        FilterTexture temp = inputTexture;
        inputTexture = outputTexture;
        outputTexture = temp;
      }

      gl.enable(BLEND);

      texture = inputTexture;
      this.texturePool.add(outputTexture);
    }

    var filter = filterBlock['filterPasses'][filterBlock['filterPasses'].length - 1];

    this.offsetX -= filterArea.x.toInt();
    this.offsetY -= filterArea.y.toInt();


    int sizeX = this.width.toInt();
    int sizeY = this.height.toInt();

    double offsetX = 0.0;
    double offsetY = 0.0;

    Framebuffer buffer = this.buffer;

    // time to render the filters texture to the previous scene
    if (this.filterStack.length == 0) {
      gl.colorMask(true, true, true, this.transparent);
    } else {
      var currentFilter = this.filterStack[this.filterStack.length - 1];
      filterArea = currentFilter.target.filterArea;

      sizeX = filterArea.width.toInt();
      sizeY = filterArea.height.toInt();

      offsetX = filterArea.x;
      offsetY = filterArea.y;

      buffer = currentFilter._glFilterTexture.frameBuffer;
    }



    // TODO need toremove thease global elements..
    projection.x = sizeX / 2;
    projection.y = -sizeY / 2;

    offset.x = offsetX;
    offset.y = offsetY;

    filterArea = filterBlock['target'].filterArea;

    var x = filterArea.x - offsetX;
    var y = filterArea.y - offsetY;

    // update the buffers..
    // make sure to flip the y!
    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);

    this.vertexArray[0] = x;
    this.vertexArray[1] = y + filterArea.height;

    this.vertexArray[2] = x + filterArea.width;
    this.vertexArray[3] = y + filterArea.height;

    this.vertexArray[4] = x;
    this.vertexArray[5] = y;

    this.vertexArray[6] = x + filterArea.width;
    this.vertexArray[7] = y;

    gl.bufferSubData(ARRAY_BUFFER, 0, this.vertexArray);

    gl.bindBuffer(ARRAY_BUFFER, this.uvBuffer);

    this.uvArray[2] = filterArea.width / this.width;
    this.uvArray[5] = filterArea.height / this.height;
    this.uvArray[6] = filterArea.width / this.width;
    this.uvArray[7] = filterArea.height / this.height;

    gl.bufferSubData(ARRAY_BUFFER, 0, this.uvArray);

    gl.viewport(0, 0, sizeX, sizeY);
    // bind the buffer
    gl.bindFramebuffer(FRAMEBUFFER, buffer);

    // set the blend mode!
    //gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA)

    // set texture
    gl.activeTexture(TEXTURE0);
    gl.bindTexture(TEXTURE_2D, texture.texture);

    // apply!
    this.applyFilterPass(filter, filterArea, sizeX, sizeY);

    // now restore the regular shader..
    gl.useProgram(this.defaultShader.program);
    gl.uniform2f(this.defaultShader.projectionVector, sizeX / 2, -sizeY / 2);
    gl.uniform2f(this.defaultShader.offsetVector, -offsetX, -offsetY);

    // return the texture to the pool
    this.texturePool.add(texture);
    filterBlock['_glFilterTexture'] = null;
  }


  /**
* Applies the filter to the specified area
* @method applyFilterPass
* @param filter {AbstractFilter} the filter that needs to be applied
* @param filterArea {texture} TODO - might need an update
* @param width {Number} the horizontal range of the filter
* @param height {Number} the vertical range of the filter
*/
  void applyFilterPass(AbstractFilter filter, Rectangle filterArea, int width, int
      height) {
    // use program
    RenderingContext gl = this.gl;
    PixiShader shader = (filter.shaders.length > 0) ? filter.shaders[WebGLRenderer._getIndexFirst(gl)] : null;

    if (shader == null) {
      shader = new PixiShader(gl);

      shader.fragmentSrc = filter.fragmentSrc;
      shader.uniforms = filter.uniforms;
      shader.init();

      if(filter.shaders.length <= WebGLRenderer._getIndexFirst(gl)){
        filter.shaders.add(shader);
      }else filter.shaders[WebGLRenderer._getIndexFirst(gl)] = shader;
    }

    // set the shader
    gl.useProgram(shader.program);

    gl.uniform2f(shader.projectionVector, width / 2, -height / 2);
    gl.uniform2f(shader.offsetVector, 0, 0);

    if (filter.uniforms['dimensions'] != null) {
      filter.uniforms['dimensions']['value'][0] = this.width;//width;
      filter.uniforms['dimensions']['value'][1] = this.height;//height;
      filter.uniforms['dimensions']['value'][2] = this.vertexArray[0];
      filter.uniforms['dimensions']['value'][3] =
          this.vertexArray[5];//filterArea.height;
    }

    shader.syncUniforms();

    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 0, 0);

    gl.bindBuffer(ARRAY_BUFFER, this.uvBuffer);
    gl.vertexAttribPointer(shader.aTextureCoord, 2, FLOAT, false, 0, 0);

    gl.bindBuffer(ARRAY_BUFFER, this.colorBuffer);
    gl.vertexAttribPointer(shader.colorAttribute, 2, FLOAT, false, 0, 0);

    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);

    // draw the filter...
    gl.drawElements(TRIANGLES, 6, UNSIGNED_SHORT, 0);

    this.renderSession.drawCount++;
  }

  /**
* Initialises the shader buffers
* @method initShaderBuffers
*/
  void initShaderBuffers() {
    RenderingContext gl = this.gl;

    // create some buffers
    this.vertexBuffer = gl.createBuffer();
    this.uvBuffer = gl.createBuffer();
    this.colorBuffer = gl.createBuffer();
    this.indexBuffer = gl.createBuffer();


    // bind and upload the vertexs..
    // keep a reference to the vertexFloatData..
    this.vertexArray = new Float32List.fromList([0.0, 0.0, 1.0, 0.0, 0.0, 1.0,
        1.0, 1.0]);

    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.bufferData(ARRAY_BUFFER, this.vertexArray, STATIC_DRAW);


    // bind and upload the uv buffer
    this.uvArray = new Float32List.fromList([0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0,
        1.0]);

    gl.bindBuffer(ARRAY_BUFFER, this.uvBuffer);
    gl.bufferData(ARRAY_BUFFER, this.uvArray, STATIC_DRAW);

    this.colorArray = new Float32List.fromList([1.0, 0xFFFFFF.toDouble(), 1.0, 0xFFFFFF.toDouble(),
        1.0, 0xFFFFFF.toDouble(), 1.0, 0xFFFFFF.toDouble()]);

    gl.bindBuffer(ARRAY_BUFFER, this.colorBuffer);
    gl.bufferData(ARRAY_BUFFER, this.colorArray, STATIC_DRAW);

    // bind and upload the index
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, new Uint16List.fromList([0, 1, 2, 1, 3,
        2]), STATIC_DRAW);
  }

  /**
* Destroys the filter and removes it from the filter stack
* @method destroy
*/
  void destroy() {
    var gl = this.gl;

    this.filterStack = null;

    this.offsetX = 0;
    this.offsetY = 0;

    // destroy textures
    for (int i = 0; i < this.texturePool.length; i++) {
      this.texturePool[i].destroy();
    }

    this.texturePool = null;

    //destroy buffers..
    gl.deleteBuffer(this.vertexBuffer);
    gl.deleteBuffer(this.uvBuffer);
    gl.deleteBuffer(this.colorBuffer);
    gl.deleteBuffer(this.indexBuffer);
  }

}
