package gui;

import com.akifox.plik.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.MouseEvent;
using hxColorToolkit.ColorToolkit;

class Spectrum extends SpriteContainer {

    var _spectrum:BitmapData;
    var _bitmap:Bitmap;

    var _frameWidth:Int;
    var _frameHeight:Int;
    var _frameSide:Int;
    var _action:Int->Void=null;

  	public function new (action:Int->Void,?width:Int=360,?height:Int=200,?side:Int=30) {
  		super();
      _frameWidth = width;
      _frameHeight = height;
      _frameSide = side;
      _action = action;

      _spectrum = new BitmapData(_frameWidth+_frameSide,_frameHeight,false,0);
      _bitmap = new Bitmap(_spectrum);
      addChild(_bitmap);


      addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

      drawSpectrum();
      drawSide();
  	}

    public function drawSpectrum() {
      var width = _frameWidth;
  		var height = _frameHeight;
  		var height2 = Std.int(height/2);
  		var side = _frameSide;
  		var hue:Int = 0;var sat:Int = 0; var bri:Int = 0;
  		var x:Int=0; var y:Int=0;

      _spectrum.lock();
  		for (i in 0...width) {
  			y=0;
  			hue = Std.int(i*360/width);
  			//bri = 95;
  			for (j in 0...height2) {
  				bri = 100-Std.int(j*5/height2); //from 100 to 95
  				sat = Std.int(j*95/height2); // from 0 to 95
          _spectrum.setPixel(x,y,(new hxColorToolkit.spaces.HSB(hue, sat, bri).getColor()));
  				y++;
  			}
  			for (k in 0...height2) {
  				bri = 95-Std.int(k*95/height2); //from 95 to 0
  				sat = 95+Std.int(k*5/height2); //from 95 to 100
          _spectrum.setPixel(x,y,(new hxColorToolkit.spaces.HSB(hue, sat, bri).getColor()));
  				y++;
  			}
  			x++;
  		}
      _spectrum.unlock();
    }

    public function drawSide() {
      var x = 0; var y = 0;
      var color:Int=0;
  		var hue:Int = 0;var sat:Int = 0; var bri:Int = 0;

      _spectrum.lock();
  		for (i in 0..._frameHeight) {
  			x=_frameWidth;
  			hue = 0;
  			bri = 100-Std.int(i*100/_frameHeight); //from 100 to 0
  			sat = 0;
  			color = (new hxColorToolkit.spaces.HSB(hue, sat, bri).getColor());
  			for (j in 0..._frameSide) {
          _spectrum.setPixel(x,y,color);
  				x++;
  			}
  			y++;
  		}
      _spectrum.unlock();
    }

    public override function destroy() {
      _spectrum.dispose();
      _spectrum = null;
      super.destroy();
    }

    private var _isChoosing = false;
    private function onMouseMove(event:MouseEvent) {
      if (_isChoosing) {
        _action(_spectrum.getPixel(Std.int(event.localX),Std.int(event.localY)));
      }
    }

    private function onMouseDown(event:MouseEvent) {
      _isChoosing = true;
      onMouseMove(event);
    }

    private function onMouseUp(event:MouseEvent) {
      _isChoosing = false;
    }

}
