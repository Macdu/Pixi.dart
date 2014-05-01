import 'package:pixi/pixi.dart';
import 'dart:html' hide Rectangle;


void main(){
// create an new instance of a pixi stage
  Stage stage = new Stage(0x66FF99);

  // create a renderer instance
  Renderer renderer = autoDetectRenderer(400, 300);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);


  // create a texture from an image path
  Texture texture = new Texture.fromImage("bunny.png");
  // create a new Sprite using the texture
  Sprite bunny = new Sprite(texture);

  // center the sprites anchor point
  bunny.anchor.x = 0.5;
  bunny.anchor.y = 0.5;

  // move the sprite t the center of the screen
  bunny.position.x = 200.0;
  bunny.position.y = 150.0;

  stage.addChild(bunny);


        CanvasElement canvas = new CanvasElement();// $('<canvas></canvas>')[0];
        canvas.width = 256; canvas.height = 256;
        CanvasRenderingContext2D context = canvas.getContext('2d');
        context.fillStyle = "#FF0000";
        context.fillRect(0,0,256,256);
        //Split Canvas into multiple textures
        List frames = new List(4*4);


        for(int i=0;i<4;i++)
            for(int ii=0;ii<4;ii++) {
                Texture tex = new Texture.fromCanvas(canvas);
                tex.setFrame(new Rectangle(ii*32.0,i*32.0,32.0,32.0));
                frames[(ii+(i*4))] = tex;
            }
        MovieClip sprite = new MovieClip(frames);
        sprite.animationSpeed = 0.1;
        sprite.currentFrame = 0.0;
        sprite.play();
        stage.addChild(sprite);
    
   

  void animate(num _) {

      window.requestAnimationFrame( animate );

      // just for fun, lets rotate mr rabbit a little
      bunny.rotation += 0.1;

//      console.log(stage.getBounds().width);
      // render the stage
      renderer.render(stage);
  }
  
  window.requestAnimationFrame( animate );
  
  
}