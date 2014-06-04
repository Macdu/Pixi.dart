part of spine;
/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.1
 * 
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to install, execute and perform the Spine Runtimes
 * Software (the "Software") solely for internal use. Without the written
 * permission of Esoteric Software (typically granted by licensing Spine), you
 * may not (a) modify, translate, adapt or otherwise create derivative works,
 * improvements of the Software or develop new applications using the Software
 * or (b) remove, delete, alter or obscure any trademarks or any copyright,
 * trademark, patent or other intellectual property or proprietary rights
 * notices on or in the Software, including any copy thereof. Redistributions
 * in binary or source form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/
typedef void StartEndDelegate(AnimationState state, int trackIndex);
typedef void EventDelegate(AnimationState state, int trackIndex, Event e);
typedef void CompleteDelegate(AnimationState state, int trackIndex, int loopCount);

class AnimationState {
		AnimationStateData _data;
		List<TrackEntry> _tracks = new List<TrackEntry>();
		List<Event>_events = new List<Event>();
		double timeScale = 1.0;

		AnimationStateData get data => data;

		
		List<StartEndDelegate> start = [];
		List<StartEndDelegate> end = [];

		List<EventDelegate> event = [];
		
		
		List<CompleteDelegate> complete = [];

		AnimationState (AnimationStateData data) {
			if (data == null) throw new ArgumentError("data cannot be null.");
			this._data = data;
		}

		void update (double delta) {
			delta *= timeScale;
			for (int i = 0; i < _tracks.length; i++) {
				TrackEntry current = _tracks[i];
				if (current == null) continue;

        double trackDelta = delta * current.timeScale;
        double time = current.time + trackDelta;
        double endTime = current.endTime;

				current.time = time;
				if (current._previous != null) {
					current._previous.time += trackDelta;
					current._mixTime += trackDelta;
				}

				// Check if completed the animation or a loop iteration.
				if (current.loop ? (current.lastTime % endTime > time % endTime) : (current.lastTime < endTime && time >= endTime)) {
					int count = (time ~/ endTime);
					current._onComplete(this, i, count);
					if (complete.isNotEmpty) complete.forEach((CompleteDelegate complete) => complete(this, i, count));
				}

				TrackEntry next = current._next;
				if (next != null) {
					next.time = current.lastTime - next.delay;
					if (next.time >= 0) _setCurrent(i, next);
				} else {
					// End non-looping animation when it reaches its end time and there is no next entry.
					if (!current.loop && current.lastTime >= current.endTime) clearTrack(i);
				}
			}
		}

		void apply (Skeleton skeleton) {
			List<Event> events = this.events;

			for (int i = 0; i < _tracks.length; i++) {
				TrackEntry current = _tracks[i];
				if (current == null) continue;

				events.clear();

				double time = current.time;
				bool loop = current.loop;
				if (!loop && time > current.endTime) time = current.endTime;

				TrackEntry previous = current._previous;
				if (previous == null) {
					if (current.mix == 1)
						current._animation.apply(skeleton, current.lastTime, time, loop, events);
					else
						current._animation.mix(skeleton, current.lastTime, time, loop, events, current.mix);
				} else {
				  double previousTime = previous.time;
					if (!previous.loop && previousTime > previous.endTime) previousTime = previous.endTime;
					previous._animation.apply(skeleton, previousTime, previousTime, previous.loop, null);

					double alpha = current._mixTime / current._mixDuration * current.mix;
					if (alpha >= 1) {
						alpha = 1.0;
						current._previous = null;
					}
					current._animation.mix(skeleton, current.lastTime, time, loop, events, alpha);
				}

				for (int ii = 0, nn = events.length; ii < nn; ii++) {
					Event e = events[ii];
					current._onEvent(this, i, e);
					if (event.isNotEmpty) event.forEach((EventDelegate event) => event(this, i, e));
				}

				current.lastTime = current.time;
			}
		}

		void clearTracks () {
			for (int i = 0, n = _tracks.length; i < n; i++)
				clearTrack(i);
			_tracks.clear();
		}

		void clearTrack (int trackIndex) {
			if (trackIndex >= _tracks.length) return;
			TrackEntry current = _tracks[trackIndex];
			if (current == null) return;

			current._onEnd(this, trackIndex);
			if (end.isNotEmpty) end.forEach((StartEndDelegate end) => end(this, trackIndex));

			_tracks[trackIndex] = null;
		}

		TrackEntry _expandToIndex (int index) {
			if (index < _tracks.length) return _tracks[index];
			while (index >= _tracks.length)
				_tracks.add(null);
			return null;
		}

