part of spine;
/******************************************************************************
 * Spine Runtimes Software License
 * Version 2
 * 
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to install, execute and perform the Spine Runtimes
 * Software (the "Software") solely for internal use. Without the written
 * permission of Esoteric Software, you may not (a) modify, translate, adapt or
 * otherwise create derivative works, improvements of the Software or develop
 * new applications using the Software or (b) remove, delete, alter or obscure
 * any trademarks or any copyright, trademark, patent or other intellectual
 * property or proprietary rights notices on or in the Software, including
 * any copy thereof. Redistributions in binary or source form must include
 * this license and terms. THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

abstract class Timeline {
  /** Sets the value(s) for the specified time. */
  apply(Skeleton skeleton, double lastTime, double time, List<Event> events, double alpha);
}

/** Base class for frames that use an interpolation bezier curve. */
abstract class CurveTimeline implements Timeline {
  static final double LINEAR = 0;
  static final double STEPPED = -1;
  static final double BEZIER = -2;
  /**/
  static final int BEZIER_SEGMENTS = 10;

  /**/
  final List<double> curves; // dfx, dfy, ddfx, ddfy, dddfx, dddfy, ...

  CurveTimeline(int frameCount) : curves = new List<double>((frameCount - 1) * 6);

  int getFrameCount() {
    return curves.length ~/ 6 + 1;
  }

  void setLinear(int frameIndex) {
    curves[frameIndex * 6] = LINEAR;
  }

  void setStepped(int frameIndex) {
    curves[frameIndex * 6] = STEPPED;
  }

  double getCurveType(int frameIndex) {
    int index = frameIndex * 6;
    if (index == curves.length) return LINEAR;
    double type = curves[index];
    if (type == LINEAR) return LINEAR;
    if (type == STEPPED) return STEPPED;
    return BEZIER;
  }

  /** Sets the control handle positions for an interpolation bezier curve used to transition from this keyframe to the next.
     * cx1 and cx2 are from 0 to 1, representing the percent of time between the two keyframes. cy1 and cy2 are the percent of
     * the difference between the keyframe's values. */
  void setCurve(int frameIndex, double cx1, double cy1, double cx2, double cy2) {
    double subdiv_step = 1.0 / BEZIER_SEGMENTS;
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
    List<double> curves = this.curves;
    curves[i] = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
    curves[i + 1] = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;
    curves[i + 2] = tmp1x * pre4 + tmp2x * pre5;
    curves[i + 3] = tmp1y * pre4 + tmp2y * pre5;
    curves[i + 4] = tmp2x * pre5;
    curves[i + 5] = tmp2y * pre5;
  }

  double getCurvePercent(int frameIndex, double percent) {
    int curveIndex = frameIndex * 6;
    List<double> curves = this.curves;
    double dfx = curves[curveIndex];
    if (dfx == LINEAR) return percent;
    if (dfx == STEPPED) return 0;
    double dfy = curves[curveIndex + 1];
    double ddfx = curves[curveIndex + 2];
    double ddfy = curves[curveIndex + 3];
    double dddfx = curves[curveIndex + 4];
    double dddfy = curves[curveIndex + 5];
    double x = dfx,
        y = dfy;
    int i = BEZIER_SEGMENTS - 2;
    while (true) {
      if (x >= percent) {
        double prevX = x - dfx;
        double prevY = y - dfy;
        return prevY + (y - prevY) * (percent - prevX) / (x - prevX);
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
  /**/
  static final int PREV_FRAME_TIME = -2;
  /**/
  static final int FRAME_VALUE = 1;

  int boneIndex;
  /**/
  final List<double> frames; // time, angle, ...

  RotateTimeline(int frameCount): super(frameCount) {
    frames = new List<double>(frameCount * 2);
  }

  void setBoneIndex(int boneIndex) {
    this.boneIndex = boneIndex;
  }

  int getBoneIndex() {
    return boneIndex;
  }

  List<double> getFrames() {
    return frames;
  }

  /** Sets the time and angle of the specified keyframe. */
  void setFrame(int frameIndex, double time, double angle) {
    frameIndex *= 2;
    frames[frameIndex] = time;
    frames[frameIndex + 1] = angle;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event> events, double alpha) {
    List<double> frames = this.frames;
    if (time < frames[0]) return; // Time is before first frame.

    Bone bone = skeleton.bones.get(boneIndex);

    if (time >= frames[frames.length - 2]) { // Time is after last frame.
      double amount = bone.data.rotation + frames[frames.length - 1] - bone.rotation;
      while (amount > 180) amount -= 360;
      while (amount < -180) amount += 360;
      bone.rotation += amount * alpha;
      return;
    }

    // Interpolate between the previous frame and the current frame.
    int frameIndex = binarySearch(frames, time, 2);
    double prevFrameValue = frames[frameIndex - 1];
    double frameTime = frames[frameIndex];
    double percent = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime), 0, 1);
    percent = getCurvePercent(frameIndex / 2 - 1, percent);

    double amount = frames[frameIndex + FRAME_VALUE] - prevFrameValue;
    while (amount > 180) amount -= 360;
    while (amount < -180) amount += 360;
    amount = bone.data.rotation + (prevFrameValue + amount * percent) - bone.rotation;
    while (amount > 180) amount -= 360;
    while (amount < -180) amount += 360;
    bone.rotation += amount * alpha;
  }
}

class TranslateTimeline extends CurveTimeline {
  static final int PREV_FRAME_TIME = -3;
  static final int FRAME_X = 1;
  static final int FRAME_Y = 2;

