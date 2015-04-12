package view;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import com.akifox.plik.*;

class ModelView extends SpriteContainer {
  var _bitmap:Bitmap = new Bitmap(null);
  var _background:ShapeContainer = new ShapeContainer();
  var _foreground:ShapeContainer = new ShapeContainer();

  var _height:Float = 0;
  var _width:Float = 0;
  var _base:TileCraft;

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

    addChild(_background);
    _bitmap.x = _bitmap.y = PADDING;
    addChild(_bitmap);
    _foreground.x = _foreground.y = PADDING;
    addChild(_foreground);

    drawBackground();
  }

  private function drawBackground() {
    _background.graphics.clear();

    // Sprite full size
		_background.graphics.beginFill(GRAY_3,0);
		_background.graphics.drawRect(0, 0, _width+PADDING*2, _height+PADDING*2);
    // Base background top
		_background.graphics.beginFill(GRAY_1);
		_background.graphics.drawRect(PADDING, PADDING, _width, _height/2);
    // Base background bottom
		_background.graphics.beginFill(GRAY_2);
		_background.graphics.drawRect(PADDING, _height/2+PADDING, _width, _height/2);

    // Grid
    var gw = _width/Model.MODEL_SIZE;
    var gh = _height/Model.MODEL_SIZE/2;

    _background.graphics.endFill();
    _background.graphics.lineStyle(1,GRAY_3,1);
    // x grid
    for (i in 0...Model.MODEL_SIZE+1) {
      _background.graphics.moveTo(i*gw+PADDING,PADDING);
      _background.graphics.lineTo(i*gw+PADDING,_height+PADDING);
    }

    // y grid
    for (i in 0...Model.MODEL_SIZE*2+1) {
      _background.graphics.moveTo(PADDING,i*gh+PADDING);
      _background.graphics.lineTo(_width+PADDING,i*gh+PADDING);
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
