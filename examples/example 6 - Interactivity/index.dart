import 'package:pixi/pixi.dart';
import'dart:html';
import 'dart:math' as Math;

void main(){
  // create an new instance of a pixi stage
  // the second parameter is interactivity...
  bool interactive = true;
  Stage stage = new Stage(0x000000 ,interactive);

  // create a renderer instance.
  Renderer renderer = autoDetectRenderer(620, 400);

  // add the renderer view element to the DOM
  document.body.append(renderer.view);

  // create a background..
  Sprite background = new Sprite.fromImage("button_test_BG.jpg");

  // add background to stage...
  stage.addChild(background);

  // create some textures from an image path
  Texture textureButton = new Texture.fromImage("button.png");
  Texture textureButtonDown = new Texture.fromImage("buttonDown.png");
  Texture textureButtonOver = new Texture.fromImage("buttonOver.png");

  List<Sprite> buttons = [];

  List<int> buttonPositions = [175,75,
               600-145, 75,
               600~/2 - 20, 400~/2 + 10,
               175, 400-75,
               600-115, 400-95];


  for (int i=0; i < 5; i++)
  {
    Sprite button = new Sprite(textureButton);
    button.buttonMode = true;

    button.anchor.x = 0.5;
    button.anchor.y = 0.5;

    button.position.x = buttonPositions[i*2].toDouble();
    button.position.y = buttonPositions[i*2 + 1].toDouble();

    // make the button interactive..
    button.interactive = true;

    // set the mousedown and touchstart callback..
    button.mousedown = button.touchstart = (InteractionData data) {
      button.isDown = true;
      button.setTexture(textureButtonDown);
      button.alpha = 1.0;
    };

    // set the mouseup and touchend callback..
    button.mouseup = button.touchend = button.mouseupoutside = button.touchendoutside = (InteractionData data) {
      //button.isDown = false;

      if (button.isOver)
      {
        button.setTexture(textureButtonOver);
      }
      else
      {
        button.setTexture(textureButton);
      }
    };

    // set the mouseover callback..
    button.mouseover = (InteractionData data) {
      //button.isOver = true;

      if (button.isDown)
        return;

      button.setTexture(textureButtonOver);
    };

    // set the mouseout callback..
    button.mouseout = (InteractionData data) {
      //button.isOver = false;
      
      if (button.isDown)
        return;

      button.setTexture(textureButton);
    };

    button.click = (InteractionData data) {
      print("CLICK!");
    };

    button.tap = (InteractionData data) {
      print("TAP!!");
    };

    // add it to the stage
    stage.addChild(button);

    // add button to array
    buttons.add(button);
  }

  // set some silly values...
  buttons[0].scale.x = 1.2;
  buttons[1].scale.y = 1.2;
  buttons[2].rotation = Math.PI / 10;
  buttons[3].scale.x = 0.8;
  buttons[3].scale.y = 0.8;
  buttons[4].scale.x = 0.8;
  buttons[4].scale.y = 1.2;
  buttons[4].rotation = Math.PI;

  void animate(num _) {
      // render the stage
      renderer.render(stage);

      window.requestAnimationFrame(animate);      
  }

  // add a logo!
  Sprite pixiLogo = new Sprite.fromImage("pixi.png");
  stage.addChild(pixiLogo);

  pixiLogo.buttonMode = true;
  pixiLogo.interactive = true;

  pixiLogo.position.x = (620 - 56).toDouble();
  pixiLogo.position.y = (400 - 32).toDouble();

  pixiLogo.click = pixiLogo.tap = (InteractionData data) {
    window.open("http://www.pixijs.com", '_blank');
  };
  
  window.requestAnimationFrame(animate);
}