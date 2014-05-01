part of pixi;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * A MovieClip is a simple way to display an animation depicted by a list of textures.
 *
 * @class MovieClip
 * @extends Sprite
 * @constructor
 * @param textures {Array<Texture>} an array of {Texture} objects that make up the animation
 */
class MovieClip extends Sprite {


  /**
     * The array of textures that make up the animation
     *
     * @property textures
     * @type Array
     */
  List<Texture> textures;

  /**
     * The speed that the MovieClip will play at. Higher is faster, lower is slower
     *
     * @property animationSpeed
     * @type Number
     * @default 1
     */
  double animationSpeed = 1.0;

  /**
     * Whether or not the movie clip repeats after playing.
     *
     * @property loop
     * @type Boolean
     * @default true
     */
  bool loop = true;

  /**
     * Function to call when a MovieClip finishes playing
     *
     * @property onComplete
     * @type Function
     */
  Function onComplete = null;

  /**
     * [read-only] The MovieClips current frame index (this may not have to be a whole number)
     *
     * @property currentFrame
     * @type Number
     * @default 0
     * @readOnly
     */
  double currentFrame = 0.0;

  /**
     * [read-only] Indicates if the MovieClip is currently playing
     *
     * @property playing
     * @type Boolean
     * @readOnly
     */
  bool playing = false;

  MovieClip(List<Texture> textures): super(textures[0]) {

    this.textures = textures;

  }

  /**
  * [read-only] totalFrames is the total number of frames in the MovieClip. This is the same as number of textures
  * assigned to the MovieClip.
  *
  * @property totalFrames
  * @type Number
  * @default 0
  * @readOnly
  */
  int get totalFrames => this.textures.length;


  /**
   * Stops the MovieClip
   *
   * @method stop
   */
  void stop() {
    this.playing = false;
  }

  /**
   * Plays the MovieClip
   *
   * @method play
   */
  void play() {
    this.playing = true;
  }

  /**
   * Stops the MovieClip and goes to a specific frame
   *
   * @method gotoAndStop
   * @param frameNumber {Number} frame index to stop at
   */
  void gotoAndStop(double frameNumber) {
    this.playing = false;
    this.currentFrame = frameNumber;
    double round = this.currentFrame + 0.5;
    this.setTexture(this.textures[(round % this.textures.length).toInt()]);
  }

  /**
   * Goes to a specific frame and begins playing the MovieClip
   *
   * @method gotoAndPlay
   * @param frameNumber {Number} frame index to start at
   */
  void gotoAndPlay(double frameNumber) {
    this.currentFrame = frameNumber;
    this.playing = true;
  }

  /*
   * Updates the object transform for rendering
   *
   * @method updateTransform
   * @private
   */
  void updateTransform() {
    super.updateTransform();

    if (!this.playing) return;

    this.currentFrame += this.animationSpeed;

    double round = (this.currentFrame + 0.5);

    if (this.loop || round < this.textures.length) {
      this.setTexture(this.textures[(round % this.textures.length).toInt()]);
    } else if (round >= this.textures.length) {
      this.gotoAndStop((this.textures.length - 1).toDouble());
      if (this.onComplete != null) {
        this.onComplete();
      }
    }
  }

}
