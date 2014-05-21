import 'package:pixi/Pixi.dart';
import 'dart:html' hide Rectangle;
import 'dart:math' as Math hide Rectangle;

void main(){
  int viewWidth = 800;
  int viewHeight = 600;

  // Create a pixi renderer
  Renderer renderer = autoDetectRenderer(viewWidth, viewHeight);
  renderer.view.className = "rendererView";
  
  // add render view to DOM
  document.body.append(renderer.view);

  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF);
  
  SpriteBatch sprites = new SpriteBatch();
  stage.addChild(sprites);
  
  List<int> tints = [0xFFFFFF, 0xFFFBEE, 0xFFEEEE, 0xFADEED, 0xE8D4CD];

  // create an array to store a refference to the fish in the pond
  List<Sprite> dudeArray = [];
  List<Map<String,double>> dudesInfos = [];
  Math.Random random = new Math.Random();

  int totalDudes = renderer is WebGLRenderer ? 10000 : 100;
  for (int i = 0; i < totalDudes; i++) 
  {
    // create a new Sprite that uses the image name that we just generated as its source
    Sprite dude =  new Sprite.fromImage("tinyMaggot.png");

    dude.tint = (random.nextDouble() * 0xE8D4CD).toInt();

    // set the anchor point so the the dude texture is centerd on the sprite
    dude.anchor.x = dude.anchor.y = 0.5;

    // set a random scale for the dude - no point them all being the same size!
    dude.scale.x = dude.scale.y = 0.8 + random.nextDouble() * 0.3;
    
    // finally lets set the dude to be a random position..
    dude.x = random.nextDouble() * viewWidth;
    dude.y = random.nextDouble() * viewHeight;

    // create some extra properties that will control movement
    dude.tint = (random.nextDouble() * 0x808080).toInt();

    Map<String,double> dudeInfos = {};
    // create a random direction in radians. This is a number between 0 and PI*2 which is the equivalent of 0 - 360 degrees
    dudeInfos['direction'] = random.nextDouble() * Math.PI * 2;

    // this number will be used to modify the direction of the dude over time
    dudeInfos['turningSpeed'] = random.nextDouble() - 0.8;

    // create a random speed for the dude between 0 - 2
    dudeInfos['speed'] = (2 + random.nextDouble() * 2) * 0.2; 

    dudeInfos['offset'] = random.nextDouble() * 100;

    // finally we push the dude into the dudeArray so it it can be easily accessed later
    dudeArray.add(dude);
    dudesInfos.add(dudeInfos);

    sprites.addChild(dude);
  }

  // create a bounding box box for the little dudes 
  double dudeBoundsPadding = 100.0;
  Rectangle dudeBounds = new Rectangle(-dudeBoundsPadding,
                    -dudeBoundsPadding, 
                    viewWidth + dudeBoundsPadding * 2, 
                    viewHeight + dudeBoundsPadding * 2);

  double tick = 0.0;
  void animate(num _) 
  {
    // iterate through the dude and update the position
    for (int i = 0; i < dudeArray.length; i++) 
    {
      Sprite dude = dudeArray[i];
      Map<String,double> dudeInfos = dudesInfos[i];
      dude.scale.y = 0.95 + Math.sin(tick + dudeInfos['offset']) * 0.05;
      dudeInfos['direction'] += dudeInfos['turningSpeed'] * 0.01;
      dude.position.x += Math.sin(dudeInfos['direction']) * (dudeInfos['speed'] * dude.scale.y);
      dude.position.y += Math.cos(dudeInfos['direction']) * (dudeInfos['speed'] * dude.scale.y);
      dude.rotation = -dudeInfos['direction'] + Math.PI;

      // wrap the dudes by testing their bounds..
      if (dude.position.x < dudeBounds.x)
        dude.position.x += dudeBounds.width;
      else if (dude.position.x > dudeBounds.x + dudeBounds.width)
        dude.position.x -= dudeBounds.width;
      
      if (dude.position.y < dudeBounds.y)
        dude.position.y += dudeBounds.height;
      else if (dude.position.y > dudeBounds.y + dudeBounds.height)
        dude.position.y -= dudeBounds.height;
    }
    
    // increment the ticker
    tick += 0.1;
    
    // time to render the stage !
      renderer.render(stage);
      
      // request another animation frame..
      window.requestAnimationFrame(animate);
  }

  window.requestAnimationFrame(animate);
  
}