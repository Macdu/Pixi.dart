part of pixi;

Map<String,spine.SkeletonData> AnimCache = {};

class _SlotProperty {

  String currentSpriteName;

  Sprite currentSprite;

  Map<String, Sprite> sprites = {};

}

Map<spine.Slot, _SlotProperty> _slotProperty = {};

/**
 * A class that enables the you to import and run your spine animations in pixi.
 * Spine animation data needs to be loaded using the PIXI.AssetLoader or PIXI.SpineLoader before it can be used by this class
 * See example 12 (http://www.goodboydigital.com/pixijs/examples/12/) to see a working example and check out the source
 */
class Spine extends DisplayObjectContainer {

  var spineData;

  spine.Skeleton skeleton;

  spine.AnimationStateData stateData;

  spine.AnimationState state;

  List<DisplayObjectContainer> slotContainers;

  int lastTime;

  /**
 * @class Spine
 * @extends DisplayObjectContainer
 * @constructor
 * @param url {String} The url of the spine anim file to be used
 */
  Spine(String url) : super() {

    this.spineData = AnimCache[url];

    if (this.spineData == null) {
      throw new Exception("Spine data must be preloaded using PIXI.SpineLoader or PIXI.AssetLoader: " + url);
    }

    this.skeleton = new spine.Skeleton(this.spineData);
    this.skeleton.updateWorldTransform();

    this.stateData = new spine.AnimationStateData(this.spineData);
    this.state = new spine.AnimationState(this.stateData);

    this.slotContainers = [];

    for (int i = 0,
        n = this.skeleton.drawOrder.length; i < n; i++) {
      spine.Slot slot = this.skeleton.drawOrder[i];
      spine.Attachment attachment = slot.attachment;
      DisplayObjectContainer slotContainer = new DisplayObjectContainer();
      this.slotContainers.add(slotContainer);
      this.addChild(slotContainer);
      if (!(attachment is spine.RegionAttachment)) {
        continue;
      }
      String spriteName = attachment.rendererObject.name;
      Sprite sprite = this.createSprite(slot, attachment.rendererObject);
      if (!_slotProperty.containsKey(slot)) _slotProperty[slot] = new _SlotProperty();
      _slotProperty[slot].currentSprite = sprite;
      _slotProperty[slot].currentSpriteName = spriteName;
      slotContainer.addChild(sprite);
    }
  }

  /*
   * Updates the object transform for rendering
   *
   * @method updateTransform
   * @private
   */
  void updateTransform() {
    this.lastTime = (this.lastTime != null) ? this.lastTime : new DateTime.now().millisecondsSinceEpoch;
    double timeDelta = (new DateTime.now().millisecondsSinceEpoch - this.lastTime) * 0.001;
    this.lastTime = new DateTime.now().millisecondsSinceEpoch;
    this.state.update(timeDelta);
    this.state.apply(this.skeleton);
    this.skeleton.updateWorldTransform();

    List<spine.Slot> drawOrder = this.skeleton.drawOrder;
    for (int i = 0,
        n = drawOrder.length; i < n; i++) {
      spine.Slot slot = drawOrder[i];
      _SlotProperty slotProperty = _slotProperty[slot];
      spine.Attachment attachment = slot.attachment;
      DisplayObjectContainer slotContainer = this.slotContainers[i];
      if (!(attachment is spine.RegionAttachment)) {
        slotContainer.visible = false;
        continue;
      }

      if (attachment.rendererObject != null) {
        if (slotProperty.currentSpriteName == null || slotProperty.currentSpriteName != attachment.name) {
          String spriteName = attachment.rendererObject.name;
          if (slotProperty.currentSprite != null) {
            slotProperty.currentSprite.visible = false;
          }
          if (slotProperty.sprites.containsKey(spriteName)) {
            slotProperty.sprites[spriteName].visible = true;
          } else {
            Sprite sprite = this.createSprite(slot, attachment.rendererObject);
            slotContainer.addChild(sprite);
          }
          slotProperty.currentSprite = slotProperty.sprites[spriteName];
          slotProperty.currentSpriteName = spriteName;
        }
      }
      slotContainer.visible = true;

      spine.Bone bone = slot.bone;

      slotContainer.position.x = bone.worldX + attachment.x * bone.m00 + attachment.y * bone.m01;
      slotContainer.position.y = bone.worldY + attachment.x * bone.m10 + attachment.y * bone.m11;
      slotContainer.scale.x = bone.worldScaleX;
      slotContainer.scale.y = bone.worldScaleY;

      slotContainer.rotation = -(slot.bone.worldRotation * Math.PI / 180);

      slotContainer.alpha = slot.a;
      slotProperty.currentSprite.tint = rgb2hex([slot.r, slot.g, slot.b]);
    }

    super.updateTransform();
  }


  Sprite createSprite(spine.Slot slot, Object descriptor) {
    String name = TextureCache.containsKey(descriptor.name) ? descriptor.name : descriptor.name + ".png";
    Sprite sprite = new Sprite(new Texture.fromFrame(name));
    sprite.scale = descriptor.scale;
    sprite.rotation = descriptor.rotation;
    sprite.anchor.x = sprite.anchor.y = 0.5;

    _slotProperty[slot].sprites[descriptor.name] = sprite;
    return sprite;
  }

}
