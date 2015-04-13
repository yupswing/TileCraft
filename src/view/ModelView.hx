package view;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import com.akifox.plik.*;
import openfl.geom.Point;
import openfl.geom.Rectangle;

//TODO work in progress

class ModelView extends SpriteContainer {
  var _bitmap:Bitmap = new Bitmap(null);
  var _grid:ShapeContainer = new ShapeContainer();
  var _projection:ShapeContainer = new ShapeContainer();
  var _foreground:ShapeContainer = new ShapeContainer();

  var _height:Float = 0;
  var _width:Float = 0;
  var _base:TileCraft;
	var moveXY:Bool = false;
	var handle:Int = -1;
	var handles:Array<Point> = [for (i in 0...8) new Point(0,0)];

  private static inline var GRAY_1 = 0x404040;
  private static inline var GRAY_2 = 0x606060;
  private static inline var GRAY_3 = 0x808080;

  private static inline var HANDLE_WIDTH = 9;
  private static inline var TOP_HANDLE = 0x535d6c;
  private static inline var SIDE_HANDLE = 0x373e48;

  public static inline var PADDING = 30;


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
  }

  public function select(shape:Shape):Shape {
    paint(); //TODO wrong place
    var _selected:Shape = _base.getSelectedShape();

    if (_selected == shape) return shape; // avoid loops with _base.updateShapeSelect
    if (shape == null) return deselect();
    _base.setSelectedShape(shape);
    return shape;
  }

  public function deselect():Shape {
    if (_base.getSelectedShape() == null) return null; // avoid loops with _base.updateShapeSelect
    _base.setSelectedShape(null);
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
    var g:Graphics;
		var w = _width;
		var h = _height;
		var x1:Float = 0;
		var y1:Float = 0;

    var s:Shape = _base.getSelectedShape();
		if(s!=null){

      // draw selected shape projection
      g = _projection.graphics;
      g.clear();

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

      // draw handles
      g = _foreground.graphics;
      g.clear();

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
				if(handle == i){
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

  public function setBitmapData(bitmapData:BitmapData) {
    //if (_bitmap.bitmapData!=null) _bitmap.bitmapData.dispose(); //TODO check if disposable
    _bitmap.bitmapData = bitmapData;
  }

  public function getBitmapData():BitmapData {
    return _bitmap.bitmapData;
  }

}
