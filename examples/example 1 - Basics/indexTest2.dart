import 'package:pixi/pixi.dart';
import 'dart:html';

void main(){

Stage stage = new Stage();
Renderer renderer = autoDetectRenderer(1024, 768, null, true, true);
//var renderer = new PIXI.CanvasRenderer(1024, 768, null, true, true);
document.body.append(renderer.view);

String imgUrl = 'http://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Ski_trail_rating_symbol-blue_square.svg/600px-Ski_trail_rating_symbol-blue_square.svg.png';

Sprite sprite = new Sprite.fromImage(imgUrl);
sprite.position.set(0.0, 0.0);
sprite.pivot.set(sprite.width/2, sprite.height/2);

stage.addChild(sprite);

void animate(num _) {
    window.requestAnimationFrame(animate);
   
    sprite.rotation += 0.1;
    
    renderer.render(stage);
}

window.requestAnimationFrame(animate);


}