  int boneIndex;
  final List<double> frames; // time, x, y, ...

  TranslateTimeline(int frameCount): super(frameCount) {
    frames = new List<double>(frameCount * 3);
  }

  void setBoneIndex(int boneIndex) {
    this.boneIndex = boneIndex;
  }

  int getBoneIndex() {
    return boneIndex;
  }

  List<double> getFrames() {
    return frames;
  }

  /** Sets the time and value of the specified keyframe. */
  void setFrame(int frameIndex, double time, double x, double y) {
    frameIndex *= 3;
    frames[frameIndex] = time;
    frames[frameIndex + 1] = x;
    frames[frameIndex + 2] = y;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event> events, double alpha) {
    List<double> frames = this.frames;
    if (time < frames[0]) return; // Time is before first frame.

    Bone bone = skeleton.bones.get(boneIndex);

    if (time >= frames[frames.length - 3]) { // Time is after last frame.
      bone.x += (bone.data.x + frames[frames.length - 2] - bone.x) * alpha;
      bone.y += (bone.data.y + frames[frames.length - 1] - bone.y) * alpha;
      return;
    }

    // Interpolate between the previous frame and the current frame.
    int frameIndex = binarySearch(frames, time, 3);
    double prevFrameX = frames[frameIndex - 2];
    double prevFrameY = frames[frameIndex - 1];
    double frameTime = frames[frameIndex];
    double percent = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime), 0, 1);
    percent = getCurvePercent(frameIndex / 3 - 1, percent);

    bone.x += (bone.data.x + prevFrameX + (frames[frameIndex + FRAME_X] - prevFrameX) * percent - bone.x) * alpha;
    bone.y += (bone.data.y + prevFrameY + (frames[frameIndex + FRAME_Y] - prevFrameY) * percent - bone.y) * alpha;
  }
}

class ScaleTimeline extends TranslateTimeline {
  ScaleTimeline(int frameCount): super(frameCount) {
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event> events, double alpha) {
    List<double> frames = this.frames;
    if (time < frames[0]) return; // Time is before first frame.

    Bone bone = skeleton.bones.get(boneIndex);
    if (time >= frames[frames.length - 3]) { // Time is after last frame.
      bone.scaleX += (bone.data.scaleX - 1 + frames[frames.length - 2] - bone.scaleX) * alpha;
      bone.scaleY += (bone.data.scaleY - 1 + frames[frames.length - 1] - bone.scaleY) * alpha;
      return;
    }

    // Interpolate between the previous frame and the current frame.
    int frameIndex = binarySearch(frames, time, 3);
    double prevFrameX = frames[frameIndex - 2];
    double prevFrameY = frames[frameIndex - 1];
    double frameTime = frames[frameIndex];
    double percent = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime), 0, 1);
    percent = getCurvePercent(frameIndex / 3 - 1, percent);

    bone.scaleX += (bone.data.scaleX - 1 + prevFrameX + (frames[frameIndex + FRAME_X] - prevFrameX) * percent - bone.scaleX) * alpha;
    bone.scaleY += (bone.data.scaleY - 1 + prevFrameY + (frames[frameIndex + FRAME_Y] - prevFrameY) * percent - bone.scaleY) * alpha;
  }
}

