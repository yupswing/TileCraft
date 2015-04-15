package view;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.events.MouseEvent;
import com.akifox.plik.*;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import motion.Actuate;

//TODO work in progress

class ModelView extends SpriteContainer {
  var _bitmap:Bitmap = new Bitmap(null);
  var _grid:ShapeContainer = new ShapeContainer();
  var _projection:ShapeContainer = new ShapeContainer();
  var _foreground:ShapeContainer = new ShapeContainer();
  var _selectedShape:Shape = null;

  var _height:Float = 0;
  var _width:Float = 0;
  var _base:TileCraft;
	var _moveXY:Bool = false;
	var _handle:Int = -1;
	var handles:Array<Point> = [for (i in 0...8) new Point(0,0)];

  private static inline var GRAY_1 = 0x404040;
  private static inline var GRAY_2 = 0x606060;
  private static inline var GRAY_3 = 0x808080;

  private static inline var HANDLE_WIDTH = 9;
  private static inline var TOP_HANDLE = 0x535d6c;
  private static inline var SIDE_HANDLE = 0x373e48;

  public static inline var PADDING = 50; //padding for the listeners

  public function new(base:TileCraft,width:Float,height:Float) {
    super();

    _base = base;
    _width = width;
    _height = height;


    addChild(_grid);

    _projection.x = _projection.y = PADDING;
    addChild(_projection);

    _bitmap.x = _bitmap.y = PADDING;
    addChild(_bitmap);

    _foreground.x = _foreground.y = PADDING;
    addChild(_foreground);

    drawBackground();

    addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
  }

  public function select(shape:Shape):Shape {

    if (_selectedShape == shape) return shape; // avoid loops with _base.updateShapeSelect
    if (shape == null) return deselect();

    _selectedShape = shape;
    _base.setSelectedShape(shape);

    updateHandles(); //paint as well

    return shape;
  }

  public function updateHandles() {
    if (_selectedShape==null) return;
    // set handle points
    var top:Rectangle = getTop(_selectedShape);
    var side:Rectangle = getSide(_selectedShape);
    handles[0].y = top.y;
    handles[1].y = handles[0].y;
    handles[2].y = side.y - HANDLE_WIDTH/2;
    handles[3].y = handles[2].y;
    handles[4].y = side.y + HANDLE_WIDTH/2;
    handles[5].y = handles[4].y;
    handles[6].y = side.y + side.height;
    handles[7].y = handles[6].y;
    var leftX = top.x;
    var rightX = top.x + top.width;
    for(i in 0...handles.length) {
      if (i%2==0) {
        handles[i].x = leftX;
      }else{
        handles[i].x = rightX;
      }
    }
    paint();
  }

  public function deselect():Shape {
    if (_selectedShape == null) return null; // avoid loops with _base.updateShapeSelect
    _selectedShape = null;
    _base.setSelectedShape(null);
    paint();
    return null;
  }

  private function drawBackground() {
    _grid.graphics.clear();

    // Sprite full size
		_grid.graphics.beginFill(GRAY_3,0);
		_grid.graphics.drawRect(0, 0, _width+PADDING*2, _height+PADDING*2);
    // Base background top
		_grid.graphics.beginFill(GRAY_1);
		_grid.graphics.drawRect(PADDING, PADDING, _width, _height/2);
    // Base background bottom
		_grid.graphics.beginFill(GRAY_2);
		_grid.graphics.drawRect(PADDING, _height/2+PADDING, _width, _height/2);

    // Grid
    var gw = _width/Model.MODEL_SIZE;
    var gh = _height/Model.MODEL_SIZE/2;

    _grid.graphics.endFill();
    _grid.graphics.lineStyle(1,GRAY_3,1);
    // x grid
    for (i in 0...Model.MODEL_SIZE+1) {
      _grid.graphics.moveTo(i*gw+PADDING,PADDING);
      _grid.graphics.lineTo(i*gw+PADDING,_height+PADDING);
    }

    // y grid
    for (i in 0...Model.MODEL_SIZE*2+1) {
      _grid.graphics.moveTo(PADDING,i*gh+PADDING);
      _grid.graphics.lineTo(_width+PADDING,i*gh+PADDING);
    }
  }

  public function paint() {
    paintProjection();
    paintForeground();
  }

