import 'dart:html';
import 'package:pixi/pixi.dart';

Stage stage;
var renderer;
TilingSprite far;
TilingSprite mid;

void main() {
            stage = new Stage(0x66FF99);
            renderer = autoDetectRenderer(
               512,
               384,
               querySelector("#game-canvas")
            );

            Texture farTexture = new Texture.fromImage("resources/bg-far.png");  
            far = new TilingSprite(farTexture, 512.0, 256.0);
            far.position
              ..x = 0.0
              ..y = 0.0;
            far.tilePosition
              ..x = 0.0
              ..y = 0.0;
            stage.addChild(far);

            Texture midTexture = new Texture.fromImage("resources/bg-mid.png");
            mid = new TilingSprite(midTexture, 512.0, 256.0);
            mid.position
              ..x = 0.0
              ..y = 128.0;
            mid.tilePosition
              ..x = 0.0
              ..y = 0.0;
            stage.addChild(mid);

            window.requestAnimationFrame(update);
         }

         void update(num _) {
            far.tilePosition.x -= 0.128;
            mid.tilePosition.x -= 0.64;
            
            renderer.render(stage);

            window.requestAnimationFrame(update);
         }