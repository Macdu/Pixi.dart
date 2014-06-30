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

class SkeletonJson{
  
  final AttachmentLoader attachmentLoader;
  double scale = 1.0;

  SkeletonJson(AttachmentLoader this.attachmentLoader);
  
  
  SkeletonData readSkeletonData(Map root) {
    SkeletonData skeletonData = new SkeletonData();

    // Bones.
    List<Map> bones = root["bones"];
    for (int i = 0, n = bones.length; i < n; i++) {
      Map boneMap = bones[i];
      BoneData parent = null;
      if (boneMap.containsKey("parent")) {
        parent = skeletonData.findBone(boneMap["parent"]);
        if (parent == null) throw new Exception("Parent bone not found: " + boneMap["parent"]);
      }
      BoneData boneData = new BoneData(boneMap["name"], parent);
      boneData.length = (boneMap.containsKey('length') ? boneMap["length"] : 0) * this.scale;
      boneData.x = (boneMap.containsKey('x') ? boneMap["x"] : 0) * this.scale;
      boneData.y = (boneMap.containsKey('y') ? boneMap["y"] : 0) * this.scale;
      boneData.rotation = (boneMap.containsKey('rotation') ? boneMap["rotation"] : 0);
      boneData.scaleX = boneMap.containsKey("scaleX") ? boneMap["scaleX"] : 1;
      boneData.scaleY = boneMap.containsKey("scaleY") ? boneMap["scaleY"] : 1;
      boneData.inheritScale = !boneMap.containsKey("inheritScale") || boneMap["inheritScale"] == "true";
      boneData.inheritRotation = !boneMap.containsKey("inheritRotation") || boneMap["inheritRotation"] == "true";
      skeletonData.bones.add(boneData);
    }

    // Slots.
    List slots = root["slots"];
    for (int i = 0, n = slots.length; i < n; i++) {
      Map slotMap = slots[i];
      BoneData boneData = skeletonData.findBone(slotMap["bone"]);
      if (boneData == null) throw new Exception("Slot bone not found: " + slotMap["bone"]);
      SlotData slotData = new SlotData(slotMap["name"], boneData);

      if (slotMap.containsKey("color")) {
        String color = slotMap["color"];
        slotData.r = this.toColor(color, 0);
        slotData.g = this.toColor(color, 1);
        slotData.b = this.toColor(color, 2);
        slotData.a = this.toColor(color, 3);
      }

      slotData.attachmentName = slotMap["attachment"];
      slotData.additiveBlending = slotMap.containsKey("additive") && slotMap["additive"] == "true";

      skeletonData.slots.add(slotData);
    }

    // Skins.
    Map skins = root["skins"];
    skins.forEach((String skinName, Map skinMap){
      Skin skin = new Skin(skinName);
      skinMap.forEach((String slotName, Map slotEntry){
        int slotIndex = skeletonData.findSlotIndex(slotName);
        slotEntry.forEach((String attachmentName, attachmentMap){
          var attachment = this.readAttachment(skin, attachmentName, slotEntry[attachmentName]);
          if (attachment != null) skin.addAttachment(slotIndex, attachmentName, attachment);
        });
      });
      skeletonData.skins.add(skin);
      if (skin.name == "default") skeletonData.defaultSkin = skin;
    });

    // Events.
    Map events = root["events"];
    events.forEach((String eventName,Map eventMap){
      EventData eventData = new EventData(eventName);
      eventData.integer = eventMap.containsKey('int') ? eventMap["int"] : 0;
      eventData.float = eventMap.containsKey('float') ? eventMap["float"] : 0.0;
      eventData.string = eventMap.containsKey('string') ? eventMap["string"] : null;
      skeletonData.events.add(eventData);
    });

    // Animations.
    Map animations = root["animations"];
    animations.forEach((String animationName,Map animationMap){
      this.readAnimation(animationName, animationMap, skeletonData);
    });
    

    return skeletonData;
  }
  
  
  Attachment readAttachment(Skin skin,String name,Map map) {
    name = map.containsKey('name') ? map["name"] : name;

    String type = map.containsKey('type') ? map["type"] : "region";
    String path = map.containsKey('path') ? map["path"] : name;

    double scale = this.scale;
    if (type == 'region') {
      RegionAttachment region = this.attachmentLoader.newRegionAttachment(skin, name, path);
      if (region == null) return null;
      region.path = path;
      region.x = (map.containsKey('x') ? map["x"] : 0) * this.scale;
      region.y = (map.containsKey('y') ? map["y"] : 0) * this.scale;
      region.scaleX = map.containsKey("scaleX") ? map["scaleX"] : 1.0;
      region.scaleY = map.containsKey("scaleY") ? map["scaleY"] : 1.0;
      region.rotation = map.containsKey('rotation') ? map["rotation"] : 0;
      region.width = (map.containsKey('width') ? map["width"] : 0) * scale;
      region.height = (map.containsKey('height') ? map["height"] : 0) * scale;

      if (map.containsKey('color')) {
        String color = map["color"];
        region.r = this.toColor(color, 0);
        region.g = this.toColor(color, 1);
        region.b = this.toColor(color, 2);
        region.a = this.toColor(color, 3);
      }

      region.updateOffset();
      return region;
    } else if (type == 'mesh') {
      MeshAttachment mesh = this.attachmentLoader.newMeshAttachment(skin, name, path);
      if (mesh == null) return null;
      mesh.path = path; 
      mesh.vertices = this.getFloatList(map, "vertices", scale);
      mesh.triangles = this.getIntList(map, "triangles");
      mesh.regionUVs = this.getFloatList(map, "uvs", 1.0);
      mesh.updateUVs();

      if (map.containsKey('color')) {
          String color = map["color"];
          mesh.r = this.toColor(color, 0);
          mesh.g = this.toColor(color, 1);
          mesh.b = this.toColor(color, 2);
          mesh.a = this.toColor(color, 3);
       }

      mesh.hullLength = (map.containsKey('hull') ? map["hull"] : 0) * 2;
      if (map.containsKey('edges')) mesh.edges = this.getIntList(map, "edges");
      mesh.width = (map.containsKey('width') ? map["width"] : 0) * scale;
      mesh.height = (map.containsKey('height') ? map["height"] : 0) * scale;
      return mesh;
    } else if (type == 'skinnedmesh') {
      SkinnedMeshAttachment mesh = this.attachmentLoader.newSkinnedMeshAttachment(skin, name, path);
      if (mesh == null) return null;
      mesh.path = path;

      List<double> uvs = this.getFloatList(map, "uvs", 1.0);
      List<double> vertices = this.getFloatList(map, "vertices", 1.0);
      List<double> weights = [];
      List<int> bones = [];
      for (int i = 0, n = vertices.length; i < n; ) {
        int boneCount = vertices[i++].toInt();// | 0;
        bones[bones.length] = boneCount;
        for (int nn = i + boneCount * 4; i < nn; ) {
          bones[bones.length] = vertices[i].toInt();
          weights[weights.length] = vertices[i + 1] * scale;
          weights[weights.length] = vertices[i + 2] * scale;
          weights[weights.length] = vertices[i + 3];
          i += 4;
        }
      }
      mesh.bones = bones;
      mesh.weights = weights;
      mesh.triangles = this.getFloatList(map, "triangles",1.0);
      mesh.regionUVs = uvs;
      mesh.updateUVs();

      if (map.containsKey('color')) {
          String color = map["color"];
          mesh.r = this.toColor(color, 0);
          mesh.g = this.toColor(color, 1);
          mesh.b = this.toColor(color, 2);
          mesh.a = this.toColor(color, 3);
       }

      mesh.hullLength = (map.containsKey('hull') ? map["hull"] : 0) * 2;
      if (map.containsKey('edges')) mesh.edges = this.getIntList(map, "edges");
      mesh.width = (map.containsKey('width') ? map["width"] : 0) * scale;
      mesh.height = (map.containsKey('height') ? map["height"] : 0) * scale;
      return mesh;
    } else if (type == 'boundingbox') {
      BoundingBoxAttachment attachment = this.attachmentLoader.newBoundingBoxAttachment(skin, name);
      List vertices = map["vertices"];
      for (int i = 0, n = vertices.length; i < n; i++)
        attachment.vertices.add(vertices[i] * this.scale);
      return attachment;
    }
    throw new Exception("Unknown attachment type: " + type.toString());
  }
  
