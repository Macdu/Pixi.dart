import 'package:pixi/pixi.dart';
import 'dart:html' hide Point;
import 'dart:math' hide Point;


void main(){
  // create an new instance of a pixi stage
  Stage stage = new Stage(0x97C56E, true);

  // create a renderer instance
  Renderer renderer = autoDetectRenderer(window.innerWidth, window.innerHeight, null);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);
  renderer.view.style.position = "absolute";
  renderer.view.style.top = "0px";
  renderer.view.style.left = "0px";
  
  // create a texture from an image path
  Texture texture = new Texture.fromImage("bunny.png");
  
  void createBunny(double x,double y)
  {
    
    InteractionData data;
    bool dragging = false;
    
    // create our little bunny friend..
    Sprite bunny = new Sprite(texture);

    // enable the bunny to be interactive.. this will allow it to respond to mouse and touch events
    bunny.interactive = true;
    // this button mode will mean the hand cursor appears when you rollover the bunny with your mouse
    bunny.buttonMode = true;

    // center the bunnys anchor point
    bunny.anchor.x = 0.5;
    bunny.anchor.y = 0.5;
    // make it a bit bigger, so its easier to touch
    bunny.scale.x = bunny.scale.y = 3.0;


    // use the mousedown and touchstart
    bunny.mousedown = bunny.touchstart = (InteractionData data)
    {
      // stop the default event...
      data.originalEvent.preventDefault();

      // store a reference to the data
      // The reason for this is because of multitouch
      // we want to track the movement of this particular touch
      data = data;
      bunny.alpha = 0.9;
      dragging = true;
    };

    // set the events for when the mouse is released or a touch is released
    bunny.mouseup = bunny.mouseupoutside = bunny.touchend = bunny.touchendoutside = (InteractionData data)
    {
      bunny.alpha = 1.0;
      dragging = false;
      // set the interaction data to null
      data = null;
    };

    // set the callbacks for when the mouse or a touch moves
    bunny.mousemove = bunny.touchmove = (InteractionData data)
    {
      if(dragging)
      {
        Point newPosition = data.getLocalPosition(bunny.parent);
        bunny.position.x = newPosition.x;
        bunny.position.y = newPosition.y;
      }
    };

    // move the sprite to its designated position
    bunny.position.x = x;
    bunny.position.y = y;

    // add it to the stage
    stage.addChild(bunny);
  }

  Random random = new Random();
  
  for (int i = 0; i < 10; i++)
  {
    createBunny(random.nextDouble() * window.innerWidth, random.nextDouble() * window.innerHeight);
  }


  void animate(num _) {

      window.requestAnimationFrame(animate);

      // render the stage
      renderer.render(stage);
  }
  
  window.requestAnimationFrame( animate );
  
  window.onResize.listen((Event _) => renderer.resize(window.innerWidth, window.innerHeight));
  window.onDeviceOrientation.listen((Event _) => renderer.resize(window.innerWidth, window.innerHeight));

}