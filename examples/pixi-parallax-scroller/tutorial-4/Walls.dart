import '../../../lib/Pixi.dart';

import 'WallSpritesPool.dart';
import 'WallSlice.dart';
import 'SliceType.dart';

class Walls extends DisplayObjectContainer {

  WallSpritesPool pool;
  List<WallSlice> slices;

  Map<int, Function> borrowWallSpriteLookup;
  Map<int, Function> returnWallSpriteLookup;


  static const int VIEWPORT_WIDTH = 512;
  static final int VIEWPORT_NUM_SLICES = (Walls.VIEWPORT_WIDTH / WallSlice.WIDTH).ceil() + 1;

  double viewportX;
  double viewportSliceX;

  Walls() {

    this.pool = new WallSpritesPool();
    this.createLookupTables();

    this.slices = [];

    this.viewportX = 0.0;
    this.viewportSliceX = 0.0;
  }


  void setViewportX(double viewportX) {
    this.viewportX = this.checkViewportXBounds(viewportX);

    double prevViewportSliceX = this.viewportSliceX;
    this.viewportSliceX = (this.viewportX / WallSlice.WIDTH).floorToDouble();

    this.removeOldSlices(prevViewportSliceX);
    this.addNewSlices();
  }

  void removeOldSlices(double prevViewportSliceX) {
    double numOldSlices = this.viewportSliceX - prevViewportSliceX;
    if (numOldSlices > Walls.VIEWPORT_NUM_SLICES) {
      numOldSlices = Walls.VIEWPORT_NUM_SLICES.toDouble();
    }

    for (int i = prevViewportSliceX.toInt(); i < prevViewportSliceX + numOldSlices; i++) {
      WallSlice slice = this.slices[i];
      if (slice.sprite != null) {
        this.returnWallSprite(slice.type, slice.sprite);
        this.removeChild(slice.sprite);
        slice.sprite = null;
      }
    }
  }

  void addSlice(int sliceType, int y) {
    WallSlice slice = new WallSlice(sliceType, y);
    this.slices.add(slice);
  }

  double checkViewportXBounds(double viewportX) {
    double maxViewportX = ((this.slices.length - Walls.VIEWPORT_NUM_SLICES) * WallSlice.WIDTH).toDouble();
    if (viewportX < 0) {
      viewportX = 0.0;
    } else if (viewportX > maxViewportX) {
      viewportX = maxViewportX;
    }

    return viewportX;
  }

  void addNewSlices() {
    double firstX = -(this.viewportX % WallSlice.WIDTH);
    for (int i = this.viewportSliceX.toInt(),
        sliceIndex = 0; i < this.viewportSliceX + Walls.VIEWPORT_NUM_SLICES; i++, sliceIndex++) {
      WallSlice slice = this.slices[i];
      if (slice.sprite == null && slice.type != SliceType.GAP) {
        slice.sprite = this.borrowWallSprite(slice.type);

        slice.sprite.position.x = firstX + (sliceIndex * WallSlice.WIDTH);
        slice.sprite.position.y = slice.y.toDouble();

        this.addChild(slice.sprite);
      } else if (slice.sprite != null) {
        slice.sprite.position.x = firstX + (sliceIndex * WallSlice.WIDTH);
      }
    }
  }

  void createLookupTables() {
    this.borrowWallSpriteLookup = {};
    this.borrowWallSpriteLookup[SliceType.FRONT] = this.pool.borrowFrontEdge;
    this.borrowWallSpriteLookup[SliceType.BACK] = this.pool.borrowBackEdge;
    this.borrowWallSpriteLookup[SliceType.STEP] = this.pool.borrowStep;
    this.borrowWallSpriteLookup[SliceType.DECORATION] = this.pool.borrowDecoration;
    this.borrowWallSpriteLookup[SliceType.WINDOW] = this.pool.borrowWindow;

    this.returnWallSpriteLookup = {};
    this.returnWallSpriteLookup[SliceType.FRONT] = this.pool.returnFrontEdge;
    this.returnWallSpriteLookup[SliceType.BACK] = this.pool.returnBackEdge;
    this.returnWallSpriteLookup[SliceType.STEP] = this.pool.returnStep;
    this.returnWallSpriteLookup[SliceType.DECORATION] = this.pool.returnDecoration;
    this.returnWallSpriteLookup[SliceType.WINDOW] = this.pool.returnWindow;
  }

  borrowWallSprite(int sliceType) {
    return this.borrowWallSpriteLookup[sliceType]();
  }

  returnWallSprite(int sliceType, Sprite sliceSprite) {
    return this.returnWallSpriteLookup[sliceType](sliceSprite);
  }
  

}