class ColorTimeline extends CurveTimeline {
  static /**/
  final int PREV_FRAME_TIME = -5;
  static /**/
  final int FRAME_R = 1;
  static /**/
  final int FRAME_G = 2;
  static /**/
  final int FRAME_B = 3;
  static /**/
  final int FRAME_A = 4;

  int slotIndex;
  /**/
  final List<double> frames; // time, r, g, b, a, ...

  ColorTimeline(int frameCount): super(frameCount) {
    frames = new List<double>(frameCount * 5);
  }

  void setSlotIndex(int slotIndex) {
    this.slotIndex = slotIndex;
  }

  int getSlotIndex() {
    return slotIndex;
  }

  List<double> getFrames() {
    return frames;
  }

  /** Sets the time and value of the specified keyframe. */
  void setFrame(int frameIndex, double time, double r, double g, double b, double a) {
    frameIndex *= 5;
    frames[frameIndex] = time;
    frames[frameIndex + 1] = r;
    frames[frameIndex + 2] = g;
    frames[frameIndex + 3] = b;
    frames[frameIndex + 4] = a;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event> events, double alpha) {
    List<double> frames = this.frames;
    if (time < frames[0]) return; // Time is before first frame.

    Color color = skeleton.slots.get(slotIndex).color;

    if (time >= frames[frames.length - 5]) { // Time is after last frame.
      int i = frames.length - 1;
      double r = frames[i - 3];
      double g = frames[i - 2];
      double b = frames[i - 1];
      double a = frames[i];
      color.set(r, g, b, a);
      return;
    }

    // Interpolate between the previous frame and the current frame.
    int frameIndex = binarySearch(frames, time, 5);
    double prevFrameR = frames[frameIndex - 4];
    double prevFrameG = frames[frameIndex - 3];
    double prevFrameB = frames[frameIndex - 2];
    double prevFrameA = frames[frameIndex - 1];
    double frameTime = frames[frameIndex];
    double percent = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime), 0, 1);
    percent = getCurvePercent(frameIndex / 5 - 1, percent);

    double r = prevFrameR + (frames[frameIndex + FRAME_R] - prevFrameR) * percent;
    double g = prevFrameG + (frames[frameIndex + FRAME_G] - prevFrameG) * percent;
    double b = prevFrameB + (frames[frameIndex + FRAME_B] - prevFrameB) * percent;
    double a = prevFrameA + (frames[frameIndex + FRAME_A] - prevFrameA) * percent;
    if (alpha < 1) color.add((r - color.r) * alpha, (g - color.g) * alpha, (b - color.b) * alpha, (a - color.a) * alpha); else color.set(r, g, b, a);
  }
}

class AttachmentTimeline implements Timeline {
  int slotIndex;
  /**/
  final List<double> frames; // time, ...
  /**/
  final List<String> attachmentNames;

  AttachmentTimeline(int frameCount): super(frameCount) {
    frames = new List<double>(frameCount);
    attachmentNames = new List<String>(frameCount);
  }

  int getFrameCount() {
    return frames.length;
  }

  int getSlotIndex() {
    return slotIndex;
  }

  void setSlotIndex(int slotIndex) {
    this.slotIndex = slotIndex;
  }

  List<double> getFrames() {
    return frames;
  }

  List<String> getAttachmentNames() {
    return attachmentNames;
  }

  /** Sets the time and value of the specified keyframe. */
  void setFrame(int frameIndex, double time, String attachmentName) {
    frames[frameIndex] = time;
    attachmentNames[frameIndex] = attachmentName;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event> events, double alpha) {
    List<double> frames = this.frames;
    if (time < frames[0]) return; // Time is before first frame.

    int frameIndex;
    if (time >= frames[frames.length - 1]) // Time is after last frame.
    frameIndex = frames.length - 1; else frameIndex = binarySearch(frames, time, 1) - 1;

    String attachmentName = attachmentNames[frameIndex];
    skeleton.slots.get(slotIndex).setAttachment(attachmentName == null ? null : skeleton.getAttachment(slotIndex, attachmentName));
  }
}

