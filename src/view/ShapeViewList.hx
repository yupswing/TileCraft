package view;

import com.akifox.plik.gui.*;
import com.akifox.plik.*;
import motion.Actuate;

import openfl.events.MouseEvent;

class ShapeViewList extends Box {

  var _shapesView = new Array<ShapeView>();
  var _shapeview_height:Float = 0;
  var _width:Float=0;
  var _height:Float=0;
  var _base:TileCraft;
  var _selected:ShapeView = null;

  var _scroll:Scroll;
  var _scrollable:SpriteContainer;

  public function new(base:TileCraft,width:Float=0,height:Float=0) {
    super(Style.getStyle('.box.shapeviewlist'));
    _base = base;
    _width = width;
    _height = height;
    draw(_width);
    _scrollable = new SpriteContainer();
    addChild(_scrollable);
    _scroll = new Scroll(Style.getStyle('.scroll'),Style.getStyle('.scrollSlider'),_height,scroll,height);
    addEventListener(MouseEvent.MOUSE_WHEEL,_scroll.onMouseWheel);
    _scroll.listen = true;
    addChild(_scroll);
    _scroll.x = _width-_scroll.getGrossWidth();
  }

  public function updateHeight(height:Float) {
    _height = height;
    _scroll.updateHeight(height);
    _scroll.setValueView(height);
    updateScroll();
    _scroll.setValue(0);
    scroll(0);
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

  //============================================================================

  public function add(shape:Shape) {
    var index:Int = -1;
    if (_selected!=null) {
      index = getSelectedIndex()-1;
    }
    if (index<0) index = 0;
    _shapesView.insert(index,new ShapeView(this,shape,_width-_style.padding*2));
    _scrollable.addChild(_shapesView[0]);
    _shapeview_height = _shapesView[0].getGrossHeight();
    updatePositions();
    updateScroll();
  }

  public function remove(shape:Shape) {
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

  public function removeAll() {
    for (i in 0..._shapesView.length) {
      _scrollable.removeChild(_shapesView.shift());
    }
    _selected = null; //deselect
    updateScroll();
  }

  //============================================================================

  public function getColor(index:Int):Int {
    return _base.getColor(index);
  }

  //============================================================================

  public function select(shapeView:ShapeView):ShapeView {
    if (_selected == shapeView) return shapeView; // avoid loops with _base.updateShapeSelect
    if (shapeView == null) return deselect();
    if (_selected != null) _selected.isSelected = false;
    _selected = shapeView;
    _base.updateShapeSelect(shapeView.getShape());
    shapeView.isSelected = true;
    return shapeView;
  }

  public function selectByIndex(index:Int):ShapeView {
    return select(getShapeViewByIndex(index));
  }

  public function selectByShape(shape:Shape):ShapeView {
    return select(getShapeViewByShape(shape));
  }

  public function deselect():ShapeView {
    if (_selected == null) return null; // avoid loops with _base.updateShapeSelect
    _selected.isSelected = false;
    _selected = null;
    _base.updateShapeSelect(null);
    return null;
  }

  //============================================================================

  public function getSelected():ShapeView {
    return _selected;
  }

  public function getSelectedShape():Shape {
    var shapeView:ShapeView = getSelected();
    if (shapeView==null) return null;
    return shapeView.getShape();
  }

  public function getSelectedIndex():Int {
    if (_selected==null) return -1;
    return _shapesView.indexOf(_selected);
  }

  //============================================================================

  public function getShapeViewByIndex(index:Int):ShapeView {
    if (index>=_shapesView.length || index<0) return null;
    return _shapesView[index];
  }

  public function getShapeViewByShape(shape:Shape):ShapeView {
    if (shape==null) return null;
    for (shapeView in _shapesView) {
      if (shapeView.getShape() == shape) return shapeView;
    }
    return null;
  }

  //============================================================================

  public function updateShape(shape:Shape) {
    var shapeView = getShapeViewByShape(shape);
    if (shapeView==null) return;
    shapeView.update();
  }

  public function updateColor(colorIndex:Int) {
    for (shapeView in _shapesView) {
      if (shapeView.getShape().color==colorIndex) shapeView.update();
    }
  }

  public function updateModel() {
    _base.updateModel();
  }

  public function toggleEnabledShape(shape:Shape) {
    shape.enabled = !shape.enabled;
    updateModel();
  }

  public function toggleLockedShape(shape:Shape) {
    shape.locked = !shape.locked;
    updateModel();
  }

  //============================================================================

  public function updateScroll() {
    _scroll.setValueMax(Math.max(_height,_style.padding + _shapesView.length*(_shapeview_height+_style.offset)));
  }

  //============================================================================

  private function updatePositions() {
    if (_shapesView.length<=0) return;

    for (i in 0..._shapesView.length) {
      _shapesView[i].x = _style.padding;
      _shapesView[i].y = _style.padding + i*(_shapeview_height+_style.offset);
    }
    draw(_width);
  }

}
