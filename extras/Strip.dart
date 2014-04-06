part of pixi;
/**
 * @author Mat Groves http://matgroves.com/
 */

/**
 * 
 * @class Strip
 * @extends DisplayObjectContainer
 * @constructor
 * @param texture {Texture} The texture to use
 * @param width {Number} the width 
 * @param height {Number} the height
 * 
 */
class Strip extends DisplayObjectContainer {

  int blendMode;

  Float32List uvs, verticies, colors;
  Uint16List indices;

  double width;

  double height;

  Texture texture;

  bool updateFrame = false;

  Strip(Texture texture, [double this.width = null, double this.height = null]) {

    this.texture = texture;
    this.blendMode = blendModes['NORMAL'];

    this.uvs = new Float32List.fromList([0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0]);

    this.verticies = new Float32List.fromList([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);

    this.colors = new Float32List.fromList([1.0, 1.0, 1.0, 1.0]);

    this.indices = new Uint16List.fromList([0, 1, 2, 3]);


    if (texture.baseTexture.hasLoaded) {
      this.width = this.texture.frame.width;
      this.height = this.texture.frame.height;
      this.updateFrame = true;
    } else {
      this.texture.stream('update').listen(this.onTextureUpdate);
    }

    this.renderable = true;
  }


  /*
    this.uvs = new Float32Array()
    this.verticies = new Float32Array()
    this.colors = new Float32Array()
    this.indices = new Uint16Array()
    */


  // load the texture!


  /*
   * Sets the texture that the Strip will use 
   *
   * @method setTexture
   * @param texture {Texture} the texture that will be used
   * @private
   */
  void setTexture(Texture texture) {
    //TODO SET THE TEXTURES
    //TODO VISIBILITY

    // stop current texture
    this.texture = texture;
    this.width = texture.frame.width;
    this.height = texture.frame.height;
    this.updateFrame = true;
  }

  /**
   * When the texture is updated, this event will fire to update the scale and frame
   *
   * @method onTextureUpdate
   * @param event
   * @private
   */
  void onTextureUpdate(_) {
    this.updateFrame = true;
  }

}
