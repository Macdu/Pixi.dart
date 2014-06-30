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

class Animation {
		List<Timeline> timelines;
		double duration;
		String _name;

		String get name => _name;

		Animation (String name, List<Timeline> timelines, double duration) {
			if (name == null) throw new ArgumentError("name cannot be null.");
			if (timelines == null) throw new ArgumentError("timelines cannot be null.");
			this._name = name;
			this.timelines = timelines;
			this.duration = duration;
		}

		/// <summary>Poses the skeleton at the specified time for this animation.</summary>
		/// <param name="lastTime">The last time the animation was applied.</param>
		/// <param name="events">Any triggered events are added.</param>
		void apply (Skeleton skeleton, double lastTime, double time, bool loop, List<Event> events) {
			if (skeleton == null) throw new ArgumentError("skeleton cannot be null.");

			if (loop && duration != 0) {
				time %= duration;
				lastTime %= duration;
			}

			List<Timeline> timelines = this.timelines;
			for (int i = 0, n = timelines.length; i < n; i++)
				timelines[i].apply(skeleton, lastTime, time, events, 1.0);
		}

		/// <summary>Poses the skeleton at the specified time for this animation mixed with the current pose.</summary>
		/// <param name="lastTime">The last time the animation was applied.</param>
		/// <param name="events">Any triggered events are added.</param>
		/// <param name="alpha">The amount of this animation that affects the current pose.</param>
		void mix(Skeleton skeleton, double lastTime, double time, bool loop, List<Event> events, double alpha) {
			if (skeleton == null) throw new ArgumentError("skeleton cannot be null.");

			if (loop && duration != 0) {
				time %= duration;
				lastTime %= duration;
			}

			List<Timeline> timelines = this.timelines;
			for (int i = 0, n = timelines.length; i < n; i++)
				timelines[i].apply(skeleton, lastTime, time, events, alpha);
		}

		/// <param name="target">After the first and before the last entry.</param>
		static int _binarySearch (List<double> values, double target, int step) {
			int low = 0;
			int high = values.length ~/ step - 2;
			if (high == 0) return step;
			int current = (high >> 1);
			while (true) {
				if (values[(current + 1) * step] <= target)
					low = current + 1;
				else
					high = current;
				if (low == high) return (low + 1) * step;
				current = (low + high) >> 1;
			}
		}

