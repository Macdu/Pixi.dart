import 'package:pixi/pixi.dart';
import 'dart:html';
import 'dart:math' as Math;

void main(){
  
  Renderer renderer = autoDetectRenderer(630, 410);
  
  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF, true);
  
  stage.interactive = true;
  
  Sprite bg = new Sprite.fromImage("depth_blur_BG.jpg");
  stage.addChild(bg);

  Sprite littleDudes = new Sprite.fromImage("depth_blur_dudes.jpg");
  littleDudes.position.y = 100.0;
  stage.addChild(littleDudes);

  Sprite littleRobot = new Sprite.fromImage("depth_blur_moby.jpg");
  littleRobot.position.x = 120.0;
  stage.addChild(littleRobot);

  BlurFilter blurFilter1 = new BlurFilter();
  BlurFilter blurFilter2 = new BlurFilter();
  
  littleDudes.filters = [blurFilter1];
  littleRobot.filters = [blurFilter2];

  // create a renderer instance
  renderer.view.style.position = "absolute";
  renderer.view.style.width = "${window.innerWidth}px";
  renderer.view.style.height = "${window.innerHeight}px";
  renderer.view.style.display = "block";
  
  // add render view to DOM
  document.body.append(renderer.view);
  
  
  
  double count = 0.0;
  bool switchy = false;
  
  stage.click = stage.tap = (_)
  {
    switchy = !switchy;
    
    if(!switchy)
    {
      //stage.filters = [filter];
    }
    else
    {
    //  stage.filters = null;
    }
    
  };
  
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
  
  logo.click = logo.tap = (_)
  {
    window.open("https://github.com/GoodBoyDigital/pixi.js", "_blank");
  };
  

  void animate(num _) {
    
    count += 0.01;
    
    double blurAmount = Math.cos(count) ;
    double blurAmount2 = Math.sin(count) ;


    blurFilter1.blur = 20 * (blurAmount);
    blurFilter2.blur = 20 * (blurAmount2);
      renderer.render(stage);
      window.requestAnimationFrame( animate );
  }
  
  window.requestAnimationFrame(animate);
  
}