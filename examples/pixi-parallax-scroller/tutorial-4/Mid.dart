import '../../../lib/Pixi.dart';

class Mid extends TilingSprite {

  double viewportX;

  static const double DELTA_X = 0.32;

  Mid(): super(new Texture.fromImage("resources/bg-mid.png"), 512.0, 256.0) {

    this.position.x = 0.0;
    this.position.y = 128.0;
    this.tilePosition.x = 0.0;
    this.tilePosition.y = 0.0;

    this.viewportX = 0.0;
  }

  void setViewportX(newViewportX) {
    double distanceTravelled = newViewportX - this.viewportX;
    this.viewportX = newViewportX;
    this.tilePosition.x -= (distanceTravelled * Mid.DELTA_X);
  }

}
