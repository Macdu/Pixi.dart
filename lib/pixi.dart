library pixi;

import 'dart:math' as Math;
import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';
import 'dart:convert';

import 'src/extras/Spine.dart' as Spine;
export 'src/extras/Spine.dart';

part 'src/core/Circle.dart';
part 'src/core/Ellipse.dart';
part 'src/core/Matrix.dart';
part 'src/core/Point.dart';
part 'src/core/Polygon.dart';
part 'src/core/Rectangle.dart';

part 'src/display/DisplayObject.dart';
part 'src/display/DisplayObjectContainer.dart';
part 'src/display/MovieClip.dart';
part 'src/display/Sprite.dart';
part 'src/display/SpriteBatch.dart';
part 'src/display/ParticleBatch.dart';
part 'src/display/Stage.dart';

part 'src/extras/Rope.dart';
part 'src/extras/Strip.dart';
part 'src/extras/TilingSprite.dart';

part 'src/filters/AbstractFilter.dart';
part 'src/filters/AlphaMaskFilter.dart';
part 'src/filters/BlurFilter.dart';
part 'src/filters/BlurXFilter.dart';
part 'src/filters/BlurYFilter.dart';
part 'src/filters/ColorMatrixFilter.dart';
part 'src/filters/ColorStepFilter.dart';
part 'src/filters/CrossHatchFilter.dart';
part 'src/filters/DisplacementFilter.dart';
part 'src/filters/DotScreenFilter.dart';
part 'src/filters/FilterBlock.dart';
part 'src/filters/GrayFilter.dart';
part 'src/filters/InvertFilter.dart';
part 'src/filters/NormalMapFilter.dart';
part 'src/filters/PixelateFilter.dart';
part 'src/filters/RGBSplitFilter.dart';
part 'src/filters/SepiaFilter.dart';
part 'src/filters/SmartBlurFilter.dart';
part 'src/filters/TwistFilter.dart';

part 'src/loaders/AssetLoader.dart';
part 'src/loaders/Loader.dart';
part 'src/loaders/AtlasLoader.dart';
part 'src/loaders/BitmapFontLoader.dart';
part 'src/loaders/ImageLoader.dart';
part 'src/loaders/JsonLoader.dart';
part 'src/loaders/SpineLoader.dart';
part 'src/loaders/SpriteSheetLoader.dart';

part 'src/primitives/Graphics.dart';

part 'src/renderers/Renderer.dart';
part 'src/renderers/RenderSession.dart';

part 'src/renderers/canvas/CanvasRenderer.dart';
part 'src/renderers/canvas/CanvasGraphics.dart';
part 'src/renderers/canvas/utils/CanvasMaskManager.dart';
part 'src/renderers/canvas/utils/CanvasTinter.dart';

part 'src/renderers/webgl/WebGLRenderer.dart';
part 'src/renderers/webgl/shaders/PixiFastShader.dart';
part 'src/renderers/webgl/shaders/PixiShader.dart';
part 'src/renderers/webgl/shaders/PrimitiveShader.dart';
part 'src/renderers/webgl/shaders/StripShader.dart';
part 'src/renderers/webgl/utils/FilterTexture.dart';
part 'src/renderers/webgl/utils/WebGLFastSpriteBatch.dart';
part 'src/renderers/webgl/utils/WebGLFilterManager.dart';
part 'src/renderers/webgl/utils/WebGLGraphics.dart';
part 'src/renderers/webgl/utils/WebGLMaskManager.dart';
part 'src/renderers/webgl/utils/WebGLShaderManager.dart';
part 'src/renderers/webgl/utils/WebGLShaderUtils.dart';
part 'src/renderers/webgl/utils/WebGLSpriteBatch.dart';

part 'src/text/BitmapText.dart';
part 'src/text/Text.dart';

part 'src/textures/BaseTexture.dart';
part 'src/textures/RenderTexture.dart';
part 'src/textures/Texture.dart';

part 'src/utils/Detector.dart';
part 'src/utils/EventTarget.dart';
part 'src/utils/Polyk.dart';
part 'src/utils/Utils.dart';

part 'src/InteractionData.dart';
part 'src/InteractionManager.dart';

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */


/* 
* 
* This file contains a lot of pixi consts which are used across the rendering engine
* @class Consts
*/
const int WEBGL_RENDERER = 0;
const int CANVAS_RENDERER = 1;

// useful for testing against if your lib is using pixi.
const String VERSION = "v1.5.1";

// the various blend modes supported by pixi
final Map blendModes = {
  'NORMAL': 0,
  'ADD': 1,
  'MULTIPLY': 2,
  'SCREEN': 3,
  'OVERLAY': 4,
  'DARKEN': 5,
  'LIGHTEN': 6,
  'COLOR_DODGE': 7,
  'COLOR_BURN': 8,
  'HARD_LIGHT': 9,
  'SOFT_LIGHT': 10,
  'DIFFERENCE': 11,
  'EXCLUSION': 12,
  'HUE': 13,
  'SATURATION': 14,
  'COLOR': 15,
  'LUMINOSITY': 16
};

// the scale modes
final Map scaleModes = {
  'DEFAULT': 0,
  'LINEAR': 0,
  'NEAREST': 1
};

// interaction frequency
const int INTERACTION_FREQUENCY = 30;
const bool AUTO_PREVENT_DEFAULT = true;

const double RAD_TO_DEG = 180 / Math.PI;
const double DEG_TO_RAD = Math.PI / 180;

var defaultRenderer;

List blendModesCanvas = [];
List blendModesWebGL = [];
