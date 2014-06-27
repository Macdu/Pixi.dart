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

class Skeleton {

  SkeletonData _data;
  List<Bone> _bones;
  List<Slot> _slots;
  List<Slot> _drawOrder;
  Skin skin;
  double r = 1.0,
      g = 1.0,
      b = 1.0,
      a = 1.0;
  double time;
  bool flipX, flipY;
  double x, y;

  SkeletonData get data => _data;
  List<Bone> get bones => _bones;
  List<Slot> get slots => _slots;
  List<Slot> get drawOrder => _drawOrder;
  Bone get rootBone => _bones.length == 0 ? null : _bones[0];

  Skeleton(SkeletonData data) {
    if (data == null) throw new ArgumentError("data cannot be null.");
    this._data = data;

    _bones = new List<Bone>(data.bones.length);
    for (BoneData boneData in data.bones) {
      Bone parent = boneData.parent == null ? null : bones[data.bones.indexOf(boneData.parent)];
      bones.add(new Bone(boneData, parent));
    }

    _slots = new List<Slot>(data.slots.length);
    _drawOrder = new List<Slot>(data.slots.length);
    for (SlotData slotData in data.slots) {
      Bone bone = bones[data.bones.indexOf(slotData.boneData)];
      Slot slot = new Slot(slotData, this, bone);
      slots.add(slot);
      drawOrder.add(slot);
    }
  }

  /// <summary>Updates the world transform for each bone.</summary>
  void updateWorldTransform() {
    bool flipX = this.flipX;
    bool flipY = this.flipY;
    List<Bone> bones = this._bones;
    for (int i = 0,
        n = bones.length; i < n; i++) bones[i].updateWorldTransform(flipX, flipY);
  }

  /// <summary>Sets the bones and slots to their setup pose values.</summary>
  void setToSetupPose() {
    setBonesToSetupPose();
    setSlotsToSetupPose();
  }

  void setBonesToSetupPose() {
    List<Bone> bones = this._bones;
    for (int i = 0,
        n = bones.length; i < n; i++) bones[i].setToSetupPose();
  }

  void setSlotsToSetupPose() {
    List<Slot> slots = this.slots;
    drawOrder.clear();
    drawOrder.addAll(slots);
    for (int i = 0,
        n = slots.length; i < n; i++) slots[i].setToSetupPose(i);
  }

  /// <returns>May be null.</returns>
  Bone findBone(String boneName) {
    if (boneName == null) throw new ArgumentError("boneName cannot be null.");
    List<Bone> bones = this._bones;
    for (int i = 0,
        n = bones.length; i < n; i++) {
      Bone bone = bones[i];
      if (bone.data.name == boneName) return bone;
    }
    return null;
  }

  /// <returns>-1 if the bone was not found.</returns>
  int findBoneIndex(String boneName) {
    if (boneName == null) throw new ArgumentError("boneName cannot be null.");
    List<Bone> bones = this._bones;
    for (int i = 0,
        n = bones.length; i < n; i++) if (bones[i].data.name == boneName) return i;
    return -1;
  }

  /// <returns>May be null.</returns>
  Slot findSlot(String slotName) {
    if (slotName == null) throw new ArgumentError("slotName cannot be null.");
    List<Slot> slots = this.slots;
    for (int i = 0,
        n = slots.length; i < n; i++) {
      Slot slot = slots[i];
      if (slot.data.name == slotName) return slot;
    }
    return null;
  }

  /// <returns>-1 if the bone was not found.</returns>
  int findSlotIndex(String slotName) {
    if (slotName == null) throw new ArgumentError("slotName cannot be null.");
    List<Slot> slots = this.slots;
    for (int i = 0,
        n = slots.length; i < n; i++) if (slots[i].data.name.equals(slotName)) return i;
    return -1;
  }

  /// <summary>Sets a skin by name (see SetSkin).</summary>
  void setSkinFromName(String skinName) {
    Skin skin = data.findSkin(skinName);
    if (skin == null) throw new ArgumentError("Skin not found: " + skinName);
    setSkin(skin);
  }

  /// <summary>Sets the skin used to look up attachments not found in the {@link SkeletonData#getDefaultSkin() default skin}. Attachments
  /// from the new skin are attached if the corresponding attachment from the old skin was attached. If there was no old skin, each slot's
  /// setup mode attachment is attached from the new skin.</summary>
  /// <param name="newSkin">May be null.</param>
  void setSkin(Skin newSkin) {
    if (newSkin != null) {
      if (skin != null) newSkin.AttachAll(this, skin); else {
        List<Slot> slots = this.slots;
        for (int i = 0,
            n = slots.length; i < n; i++) {
          Slot slot = slots[i];
          String name = slot.data.attachmentName;
          if (name != null) {
            Attachment attachment = newSkin.getAttachment(i, name);
            if (attachment != null) slot.attachment = attachment;
          }
        }
      }
    }
    skin = newSkin;
  }

  /// <returns>May be null.</returns>
  Attachment getAttachmentFromName(String slotName, String attachmentName) {
    return getAttachment(data.FindSlotIndex(slotName), attachmentName);
  }

  /// <returns>May be null.</returns>
  Attachment getAttachment(int slotIndex, String attachmentName) {
    if (attachmentName == null) throw new ArgumentError("attachmentName cannot be null.");
    if (skin != null) {
      Attachment attachment = skin.getAttachment(slotIndex, attachmentName);
      if (attachment != null) return attachment;
    }
    if (data.defaultSkin != null) return data.defaultSkin.getAttachment(slotIndex, attachmentName);
    return null;
  }

  /// <param name="attachmentName">May be null.</param>
  void setAttachment(String slotName, String attachmentName) {
    if (slotName == null) throw new ArgumentError("slotName cannot be null.");
    List<Slot> slots = this.slots;
    for (int i = 0,
        n = slots.length; i < n; i++) {
      Slot slot = slots[i];
      if (slot.data.name == slotName) {
        Attachment attachment = null;
        if (attachmentName != null) {
          attachment = getAttachment(i, attachmentName);
          if (attachment == null) throw new Exception("Attachment not found: " + attachmentName + ", for slot: " + slotName);
        }
        slot.Attachment = attachment;
        return;
      }
    }
    throw new Exception("Slot not found: " + slotName);
  }

  void update(double delta) {
    time += delta;
  }
}
