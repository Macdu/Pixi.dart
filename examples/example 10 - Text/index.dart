import 'package:pixi/pixi.dart';
import 'dart:html' hide Text;

void main(){
/*  
    // Load them google fonts before starting...!
  Map WebFontConfig = {
    'google': {
      'families': [ 'Snippet', 'Arvo:700italic', 'Podkova:700' ]
    },

    'active' : () {
      // do something
      init();
    }
  };
*/

  /*
        ScriptElement  wf = new ScriptElement();
        wf.src = ('https:' == window.location.protocol ? 'https' : 'http') +
            '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
        wf.type = 'text/javascript';
        wf.async = true;
        ScriptElement s = querySelectorAll('script')[0];
        s.parentNode.insertBefore(wf, s);
      */

/*
  void runList(BitmapText item)
  {
    print("_");
    int safe = 0;
    var tmp = item;
    while(tmp._iNext)
    {
      safe++;
      tmp = tmp._iNext;
      print(tmp);

      if(safe > 100)
      {
        print("BREAK");
        break;
      }
    }
  }
*/
    void init(Event _)
    {
        List assetsToLoader = ["desyrel.xml"];

        // create a new loader
        AssetLoader loader = new AssetLoader(assetsToLoader);
        
        // create an new instance of a pixi stage
    Stage stage = new Stage(0x66FF99);
        
        void onAssetsLoaded()
                {
                    BitmapText bitmapFontText = new BitmapText("bitmap fonts are\n now supported!", {'font' : "35 Desyrel",'align' : "right"});
                    bitmapFontText.position.x = 620 - bitmapFontText.textWidth - 20;
                    bitmapFontText.position.y = 20.0;

              //runList(bitmapFontText);

                  stage.addChild(bitmapFontText);
                }

        // use callback
        loader.onComplete = onAssetsLoaded;

    // begin load
        loader.load();


    // create a renderer instance
    Renderer renderer = autoDetectRenderer(620, 400);
    // add the renderer view element to the DOM
    document.body.append(renderer.view);
    
    // add a shiny background...
    Texture backgroundTexture = new Texture.fromImage("textDemoBG.jpg");
    Sprite background = new Sprite(backgroundTexture);
    stage.addChild(background);

    // create some white text using the Snippet webfont
    Text textSample = new Text("Pixi.js can has\nmultiline text!", { 'font': "35px Snippet", 'fill': "white", 'align': "left" });
    textSample.position.x = 20.0;
    textSample.position.y = 20.0;

    // create a text object with a nice stroke
    Text spinningText = new Text("I'm fun!", { 'font': "bold 60px Podkova", 'fill': "#cc00ff", 'align': "center", 'stroke': "#FFFFFF", 'strokeThickness': 6 });

    // setting the anchor point to 0.5 will center align the text... great for spinning!
    spinningText.anchor.x = spinningText.anchor.y = 0.5;
    spinningText.position.x = 620 / 2;
    spinningText.position.y = 400 / 2;

    // create a text object that will be updated..
    Text countingText = new Text("COUNT 4EVAR: 0", { 'font': "bold italic 60px Arvo", 'fill': "#3e1707", 'align': "center", 'stroke': "#a4410e", 'strokeThickness': 7 });
    countingText.position.x = 620 / 2;
    countingText.position.y = 320.0;
    countingText.anchor.x = 0.5;

    stage.addChild(textSample);
    stage.addChild(spinningText);
    stage.addChild(countingText);

    double count = 0.0;
    int score = 0;
    int remaining = 10;

    renderer.render(stage);

    void animate(num _) {
      window.requestAnimationFrame( animate );
            count++;
            if(count == 50)
            {
              count = 0.0;
              score++;
              // update the text...
              countingText.text = "COUNT 4EVAR: " + score.toString();
            }
              // just for fun, lets rotate the text
              spinningText.rotation += 0.03;
            
              // render the stage   
              renderer.render(stage);
          
    }

        window.requestAnimationFrame(animate);
  }
    
    LinkElement le = new LinkElement();
    le.onLoad.listen(init);
    le.type = "text/css";
    le.rel = "stylesheet";
    le.href = "http://fonts.googleapis.com/css?family=Snippet|Arvo:700italic|Podkova:700";
    document.head.append(le);
}

  