	public function paintProjection() {
    var s:Shape = _selectedShape;

    // draw _selectedShape shape projection
    var g = _projection.graphics;
    g.clear();
		if(s!=null){
      var color = _base.getColor(s.getColor());
			var h2 = (_height)/2;
			var cw = (_width)/Model.MODEL_SIZE;
			var ch = (_height)/(Model.MODEL_SIZE*2);
			var rect = new Rectangle();
			rect.x = s.x1*cw;
			rect.width = s.x2*cw - rect.x;
			rect.y = h2 - (- s.y1)*ch;
			rect.height = (h2 - (- s.y2)*ch) - rect.y;
      g.beginFill(color,0.5);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			rect.y = h2 - (s.z2*ch);
			rect.height = (h2 - (s.z1*ch) - rect.y);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
    }
	}



	public function paintForeground() {
    var s:Shape = _selectedShape;
    // draw handles
    var g = _foreground.graphics;
    g.clear();
    if(s!=null){

      g.lineStyle(1,0xFFFFFF,0.5);
      g.moveTo(handles[0].x,handles[0].y);
      g.lineTo(handles[1].x,handles[1].y);

      g.moveTo(handles[2].x,(handles[2].y+handles[4].y)/2);
      g.lineTo(handles[3].x,(handles[3].y + handles[5].y)/2);

      g.moveTo(handles[6].x,handles[6].y);
      g.lineTo(handles[7].x,handles[7].y);

      g.moveTo(handles[0].x,handles[0].y);
      g.lineTo(handles[6].x,handles[6].y);

			g.moveTo(handles[1].x,handles[1].y);
      g.lineTo(handles[7].x,handles[7].y);

			var hw2 = HANDLE_WIDTH/2;
			for(i in 0...handles.length){
				if(_handle == i){
					g.beginFill(0xFF0000);
				} else {
					if(i < 4){
						g.beginFill(TOP_HANDLE);
					} else {
						g.beginFill(SIDE_HANDLE);
					}
				}
				g.drawRect(handles[i].x-hw2, handles[i].y-hw2, HANDLE_WIDTH, HANDLE_WIDTH);
			}
		}
	}

	public function getTop(s:Shape):Rectangle{
    // get top side of the cube (projected)
    var h2 = (_height)/2;
    var cw = (_width)/Model.MODEL_SIZE;
    var ch = (_height)/(Model.MODEL_SIZE*2);
		var rect = new Rectangle();
		rect.x = s.x1*cw;
		rect.width = s.x2*cw - rect.x;
		rect.y = h2 - (s.z2 - s.y1)*ch;
		rect.height = (h2 - (s.z2 - s.y2)*ch) - rect.y;
		return rect;
	}

	public function getSide(s:Shape):Rectangle{
    // get front side of the cube (projected)
    var h2 = (_height)/2;
    var cw = (_width)/Model.MODEL_SIZE;
    var ch = (_height)/(Model.MODEL_SIZE*2);
		var rect = new Rectangle();
		rect.x = s.x1*cw;
		rect.width = s.x2*cw - rect.x;
		rect.y = h2 - (s.z2 - s.y2)*ch;
		rect.height = (h2 - (s.z1 - s.y2)*ch) - rect.y;
		return rect;
	}

	private function getHandle(x:Float, y:Float):Int{
		if(_selectedShape == null) return -1;
		var hw2 = HANDLE_WIDTH/2;
		for(i in 0...handles.length){
			var h:Point = handles[i];
			if(x > h.x - hw2 && x < h.x + hw2 && y > h.y - hw2 && y < h.y + hw2){
				return i;
			}
		}
		return -1;
	}


