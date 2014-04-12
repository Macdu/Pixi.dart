part of pixi;

class RenderSession{
  
  CanvasRenderingContext2D context = null;
  
  RenderingContext gl = null;
  
  int scaleMode = null;
  
  String smoothProperty = null;
  
  int drawCount = 0;
  
  WebGLShaderManager shaderManager = null;
  var maskManager = null;
  WebGLFilterManager filterManager = null;
  WebGLSpriteBatch spriteBatch = null;
  
  int currentBlendMode;
  
  Point projection;
  Point offset;
  
  bool roundPixels = false;
  
}