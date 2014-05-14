import 'package:pixi/pixi.dart';
import 'dart:html' hide Text;
import 'dart:math' as Math;

void main(){
  
  Renderer renderer = autoDetectRenderer(620, 380);
  
  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF, true);
  
  stage.interactive = true;
  
  Sprite bg = new Sprite.fromImage("BGrotate.jpg");
  bg.anchor.x = 0.5;
  bg.anchor.y = 0.5;
   
  bg.position.x = 620 / 2;
  bg.position.y = 380 / 2;
  
  List colorMatrix =  [1,0,0,0,
            0,1,0,0,
            0,0,1,0,
            0,0,0,1];
            
  ColorMatrixFilter filter = new ColorMatrixFilter();
  
  DisplayObjectContainer container = new DisplayObjectContainer();
  container.position.x = 620 / 2;
  container.position.y = 380 / 2;
  
  Sprite bgFront = new Sprite.fromImage("SceneRotate.jpg");
  bgFront.anchor.x = 0.5;
  bgFront.anchor.y = 0.5;
   
  container.addChild(bgFront);
  
  Sprite light2 = new Sprite.fromImage("LightRotate2.png");
  light2.anchor.x = 0.5;
  light2.anchor.y = 0.5;
  container.addChild(light2);
  
  Sprite light1 = new Sprite.fromImage("LightRotate1.png");
  light1.anchor.x = 0.5;
  light1.anchor.y = 0.5;
  container.addChild(light1);
  
  Sprite panda =  new Sprite.fromImage("panda.png");
  panda.anchor.x = 0.5;
  panda.anchor.y = 0.5;
  
  container.addChild(panda);
  
  stage.addChild(container);
  
  // create a renderer instance
  renderer.view.style.position = "absolute";
  renderer.view.style.width = "${window.innerWidth}px";
  renderer.view.style.height = "${window.innerHeight}px";
  renderer.view.style.display = "block";
  
  // add render view to DOM
  document.body.append(renderer.view);
  
  stage.filters = [filter];
  
  double count = 0.0;
  bool switchy = false;
  
  stage.click = stage.tap = (InteractionData data)
  {
    switchy = !switchy;
    
    if(!switchy)
    {
      stage.filters = [filter];
    }
    else
    {
      stage.filters = null;
    }
  };
  
  // Add a pixi Logo!
  Sprite logo = new Sprite.fromImage("../../logo_small.png");
  
  logo.anchor.x = 1.0;
  logo.position.x = 620.0;
  logo.scale.x = logo.scale.y = 0.5;
  logo.position.y = 320.0;
  logo.interactive = true;
  logo.buttonMode = true;
  
  logo.click = logo.tap = (InteractionData data)
  {
    window.open("https://github.com/GoodBoyDigital/pixi.js", "_blank");
  };
  
  Text help = new Text("Click to turn filters on / off.", { 'font': "bold 12pt Arial", 'fill': "white" });
  help.position.y = 350.0;
  help.position.x = 10.0;
  stage.addChild(help);
  
  void animate(num _) {
    bg.rotation += 0.01;
    bgFront.rotation -= 0.01;
    
    light1.rotation += 0.02;
    light2.rotation += 0.01;

    panda.scale.x = 1 + Math.sin(count) * 0.04;
    panda.scale.y = 1 + Math.cos(count) * 0.04;
    
    count += 0.1;
    
    colorMatrix[1] = Math.sin(count) * 3;
    colorMatrix[2] = Math.cos(count);
    colorMatrix[3] = Math.cos(count) * 1.5;
    colorMatrix[4] = Math.sin(count / 3) * 2;
    colorMatrix[5] = Math.sin(count / 2);
    colorMatrix[6] = Math.sin(count / 4);
    filter.matrix = colorMatrix;

      renderer.render(stage);
      window.requestAnimationFrame(animate);
  }

  window.requestAnimationFrame(animate);
  
}