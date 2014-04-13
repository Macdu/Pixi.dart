part of pixi;

abstract class Renderer{
  
  /**
       * The canvas element that everything is drawn to
       *
       * @property view
       * @type HTMLCanvasElement
       */
  CanvasElement view;
  
  Renderer([int width = 800, int height = 600, CanvasElement view =
        null, bool transparent = false, bool antialias = false]);
  
  void render(Stage stage);
  
  void resize(int width, int height);
  
}