import 'package:pixi/pixi.dart';
import 'dart:html' hide Rectangle;
import 'dart:math' as Math hide Rectangle;

void main(){
  
  Renderer renderer = autoDetectRenderer(630, 410);
  renderer.view.style.position = "absolute";
  renderer.view.style.width = "${window.innerWidth}px";
  renderer.view.style.height = "${window.innerHeight}px";
  renderer.view.style.display = "block";
  
  // add render view to DOM
  document.body.append(renderer.view);

  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF, true);
  
  DisplayObjectContainer pondContainer = new DisplayObjectContainer();
  stage.addChild(pondContainer);

  stage.interactive = true;
  
  Sprite bg = new Sprite.fromImage("displacement_BG.jpg");
  pondContainer.addChild(bg);

  //var fish = PIXI.Sprite.fromImage("displacement_fish2.jpg");//
  //littleDudes.position.y = 100;
  double padding = 100.0;
  Rectangle bounds = new Rectangle(-padding, -padding, 630 + padding * 2, 410 + padding * 2);
  List<Sprite> fishs = [];
  List<Map<String,double>> fishsInfos = [];
  
  Math.Random random = new Math.Random();

  for (int i = 0; i < 20; i++) 
  {
    int fishId = i % 4;
    fishId += 1;

    //console.log("displacement_fish"+fishId+".png")
    Sprite fish =  new Sprite.fromImage("displacement_fish${fishId}.png");
    fish.anchor.x = fish.anchor.y = 0.5;
    pondContainer.addChild(fish);
    
    Map<String,double> fishInfo = {};
    //var direction 
    //var speed = 
    fishInfo["direction"] = random.nextDouble() * Math.PI * 2;
    fishInfo["speed"] = 2 + random.nextDouble() * 2;
    fishInfo["turnSpeed"] = random.nextDouble() - 0.8;

    fish.position.x = random.nextDouble() * bounds.width;
    fish.position.y = random.nextDouble() * bounds.height;
    //fish.speed = new PIXI.Point(0,0)

    fish.scale.x = fish.scale.y = 0.8 + random.nextDouble() * 0.3;
    fishs.add(fish);
    fishsInfos.add(fishInfo);

  };
  
  TilingSprite overlay = new TilingSprite(new Texture.fromImage("zeldaWaves.png"), 630.0, 410.0);
  overlay.alpha = 0.2;
  pondContainer.addChild(overlay);


  Texture displacementTexture = new Texture.fromImage("displacement_map.jpg");
  DisplacementFilter displacementFilter = new DisplacementFilter(displacementTexture);

  
  pondContainer.filters = [displacementFilter];

  

  displacementFilter.scale["x"] = 50;
  displacementFilter.scale["y"] = 50;

  

  
  
  
  
  double count = 0.0;
  bool switchy = false;
  
  /*
   * Add a pixi Logo!
   */
  Sprite logo = new Sprite.fromImage("../../logo_small.png");
  stage.addChild(logo);
  
  logo.anchor.x = 1.0;
  logo.anchor.y = 1.0;

  logo.position.x = 630.0;
  logo.scale.x = logo.scale.y = 0.5;
  logo.position.y = 400.0;
  logo.interactive = true;
  logo.buttonMode = true;
  
  logo.click = logo.tap = (InteractionData data)
  {
    window.open("https://github.com/GoodBoyDigital/pixi.js", "_blank");
  };
  

  void animate(num _) {
    
    count += 0.1;
    
    double blurAmount = Math.cos(count) ;
    double blurAmount2 = Math.sin(count * 0.8)  ;

    

    for (int i = 0; i < fishs.length; i++) 
    {
      Sprite fish = fishs[i];
      Map fishInfo = fishsInfos[i];

      fishInfo["direction"] += fishInfo["turnSpeed"] * 0.01;
      fish.position.x += Math.sin(fishInfo["direction"]) * fishInfo["speed"];
      fish.position.y += Math.cos(fishInfo["direction"]) * fishInfo["speed"];

      fish.rotation = -fishInfo["direction"] - Math.PI/2;

      // wrap..

      if(fish.position.x < bounds.x)fish.position.x += bounds.width;
      if(fish.position.x > bounds.x + bounds.width)fish.position.x -= bounds.width;

      if(fish.position.y < bounds.y)fish.position.y += bounds.height;
      if(fish.position.y > bounds.y + bounds.height)fish.position.y -= bounds.height;
    }

  
    displacementFilter.offset["x"] = count * 10;//blurAmount * 40;
    displacementFilter.offset["y"] = count * 10;
    
    overlay.tilePosition.x = count * -10;//blurAmount * 40;
    overlay.tilePosition.y = count * -10;
    
      renderer.render(stage);
      window.requestAnimationFrame( animate );
  }
  
  window.requestAnimationFrame(animate);
  
}
