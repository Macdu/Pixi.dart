import 'package:pixi/pixi.dart';
import 'dart:html' hide Rectangle;
import 'dart:math' as Math hide Rectangle;

void main(){
  int viewWidth = 630;
  int viewHeight = 410;

  // Create a pixi renderer
  Renderer renderer = autoDetectRenderer(viewWidth, viewHeight);
  renderer.view.className = "rendererView";
  
  // add render view to DOM
  document.body.append(renderer.view);

  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF);

  // create a background texture
  Texture pondFloorTexture = new Texture.fromImage("BGrotate.jpg");
  
  // create an array to store a refference to the dude in the pond
  List<Sprite> dudeArray = [];
  List<Map<String,double>> dudesInfos = [];
  Math.Random random = new Math.Random();
   
  int totaldude = 20;
  for (int i = 0; i < totaldude; i++) 
  {
    // create a new Sprite that uses the image name that we just generated as its source
    Sprite dude =  new Sprite.fromImage("eggHead.png");

    // set the anchor point so the the dude texture is centerd on the sprite
    dude.anchor.x = dude.anchor.y = 0.5;

    // set a random scale for the dude - no point them all being the same size!
    dude.scale.x = dude.scale.y = 0.8 + random.nextDouble() * 0.3;
    
    // finally let's set the dude to be a random position..
    dude.position.x = random.nextDouble() * viewWidth;
    dude.position.y = random.nextDouble() * viewHeight;
    
    dude.tint = (random.nextDouble() * 0xFFFFFF).toInt();
  
    // time to add the dude to the pond container!
    stage.addChild(dude);

    Map<String,double> dudeInfos = {};
    // create some extra properties that will control movement
    // create a random direction in radians. This is a number between 0 and PI*2 which is the equivalent of 0 - 360 degrees
    dudeInfos['direction'] = random.nextDouble() * Math.PI * 2;

    // this number will be used to modify the direction of the dude over time
    dudeInfos["turningSpeed"] = random.nextDouble() - 0.8;

    // create a random speed for the dude between 0 - 2
    dudeInfos['speed'] = 2 + random.nextDouble() * 2; 

    // finally we push the dude into the dudeArray so it it can be easily accessed later
    dudeArray.add(dude);
    dudesInfos.add(dudeInfos);
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
    // iterate through the dude and update the positiond
    for (int i = 0; i < dudeArray.length; i++) 
        {
          Sprite dude = dudeArray[i];
          Map<String,double> dudeInfos = dudesInfos[i];
          dudeInfos['direction'] += dudeInfos['turningSpeed'] * 0.01;
          dude.position.x += Math.sin(dudeInfos['direction']) * dudeInfos['speed'];
          dude.position.y += Math.cos(dudeInfos['direction']) * dudeInfos['speed'];
          dude.rotation = -dudeInfos['direction'] - Math.PI / 2;

          // wrap the dudes by testing there bounds..
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
    
    // time to render the state!
      renderer.render(stage);
      
      // request another animation frame..
      window.requestAnimationFrame(animate);
  }
  
  window.requestAnimationFrame(animate);
}
