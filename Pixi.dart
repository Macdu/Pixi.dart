library pixi;

import 'dart:math' as Math;
import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';

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
part 'extras/Spine.dart';
part 'extras/Strip.dart';
part 'extras/TilingSprite.dart';

part 'filters/AbstractFilter.dart';
part 'filters/AlphaMaskFilter.dart';

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