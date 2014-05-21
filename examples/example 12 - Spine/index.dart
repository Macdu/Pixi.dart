import 'package:pixi/pixi.dart';
import 'dart:html';

void main(){


  // create an array of assets to load

  List<String> assetsToLoader = ["data/spineboy.json", "data/spineboySpineData.json"];

  // create a new loader
  AssetLoader loader = new AssetLoader(assetsToLoader);
  
  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF, true);

  // create a renderer instance
  Renderer renderer = autoDetectRenderer(window.innerWidth, window.innerHeight);
  
  void onAssetsLoaded()
  {
    // create a spine boy
    var spineBoy = new Spine("data/spineboySpineData.json");

    // set the position
    spineBoy.position.x = window.innerWidth/2;
    spineBoy.position.y = window.innerHeight;

    spineBoy.scale.x = spineBoy.scale.y = window.innerHeight / 400;

    // set up the mixes!
    spineBoy.stateData.setMixByName("walk", "jump", 0.2);
    spineBoy.stateData.setMixByName("jump", "walk", 0.4);

    // play animation
    spineBoy.state.setAnimationByName("walk", true);


    stage.addChild(spineBoy);

    stage.click = (InteractionData data)
    {
      spineBoy.state.setAnimationByName("jump", false);
      spineBoy.state.addAnimationByName("walk", true);

    };

    Sprite logo = new Sprite.fromImage("../../logo_small.png");
    stage.addChild(logo);


    logo.anchor.x = 1.0;
    logo.position.x = window.innerWidth.toDouble();
    logo.scale.x = logo.scale.y = 0.5;
    logo.position.y = (window.innerHeight - 70).toDouble();
    logo.interactive = true;
    logo.buttonMode = true;
    logo.click = logo.tap = (InteractionData data)
    {
      window.open("https://github.com/GoodBoyDigital/pixi.js", "_blank");
    };
  }

  // use callback
  loader.onComplete = onAssetsLoaded;

  //begin load
  loader.load();


  // set the canvas width and height to fill the screen
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);


  void animate(num _) {

      window.requestAnimationFrame( animate );
      renderer.render(stage);
  }

  window.requestAnimationFrame(animate);
  
}