		void _setCurrent (int index, TrackEntry entry) {
			TrackEntry current = _expandToIndex(index);
			if (current != null) {
				TrackEntry previous = current._previous;
				current._previous = null;

				current._onEnd(this, index);
				if (end.isNotEmpty) end.forEach((StartEndDelegate end) => end(this, index));

				entry._mixDuration = data.getMix(current._animation, entry._animation);
				if (entry._mixDuration > 0) {
					entry._mixTime = 0.0;
					// If a mix is in progress, mix from the closest animation.
					if (previous != null && current._mixTime / current._mixDuration < 0.5)
						entry._previous = previous;
					else
						entry._previous = current;
				}
			}

			_tracks[index] = entry;

			entry._onStart(this, index);
			if (start.isNotEmpty)start.forEach((StartEndDelegate start) => start(this, index));
		}

		///[animationName_or_animation] has to be a [String] or an [Animation]
		///<summary>Set the current animation. Any queued animations are cleared.</summary>
		TrackEntry setAnimation (int trackIndex, animationName_or_animation, bool loop) {
		  Animation animation;
		  if(animationName_or_animation is String){
  			animation = data.skeletonData.findAnimation(animationName_or_animation);
  			if (animation == null) throw new ArgumentError("Animation not found: " + animationName_or_animation);
		  }
  	  else if(animationName_or_animation is Animation)
  	    animation = animationName_or_animation;
		  TrackEntry entry = new TrackEntry();
      entry._animation = animation;
      entry.loop = loop;
      entry.time = 0.0;
      entry.endTime = animation.duration;
      _setCurrent(trackIndex, entry);
      return entry;
		}

  ///[animationName_or_animation] has to be a [String] or an [Animation]
  /// <summary>Adds an animation to be played delay seconds after the current or last queued animation.</summary>
  /// <param name="delay">May be <= 0 to use duration of previous animation minus any mix duration plus the negative delay.</param>
  TrackEntry addAnimation (int trackIndex, animationName_or_animation, bool loop, double delay) {
		  Animation animation;
      if(animationName_or_animation is String){
        animation = data.skeletonData.findAnimation(animationName_or_animation);
        if (animation == null) throw new ArgumentError("Animation not found: " + animationName_or_animation);
      }
      else if(animationName_or_animation is Animation)
        animation = animationName_or_animation;
      
      TrackEntry entry = new TrackEntry();
      entry._animation = animation;
      entry.loop = loop;
      entry.time = 0.0;
      entry.endTime = animation.duration;

      TrackEntry last = _expandToIndex(trackIndex);
      if (last != null) {
        while (last._next != null)
          last = last._next;
        last._next = entry;
      } else
        _tracks[trackIndex] = entry;

      if (delay <= 0) {
        if (last != null)
          delay += last.endTime - data.GetMix(last._animation, animation);
        else
          delay = 0.0;
      }
      entry.delay = delay;

      return entry;
      
		}


		/// <returns>May be null.</returns>
		TrackEntry getCurrent (int trackIndex) {
			if (trackIndex >= _tracks.length) return null;
			return _tracks[trackIndex];
		}

		@override
		String toString () {
			StringBuffer buffer = new StringBuffer();
			for (int i = 0, n = _tracks.length; i < n; i++) {
				TrackEntry entry = _tracks[i];
				if (entry == null) continue;
				if (buffer.length > 0) buffer.write(", ");
				buffer.write(entry.toString());
			}
			if (buffer.length == 0) return "<none>";
			return buffer.toString();
		}
	}

	class TrackEntry {
		TrackEntry _next, _previous;
		Animation _animation;
		bool loop;
		double delay, time, lastTime = -1.0, endTime, timeScale = 1.0;
		double _mixTime, _mixDuration, mix = 1.0;

		Animation get animation => _animation;

    List<StartEndDelegate> start = [];
    List<StartEndDelegate> end = [];

    List<EventDelegate> event = [];
    
    
    List<CompleteDelegate> complete = [];

		void _onStart (AnimationState state, int index) {
			if (start.isNotEmpty) start.forEach((StartEndDelegate start) => start(state, index));
		}

		void _onEnd (AnimationState state, int index) {
			if (end.isNotEmpty) end.forEach((StartEndDelegate end) => end(state, index));
		}

		void _onEvent (AnimationState state, int index, Event e) {
			if (event.isNotEmpty) event.forEach((EventDelegate event) => event(state, index, e));
		}

		void _onComplete (AnimationState state, int index, int loopCount) {
			if (complete.isNotEmpty) complete.forEach((CompleteDelegate complete) => complete(state, index, loopCount));
		}

		@override
    String toString () {
			return animation == null ? "<none>" : animation.name;
		}
	}

