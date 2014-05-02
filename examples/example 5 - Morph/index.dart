import 'package:pixi/pixi.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math' as Math;

void main(){


  int w = 1024;
  int h = 768;

  int n = 2000;
  int d = 1;
  int current = 1;
  int objs = 17;
  double vx = 0.0;
  double vy = 0.0;
  double vz = 0.0;
  List<double> points1 = new List<double>(n);
  List<double> points2 = new List<double>(n);
  List<double> points3 = new List<double>(n);
  List<double> tpoint1 = new List<double>(n);
  List<double> tpoint2 = new List<double>(n);
  List<double> tpoint3 = new List<double>(n);
  List<Sprite> balls = new List<Sprite>(n);
  Renderer renderer;
  Stage stage;
  Math.Random random = new Math.Random();


  void makeObject(int t) {
    var xd;

    switch (t)
    {
      case 0:
        for ( int i = 0; i < n; i++)
        {
          points1[i] = -50 + (random.nextDouble() * 100).roundToDouble();
          points2[i] = 0.0;
          points3[i] = 0.0;
        }
        break;
      case 1:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(t * 360 / n) * 10);
          points2[i] = (Math.cos(xd) * 10) * (Math.sin(t * 360 / n) * 10);
          points3[i] = Math.sin(xd) * 100;
        }
        break;
      case 2:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(t * 360 / n) * 10);
          points2[i] = (Math.cos(xd) * 10) * (Math.sin(t * 360 / n) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 3:

        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(xd) * 10);
          points2[i] = (Math.cos(xd) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(xd) * 100;
        }
        break;
      case 4:

        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(xd) * 10);
          points2[i] = (Math.cos(xd) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 5:

        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(xd) * 10);
          points2[i] = (Math.cos(i * 360 / n) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 6:

        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(i * 360 / n) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.cos(i * 360 / n) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 7:

        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(i * 360 / n) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.cos(i * 360 / n) * 10) * (Math.sin(i * 360 / n) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 8:

        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.cos(i * 360 / n) * 10) * (Math.sin(i * 360 / n) * 10);
          points3[i] = Math.sin(xd) * 100;
        }
        break;
      case 9:

        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.cos(i * 360 / n) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(xd) * 100;
        }
        break;
      case 10:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(i * 360 / n) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.cos(xd) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 11:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.sin(xd) * 10) * (Math.sin(i * 360 / n) * 10);
          points3[i] = Math.sin(xd) * 100;
        }
        break;
      case 12:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(xd) * 10);
          points2[i] = (Math.sin(xd) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 13:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.sin(i * 360 / n) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 14:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.sin(xd) * 10) * (Math.cos(xd) * 10);
          points2[i] = (Math.sin(xd) * 10) * (Math.sin(i * 360 / n) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 15:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(i * 360 / n) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.sin(i * 360 / n) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
      case 16:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(i * 360 / n) * 10);
          points2[i] = (Math.sin(i * 360 / n) * 10) * (Math.sin(xd) * 10);
          points3[i] = Math.sin(xd) * 100;
        }
        break;
      case 17:
        for ( int i = 0; i < n; i++)
        {
          xd = -90 + (random.nextDouble() * 180).roundToDouble();
          points1[i] = (Math.cos(xd) * 10) * (Math.cos(xd) * 10);
          points2[i] = (Math.cos(i * 360 / n) * 10) * (Math.sin(i * 360 / n) * 10);
          points3[i] = Math.sin(i * 360 / n) * 100;
        }
        break;
    }
  }
  

  void nextObject() {
    current++;
    if (current > objs)
    {
      current = 0;
    }

    makeObject(current);
    new Timer(const Duration(seconds : 8), nextObject);
  }

  void resize([Event _])
  {
    w = window.innerWidth - 16;
    h = window.innerHeight - 16;

    renderer.resize(w, h);
  }

  void update(num _)
  {
    double x3d = 0.0, y3d = 0.0, z3d = 0.0, tx = 0.0, ty = 0.0, tz = 0.0, ox = 0.0;

    if (d < 250)
    {
      d++;
    }

    vx += 0.0075;
    vy += 0.0075;
    vz += 0.0075;

    for ( int i = 0; i < n; i++)
    {
      if (points1[i] > tpoint1[i]) { tpoint1[i] = tpoint1[i] + 1; }
      if (points1[i] < tpoint1[i]) { tpoint1[i] = tpoint1[i] - 1; }
      if (points2[i] > tpoint2[i]) { tpoint2[i] = tpoint2[i] + 1; }
      if (points2[i] < tpoint2[i]) { tpoint2[i] = tpoint2[i] - 1; }
      if (points3[i] > tpoint3[i]) { tpoint3[i] = tpoint3[i] + 1; }
      if (points3[i] < tpoint3[i]) { tpoint3[i] = tpoint3[i] - 1; }

      x3d = tpoint1[i];
      y3d = tpoint2[i];
      z3d = tpoint3[i];

      ty = (y3d * Math.cos(vx)) - (z3d * Math.sin(vx));
      tz = (y3d * Math.sin(vx)) + (z3d * Math.cos(vx));
      tx = (x3d * Math.cos(vy)) - (tz * Math.sin(vy));
      tz = (x3d * Math.sin(vy)) + (tz * Math.cos(vy));
      ox = tx;
      tx = (tx * Math.cos(vz)) - (ty * Math.sin(vz));
      ty = (ox * Math.sin(vz)) + (ty * Math.cos(vz));

      balls[i].position.x = (512 * tx) / (d - tz) + w / 2;
      balls[i].position.y = (h/2) - (512 * ty) / (d - tz);
    }

    renderer.render(stage);

    window.requestAnimationFrame(update);
  }
  
  void start() {
    Texture ballTexture = new Texture.fromImage("assets/pixel.png");
    renderer = autoDetectRenderer(w, h);
    stage = new Stage();

    document.body.append(renderer.view);

    makeObject(0);

    for (int i = 0; i < n; i++)
    {
      tpoint1[i] = points1[i];
      tpoint2[i] = points2[i];
      tpoint3[i] = points3[i];

      Sprite tempBall = new Sprite(ballTexture);
      tempBall.anchor.x = 0.5;
      tempBall.anchor.y = 0.5;
      tempBall.alpha = 0.5;
      balls[i] = tempBall;

      stage.addChild(tempBall);
    }

    resize();

    new Timer(const Duration(seconds : 5), nextObject);

    window.requestAnimationFrame(update);
  }
  
  
  window.onResize.listen(resize);
  window.onDeviceMotion.listen(resize);

  start();
}