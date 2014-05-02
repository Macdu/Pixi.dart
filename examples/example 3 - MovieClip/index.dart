import 'package:pixi/pixi.dart';
import 'dart:html';
import 'dart:math';

void main(){
  
  // create an array of assets to load
  List assetsToLoader = [ "SpriteSheet.json"];

  // create a new loader
  AssetLoader loader = new AssetLoader(assetsToLoader);

  // holder to store aliens
  List explosions = [];

  double count = 0.0;

  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF);

  // create a renderer instance.
  Renderer renderer = autoDetectRenderer(800, 600);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);


  void animate(num _) {
      renderer.render(stage);

      window.requestAnimationFrame(animate);
  }
  
  void onAssetsLoaded()
  {
    // create an array to store the textures
    List<Texture> explosionTextures = [];

    for (int i=0; i < 26; i++)
    {
      Texture texture = new Texture.fromFrame("Explosion_Sequence_A ${i+1}.png");
      explosionTextures.add(texture);
    };
    
    Random random = new Random();
    for (int i = 0; i < 50; i++)
    {
      // create an explosion MovieClip
      MovieClip explosion = new MovieClip(explosionTextures);

      explosion.position.x = random.nextDouble() * 800;
      explosion.position.y = random.nextDouble() * 600;
      explosion.anchor.x = 0.5;
      explosion.anchor.y = 0.5;

      explosion.rotation = random.nextDouble() * PI;
      explosion.scale.x = explosion.scale.y = 0.75 + random.nextDouble() * 0.5;

      explosion.gotoAndPlay(random.nextDouble() * 27);

      stage.addChild(explosion);
    }

    // start animating
    window.requestAnimationFrame( animate );
  }
  
  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();

  
}