  private var _isDragging = false;
  private function onMouseMove(event:MouseEvent) {
    if (APP.isDelayLocked()) return;

    if (!_isDragging) return;
    if (_selectedShape==null) return;

    var x = Std.int(event.localX)-PADDING;
    var y = Std.int(event.localY)-PADDING;

    var x_grid = (_width/Model.MODEL_SIZE);
    var y_grid = (_height/(Model.MODEL_SIZE*2));

    var s:Shape = _selectedShape;

    var changed:Bool = false;

  	if(_handle >= 0){
      var xg = clampSize(Std.int((x + x_grid/2)/x_grid));
      var y1 = clampSize(Std.int((y + y_grid/2)/y_grid - Model.MODEL_SIZE + s.z2));
      var z1 = clampSize(Std.int(Model.MODEL_SIZE - (y + y_grid/2)/y_grid + s.y2));
			if(_handle%2 == 0){
				// a left handle
				if(xg < s.x2 && xg != s.x1){
					s.x1 = xg;
					changed = true;
				}
			} else {
				if(xg > s.x1 && xg != s.x2){
					s.x2 = xg;
					changed = true;
				}
			}
			if(_handle < 2){
				// a top handle
				if(y1 < s.y2 && y1 != s.y1){
					s.y1 = y1;
					changed = true;
				}
			} else if(_handle < 4){
				// a mid upper handle
				if(y1 > s.y1 && y1 != s.y2){
					s.y2 = y1;
					changed = true;
				}
			} else if(_handle < 6){
				// mid lower handle
				if(z1 > s.z1 && z1 != s.z2){
					s.z2 = z1;
					changed = true;
				}
			} else {
				// a bottom handle
				if(z1 < s.z2 && z1 != s.z1){
					s.z1 = z1;
					changed = true;
				}
			}

		} else {
			var xg = clampSize(Std.int((x + x_grid/2)/x_grid));
			var deltaX = xg - s.centerX;
			if(deltaX != 0 && s.x1 + deltaX >= 0 && s.x2 + deltaX <= Model.MODEL_SIZE){
				s.x1 = s.x1 + deltaX;
				s.x2 = s.x2 + deltaX;
				changed = true;
			}
			if(_moveXY){
				var zg = s.z2;
				var yg = clampSize(Std.int((y + y_grid/2)/y_grid - Model.MODEL_SIZE + zg));
				var deltaY = Std.int(yg - (s.y2 + s.y1)/2);
				if(deltaY != 0 && s.y1 + deltaY >= 0 && s.y2 + deltaY <= Model.MODEL_SIZE){
					s.y1 = s.y1 + deltaY;
					s.y2 = s.y2 + deltaY;
					changed = true;
				}
			} else {
				var yg = s.y2;
				var zg = clampSize(Std.int(Model.MODEL_SIZE - (y + y_grid/2)/y_grid + yg));
				var deltaZ = Std.int(zg - (s.z2 + s.z1)/2);
				if(deltaZ != 0 && s.z1 + deltaZ >= 0 && s.z2 + deltaZ <= Model.MODEL_SIZE){
					s.z1 = s.z1 + deltaZ;
					s.z2 = s.z2 + deltaZ;
					changed = true;
				}
			}
		}

    if(changed){
      updateHandles();
      _base.updateModel();
    }
  }

  private function onMouseDown(event:MouseEvent) {
    _isDragging=true;
    var x = event.localX-PADDING;
    var y = event.localY-PADDING;

    _handle = getHandle(x,y);
    if(_handle < 0){
      var shape:Shape = _selectedShape;

      if (shape!=null) {
        // shape already selected
        // if in boundaries keep the selection
        var top:Rectangle = getTop(shape);
        var side:Rectangle = getSide(shape);
        if (!top.contains(x,y)&&!side.contains(x,y)) {
          // click outside boundaries
          // let the method determine a new shape
          shape=null;
        }
      }

      if(shape == null && (x >= 0 && x < _width && y >= 0 && y < _height)){
        // if no shape selected get top shape is in coordinates
        shape = _base.getShapeInCoordinates(Std.int(x),Std.int(y));
      }

      if(shape != null && shape.locked) {
        // got a shape but it is locked
        shape = null;
      }

      if(shape != null){
        // got a shape
        // determine if moving XY plane or XZ plane
        var top:Rectangle = getTop(shape);
        _moveXY = top.contains(x,y);
      }

      // select and paint (could be null)
      select(shape); //will paint both
    } else {
      // it is an handle
      // just repaint them
      paintForeground(); //paint only foreground
    }
  }

  private function onMouseUp(event:MouseEvent) {
    _isDragging = false;
    _handle = -1;
    if (_selectedShape!=null) updateHandles();
  }

  private function onMouseOut(event:MouseEvent) {
    if (!_isDragging) return;
    onMouseUp(event);
    onMouseMove(event);
  }



	public function clampSize(value:Int):Int{
		if(value < 0){
			return 0;
		} else if (value > Model.MODEL_SIZE){
			return Model.MODEL_SIZE;
		} else {
			return value;
		}
	}

	public function clamp(value:Int, min:Int, max:Int):Int{
		if (value < min){
			return min;
		} else if (value > max){
			return max;
		} else {
			return value;
		}
	}

  public function setBitmapData(bitmapData:BitmapData) {
    //if (_bitmap.bitmapData!=null) _bitmap.bitmapData.dispose(); //TODO check if disposable
    _bitmap.bitmapData = bitmapData;
  }

  public function getBitmapData():BitmapData {
    return _bitmap.bitmapData;
  }

}
