import 'dart:math';
import '../../../lib/Pixi.dart';

class WallSpritesPool {

  List<Sprite> windows = [];
  List<Sprite> decorations = [];
  List<Sprite> frontEdges = [];
  List<Sprite> backEdges = [];
  List<Sprite> steps = [];

  WallSpritesPool() {
    this.createWindows();
    this.createDecorations();
    this.createFrontEdges();
    this.createBackEdges();
    this.createSteps();
  }

  Sprite borrowWindow() {
    return this.windows.removeAt(0);
  }

  void returnWindow(Sprite sprite) {
    this.windows.add(sprite);
  }

  Sprite borrowDecoration() {
    return this.decorations.removeAt(0);
  }

  void returnDecoration(Sprite sprite) {
    this.decorations.add(sprite);
  }

  Sprite borrowFrontEdge() {
    return this.frontEdges.removeAt(0);
  }

  void returnFrontEdge(Sprite sprite) {
    this.frontEdges.add(sprite);
  }

  Sprite borrowBackEdge() {
    return this.backEdges.removeAt(0);
  }

  void returnBackEdge(Sprite sprite) {
    this.backEdges.add(sprite);
  }

  Sprite borrowStep() {
    return this.steps.removeAt(0);
  }

  void returnStep(Sprite sprite) {
    this.steps.add(sprite);
  }

  void createWindows() {
    this.windows = [];

    this.addWindowSprites(6, "window_01");
    this.addWindowSprites(6, "window_02");

    this.shuffle(this.windows);
  }

  void createDecorations() {
    this.decorations = [];

    this.addDecorationSprites(6, "decoration_01");
    this.addDecorationSprites(6, "decoration_02");
    this.addDecorationSprites(6, "decoration_03");

    this.shuffle(this.decorations);
  }

  void createFrontEdges() {
    this.frontEdges = [];

    this.addFrontEdgeSprites(2, "edge_01");
    this.addFrontEdgeSprites(2, "edge_02");

    this.shuffle(this.frontEdges);
  }

  void createBackEdges() {
    this.backEdges = [];

    this.addBackEdgeSprites(2, "edge_01");
    this.addBackEdgeSprites(2, "edge_02");

    this.shuffle(this.backEdges);
  }

  void createSteps() {
    this.steps = [];
    this.addStepSprites(2, "step_01");
  }

  void addWindowSprites(int amount, String frameId) {
    for (int i = 0; i < amount; i++) {
      Sprite sprite = new Sprite.fromFrame(frameId);
      this.windows.add(sprite);
    }
  }

  void addDecorationSprites(int amount, String frameId) {
    for (int i = 0; i < amount; i++) {
      Sprite sprite = new Sprite.fromFrame(frameId);
      this.decorations.add(sprite);
    }
  }

  void addFrontEdgeSprites(int amount, String frameId) {
    for (int i = 0; i < amount; i++) {
      Sprite sprite = new Sprite.fromFrame(frameId);
      this.frontEdges.add(sprite);
    }
  }

  void addBackEdgeSprites(int amount, String frameId) {
    for (int i = 0; i < amount; i++) {
      Sprite sprite = new Sprite.fromFrame(frameId);
      sprite.anchor.x = 1.0;
      sprite.scale.x = -1.0;
      this.backEdges.add(sprite);
    }
  }

  void addStepSprites(int amount, String frameId) {
    for (int i = 0; i < amount; i++) {
      Sprite sprite = new Sprite.fromFrame(frameId);
      sprite.anchor.y = 0.25;
      this.steps.add(sprite);
    }
  }

  void shuffle(List<Sprite> array) {
    int len = array.length;
    int shuffles = len * 3;
    for (int i = 0; i < shuffles; i++) {
      Sprite wallSlice = array.removeLast();
      int pos = (new Random().nextDouble() * (len - 1)).floor();
      array.insert(pos, wallSlice);
    }
  }

}
