import 'SliceType.dart';
import 'Walls.dart';

class MapBuilder {

  Walls walls;

  MapBuilder(Walls walls) {
    this.walls = walls;
    this.createMap();
  }

  static final List<int> WALL_HEIGHTS = [256, // Lowest slice
    224, 192, 160, 128 // Highest slice
  ];

  void createMap() {
    this.createWallSpan(3, 9, true);
    this.createGap(1);
    this.createWallSpan(1, 30);
    this.createGap(1);
    this.createWallSpan(2, 18);
    this.createGap(1);
    this.createSteppedWallSpan(2, 5, 28);
    this.createGap(1);
    this.createWallSpan(1, 10);
    this.createGap(1);
    this.createWallSpan(2, 6);
    this.createGap(1);
    this.createWallSpan(1, 8);
    this.createGap(1);
    this.createWallSpan(2, 6);
    this.createGap(1);
    this.createWallSpan(1, 8);
    this.createGap(1);
    this.createWallSpan(2, 7);
    this.createGap(1);
    this.createWallSpan(1, 16);
    this.createGap(1);
    this.createWallSpan(2, 6);
    this.createGap(1);
    this.createWallSpan(1, 22);
    this.createGap(2);
    this.createWallSpan(2, 14);
    this.createGap(2);
    this.createWallSpan(3, 8);
    this.createGap(2);
    this.createSteppedWallSpan(3, 5, 12);
    this.createGap(3);
    this.createWallSpan(0, 8);
    this.createGap(3);
    this.createWallSpan(1, 50);
    this.createGap(20);
  }

  void createGap(int spanLength) {
    for (int i = 0; i < spanLength; i++) {
      this.walls.addSlice(SliceType.GAP,0);
    }
  }

  void createWallSpan(int heightIndex, int spanLength, [noFront = false, noBack = false]) {

    if (noFront == false && spanLength > 0) {
      this.addWallFront(heightIndex);
      spanLength--;
    }

    int midSpanLength = spanLength - (noBack ? 0 : 1);
    if (midSpanLength > 0) {
      this.addWallMid(heightIndex, midSpanLength);
      spanLength -= midSpanLength;
    }

    if (noBack == false && spanLength > 0) {
      this.addWallBack(heightIndex);
    }
  }

  void createSteppedWallSpan(int heightIndex, int spanALength, int spanBLength) {
    if (heightIndex < 2) {
      heightIndex = 2;
    }

    this.createWallSpan(heightIndex, spanALength, false, true);
    this.addWallStep(heightIndex - 2);
    this.createWallSpan(heightIndex - 2, spanBLength - 1, true, false);
  }

  void addWallFront(int heightIndex) {
    int y = MapBuilder.WALL_HEIGHTS[heightIndex];
    this.walls.addSlice(SliceType.FRONT, y);
  }

  void addWallBack(int heightIndex) {
    int y = MapBuilder.WALL_HEIGHTS[heightIndex];
    this.walls.addSlice(SliceType.BACK, y);
  }

  void addWallMid(heightIndex, spanLength) {
    int y = MapBuilder.WALL_HEIGHTS[heightIndex];
    for (int i = 0; i < spanLength; i++) {
      if (i % 2 == 0) {
        this.walls.addSlice(SliceType.WINDOW, y);
      } else {
        this.walls.addSlice(SliceType.DECORATION, y);
      }
    }
  }

  void addWallStep(int heightIndex) {
    int y = MapBuilder.WALL_HEIGHTS[heightIndex];
    this.walls.addSlice(SliceType.STEP, y);
  }

}
