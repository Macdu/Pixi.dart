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

class _KeyValuePair<TKey,TValue>{
  
  TKey key;
  TValue value;
  
  _KeyValuePair(TKey this.key, TValue this.value);
  
  @override
  String toString(){
    return '[' + key.toString() + ' ,' + value.toString() + ']';
  }
  
}

class AnimationStateData {
		SkeletonData _skeletonData;
		Map<_KeyValuePair<Animation, Animation>, double> animationToMixTime = new Map<_KeyValuePair<Animation, Animation>, double>();
		double defaultMix;

		SkeletonData get skeletonData => skeletonData; 

		AnimationStateData (SkeletonData skeletonData) {
			this._skeletonData = skeletonData;
		}

		void setMix (fromAnimation_or_name,toAnimation_or_name, double duration) {
		  Animation from,to;
		  if(fromAnimation_or_name is String && toAnimation_or_name is String){
  			from = skeletonData.findAnimation(fromAnimation_or_name);
  			if (from == null) throw new ArgumentError("Animation not found: " + fromAnimation_or_name);
  			to = skeletonData.findAnimation(toAnimation_or_name);
  			if (to == null) throw new ArgumentError("Animation not found: " + toAnimation_or_name);
  		else if(fromAnimation_or_name is Animation && toAnimation_or_name is Animation){
  		  from = fromAnimation_or_name;
  		  to = toAnimation_or_name;
        if (from == null) throw new ArgumentError("from cannot be null.");
        if (to == null) throw new ArgumentError("to cannot be null.");
  		}
  		else throw new ArgumentError();
  			
      _KeyValuePair<Animation, Animation> key = new _KeyValuePair<Animation, Animation>(from, to);
      animationToMixTime.remove(key);
      animationToMixTime[key] = duration;
			
		}


		double getMix (Animation from, Animation to) {
			_KeyValuePair<Animation, Animation> key = new _KeyValuePair<Animation, Animation>(from, to);
			if (animationToMixTime.containsKey(key)) return animationToMixTime[key];
			return defaultMix;
		}
	}
}
