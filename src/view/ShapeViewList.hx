package view;

import gui.*;

class ShapeViewList extends Box {

  var _shapesView = new Array<ShapeView>();
  var _selected:Int=-1;
  var _width:Float=0;
  var _base:TileCraft;

  public function new(base:TileCraft,width:Float=0) {
    _base = base;
    _width = width;
    super(Style.shapeviewlist());
    draw(_width);
  }

  public function addShape(shape:Shape) {
    _shapesView.unshift(new ShapeView(this,shape,_width-_style.padding*2));
    addChild(_shapesView[0]);
    updatePositions();
  }

  public function getColor(index:Int):Int {
    return _base.getColor(index);
  }

  public function removeAllShape() {
    for (i in 0..._shapesView.length) {
      removeChild(_shapesView.shift());
    }
  }

  public function updateModel() {
    _base.updateModel();
  }

  public function removeShape(shape:Shape) {
    for (i in 0..._shapesView.length) {
      if (_shapesView[i].getShape()==shape) {
        removeChild(_shapesView[i]); //remove from view
        _base.currentModel.removeShape(_base.currentModel.indexOf(_shapesView[i].getShape())); //remove from model
        _shapesView.remove(_shapesView[i]); //remove from array list
        updatePositions();
        updateModel();
        break;
      }
    }
  }

  public function toggleEnabledShape(shape:Shape) {
    shape.enabled = !shape.enabled;
    updateModel();
  }

  public function toggleLockedShape(shape:Shape) {
    shape.locked = !shape.locked;
    updateModel();
  }

  private function updatePositions() {
    if (_shapesView.length<=0) return;

    var SHAPE_HEIGHT = _shapesView[0].height;
    for (i in 0..._shapesView.length) {
      _shapesView[i].x = _style.padding;
      _shapesView[i].y = _style.padding + i*(SHAPE_HEIGHT+_style.offset);
    }
    draw(_width);
  }

  public function getSelected():Shape {
    if (_selected<0) return null;
    return _shapesView[_selected].getShape();
  }

}
