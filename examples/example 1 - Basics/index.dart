import 'package:pixi/pixi.dart';
import 'dart:html';

void main(){

// create an new instance of a pixi stage
  Stage stage = new Stage(0x66FF99);

  // create a renderer instance
  Renderer renderer = autoDetectRenderer(400, 300);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);
  

  // create a texture from an image path
  Texture texture = new Texture.fromImage("bunny.png");

  // create a new Sprite using the texture
  Sprite bunny = new Sprite(texture);

  // center the sprites anchor point
  bunny.anchor.x = 0.5;
  bunny.anchor.y = 0.5;

  // move the sprite t the center of the screen
  bunny.position.x = 200.0;
  bunny.position.y = 150.0;

  stage.addChild(bunny);

  void animate(num _) {
      window.requestAnimationFrame(animate);

      // just for fun, let's rotate mr rabbit a little
      bunny.rotation += 0.1;

      // render the stage
      renderer.render(stage);
  }
  
  window.requestAnimationFrame(animate);

  
}