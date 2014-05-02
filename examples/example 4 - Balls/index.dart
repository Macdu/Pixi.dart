import 'package:pixi/pixi.dart';
import 'dart:html';
import 'dart:math';

class Ball{
  
  Sprite sprite;
  
  double x;
  
  double y;
  
  Ball(this.sprite,this.x,this.y);
  
}

void main(){
  
  Random random = new Random();
  //  Globals, globals everywhere and not a drop to drink
  int w = 1024;
  int h = 768;
  int starCount = 2500;
  double sx = 1.0 + (random.nextDouble() / 20);
  double sy = 1.0 + (random.nextDouble() / 20);
  int slideX = w ~/ 2;
  int slideY = h ~/ 2;
  List<Ball> stars = [];
  Renderer renderer;
  Stage stage;
  

    void newWave (MouseEvent _) {
      sx = 1.0 + (random.nextDouble() / 20);
      sy = 1.0 + (random.nextDouble() / 20);
      querySelector('#sx').innerHtml = 'SX: $sx<br />SY: $sy';
    }

    void resize([Event _])
    {
      w = window.innerWidth - 16;
      h = window.innerHeight - 16;

      slideX = w ~/ 2;
      slideY = h ~/ 2;

      renderer.resize(w, h);
    }

    void update(num _)
    {
      for (int i = 0; i < starCount; i++)
      {
        stars[i].sprite.position.x = stars[i].x + slideX;
        stars[i].sprite.position.y = stars[i].y + slideY;
        stars[i].x = stars[i].x * sx;
        stars[i].y = stars[i].y * sy;

        if (stars[i].x > w)
        {
          stars[i].x = stars[i].x - w;
        }
        else if (stars[i].x < -w)
        {
          stars[i].x = stars[i].x + w;
        }

        if (stars[i].y > h)
        {
          stars[i].y = stars[i].y - h;
        }
        else if (stars[i].y < -h)
        {
          stars[i].y = stars[i].y + h;
        }
      }
      renderer.render(stage);
      window.requestAnimationFrame(update);
    }
    
  
  void start() {
      Texture ballTexture = new Texture.fromImage("assets/bubble_32x32.png");
      renderer = autoDetectRenderer(w, h);
      stage = new Stage();

      document.body.append(renderer.view);

      for (int i = 0; i < starCount; i++)
      {
        Sprite tempBall = new Sprite(ballTexture);

        tempBall.position.x = (random.nextDouble() * w) - slideX;
        tempBall.position.y = (random.nextDouble() * h) - slideY;
        tempBall.anchor.x = 0.5;
        tempBall.anchor.y = 0.5;

        stars.add(new Ball(tempBall,tempBall.position.x,tempBall.position.y));

        stage.addChild(tempBall);
      }

      querySelector('#rnd').onClick.listen(newWave);
      querySelector('#sx').innerHtml = 'SX: $sx<br />SY: $sy';

      resize();

      window.requestAnimationFrame(update);
    }

  window.onResize.listen(resize);
  window.onDeviceOrientation.listen(resize);

  //document.addEventListener('DOMContentLoaded', start, false);

    start();
    
    renderer.render(stage);

    
  }