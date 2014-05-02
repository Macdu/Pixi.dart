import 'package:pixi/pixi.dart';
import 'dart:html' hide EventTarget;
import 'dart:math' as Math;

void main(){

  // create an array of assets to load
  List assetsToLoader = [ "SpriteSheet.json"];

  // create a new loader
  AssetLoader loader = new AssetLoader(assetsToLoader);
  
  // holder to store aliens
  List<Sprite> aliens = [];
  
  List<String> alienFrames = ["eggHead.png", "flowerTop.png", "helmlok.png", "skully.png"];
  
  // create an empty container
  DisplayObjectContainer alienContainer = new DisplayObjectContainer();
  
  double count = 0.0;
  
  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF);

  // create a renderer instance.
  Renderer renderer = autoDetectRenderer(800, 600);
  
  void animate(num _) {
          // just for fun, lets rotate mr rabbit a little
          for (int i = 0; i < 100; i++)
        {
          Sprite alien = aliens[i];
          alien.rotation += 0.1;
        }

        count += 0.01;
        alienContainer.scale.x = Math.sin(count);
        alienContainer.scale.y = Math.sin(count);

        alienContainer.rotation += 0.01;
          
          // render the stage
          renderer.render(stage);

          window.requestAnimationFrame(animate);
      }
  
  
  void onAssetsLoaded()
    {
    
      Math.Random random = new Math.Random();
      // add a bunch of aliens with textures from image paths
      for (int i = 0; i < 100; i++)
      {
        String frameName = alienFrames[i % 4];

        // create an alien using the frame name..
        Sprite alien = new Sprite.fromFrame(frameName);
        alien.tint = (random.nextDouble() * 0xFFFFFF).toInt();

        /*
         * fun fact for the day :)
         * another way of doing the above would be
         * var texture = PIXI.Texture.fromFrame(frameName);
         * var alien = new PIXI.Sprite(texture);
         */
        alien.position.x = random.nextDouble() * 800 - 400;
        alien.position.y = random.nextDouble() * 600 - 300;
        alien.anchor.x = 0.5;
        alien.anchor.y = 0.5;
        aliens.add(alien);
        alienContainer.addChild(alien);
      }
      
      // start animating
      window.requestAnimationFrame(animate);
    }


  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();


  // add the renderer view element to the DOM
  document.body.append(renderer.view);

  alienContainer.position.x = 400.0;
  alienContainer.position.y = 300.0;

  stage.addChild(alienContainer);
  
}

  