class EventTimeline implements Timeline {
  /**/
  final List<double> frames; // time, ...
  /**/
  final List<Event> events;

  EventTimeline(int frameCount) {
    frames = new List<double>(frameCount);
    events = new List<Event>(frameCount);
  }

  int getFrameCount() {
    return frames.length;
  }

  List<double> getFrames() {
    return frames;
  }

  List<Event> getEvents() {
    return events;
  }

  /** Sets the time of the specified keyframe. */
  void setFrame(int frameIndex, double time, Event event) {
    frames[frameIndex] = time;
    events[frameIndex] = event;
  }

  /** Fires events for frames > lastTime and <= time. */
  void apply(Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
    if (firedEvents == null) return;
    List<double> frames = this.frames;
    int frameCount = frames.length;

    if (lastTime > time) { // Fire events after last time for looped animations.
      apply(skeleton, lastTime, Integer.MAX_VALUE, firedEvents, alpha);
      lastTime = -1.0;
    } else if (lastTime >= frames[frameCount - 1]) // Last time is after last frame.
    return;
    if (time < frames[0]) return; // Time is before first frame.

    int frameIndex;
    if (lastTime < frames[0]) frameIndex = 0; else {
      frameIndex = binarySearch(frames, lastTime, 1);
      double frame = frames[frameIndex];
      while (frameIndex > 0) { // Fire multiple events with the same frame.
        if (frames[frameIndex - 1] != frame) break;
        frameIndex--;
      }
    }
    for ( ; frameIndex < frameCount && time >= frames[frameIndex]; frameIndex++) firedEvents.add(events[frameIndex]);
  }
}

class DrawOrderTimeline implements Timeline {
  /**/
  final List<double> frames; // time, ...
  /**/
  final List<List<int>> drawOrders;

  DrawOrderTimeline(int frameCount) {
    frames = new List<double>(frameCount);
    drawOrders = new List<int>(frameCount);
  }

  int getFrameCount() {
    return frames.length;
  }

  List<double> getFrames() {
    return frames;
  }

  List<List<int>> getDrawOrders() {
    return drawOrders;
  }

  /** Sets the time of the specified keyframe.
     * @param drawOrder May be null to use bind pose draw order. */
  void setFrame(int frameIndex, double time, List<int> drawOrder) {
    frames[frameIndex] = time;
    drawOrders[frameIndex] = drawOrder;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
    List<double> frames = this.frames;
    if (time < frames[0]) return; // Time is before first frame.

    int frameIndex;
    if (time >= frames[frames.length - 1]) // Time is after last frame.
    frameIndex = frames.length - 1; else frameIndex = binarySearch(frames, time, 1) - 1;

    List<Slot> drawOrder = skeleton.drawOrder;
    List<Slot> slots = skeleton.slots;
    List<int> drawOrderToSetupIndex = drawOrders[frameIndex];
    if (drawOrderToSetupIndex == null) System.arraycopy(slots.items, 0, drawOrder.items, 0, slots.size); else {
      for (int i = 0,
          n = drawOrderToSetupIndex.length; i < n; i++) drawOrder.set(i, slots.get(drawOrderToSetupIndex[i]));
    }
  }
}

class FfdTimeline extends CurveTimeline {
  /**/
  final List<double> frames; // time, ...
  /**/
  final List<List<double>> frameVertices;
  int slotIndex;
  MeshAttachment meshAttachment;

  FfdTimeline(int frameCount): super(frameCount) {
    frames = new List<double>(frameCount);
    frameVertices = new List<List<double>>(frameCount);
  }

  void setSlotIndex(int slotIndex) {
    this.slotIndex = slotIndex;
  }

  int getSlotIndex() {
    return slotIndex;
  }

  void setMeshAttachment(MeshAttachment attachment) {
    this.meshAttachment = attachment;
  }

  MeshAttachment getMeshAttachment() {
    return meshAttachment;
  }

  List<double> getFrames() {
    return frames;
  }

  List<List<double>> getVertices() {
    return frameVertices;
  }

