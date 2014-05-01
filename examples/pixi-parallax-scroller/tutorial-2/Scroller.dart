import '../../../lib/Pixi.dart';
import 'Mid.dart';
import 'Far.dart';

class Scroller {

  Far far;
  Mid mid;
  double viewportX;

  Scroller(Stage stage) {

    this.far = new Far();
    stage.addChild(this.far);

    this.mid = new Mid();
    stage.addChild(this.mid);

    this.viewportX = 0.0;
  }

  void setViewportX(viewportX) {
    this.viewportX = viewportX;
    this.far.setViewportX(viewportX);
    this.mid.setViewportX(viewportX);
  }

  double getViewportX() {
    return this.viewportX;
  }

  void moveViewportXBy(double units) {
    double newViewportX = this.viewportX + units;
    this.setViewportX(newViewportX);
  }

}
