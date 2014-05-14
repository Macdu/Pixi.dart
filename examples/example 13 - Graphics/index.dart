import 'package:pixi/pixi.dart';
import 'dart:html';
import 'dart:math' as Math;

void main(){

  // create an new instance of a pixi stage
  Stage stage = new Stage(0xFFFFFF, true);
  
  Renderer renderer = autoDetectRenderer(620, 380);
  
  renderer.view.style.display = "block";
   
  // add render view to DOM
  document.body.append(renderer.view);
  
  Graphics graphics = new Graphics();
  
  // set a fill and line style
  graphics.beginFill(0xFF3300);
  graphics.lineStyle(10, 0xffd900, 1.0);
  
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
  graphics.beginFill(0xFF700B, 1.0);
  
  // draw a second shape
  graphics.moveTo(210,300);
  graphics.lineTo(450,320);
  graphics.lineTo(570,350);
  graphics.lineTo(580,20);
  graphics.lineTo(330,120);
  graphics.lineTo(410,200);
  graphics.lineTo(210,300);
  graphics.endFill();
  
  // draw a rectangle
  graphics.lineStyle(2, 0x0000FF, 1.0);
  graphics.drawRect(50, 250, 100, 100);
  
  // draw a circle
  graphics.lineStyle(0,0x000000,0.0);
  graphics.beginFill(0xFFFF0B, 0.5);
  graphics.drawCircle(470, 200,100.0);
  
  graphics.lineStyle(20, 0x33FF00);
  graphics.moveTo(30,30);
  graphics.lineTo(600, 300);
    
  stage.addChild(graphics);
  
  // let's create moving shape
  Graphics thing = new Graphics();
  stage.addChild(thing);
  thing.position.x = 620/2;
  thing.position.y = 380/2;
  
  double count = 0.0;
  
  Math.Random random = new Math.Random();
  
  // Just click on the stage to draw random lines
  stage.click = stage.tap = (InteractionData data)
  {
    graphics.lineStyle((random.nextDouble() * 30).toInt(), (random.nextDouble() * 0xFFFFFF).toInt(), 1.0);
      graphics.moveTo((random.nextDouble() * 620).toInt(),(random.nextDouble() * 380).toInt());
    graphics.lineTo((random.nextDouble() * 620).toInt(),(random.nextDouble() * 380).toInt());
  };
  // run the render loop

  void animate(num _) {
    
    thing.clear();
    
    count += 0.1;
    
    thing.clear();
    thing.lineStyle(30, 0xff0000, 1.0);
    thing.beginFill(0xffFF00, 0.5);
    
    thing.moveTo((-120 + Math.sin(count) * 20).toInt(),(-100 + Math.cos(count)* 20).toInt());
    thing.lineTo((120 + Math.cos(count) * 20).toInt(), (-100 + Math.sin(count)* 20).toInt());
    thing.lineTo((120 + Math.sin(count) * 20).toInt(), (100 + Math.cos(count)* 20).toInt());
    thing.lineTo((-120 + Math.cos(count)* 20).toInt(), (100 + Math.sin(count)* 20).toInt());
    thing.lineTo((-120 + Math.sin(count) * 20).toInt(), (-100 + Math.cos(count)* 20).toInt());
    
    thing.rotation = count * 0.1;
      renderer.render(stage);
      window.requestAnimationFrame( animate );
  }
  
  window.requestAnimationFrame(animate);
  
}
