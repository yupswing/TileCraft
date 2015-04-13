package view;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import com.akifox.plik.*;
using hxColorToolkit.ColorToolkit;

class OutputView extends SpriteContainer {

  var _bitmap:Bitmap = new Bitmap(null);
  var _width:Float = 0;
  var _base:TileCraft;
  var _backgroundColor = -1;

  public function setBackgroundColor(color:Int) {
    _backgroundColor = color;
    drawBackground();
  }

  public function new(base:TileCraft,width:Float) {
    super();
    _width = width;
    _base = base;
    addChild(_bitmap);
    drawBackground();
    this.updateTransformation();
  }

  public function setBitmapData(bitmapData:BitmapData) {
    if (_bitmap.bitmapData!=null) _bitmap.bitmapData.dispose();
    _bitmap.bitmapData = bitmapData;
    _bitmap.x = _width/2-_bitmap.width/2;
    this.updateTransformation();
  }

  public function getBitmapData():BitmapData {
    return _bitmap.bitmapData;
  }

	public function drawBackground() {
		graphics.clear();
		var color = _backgroundColor;
		var alpha = 0.9;
		var span = 0; //BASE_SPAN

    var height = (_bitmap.bitmapData == null?100:_bitmap.height);

		if (_backgroundColor==-1) {
			//transparent
			APP.makeChessboard(graphics,Std.int(20*_base.getOutputScale()),0,0,_width,height,0xBBBBBB,0xEEEEEE);

		} else {
			graphics.beginFill(_backgroundColor);
			graphics.drawRect(0,0,_width,height);

			var shiftColor:Int=0;
			if (color<0x888888) {
				shiftColor = ColorToolkit.shiftBrighteness(color,30);
			}	else {
				shiftColor = ColorToolkit.shiftBrighteness(color,-30);
			}
			graphics.beginFill(shiftColor,alpha);
			graphics.drawRect(_width/2-_bitmap.width/2,span,
						_bitmap.width,_bitmap.height/2);

			if (color<0x888888) {
				shiftColor = ColorToolkit.shiftBrighteness(color,15);
			}	else {
				shiftColor = ColorToolkit.shiftBrighteness(color,-15);
			}
			graphics.beginFill(shiftColor,alpha);
			graphics.drawRect(_width/2-_bitmap.width/2,span+_bitmap.height/2,
			_bitmap.width,_bitmap.height/2);
		}
		graphics.endFill();
    this.updateTransformation();

	}

}
