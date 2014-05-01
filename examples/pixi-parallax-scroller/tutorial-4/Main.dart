import 'dart:html';
import '../../../lib/Pixi.dart';

import 'Scroller.dart';

class Main {

  Stage stage;
  Renderer renderer;

  double scrollSpeed;

  Scroller scroller;


  static const double MIN_SCROLL_SPEED = 5.0;
  static const double MAX_SCROLL_SPEED = 6.0;
  static const double SCROLL_ACCELERATION = 0.005;

  Main() {
    this.stage = new Stage(0x66FF99);
    this.renderer = new WebGLRenderer(512, 384, querySelector("#game-canvas"));

    this.scrollSpeed = Main.MIN_SCROLL_SPEED;

    this.loadSpriteSheet();
  }


  void update([num _]) {
    this.scroller.moveViewportXBy(this.scrollSpeed);
    this.scrollSpeed += Main.SCROLL_ACCELERATION;
    if (this.scrollSpeed > Main.MAX_SCROLL_SPEED) {
      this.scrollSpeed = Main.MAX_SCROLL_SPEED;
    }

    this.renderer.render(this.stage);
    window.requestAnimationFrame(this.update);
  }

  void loadSpriteSheet() {
    List<String> assetsToLoad = ["resources/wall.json", "resources/bg-mid.png", "resources/bg-far.png"];
    AssetLoader loader = new AssetLoader(assetsToLoad);
    loader.onComplete = this.spriteSheetLoaded;
    loader.load();
  }

  void spriteSheetLoaded([_]) {
    this.scroller = new Scroller(this.stage);
    window.requestAnimationFrame(this.update);
  }

}

void main(){
  new Main();
}