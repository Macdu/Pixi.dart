part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */

/**
 * This helper function will automatically detect which renderer you should be using.
 * WebGL is the preferred renderer as it is a lot faster. If webGL is not supported by
 * the browser then this function will return a canvas renderer
 * @class autoDetectRenderer
 * @static
 * @param width=800 {Number} the width of the renderers view
 * @param height=600 {Number} the height of the renderers view
 * @param [view] {Canvas} the canvas to use as a view, optional 
 * @param [transparent=false] {Boolean} the transparency of the render view, default false
 * @param [antialias=false] {Boolean} sets antialias (only applicable in webGL chrome at the moment)
 *
 */
Renderer autoDetectRenderer([int width = 800,int height = 600,CanvasElement view = null,bool transparent = false,bool antialias = false])
{

    // BORROWED from Mr Doob (mrdoob.com)
    bool webgl = ( () { try {
                                    CanvasElement canvas = new CanvasElement();
                                    return  ( canvas.getContext( 'webgl' ) != null || canvas.getContext( 'experimental-webgl' ) != null);
                                } catch( e ) {
                                    return false;
                                }
                            } )();


    if( webgl )
    {
        return new WebGLRenderer(width, height, view, transparent, antialias);
    }

    return  new CanvasRenderer(width, height, view, transparent);
}
