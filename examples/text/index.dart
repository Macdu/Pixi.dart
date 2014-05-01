import 'package:pixi/pixi.dart';
import 'dart:html' hide Text;

void main(){
  
  Renderer renderer = autoDetectRenderer();
  
  document.body.append(renderer.view);
  
  Stage stage = new Stage(0x586324);
  
  Text text = new Text("Text works! \n very well",
      {'font':"50px Arial", 'fill':"red"});
  text.position.x = 300.0;
  text.position.y = 250.0;
  text.anchor
    ..x = 0.5
    ..y = 0.5;
  
  stage.addChild(text);
  
  renderer.render(stage);
  
  update(num _){
      text.rotation += 0.05;
      window.requestAnimationFrame(update);
      renderer.render(stage);
    }
  
  window.requestAnimationFrame(update);
  
}