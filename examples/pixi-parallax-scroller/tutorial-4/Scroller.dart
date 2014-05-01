import '../../../lib/Pixi.dart';
import 'Far.dart';
import 'Mid.dart';
import 'Walls.dart';
import 'MapBuilder.dart';

class Scroller {

  Far far;
  Mid mid;
  Walls front;
  MapBuilder mapBuilder;

  double viewportX;

  Scroller(Stage stage) {
    this.far = new Far();
    stage.addChild(this.far);

    this.mid = new Mid();
    stage.addChild(this.mid);

    this.front = new Walls();
    stage.addChild(this.front);

    this.mapBuilder = new MapBuilder(this.front);

    this.viewportX = 0.0;
  }

  void setViewportX(double viewportX) {
    this.viewportX = viewportX;
    this.far.setViewportX(viewportX);
    this.mid.setViewportX(viewportX);
    this.front.setViewportX(viewportX);
  }

  double getViewportX() => this.viewportX;


  void moveViewportXBy(double units) {
    double newViewportX = this.viewportX + units;
    this.setViewportX(newViewportX);
  }


}
