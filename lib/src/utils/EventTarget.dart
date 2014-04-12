part of pixi;
/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */
 
/**
 * https://github.com/mrdoob/eventtarget.js/
 * THankS mr DOob!
 */

/**
 * Adds event emitter functionality to a class
 *
 * @class EventTarget
 * @example
 *      function MyEmitter() {
 *          PIXI.EventTarget.call(this); //mixes in event target stuff
 *      }
 *
 *      var em = new MyEmitter();
 *      em.emit({ type: 'eventName', data: 'some data' });
 */
class EventTarget{
  
  /**
       * Holds all the listeners
       *
       * @property listeneners
       * @type Object
       */
      Map<String,List<Function>> listeners = {};

    /**
     * Adds a listener for a specific event
     *
     * @method addEventListener
     * @param type {string} A string representing the event type to listen for.
     * @param listener {function} The callback function that will be fired when the event occurs
     */
    void listen(String type,Function listener ) {


        if (!listeners.containsKey('type')) {

            listeners[ type ] = [];

        }

        if ( listeners[ type ].indexOf( listener ) == - 1 ) {

            listeners[ type ].add( listener );
        }

    }

    /**
     * Fires the event, ie pretends that the event has happened
     *
     * @method dispatchEvent
     * @param event {Event} the event object
     */
    void fire(Map<String,dynamic> event ) {

        if ( !listeners.containsKey(event['type']) || listeners[event['type']].length == 0 ) {

            return;

        }

        for(int i = 0, l = listeners[ event['type'] ].length; i < l; i++) {

            listeners[ event['type'] ][ i ]( event );

        }

    }

    /**
     * Removes the specified listener that was assigned to the specified event type
     *
     * @method removeEventListener
     * @param type {string} A string representing the event type which will have its listener removed
     * @param listener {function} The callback function that was be fired when the event occured
     */
    void stopListen( String type,Function listener ) {

        int index = listeners[ type ].indexOf( listener );

        if ( index != - 1 ) {

            listeners[ type ].remove( index );

        }

    }

    /**
     * Removes all the listeners that were active for the specified event type
     *
     * @method removeAllEventListeners
     * @param type {string} A string representing the event type which will have all its listeners removed
     */
	void removeAllEventListeners(String type ) {
		listeners[type].length = 0;
		
	}
}
