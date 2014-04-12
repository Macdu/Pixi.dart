part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

// TODO Alvin and Mat
// Should we eventually create a Utils class ?
// Or just move this file to the pixi.js file ?
void initDefaultShaders() {

  //  PIXI.stripShader = new PIXI.StripShader();
  //    PIXI.stripShader.init();

}

Shader CompileVertexShader(RenderingContext gl, List shaderSrc) {
  return _CompileShader(gl, shaderSrc, VERTEX_SHADER);
}

Shader CompileFragmentShader(RenderingContext gl, List shaderSrc) {
  return _CompileShader(gl, shaderSrc, FRAGMENT_SHADER);
}

Shader _CompileShader(RenderingContext gl, List shaderSrc, int shaderType) {
  String src = shaderSrc.join("\n");
  Shader shader = gl.createShader(shaderType);
  gl.shaderSource(shader, src);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, COMPILE_STATUS)) {
    print(gl.getShaderInfoLog(shader));
    return null;
  }

  return shader;
}

Program compileProgram(RenderingContext gl, List vertexSrc, List fragmentSrc) {
  Shader fragmentShader = CompileFragmentShader(gl, fragmentSrc);
  Shader vertexShader = CompileVertexShader(gl, vertexSrc);

  Program shaderProgram = gl.createProgram();

  gl.attachShader(shaderProgram, vertexShader);
  gl.attachShader(shaderProgram, fragmentShader);
  gl.linkProgram(shaderProgram);

  if (!gl.getProgramParameter(shaderProgram, LINK_STATUS)) {
    print("Could not initialise shaders");
  }

  return shaderProgram;
}