  /** Sets the time of the specified keyframe. */
  void setFrame(int frameIndex, double time, List<double> vertices) {
    frames[frameIndex] = time;
    frameVertices[frameIndex] = vertices;
  }

  void apply(Skeleton skeleton, double lastTime, double time, List<Event> firedEvents, double alpha) {
    Slot slot = skeleton.slots.get(slotIndex);
    if (slot.getAttachment() != meshAttachment) return;

    FloatList verticesList = slot.getAttachmentVertices();
    verticesList.size = 0;

    List<double> frames = this.frames;
    if (time < frames[0]) return; // Time is before first frame.

    List<List<double>> frameVertices = this.frameVertices;
    int vertexCount = frameVertices[0].length;
    verticesList.ensureCapacity(vertexCount);
    verticesList.size = vertexCount;
    List<double> vertices = verticesList.items;

    if (time >= frames[frames.length - 1]) { // Time is after last frame.
      System.arraycopy(frameVertices[frames.length - 1], 0, vertices, 0, vertexCount);
      return;
    }

    // Interpolate between the previous frame and the current frame.
    int frameIndex = binarySearch(frames, time, 1);
    double frameTime = frames[frameIndex];
    double percent = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex - 1] - frameTime), 0, 1);
    percent = getCurvePercent(frameIndex - 1, percent);

    List<double> prevVertices = frameVertices[frameIndex - 1];
    List<double> nextVertices = frameVertices[frameIndex];

    // BOZO - FFD, use alpha for mixing?
    for (int i = 0; i < vertexCount; i++) {
      double prev = prevVertices[i];
      vertices[i] = prev + (nextVertices[i] - prev) * percent;
    }
  }
}


class Animation {
  final String name;
  /**/
  final List<Timeline> timelines;
  /**/
  double duration;

  Animation(String name, List<Timeline> timelines, double duration) {
    if (name == null) throw new IllegalArgumentException("name cannot be null.");
    if (timelines == null) throw new IllegalArgumentException("timelines cannot be null.");
    this.name = name;
    this.timelines = timelines;
    this.duration = duration;
  }

  List<Timeline> getTimelines() {
    return timelines;
  }

  /** Returns the duration of the animation in seconds. */
  double getDuration() {
    return duration;
  }

  void setDuration(double duration) {
    this.duration = duration;
  }

  /** Poses the skeleton at the specified time for this animation.
	 * @param lastTime The last time the animation was applied.
	 * @param events Any triggered events are added. */
  void apply(Skeleton skeleton, double lastTime, double time, bool loop, List<Event> events) {
    if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");

    if (loop && duration != 0) {
      time %= duration;
      lastTime %= duration;
    }

    List<Timeline> timelines = this.timelines;
    for (int i = 0,
        n = timelines.size; i < n; i++) timelines.get(i).apply(skeleton, lastTime, time, events, 1);
  }

  /** Poses the skeleton at the specified time for this animation mixed with the current pose.
	 * @param lastTime The last time the animation was applied.
	 * @param events Any triggered events are added.
	 * @param alpha The amount of this animation that affects the current pose. */
  void mix(Skeleton skeleton, double lastTime, double time, bool loop, List<Event> events, double alpha) {
    if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");

    if (loop && duration != 0) {
      lastTime %= duration;
      time %= duration;
    }

    List<Timeline> timelines = this.timelines;
    for (int i = 0,
        n = timelines.size; i < n; i++) timelines.get(i).apply(skeleton, lastTime, time, events, alpha);
  }

  String getName() {
    return name;
  }

  String toString() {
    return name;
  }

  /** @param target After the first and before the last value.
	 * @return index of first value greater than the target. */
  static int binarySearch(List<double> values, double target, int step) {
    int low = 0;
    int high = values.length / step - 2;
    if (high == 0) return step;
    int current = high >> 1;
    while (true) {
      if (values[(current + 1) * step] <= target) low = current + 1; else high = current;
      if (low == high) return (low + 1) * step;
      current = (low + high) >> 1;
    }
  }

  static int linearSearch(List<double> values, double target, int step) {
    for (int i = 0,
        last = values.length - step; i <= last; i += step) if (values[i] > target) return i;
    return -1;
  }



}
