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

class SkeletonData {
  String name;
  List<BoneData> _bones = new List<BoneData>();
  List<SlotData> _slots = new List<SlotData>();
  List<Skin> skins = new List<Skin>();
  Skin defaultSkin;
  List<EventData> events = new List<EventData>();
  List<Animation> animations = new List<Animation>();

  List<BoneData> get bones => _bones; // Ordered parents first.
  List<SlotData> get slots => _slots; // Setup pose draw order.

  // --- Bones.

  void addBone(BoneData bone) {
    if (bone == null) throw new ArgumentError("bone cannot be null.");
    bones.add(bone);
  }


  /// <returns>May be null.</returns>
  BoneData findBone(String boneName) {
    if (boneName == null) throw new ArgumentError("boneName cannot be null.");
    List<BoneData> bones = this._bones;
    for (int i = 0,
        n = bones.length; i < n; i++) {
      BoneData bone = bones[i];
      if (bone.name == boneName) return bone;
    }
    return null;
  }

  /// <returns>-1 if the bone was not found.</returns>
  int findBoneIndex(String boneName) {
    if (boneName == null) throw new ArgumentError("boneName cannot be null.");
    List<BoneData> bones = this.bones;
    for (int i = 0,
        n = bones.length; i < n; i++) if (bones[i].name == boneName) return i;
    return -1;
  }

  // --- Slots.

  void addSlot(SlotData slot) {
    if (slot == null) throw new ArgumentError("slot cannot be null.");
    slots.add(slot);
  }

  /// <returns>May be null.</returns>
  SlotData findSlot(String slotName) {
    if (slotName == null) throw new ArgumentError("slotName cannot be null.");
    List<SlotData> slots = this.slots;
    for (int i = 0,
        n = slots.length; i < n; i++) {
      SlotData slot = slots[i];
      if (slot.name == slotName) return slot;
    }
    return null;
  }

  /// <returns>-1 if the bone was not found.</returns>
  int findSlotIndex(String slotName) {
    if (slotName == null) throw new ArgumentError("slotName cannot be null.");
    List<SlotData> slots = this.slots;
    for (int i = 0,
        n = slots.length; i < n; i++) if (slots[i].name == slotName) return i;
    return -1;
  }

  // --- Skins.

  void addSkin(Skin skin) {
    if (skin == null) throw new ArgumentError("skin cannot be null.");
    skins.add(skin);
  }

  /// <returns>May be null.</returns>
  Skin findSkin(String skinName) {
    if (skinName == null) throw new ArgumentError("skinName cannot be null.");
    for (Skin skin in skins) if (skin.name == skinName) return skin;
    return null;
  }

  // --- Events.

  void addEvent(EventData eventData) {
    if (eventData == null) throw new ArgumentError("eventData cannot be null.");
    events.add(eventData);
  }

  /// <returns>May be null.</returns>
  EventData findEvent(String eventDataName) {
    if (eventDataName == null) throw new ArgumentError("eventDataName cannot be null.");
    for (EventData eventData in events) if (eventData.name == eventDataName) return eventData;
    return null;
  }

  // --- Animations.

  void addAnimation(Animation animation) {
    if (animation == null) throw new ArgumentError("animation cannot be null.");
    animations.add(animation);
  }

  /// <returns>May be null.</returns>
  Animation findAnimation(String animationName) {
    if (animationName == null) throw new ArgumentError("animationName cannot be null.");
    List<Animation> animations = this.animations;
    for (int i = 0,
        n = animations.length; i < n; i++) {
      Animation animation = animations[i];
      if (animation.name == animationName) return animation;
    }
    return null;
  }

  // ---

  @override
  String toString() {
    return name != null ? name : super.toString();
  }
}
