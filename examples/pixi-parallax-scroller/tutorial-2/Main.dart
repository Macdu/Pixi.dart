import 'dart:html';
import 'package:pixi/pixi.dart';
import 'Scroller.dart';

class Main {

  Stage stage;

  var renderer;

  Scroller scroller;

  static const double SCROLL_SPEED = 5.0;

  Main() {
    this.stage = new Stage(0x66FF99);
    this.renderer = autoDetectRenderer(512, 384, document.getElementById("game-canvas"));

    this.scroller = new Scroller(this.stage);

    window.requestAnimationFrame(this.update);
  }



  void update(num _) {
    this.scroller.moveViewportXBy(Main.SCROLL_SPEED);
    this.renderer.render(this.stage);
    window.requestAnimationFrame(this.update);
  }
}
