import 'package:pixi/pixi.dart';
import 'dart:html';

void main(){


  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF, true);

  stage.interactive = true;

  Sprite sprite=  new Sprite.fromImage("spinObj_02.png");
  //stage.addChild(sprite);
  // create a renderer instance
  Renderer renderer = autoDetectRenderer(620, 380, null, false /* transparent */, true /* antialias */);

  // set the canvas width and height to fill the screen
  //renderer.view.style.width = window.innerWidth + "px";
  //renderer.view.style.height = window.innerHeight + "px";
  renderer.view.style.display = "block";

  // add render view to DOM
  document.body.append(renderer.view);

  Graphics graphics = new Graphics();
/*
  // set a fill and line style
  graphics.beginFill(0xFF3300);
  graphics.lineStyle(10, 0xffd900, 1);

  // draw a shape
  graphics.moveTo(50,50);
  graphics.lineTo(250, 50);
  graphics.lineTo(100, 100);
  graphics.lineTo(250, 220);
  graphics.lineTo(50, 220);
  graphics.lineTo(50, 50);
  graphics.endFill();

  // set a fill and line style again
  graphics.lineStyle(10, 0xFF0000, 0.8);
  graphics.beginFill(0xFF700B, 1);

  // draw a second shape
  graphics.moveTo(210,300);
  graphics.lineTo(450,320);
  graphics.lineTo(570,350);
  graphics.lineTo(580,20);
  graphics.lineTo(330,120);
  graphics.lineTo(410,200);
  graphics.lineTo(210,300);
  graphics.endFill();

  // draw a rectangel
  graphics.lineStyle(2, 0x0000FF, 1);
  graphics.drawRect(50, 250, 100, 100);

  // draw a circle
  graphics.lineStyle(0);
  graphics.beginFill(0xFFFF0B, 0.5);
  graphics.drawCircle(470, 200,100);

  graphics.lineStyle(20, 0x33FF00);
  graphics.moveTo(30,30);
  graphics.lineTo(600, 300);
*/

  Graphics g = new Graphics();
  g.lineStyle(10, 0x000000, 1.0);
  g.beginFill(0xff0000);
  g.moveTo(0,0);
  g.drawRect(0, 0, 100, 100);

  g.pivot.x = 50.0;
  g.pivot.y = 50.0;

//  g.lineTo(00, 200);
//  g.lineTo(300, 300);
  
  g.position.x = 100.0;
  g.position.y = 100.0;

  stage.addChild(g);

  // lets create moving shape
  Graphics thing = new Graphics();
  stage.addChild(thing);
  thing.position.x = 620/2;
  thing.position.y = 380/2;

  double count = 0.0;

  stage.click = stage.tap = (InteractionData data)
  {
  //  graphics.lineStyle(Math.random() * 30, Math.random() * 0xFFFFFF, 1);
  //    graphics.moveTo(Math.random() * 620,Math.random() * 380);
//    graphics.lineTo(Math.random() * 620,Math.random() * 380);
  };

  void animate(num _) {

    thing.clear();
    g.rotation += 0.1;
    count += 0.1;
/*
    thing.clear();
    thing.lineStyle(30, 0xff0000, 1);
    thing.beginFill(0xffFF00, 0.5);

    thing.moveTo(-120 + Math.sin(count) * 20, -100 + Math.cos(count)* 20);
    thing.lineTo(120 + Math.cos(count) * 20, -100 + Math.sin(count)* 20);
    thing.lineTo(120 + Math.sin(count) * 20, 100 + Math.cos(count)* 20);
    thing.lineTo(-120 + Math.cos(count)* 20, 100 + Math.sin(count)* 20);
    thing.lineTo(-120 + Math.sin(count) * 20, -100 + Math.cos(count)* 20);
*/
    thing.rotation = count * 0.1;
      renderer.render(stage);
      window.requestAnimationFrame( animate );
  }
  
  window.requestAnimationFrame(animate);

}