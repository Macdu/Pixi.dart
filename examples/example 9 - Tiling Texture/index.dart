import 'package:pixi/pixi.dart';
import 'dart:html';
import 'dart:math' as Math;

void main(){

  // create an new instance of a pixi stage
  Stage stage = new Stage(0x97C56E, false);

  // create a renderer instance
  Renderer renderer = autoDetectRenderer(window.innerWidth, window.innerHeight);

  // add the renderer view element to the DOM
  renderer.view.style.position = "absolute";
  renderer.view.style.top = "0px";
  renderer.view.style.left = "0px";
  document.body.append(renderer.view);

  // create a texture from an image path
  Texture texture = new Texture.fromImage("p2.jpeg");

  // create a tiling sprite ...
  // requires a texture, width and height
  // to work in webGL the texture size must be a power of two
  TilingSprite tilingSprite = new TilingSprite(texture, window.innerWidth.toDouble(), window.innerHeight.toDouble());
  stage.addChild(tilingSprite);

  double count = 0.0;
  void animate(num _) {
    count += 0.005;

    tilingSprite.tileScale.x = 2 + Math.sin(count);
    tilingSprite.tileScale.y = 2 + Math.cos(count);

    tilingSprite.tilePosition.x += 1;
    tilingSprite.tilePosition.y += 1;

      // render the stage
      renderer.render(stage);
      
      window.requestAnimationFrame(animate);
  }

  window.requestAnimationFrame(animate);
  
}