		static int _linearSearch(List<double> values, double target, int step) {
			for (int i = 0, last = values.length - step; i <= last; i += step)
				if (values[i] > target) return i;
			return -1;
		}
	}

	abstract class Timeline {
		/// <summary>Sets the value(s) for the specified time.</summary>
		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha);
	}

	/// <summary>Base class for frames that use an interpolation bezier curve.</summary>
	abstract class CurveTimeline implements Timeline {
		static const int LINEAR = 0;
		static const int STEPPED = -1;
		static const int BEZIER_SEGMENTS = 10;

		List<double> _curves; // dfx, dfy, ddfx, ddfy, dddfx, dddfy, ...
		int get frameCount => _curves.length ~/ 6 + 1;

		CurveTimeline (int frameCount) {
			_curves = new List<double>((frameCount - 1) * 6);
		}
    
		//No need
		//void apply (Skeleton skeleton, float lastTime, float time, List<Event> firedEvents, float alpha);

		void setLinear (int frameIndex) {
			_curves[frameIndex * 6] = LINEAR.toDouble();
		}

		void setStepped (int frameIndex) {
			_curves[frameIndex * 6] = STEPPED.toDouble();
		}

		/// <summary>Sets the control handle positions for an interpolation bezier curve used to transition from this keyframe to the next.
		/// cx1 and cx2 are from 0 to 1, representing the percent of time between the two keyframes. cy1 and cy2 are the percent of
		/// the difference between the keyframe's values.</summary>
		void setCurve (int frameIndex, double cx1, double cy1, double cx2, double cy2) {
			double subdiv_step = 1 / BEZIER_SEGMENTS;
			double subdiv_step2 = subdiv_step * subdiv_step;
			double subdiv_step3 = subdiv_step2 * subdiv_step;
			double pre1 = 3 * subdiv_step;
			double pre2 = 3 * subdiv_step2;
			double pre4 = 6 * subdiv_step2;
			double pre5 = 6 * subdiv_step3;
			double tmp1x = -cx1 * 2 + cx2;
			double tmp1y = -cy1 * 2 + cy2;
			double tmp2x = (cx1 - cx2) * 3 + 1;
			double tmp2y = (cy1 - cy2) * 3 + 1;
			int i = frameIndex * 6;
			List<double> curves = this._curves;
			curves[i] = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
			curves[i + 1] = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;
			curves[i + 2] = tmp1x * pre4 + tmp2x * pre5;
			curves[i + 3] = tmp1y * pre4 + tmp2y * pre5;
			curves[i + 4] = tmp2x * pre5;
			curves[i + 5] = tmp2y * pre5;
		}

		double getCurvePercent (int frameIndex, double percent) {
			int curveIndex = frameIndex * 6;
			List<double> curves = this._curves;
			double dfx = curves[curveIndex];
			if (dfx == LINEAR) return percent;
			if (dfx == STEPPED) return 0.0;
			double dfy = curves[curveIndex + 1];
			double ddfx = curves[curveIndex + 2];
			double ddfy = curves[curveIndex + 3];
			double dddfx = curves[curveIndex + 4];
			double dddfy = curves[curveIndex + 5];
			double x = dfx, y = dfy;
			int i = BEZIER_SEGMENTS - 2;
			while (true) {
				if (x >= percent) {
				  double lastX = x - dfx;
				  double lastY = y - dfy;
					return lastY + (y - lastY) * (percent - lastX) / (x - lastX);
				}
				if (i == 0) break;
				i--;
				dfx += ddfx;
				dfy += ddfy;
				ddfx += dddfx;
				ddfy += dddfy;
				x += dfx;
				y += dfy;
			}
			return y + (1 - y) * (percent - x) / (1 - x); // Last point is 1,1.
		}
	}

	class RotateTimeline extends CurveTimeline {
		static const int LAST_FRAME_TIME = -2;
		static const int FRAME_VALUE = 1;

		int boneIndex;
		List<double> frames;

		RotateTimeline (int frameCount)
			: super(frameCount) {
			frames = new List<double>(frameCount * 2);
		}

		/// <summary>Sets the time and value of the specified keyframe.</summary>
		void setFrame (int frameIndex, double time, double angle) {
			frameIndex *= 2;
			frames[frameIndex] = time;
			frames[frameIndex + 1] = angle;
		}

		@override
		void apply(Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			List<double> frames = this.frames;
			if (time < frames[0]) return; // Time is before first frame.

			Bone bone = skeleton.bones[boneIndex];

			double amount;

			if (time >= frames[frames.length - 2]) { // Time is after last frame.
				amount = bone.data.rotation + frames[frames.length - 1] - bone.rotation;
				while (amount > 180)
					amount -= 360;
				while (amount < -180)
					amount += 360;
				bone.rotation += amount * alpha;
				return;
			}

			// Interpolate between the last frame and the current frame.
			int frameIndex = Animation._binarySearch(frames, time, 2);
			double lastFrameValue = frames[frameIndex - 1];
			double frameTime = frames[frameIndex];
			double percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
			percent = getCurvePercent(frameIndex ~/ 2 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

			amount = frames[frameIndex + FRAME_VALUE] - lastFrameValue;
			while (amount > 180)
				amount -= 360;
			while (amount < -180)
				amount += 360;
			amount = bone.data.rotation + (lastFrameValue + amount * percent) - bone.rotation;
			while (amount > 180)
				amount -= 360;
			while (amount < -180)
				amount += 360;
			bone.rotation += amount * alpha;
		}
	}

	class TranslateTimeline extends CurveTimeline {
		static const int LAST_FRAME_TIME = -3;
		static const int FRAME_X = 1;
		static const int FRAME_Y = 2;

		int boneIndex;
		List<double> frames;

		TranslateTimeline (int frameCount)
			: super(frameCount) {
			frames = new List<double>(frameCount * 3);
		}

		/// <summary>Sets the time and value of the specified keyframe.</summary>
		void setFrame (int frameIndex, double time, double x, double y) {
			frameIndex *= 3;
			frames[frameIndex] = time;
			frames[frameIndex + 1] = x;
			frames[frameIndex + 2] = y;
		}

		@override
		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			List<double> frames = this.frames;
			if (time < frames[0]) return; // Time is before first frame.

			Bone bone = skeleton.bones[boneIndex];

			if (time >= frames[frames.length - 3]) { // Time is after last frame.
				bone.x += (bone.data.x + frames[frames.length - 2] - bone.x) * alpha;
				bone.y += (bone.data.y + frames[frames.length - 1] - bone.y) * alpha;
				return;
			}

			// Interpolate between the last frame and the current frame.
			int frameIndex = Animation._binarySearch(frames, time, 3);
			double lastFrameX = frames[frameIndex - 2];
			double lastFrameY = frames[frameIndex - 1];
			double frameTime = frames[frameIndex];
			double percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
			percent = getCurvePercent(frameIndex ~/ 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

			bone.x += (bone.data.x + lastFrameX + (frames[frameIndex + FRAME_X] - lastFrameX) * percent - bone.x) * alpha;
			bone.y += (bone.data.y + lastFrameY + (frames[frameIndex + FRAME_Y] - lastFrameY) * percent - bone.y) * alpha;
		}
	}

	class ScaleTimeline extends TranslateTimeline {
		ScaleTimeline (int frameCount)
			: super(frameCount) {
		}

		@override
		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			List<double> frames = this.frames;
			if (time < frames[0]) return; // Time is before first frame.

			Bone bone = skeleton.bones[boneIndex];
			if (time >= frames[frames.length - 3]) { // Time is after last frame.
				bone.scaleX += (bone.data.scaleX - 1 + frames[frames.length - 2] - bone.scaleX) * alpha;
				bone.scaleY += (bone.data.scaleY - 1 + frames[frames.length - 1] - bone.scaleY) * alpha;
				return;
			}

			// Interpolate between the last frame and the current frame.
			int frameIndex = Animation._binarySearch(frames, time, 3);
			double lastFrameX = frames[frameIndex - 2];
			double lastFrameY = frames[frameIndex - 1];
			double frameTime = frames[frameIndex];
			double percent = 1 - (time - frameTime) / (frames[frameIndex + TranslateTimeline.LAST_FRAME_TIME] - frameTime);
			percent = getCurvePercent(frameIndex ~/ 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

			bone.scaleX += (bone.data.scaleX - 1 + lastFrameX + (frames[frameIndex + TranslateTimeline.FRAME_X] - lastFrameX) * percent - bone.scaleX) * alpha;
			bone.scaleY += (bone.data.scaleY - 1 + lastFrameY + (frames[frameIndex + TranslateTimeline.FRAME_Y] - lastFrameY) * percent - bone.scaleY) * alpha;
		}
	}

	class ColorTimeline extends CurveTimeline {
		static const int LAST_FRAME_TIME = -5;
		static const int FRAME_R = 1;
		static const int FRAME_G = 2;
		static const int FRAME_B = 3;
		static const int FRAME_A = 4;

		int slotIndex;
		List<double> frames;

		ColorTimeline (int frameCount)
			: super(frameCount) {
			frames = new List<double>(frameCount * 5);
		}

		/// <summary>Sets the time and value of the specified keyframe.</summary>
		void setFrame (int frameIndex, double time, double r, double g, double b, double a) {
			frameIndex *= 5;
			frames[frameIndex] = time;
			frames[frameIndex + 1] = r;
			frames[frameIndex + 2] = g;
			frames[frameIndex + 3] = b;
			frames[frameIndex + 4] = a;
		}

		@override
		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			List<double> frames = this.frames;
			if (time < frames[0]) return; // Time is before first frame.

			double r, g, b, a;
			if (time >= frames[frames.length - 5]) {
				// Time is after last frame.
				int i = frames.length - 1;
				r = frames[i - 3];
				g = frames[i - 2];
				b = frames[i - 1];
				a = frames[i];
			} else {
				// Interpolate between the last frame and the current frame.
				int frameIndex = Animation._binarySearch(frames, time, 5);
				double lastFrameR = frames[frameIndex - 4];
				double lastFrameG = frames[frameIndex - 3];
				double lastFrameB = frames[frameIndex - 2];
				double lastFrameA = frames[frameIndex - 1];
				double frameTime = frames[frameIndex];
				double percent = 1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime);
				percent = getCurvePercent(frameIndex ~/ 5 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

				r = lastFrameR + (frames[frameIndex + FRAME_R] - lastFrameR) * percent;
				g = lastFrameG + (frames[frameIndex + FRAME_G] - lastFrameG) * percent;
				b = lastFrameB + (frames[frameIndex + FRAME_B] - lastFrameB) * percent;
				a = lastFrameA + (frames[frameIndex + FRAME_A] - lastFrameA) * percent;
			}
			Slot slot = skeleton.slots[slotIndex];
			if (alpha < 1) {
				slot.r += (r - slot.r) * alpha;
				slot.g += (g - slot.g) * alpha;
				slot.b += (b - slot.b) * alpha;
				slot.a += (a - slot.a) * alpha;
			} else {
				slot.r = r;
				slot.g = g;
				slot.b = b;
				slot.a = a;
			}
		}
	}

	class AttachmentTimeline implements Timeline {
		int slotIndex;
		List<double> frames;
		List<String> attachmentNames;

		int get frameCount => frames.length; 

		AttachmentTimeline (int frameCount) {
			frames = new List<double>(frameCount);
			attachmentNames = new List<String>(frameCount);
		}

		/// <summary>Sets the time and value of the specified keyframe.</summary>
		void setFrame (int frameIndex, double time, String attachmentName) {
			frames[frameIndex] = time;
			attachmentNames[frameIndex] = attachmentName;
		}

		@override
		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			List<double> frames = this.frames;
			if (time < frames[0]) return; // Time is before first frame.

			int frameIndex;
			if (time >= frames[frames.length - 1]) // Time is after last frame.
				frameIndex = frames.length - 1;
			else
				frameIndex = Animation._binarySearch(frames, time, 1) - 1;

			String attachmentName = attachmentNames[frameIndex];
			skeleton.slots[slotIndex].attachment =
				 attachmentName == null ? null : skeleton.getAttachment(slotIndex, attachmentName);
		}
	}

	class EventTimeline extends Timeline {
		List<double> frames;
		List<Event> events;

		int get frameCount => frames.length;

		EventTimeline (int frameCount) {
			frames = new List<double>(frameCount);
			events = new List<Event>(frameCount);
		}

		/// <summary>Sets the time and value of the specified keyframe.</summary>
		void setFrame (int frameIndex, double time, Event e) {
			frames[frameIndex] = time;
			events[frameIndex] = e;
		}

		/// <summary>Fires events for frames > lastTime and <= time.</summary>
		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			if (firedEvents == null) return;
			List<double> frames = this.frames;
			int frameCount = frames.length;

			if (lastTime > time) { // Fire events after last time for looped animations.
				this.apply(skeleton, lastTime, double.MAX_FINITE, firedEvents, alpha);
				lastTime = -1.0;
			} else if (lastTime >= frames[frameCount - 1]) // Last time is after last frame.
				return;
			if (time < frames[0]) return; // Time is before first frame.

			int frameIndex;
			if (lastTime < frames[0])
				frameIndex = 0;
			else {
				frameIndex = Animation._binarySearch(frames, lastTime, 1);
				double frame = frames[frameIndex];
				while (frameIndex > 0) { // Fire multiple events with the same frame.
					if (frames[frameIndex - 1] != frame) break;
					frameIndex--;
				}
			}
			for (; frameIndex < frameCount && time >= frames[frameIndex]; frameIndex++)
				firedEvents.add(events[frameIndex]);
		}
	}

	class DrawOrderTimeline implements Timeline {
		List<double> frames;
		List<List<int>> drawOrders;

		int get frameCount => frames.length;

		DrawOrderTimeline (int frameCount) {
			frames = new List<double>(frameCount);
			drawOrders = new List<List<int>>(frameCount);
		}

		/// <summary>Sets the time and value of the specified keyframe.</summary>
		/// <param name="drawOrder">May be null to use bind pose draw order.</param>
		void setFrame(int frameIndex, double time, List<int> drawOrder) {
			frames[frameIndex] = time;
			drawOrders[frameIndex] = drawOrder;
		}

		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			List<double> frames = this.frames;
			if (time < frames[0]) return; // Time is before first frame.

			int frameIndex;
			if (time >= frames[frames.length - 1]) // Time is after last frame.
				frameIndex = frames.length - 1;
			else
				frameIndex = Animation._binarySearch(frames, time, 1) - 1;

			List<Slot> drawOrder = skeleton.drawOrder;
			List<Slot> slots = skeleton.slots;
			List<int> drawOrderToSetupIndex = drawOrders[frameIndex];
			if (drawOrderToSetupIndex == null) {
				drawOrder.clear();
				drawOrder.addAll(slots);
			} else {
				for (int i = 0, n = drawOrderToSetupIndex.length; i < n; i++)
					drawOrder[i] = slots[drawOrderToSetupIndex[i]];
			}
		}
	}

	class FFDTimeline extends CurveTimeline {
		int slotIndex;
		List<double> frames;
		List<List<double>> frameVertices;
		Attachment attachment;

		FFDTimeline (int frameCount)
			: super(frameCount) {
			frames = new List<double>(frameCount);
			frameVertices = new List<List<double>>(frameCount);
		}

		/// <summary>Sets the time and value of the specified keyframe.</summary>
		void setFrame (int frameIndex, double time, List<double> vertices) {
			frames[frameIndex] = time;
			frameVertices[frameIndex] = vertices;
		}

		@override
		void apply (Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
			Slot slot = skeleton.slots[slotIndex];
			if (slot.attachment != attachment) return;

			List<double> frames = this.frames;
			if (time < frames[0]) {
				slot.attachmentVerticesCount = 0;
				return; // Time is before first frame.
			}

			List<List<double>> frameVertices = this.frameVertices;
			int vertexCount = frameVertices[0].length;

			List<double> vertices = slot.attachmentVertices;
			if (vertices.length < vertexCount) {
				vertices = new List<double>(vertexCount);
				slot.attachmentVertices = vertices;
			}
			slot.attachmentVerticesCount = vertexCount;

			if (time >= frames[frames.length - 1]) { // Time is after last frame.
				List<double> lastVertices = frameVertices[frames.length - 1];
				if (alpha < 1) {
					for (int i = 0; i < vertexCount; i++)
						vertices[i] += (lastVertices[i] - vertices[i]) * alpha;
				} else
				  vertices.insertAll(0, lastVertices.sublist(0,vertexCount));
				return;
			}

			// Interpolate between the previous frame and the current frame.
			int frameIndex = Animation._binarySearch(frames, time, 1);
			double frameTime = frames[frameIndex];
			double percent = 1 - (time - frameTime) / (frames[frameIndex - 1] - frameTime);
			percent = getCurvePercent(frameIndex - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

			List<double> prevVertices = frameVertices[frameIndex - 1];
			List<double> nextVertices = frameVertices[frameIndex];

			if (alpha < 1) {
				for (int i = 0; i < vertexCount; i++) {
					double prev = prevVertices[i];
					vertices[i] += (prev + (nextVertices[i] - prev) * percent - vertices[i]) * alpha;
				}
			} else {
				for (int i = 0; i < vertexCount; i++) {
					double prev = prevVertices[i];
					vertices[i] = prev + (nextVertices[i] - prev) * percent;
				}
			}
		}
	}

