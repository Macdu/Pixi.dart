part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 *
 * The BlurFilter applies a Gaussian blur to an object.
 * The strength of the blur can be set for x- and y-axis separately (always relative to the stage).
 *
 * @class BlurFilter
 * @contructor
 */
class BlurFilter {

  BlurXFilter blurXFilter;
  BlurYFilter blurYFilter;

  List<AbstractFilter> passes;

  BlurFilter() {
    this.blurXFilter = new PIXI.BlurXFilter();
    this.blurYFilter = new PIXI.BlurYFilter();

    this.passes = [this.blurXFilter, this.blurYFilter];
  }

  /**
   * Sets the strength of both the blurX and blurY properties simultaneously
   *
   * @property blur
   * @type Number the strength of the blur
   * @default 2
   */
  double get blur => this.blurXFilter.blur;
  set blur(double value) => this.blurXfilter = this.blurYFilter = value;

  /**
   * Sets the strength of the blurX property
   *
   * @property blurX
   * @type Number the strength of the blurX
   * @default 2
   */
  double get blurX => this.blurXFilter.blur;
  set blurX(double value) => this.blurXfilter = value;

  /**
   * Sets the strength of the blurX property
   *
   * @property blurY
   * @type Number the strength of the blurY
   * @default 2
   */
  double get blurY => this.blurYFilter.blur;
  set blurY(double value) => this.blurYFilter = value;

}
