library pixi;

import 'dart:math' as Math;
import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';
import 'dart:convert';

import 'extras/Spine.dart' as Spine;
export 'extras/Spine.dart';

part 'core/Circle.dart';
part 'core/Ellipse.dart';
part 'core/Matrix.dart';
part 'core/Point.dart';
part 'core/Polygon.dart';
part 'core/Rectangle.dart';

part 'display/DisplayObject.dart';
part 'display/DisplayObjectContainer.dart';
part 'display/MovieClip.dart';
part 'display/Sprite.dart';
part 'display/SpriteBatch.dart';
part 'display/ParticleBatch.dart';
part 'display/Stage.dart';

part 'extras/Rope.dart';
part 'extras/Strip.dart';
part 'extras/TilingSprite.dart';

part 'filters/AbstractFilter.dart';
part 'filters/AlphaMaskFilter.dart';
part 'filters/BlurFilter.dart';
part 'filters/BlurXFilter.dart';
part 'filters/BlurYFilter.dart';
part 'filters/ColorMatrixFilter.dart';
part 'filters/ColorStepFilter.dart';
part 'filters/CrossHatchFilter.dart';
part 'filters/DisplacementFilter.dart';
part 'filters/DotScreenFilter.dart';
part 'filters/FilterBlock.dart';
part 'filters/GrayFilter.dart';
part 'filters/InvertFilter.dart';
part 'filters/NormalMapFilter.dart';
part 'filters/PixelateFilter.dart';
part 'filters/RGBSplitFilter.dart';
part 'filters/SepiaFilter.dart';
part 'filters/SmartBlurFilter.dart';
part 'filters/TwistFilter.dart';

part 'loaders/AssetLoader.dart';
part 'loaders/AtlasLoader.dart';
part 'loaders/BitmapFontLoader.dart';
part 'loaders/ImageLoader.dart';
part 'loaders/JsonLoader.dart';
part 'loaders/SpineLoader.dart';
part 'loaders/SpriteSheetLoader.dart';

part 'primitives/Graphics.dart';

part 'renderers/canvas/CanvasRenderer.dart';
part 'renderers/canvas/CanvasGraphics.dart';
part 'renderers/canvas/utils/CanvasMaskManager.dart';
part 'renderers/canvas/utils/CanvasTinter.dart';

part 'renderers/webgl/WebGLRenderer.dart';


/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */


/* 
* 
* This file contains a lot of pixi consts which are used across the rendering engine
* @class Consts
*/
int WEBGL_RENDERER = 0;
int CANVAS_RENDERER = 1;

// useful for testing against if your lib is using pixi.
String VERSION = "v1.5.1";

// the various blend modes supported by pixi
Map blendModes = {
    'NORMAL':0,
    'ADD':1,
    'MULTIPLY':2,
    'SCREEN':3,
    'OVERLAY':4,
    'DARKEN':5,
    'LIGHTEN':6,
    'COLOR_DODGE':7,
    'COLOR_BURN':8,
    'HARD_LIGHT':9,
    'SOFT_LIGHT':10,
    'DIFFERENCE':11,
    'EXCLUSION':12,
    'HUE':13,
    'SATURATION':14,
    'COLOR':15,
    'LUMINOSITY':16
};

// the scale modes
Map scaleModes = {
    'DEFAULT':0,
    'LINEAR':0,
    'NEAREST':1
};

// interaction frequency 
int INTERACTION_FREQUENCY = 30;
bool AUTO_PREVENT_DEFAULT = true;

double RAD_TO_DEG = 180 / Math.PI;
double DEG_TO_RAD = Math.PI / 180;

var defaultRenderer;

List blendModesCanvas = [];