  void readAnimation(String name,Map map,SkeletonData skeletonData) {
    List<Timeline> timelines = [];
    int duration = 0;

    Map slots = map["slots"];
    slots.forEach((String slotName, Map slotMap){
      int slotIndex = skeletonData.findSlotIndex(slotName);

      slotMap.forEach((String timelineName, List values){
        if (timelineName == "color") {
          ColorTimeline timeline = new ColorTimeline(values.length);
          timeline.slotIndex = slotIndex;

          int frameIndex = 0;
          for (int i = 0, n = values.length; i < n; i++) {
            Map valueMap = values[i];
            String color = valueMap["color"];
            double r = this.toColor(color, 0);
            double g = this.toColor(color, 1);
            double b = this.toColor(color, 2);
            double a = this.toColor(color, 3);
            timeline.setFrame(frameIndex, valueMap["time"], r, g, b, a);
            this.readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          }
          timelines.add(timeline);
          duration = Math.max(duration, timeline.frames[timeline.frameCount * 5 - 5]);

        } else if (timelineName == "attachment") {
          AttachmentTimeline timeline = new AttachmentTimeline(values.length);
          timeline.slotIndex = slotIndex;

         int frameIndex = 0;
          for (int i = 0, n = values.length; i < n; i++) {
            Map valueMap = values[i];
            timeline.setFrame(frameIndex++, valueMap["time"], valueMap["name"]);
          }
          timelines.add(timeline);
          duration = Math.max(duration, timeline.frames[timeline.frameCount - 1]);

        } else
          throw new Exception("Invalid timeline type for a slot: " + timelineName + " (" + slotName + ")");
      });
    });

    Map bones = map["bones"];
    bones.forEach((String boneName, Map boneMap){
      int boneIndex = skeletonData.findBoneIndex(boneName);
      if (boneIndex == -1) throw new Exception("Bone not found: " + boneName);

      boneMap.forEach((String timelineName, List values){
        if (timelineName == "rotate") {
          RotateTimeline timeline = new RotateTimeline(values.length);
          timeline.boneIndex = boneIndex;

          int frameIndex = 0;
          for (int i = 0, n = values.length; i < n; i++) {
            Map valueMap = values[i];
            timeline.setFrame(frameIndex, valueMap["time"], valueMap["angle"]);
            this.readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          }
          timelines.add(timeline);
          duration = Math.max(duration, timeline.frames[timeline.frameCount * 2 - 2]);

        } else if (timelineName == "translate" || timelineName == "scale") {
          TranslateTimeline timeline;
          double timelineScale = 1.0;
          if (timelineName == "scale")
            timeline = new ScaleTimeline(values.length);
          else {
            timeline = new TranslateTimeline(values.length);
            timelineScale = this.scale;
          }
          timeline.boneIndex = boneIndex;

          int frameIndex = 0;
          for (int i = 0, n = values.length; i < n; i++) {
            Map valueMap = values[i];
            var x = (valueMap.containsKey('x') ? map["x"] : 0) * timelineScale;
            var y = (valueMap.containsKey('y') ? map["y"] : 0) * timelineScale;
            timeline.setFrame(frameIndex, valueMap["time"], x, y);
            this.readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          }
          timelines.add(timeline);
          duration = Math.max(duration, timeline.frames[timeline.frameCount * 3 - 3]);

        } else
          throw new Exception("Invalid timeline type for a bone: " + timelineName + " (" + boneName + ")");
      });
    });

    Map ffd = map["ffd"];
    ffd.forEach((String skinName, Map slotMap){
      Skin skin = skeletonData.findSkin(skinName);
      slotMap.forEach((String slotName, Map meshMap){
        var slotIndex = skeletonData.findSlotIndex(slotName);
        meshMap.forEach((String meshName, List values){
          FFDTimeline timeline = new FFDTimeline(values.length);
          Attachment attachment = skin.getAttachment(slotIndex, meshName);
          if (attachment == null) throw  new Exception("FFD attachment not found: " + meshName);
          timeline.slotIndex = slotIndex;
          timeline.attachment = attachment;

          bool isMesh = attachment is MeshAttachment;
          int vertexCount;
          if (isMesh)
            vertexCount = (attachment as MeshAttachment).vertices.length;
          else
            vertexCount = attachment.weights.length / 3 * 2;

          int frameIndex = 0;
          for (int i = 0, n = values.length; i < n; i++) {
            Map valueMap = values[i];
            List vertices;
            if (!valueMap.containsKey("vertices")) {
              if (isMesh)
                vertices = (attachment as MeshAttachment).vertices;
              else {
                vertices = [];
                vertices.length = vertexCount;
              }
            } else {
              List verticesValue = valueMap["vertices"];
              List vertices = [];
              vertices.length = vertexCount;
              int start = valueMap.containsKey('offset') ? valueMap["offset"] : 0;
              int nn = verticesValue.length;
              if (scale == 1) {
                for (int ii = 0; ii < nn; ii++)
                  vertices[ii + start] = verticesValue[ii];
              } else {
                for (int ii = 0; ii < nn; ii++)
                  vertices[ii + start] = verticesValue[ii] * scale;
              }
              if (isMesh) {
                List meshVertices = (attachment as MeshAttachment).vertices;
                for (int ii = 0, nn = vertices.length; ii < nn; i++)
                  vertices[ii] += meshVertices[ii];
              }
            }

            timeline.setFrame(frameIndex, valueMap["time"], vertices);
            this.readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          }
          timelines[timelines.length] = timeline;
          duration = Math.max(duration, timeline.frames[timeline.frameCount - 1]);
        });
      });
    });

    if (map.containsKey('draworder')) {
      List drawOrderValues = map["draworder"];
      DrawOrderTimeline timeline = new DrawOrderTimeline(drawOrderValues.length);
      int slotCount = skeletonData.slots.length;
      int frameIndex = 0;
      for (int i = 0, n = drawOrderValues.length; i < n; i++) {
        Map drawOrderMap = drawOrderValues[i];
        List drawOrder;
        if (drawOrderMap.containsKey("offsets")) {
          drawOrder = [];
          drawOrder.length = slotCount;
          for (int ii = slotCount - 1; ii >= 0; ii--)
            drawOrder[ii] = -1;
          List offsets = drawOrderMap["offsets"];
          List unchanged = [];
          unchanged.length = slotCount - offsets.length;
          int originalIndex = 0, unchangedIndex = 0;
          for (int ii = 0, nn = offsets.length; ii < nn; ii++) {
            Map offsetMap = offsets[ii];
            int slotIndex = skeletonData.findSlotIndex(offsetMap["slot"]);
            if (slotIndex == -1) throw new Exception("Slot not found: " + offsetMap["slot"]);
            // Collect unchanged items.
            while (originalIndex != slotIndex)
              unchanged[unchangedIndex++] = originalIndex++;
            // Set changed items.
            drawOrder[originalIndex + offsetMap["offset"]] = originalIndex++;
          }
          // Collect remaining unchanged items.
          while (originalIndex < slotCount)
            unchanged[unchangedIndex++] = originalIndex++;
          // Fill in unchanged items.
          for (int ii = slotCount - 1; ii >= 0; ii--)
            if (drawOrder[ii] == -1) drawOrder[ii] = unchanged[--unchangedIndex];
        }
        timeline.setFrame(frameIndex++, drawOrderMap["time"], drawOrder);
      }
      timelines.add(timeline);
      duration = Math.max(duration, timeline.frames[timeline.frameCount - 1]);
    }

    if (map.containsKey('events')) {
      Map events = map["events"];
      EventTimeline timeline = new EventTimeline(events.length);
      int frameIndex = 0;
      for (int i = 0, n = events.length; i < n; i++) {
        Map eventMap = events[i];
        EventData eventData = skeletonData.findEvent(eventMap["name"]);
        if (eventData == null) throw new Exception("Event not found: " + eventMap["name"]);
        Event event = new Event(eventData);
        event.integer = eventMap.containsKey("int") ? eventMap["int"] : eventData.integer;
        event.float = eventMap.containsKey("float") ? eventMap["float"] : eventData.float;
        event.string = eventMap.containsKey("string") ? eventMap["string"] : eventData.string;
        timeline.setFrame(frameIndex++, eventMap["time"], event);
      }
      timelines.add(timeline);
      duration = Math.max(duration, timeline.frames[timeline.frameCount - 1]);
    }

    skeletonData.animations.add(new Animation(name, timelines, duration.toDouble()));
  }
  
  
  void readCurve(CurveTimeline timeline,int frameIndex,Map valueMap) {
    if (!valueMap.containsKey('curve')) return;
    var curve = valueMap["curve"];
    if (curve == "stepped")
      timeline.setStepped(frameIndex);
    else if (curve is List)
      timeline.setCurve(frameIndex, curve[0], curve[1], curve[2], curve[3]);
  }
  
  
  double toColor(String hexString,int colorIndex) {
    if (hexString.length != 8) throw "Color hexidecimal length must be 8, recieved: " + hexString;
    return int.parse(hexString.substring(colorIndex * 2, (colorIndex * 2) + 2), radix: 16) / 255;
  }
  
  List<double> getFloatList(Map map,String name,double scale) {
    List list = map[name];
    List<double> values = new List<double>(list.length);
    int i = 0, n = list.length;
    if (scale == 1) {
      for (; i < n; i++)
        values[i] = list[i].toDouble();
    } else {
      for (; i < n; i++)
        values[i] = list[i].toDouble() * scale;
    }
    return values;
  }
  
  
  List<int> getIntList(Map map,String name) {
    List list = map[name];
    List<int> values = new List<int>(list.length);
    for (int i = 0, n = list.length; i < n; i++)
      values[i] = list[i];
    return values;
  }
  
  
}