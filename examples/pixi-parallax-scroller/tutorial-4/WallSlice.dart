import 'package:pixi/pixi.dart';

class WallSlice {

  int type;
  int y;
  Sprite sprite;

  static const int WIDTH = 64;

  WallSlice(int type, int y) {
    this.type = type;
    this.y = y;
    this.sprite = null;
  }

}
