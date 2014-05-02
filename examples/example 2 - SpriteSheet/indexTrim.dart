import 'package:pixi/pixi.dart';
import 'dart:html';

void main(){
  // create an array of assets to load
  List assetsToLoader = [ "fighter.json"];

  // create a new loader
  AssetLoader loader = new AssetLoader(assetsToLoader);
  
  MovieClip movie;
  
  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF);

  // create a renderer instance.
  Renderer renderer = new CanvasRenderer(800, 600);
  
  void animate(num _) {
    movie.rotation += 0.01;
      
      // render the stage
      renderer.render(stage);

      window.requestAnimationFrame(animate);
  }
  
  void onAssetsLoaded()
    {
      // create a texture from an image path
      // add a bunch of aliens
      List<Texture> frames = [];

      for (int i = 0; i < 30; i++) {
        String val = i < 10 ? "0$i" : "$i";
        frames.add(new Texture.fromFrame("rollSequence00" + val + ".png"));
      };

      movie = new MovieClip(frames);

      movie.position.x = 300.0;
      movie.position.y = 300.0;

      movie.anchor.x = movie.anchor.y =  0.5;
      movie.play();
      movie.animationSpeed = 0.5;
      stage.addChild(movie);
      
      // start animating
      window.requestAnimationFrame(animate);
    }


  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();

  // holder to store aliens
  List aliens = [];

  double count = 0.0;


  // add the renderer view element to the DOM
  document.body.append(renderer.view);

  // create an empty container
  DisplayObjectContainer alienContainer = new DisplayObjectContainer();
  alienContainer.position.x = 400.0;
  alienContainer.position.y = 300.0;

  stage.addChild(alienContainer);

}