import 'package:pixi/pixi.dart';
import 'dart:html' hide Point;
import'dart:math' as Math;

void main(){

  // create an new instance of a pixi stage
  Stage stage = new Stage(0x000000);

  // create a renderer instance
  Renderer renderer = autoDetectRenderer(800, 600);

  // set the canvas width and height to fill the screen
  renderer.view.style.width = window.innerWidth.toString() + "px";
  renderer.view.style.height = window.innerHeight.toString() + "px";
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);

  // OOH! SHINY!
  // create two render textures.. these dynamic textures will be used to draw the scene into itself
  RenderTexture renderTexture = new RenderTexture(800, 600);
  RenderTexture renderTexture2 = new RenderTexture(800, 600);
  RenderTexture currentTexture = renderTexture;

  // create a new sprite that uses the render texture we created above
  Sprite outputSprite = new Sprite(currentTexture);

  // align the sprite
  outputSprite.position.x = 800 / 2;
  outputSprite.position.y = 600 / 2;
  outputSprite.anchor.x = 0.5;
  outputSprite.anchor.y = 0.5;

  // add to stage
  stage.addChild(outputSprite);

  DisplayObjectContainer stuffContainer = new DisplayObjectContainer();

  stuffContainer.position.x = 800 / 2;
  stuffContainer.position.y = 600 / 2;

  stage.addChild(stuffContainer);

  // create an array of image ids..
  List<String> fruits = ["spinObj_01.png", "spinObj_02.png",
          "spinObj_03.png", "spinObj_04.png",
          "spinObj_05.png", "spinObj_06.png",
          "spinObj_07.png", "spinObj_08.png"];

  // create an array of items
  List items = [];

  Math.Random random = new Math.Random();
  // now create some items and randomly position them in the stuff container
  for (int i=0; i < 20; i++)
  {
    Sprite item = new Sprite.fromImage(fruits[i % fruits.length]);
    item.position.x = random.nextDouble() * 400 - 200;
    item.position.y = random.nextDouble() * 400 - 200;

    item.anchor.x = 0.5;
    item.anchor.y = 0.5;

    stuffContainer.addChild(item);

    items.add(item);
  };

  // used for spinning!
  double count = 0.0;

  void animate(num _) {

      window.requestAnimationFrame( animate );

    for (int i = 0; i < items.length; i++)
    {
      // rotate each item
      Sprite item = items[i];
      item.rotation += 0.1;
    };

    count += 0.01;

    // swap the buffers..
    RenderTexture temp = renderTexture;
    renderTexture = renderTexture2;
    renderTexture2 = temp;

    // set the new texture
    outputSprite.setTexture(renderTexture);

    // twist this up!
    stuffContainer.rotation -= 0.01;
    outputSprite.scale.x = outputSprite.scale.y = 1 + Math.sin(count) * 0.2;

    // render the stage to the texture
    // the true clears the texture before content is rendered
    renderTexture2.render(stage, new Point(0.0,0.0), true);

    // and finally render the stage
      renderer.render(stage);
  }
  
  window.requestAnimationFrame(animate);
  
}
