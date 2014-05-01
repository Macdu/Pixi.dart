import 'package:pixi/pixi.dart';

class Far extends TilingSprite{

  double viewportX;
  
Far() : super (new Texture.fromImage("resources/bg-far.png"),512.0,256.0){

	this.position.x = 0.0;
	this.position.y = 0.0;
	this.tilePosition.x = 0.0;
	this.tilePosition.y = 0.0;

	this.viewportX = 0.0;
}

static const double DELTA_X = 0.128;

void setViewportX(double newViewportX) {
	double distanceTravelled = newViewportX - this.viewportX;
	this.viewportX = newViewportX;
	this.tilePosition.x -= (distanceTravelled * Far.DELTA_X);
}

}