package view;

import gui.*;
import com.akifox.plik.*;
import motion.Actuate;

import openfl.events.MouseEvent;

class ShapeViewList extends Box {

  var _shapesView = new Array<ShapeView>();
  var _shapeview_height:Float = 0;
  var _width:Float=0;
  var _height:Float=0;
  var _base:TileCraft;

  var _scroll:Scroll;
  var _scrollable:SpriteContainer;

  public function new(base:TileCraft,width:Float=0,height:Float=0) {
    super(Style.shapeviewlist());
    _base = base;
    _width = width;
    _height = height;
    draw(_width);
    _scrollable = new SpriteContainer();
    addChild(_scrollable);
    _scroll = new Scroll(_height,scroll,height);
    addEventListener(MouseEvent.MOUSE_WHEEL,_scroll.onMouseWheel);
    _scroll.listen = true;
    addChild(_scroll);
    _scroll.x = _width-_scroll.getGrossWidth();
  }

  public override function getNetHeight():Float {
    return Math.max(_height,_shapeview_height*_shapesView.length);
  }

  public function scroll(y:Float) {
    if (Math.abs(y+_scrollable.y)<20) {
      Actuate.stop(_scrollable);
      _scrollable.y = -y;
    } else {
      Actuate.tween(_scrollable,0.3,{'y':-y});
    }
  }

  public function add(shape:Shape) {
    _shapesView.unshift(new ShapeView(this,shape,_width-_style.padding*2));
    _scrollable.addChild(_shapesView[0]);
    _shapeview_height = _shapesView[0].getGrossHeight();
    updatePositions();
    updateScroll();
  }

  public function getColor(index:Int):Int {
    return _base.getColor(index);
  }

  public function removeAll() {
    for (i in 0..._shapesView.length) {
      _scrollable.removeChild(_shapesView.shift());
    }
    _selected = null; //deselect
    updateScroll();
  }

  var _selected:ShapeView = null;

  public function getSelected():ShapeView {
    return _selected;
  }

  public function getSelectedShape():Shape {
    var shapeView:ShapeView = getSelected();
    if (shapeView==null) return null;
    return shapeView.getShape();
  }

  public function getShapeViewByIndex(index:Int):ShapeView {
    if (index>=_shapesView.length || index<0) return null;
    return _shapesView[index];
  }

  public function selectByIndex(index:Int):ShapeView {
    var shapeView = getShapeViewByIndex(index);
    if (shapeView==null) return null;
    select(shapeView);
    return shapeView;
  }

  public function select(shapeView:ShapeView):Bool {
    if (shapeView==null) return false;
    if (_selected != null) _selected.isSelected = false;
    _selected = shapeView;
    shapeView.isSelected = true;
    return true;
  }

  public function updateModel() {
    _base.updateModel();
  }

  public function updateScroll() {
    _scroll.setValueMax(Math.max(_height,_style.padding + _shapesView.length*(_shapeview_height+_style.offset)));
  }

  public function removeShape(shape:Shape) {
    // TODO this is not right (mixing model + shapeviewlist removals)
    for (i in 0..._shapesView.length) {
      if (_shapesView[i].getShape()==shape) {
        if (_selected==_shapesView[i]) _selected = null; //deselect
        _scrollable.removeChild(_shapesView[i]); //remove from view
        _base.currentModel.removeShape(shape); //remove from model
        _shapesView.remove(_shapesView[i]); //remove from array list
        updatePositions();
        updateModel();
        updateScroll();
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

    for (i in 0..._shapesView.length) {
      _shapesView[i].x = _style.padding;
      _shapesView[i].y = _style.padding + i*(_shapeview_height+_style.offset);
    }
    draw(_width);
  }

}
