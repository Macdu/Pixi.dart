import 'package:pixi/pixi.dart';
import 'dart:html' hide Text;
import 'dart:math' as Math;

void main(){

  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF, true);

  stage.interactive = true;

  Sprite bg = new Sprite.fromImage("BGrotate.jpg");
  bg.anchor.x = 0.5;
  bg.anchor.y = 0.5;

  bg.position.x = 620 / 2;
  bg.position.y = 380 / 2;

  stage.addChild(bg);

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
  Renderer renderer = autoDetectRenderer(620, 380);

  renderer.view.style.position = "absolute";
  renderer.view.style.marginLeft = "-310px";
  renderer.view.style.marginTop = "-190px";
  renderer.view.style.top = "50%";
  renderer.view.style.left = "50%";
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);

  // lets create moving shape
  Graphics thing = new Graphics();
  stage.addChild(thing);
  thing.position.x = 620 / 2;
  thing.position.y = 380 / 2;
  thing.lineStyle(0,0x000000,0.0);

  container.mask = thing;
  container.interactive = true;

  double count = 0.0;

  stage.click = stage.tap = (InteractionData data)
  {
    if(container.mask == null)
    {
      container.mask = thing;
      //runList(stage);
    }
    else
    {
      container.mask = null;
    }
  };

  /*
   * Add a pixi Logo!
   */
  Sprite logo = new Sprite.fromImage("../../logo_small.png");
  stage.addChild(logo);

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

  Text help = new Text("Click to turn masking on / off.", {'font':"bold 12pt Arial", 'fill':"white"});
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

    thing.clear();

    thing.beginFill(0x8bc5ff, 0.4);
    thing.moveTo(-120 + Math.sin(count) * 20, -100 + Math.cos(count)* 20);
    thing.lineTo(120 + Math.cos(count) * 20, -100 + Math.sin(count)* 20);
    thing.lineTo(120 + Math.sin(count) * 20, 100 + Math.cos(count)* 20);
    thing.lineTo(-120 + Math.cos(count)* 20, 100 + Math.sin(count)* 20);
    thing.lineTo(-120 + Math.sin(count) * 20, -100 + Math.cos(count)* 20);
    thing.rotation = count * 0.1;
  

      renderer.render(stage);
      window.requestAnimationFrame(animate);
  }
  
  window.requestAnimationFrame(animate);
  
}