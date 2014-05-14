part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * This is the base class for creating a pixi.js filter. Currently only webGL supports filters.
 * If you want to make a custom filter this should be your base class.
 * @class AbstractFilter
 * @constructor
 * @param fragmentSrc
 * @param uniforms
 */
abstract class AbstractFilter{
  
  List<AbstractFilter> passes;
  
  /**
      * @property shaders
      * @type Array an array of shaders
      * @private
      */
      List shaders = [];
      
      bool dirty = true;
      double padding = 0.0;
      
      Map uniforms;
      List fragmentSrc;
  
  AbstractFilter([fragmentSrc = null, uniforms = null])
  {
    this.fragmentSrc = (fragmentSrc != null) ? fragmentSrc : [];
    this.uniforms = (uniforms != null) ? uniforms : {};
    /**
    * An array of passes - some filters contain a few steps this array simply stores the steps in a liniear fashion.
    * For example the blur filter has two passes blurX and blurY.
    * @property passes
    * @type Array an array of filter objects
    * @private
    */
    this.passes = [this];
  }
  
}
