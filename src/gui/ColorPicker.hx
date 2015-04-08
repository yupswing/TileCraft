package gui;

import com.akifox.plik.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.MouseEvent;
using hxColorToolkit.ColorToolkit;

class ColorPicker extends SpriteContainer {

    var _spectrum:BitmapData;
    var _slider:BitmapData;
    var _bitmapSpectrum:Bitmap;
    var _bitmapSlider:Bitmap;

    var _frameWidth:Int;
    var _frameHeight:Int;
    var _frameSide:Int;
    var _action:Int->Void=null;

    var selectorSpectrum:ShapeContainer;
    var selectorSpectrumSize:Int = 20;

    var _selectorSlider:ShapeContainer;
    var _selectorSliderSize:Int = 7;

    public var _offset = 10;
    public var _padding = 5;

    var _byteArrayUtil:openfl.utils.ByteArray;

    var _colorHSB:hxColorToolkit.spaces.HSB;

    var _lastdraw:Float = 0;

    var _listen:Bool=false;
    public var listen(get,set):Bool;
    private function get_listen():Bool {return _listen;}
    private function set_listen(value:Bool):Bool {
      _listen = value;
      if (value) {
        //hookers on
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      } else {
        //hookers off
        removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      }
      return value;
    }

  	public function new (action:Int->Void,?width:Int=360,?height:Int=150,?side:Int=30) {
  		super();
      _frameWidth = width;
      _frameHeight = height;
      _frameSide = side;
      _action = action;

      //graphics.beginFill(0xFF0000);
      //graphics.drawRect(0,0,_frameWidth+_frameSide+_offset+_padding*2,_frameHeight+_padding*2);

      _byteArrayUtil = new openfl.utils.ByteArray();

      _spectrum = new BitmapData(_frameWidth,_frameHeight,false,0);
      _bitmapSpectrum = new Bitmap(_spectrum);
      _bitmapSpectrum.x = _padding;
      _bitmapSpectrum.y = _padding;
      addChild(_bitmapSpectrum);

      _slider = new BitmapData(_frameSide,_frameHeight,false,0);
      _bitmapSlider = new Bitmap(_slider);
      _bitmapSlider.x = _frameWidth+_offset+_padding;
      _bitmapSlider.y = _padding;
      addChild(_bitmapSlider);

      selectorSpectrum = new ShapeContainer();
      drawSelectorColorPicker();
      addChild(selectorSpectrum);

      _selectorSlider = new ShapeContainer();
      _selectorSlider.x = _frameWidth+_offset+_padding;
      drawSelectorSlider();
      addChild(_selectorSlider);

      // Select default (HSB 180,50,50)
      selector(0x408080);
  	}

    public override function destroy() {
      _slider.dispose();
      _spectrum.dispose();
      _byteArrayUtil.clear();
      super.destroy();
    }

    public function selector(color:Int) {
      var hsb = color.toHSB();
      _colorHSB = hsb;
      drawSpectrum();
      drawSide();
      selectorSpectrum.x = Std.int(hsb.hue*_frameWidth/360-selectorSpectrumSize*0.5)+_padding;
      selectorSpectrum.y = Std.int((hsb.saturation*_frameHeight/100)-selectorSpectrumSize*0.5)+_padding;
      _selectorSlider.y = Std.int(_frameHeight-(hsb.brightness*_frameHeight/100)-_selectorSliderSize/2)+_padding;
    }

    private inline function selectorManual(color:Int,x:Int,y:Int) {
      _colorHSB = color.toHSB();
      if (x>_frameWidth+_padding) {
        _selectorSlider.y = y-_selectorSliderSize/2;
        drawSpectrum();
      } else {
        selectorSpectrum.x = x-selectorSpectrumSize*0.5;
        selectorSpectrum.y = y-selectorSpectrumSize*0.5;
        drawSide();
      }
    }

    //*****************************************************************
    // Main render

    public function drawSpectrum() {
      // avoid too many draw spectrum calls
      if (haxe.Timer.stamp()-_lastdraw<0.05) return;

      var hsbcolor = new hxColorToolkit.spaces.HSB(0, 0, Std.int(_colorHSB.brightness));

      // // SPECIAL SPECTRUM (half saturation, half brightness)
      // var x:Int=0; var y:Int=0;
      // _spectrum.lock();
  		// for (i in 0...width) {
  		// 	y=0;
  		// 	hue = Std.int(i*360/width);
  		// 	//bri = 95;
  		// 	for (j in 0...height2) {
  		// 		bri = 100-Std.int(j*5/height2); //from 100 to 95
  		// 		sat = Std.int(j*95/height2); // from 0 to 95
      //     _spectrum.setPixel(x,y,(new hxColorToolkit.spaces.HSB(hue, sat, bri).getColor()));
  		// 		y++;
  		// 	}
  		// 	for (k in 0...height2) {
  		// 		bri = 95-Std.int(k*95/height2); //from 95 to 0
  		// 		sat = 95+Std.int(k*5/height2); //from 95 to 100
      //     _spectrum.setPixel(x,y,(new hxColorToolkit.spaces.HSB(hue, sat, bri).getColor()));
  		// 		y++;
  		// 	}
  		// 	x++;
  		// }

      // // SET PIXEL VERSION (Slower)
      // var x = 0;
      // var y = 0;
      // _spectrum.lock();
      // for (i in 0..._frameWidth) {
  		// 	y=0;
      //   hsbcolor.hue = Std.int(i*360/_frameWidth);
  		// 	for (j in 0..._frameHeight) {
      //     hsbcolor.saturation = Std.int(j*100/_frameHeight); //from 0 to 100
      //     _spectrum.setPixel(x,y,hsbcolor.getColor());
  		// 		y++;
  		// 	}
  		// 	x++;
  		// }
      // _spectrum.unlock();

      // ByteArray version (Faster)
      _byteArrayUtil.clear();
      for (i in 0..._frameHeight) {
      hsbcolor.saturation = Std.int(i*100/_frameHeight); //from 0 to 100
  			for (j in 0..._frameWidth) {
          hsbcolor.hue = Std.int(j*360/_frameWidth);
          _byteArrayUtil.writeUnsignedInt(hsbcolor.getColor());
  			}
  		}

      _byteArrayUtil.position = 0;
      _spectrum.lock();
      _spectrum.setPixels(new openfl.geom.Rectangle(0,0,_frameWidth,_frameHeight),_byteArrayUtil);
      _spectrum.unlock();

      _lastdraw = haxe.Timer.stamp();

    }

    public function drawSide() {
      var color:Int=0;
      var hsbcolor = new hxColorToolkit.spaces.HSB(Std.int(_colorHSB.hue), Std.int(_colorHSB.saturation), 0);
      _byteArrayUtil.clear();

  		for (i in 0..._frameHeight) {
        hsbcolor.brightness = 100-Std.int(i*100/_frameHeight); //from 100 to 0
  			color = hsbcolor.getColor();
  			for (j in 0..._frameSide) {
          _byteArrayUtil.writeUnsignedInt(color);
  			}
  		}

      _byteArrayUtil.position = 0;
      _slider.lock();
      _slider.setPixels(new openfl.geom.Rectangle(0,0,_frameSide,_frameHeight),_byteArrayUtil);
      _slider.unlock();
    }

    //*****************************************************************
    // Listeners

    private var _isChoosing = false;
    private function onMouseMove(event:MouseEvent) {

      if (!_isChoosing) return;

      var x = Std.int(event.localX);
      var y = Std.int(event.localY);

      // out of big boundaries
      if (x<_padding || x>_padding+_frameWidth+_offset+_frameSide || y<_padding || y>_padding+_frameHeight) return;

      var color = -1;
      if (x > _padding+_frameWidth+_offset && x < _padding+_frameWidth+_offset+_frameSide) {
        color = _slider.getPixel(x-_frameWidth-_offset-_padding,y-_padding);
      } else if (x > _padding && x < _padding+_frameWidth) {
        color = _spectrum.getPixel(x-_padding,y-_padding);
      }
      //out of precise boundaries
      if (color==-1) return;

      selectorManual(color,x,y);
      _action(color);
    }

    private function onMouseDown(event:MouseEvent) {
      _isChoosing = true;
      onMouseMove(event);
    }

    private function onMouseUp(event:MouseEvent) {
      _lastdraw = 0;
      _isChoosing = false;
    }

    private function onMouseOut(event:MouseEvent) {
      if (!_isChoosing) return;
      trace('out');
      onMouseUp(event);
      var x = Std.int(event.localX);
      var y = Std.int(event.localY);
      trace(x,y);
      if (x<_padding) x = _padding;
      if (x>_padding+_frameWidth+_offset+_frameSide) x = _padding+_frameWidth+_offset+_frameSide;
      if (y<_padding) y = _padding;
      if (y>_padding+_frameHeight) y = _padding+_frameHeight;
      event.localX = x;
      event.localY = y;
      trace(x,y,event.localX,event.localY);
      onMouseMove(event);
    }


    //*****************************************************************
    // Drawers

    private function drawSelectorColorPicker() {
      selectorSpectrum.graphics.clear();
      selectorSpectrum.graphics.lineStyle(3,0x000000);
      selectorSpectrum.graphics.drawCircle(10,10,5);

      selectorSpectrum.graphics.moveTo(selectorSpectrumSize*0.5,0);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize*0.5,selectorSpectrumSize*0.25+selectorSpectrumSize/20);
      selectorSpectrum.graphics.moveTo(selectorSpectrumSize*0.5,selectorSpectrumSize*0.75-selectorSpectrumSize/20);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize*0.5,selectorSpectrumSize);

      selectorSpectrum.graphics.moveTo(0,selectorSpectrumSize*0.5);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize*0.25+selectorSpectrumSize/20,selectorSpectrumSize*0.5);
      selectorSpectrum.graphics.moveTo(selectorSpectrumSize*0.75-selectorSpectrumSize/20,selectorSpectrumSize*0.5);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize,selectorSpectrumSize*0.5);

      selectorSpectrum.graphics.lineStyle(1,0xFFFFFF);
      selectorSpectrum.graphics.drawCircle(selectorSpectrumSize*0.5,selectorSpectrumSize*0.5,5);

      selectorSpectrum.graphics.moveTo(selectorSpectrumSize*0.5,0);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize*0.5,selectorSpectrumSize*0.25+selectorSpectrumSize/20);
      selectorSpectrum.graphics.moveTo(selectorSpectrumSize*0.5,selectorSpectrumSize*0.75-selectorSpectrumSize/20);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize*0.5,selectorSpectrumSize);

      selectorSpectrum.graphics.moveTo(0,selectorSpectrumSize*0.5);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize*0.25+selectorSpectrumSize/20,selectorSpectrumSize*0.5);
      selectorSpectrum.graphics.moveTo(selectorSpectrumSize*0.75-selectorSpectrumSize/20,selectorSpectrumSize*0.5);
      selectorSpectrum.graphics.lineTo(selectorSpectrumSize,selectorSpectrumSize*0.5);
    }

    private function drawSelectorSlider() {
      _selectorSlider.graphics.clear();


      _selectorSlider.graphics.lineStyle(3,0x000000);
      _selectorSlider.graphics.drawRect(0,0,_frameSide,_selectorSliderSize);//,_selectorSliderSize/2);
      _selectorSlider.graphics.lineStyle(1,0xFFFFFF);
      _selectorSlider.graphics.drawRect(0,0,_frameSide,_selectorSliderSize);//,_selectorSliderSize/2);
    }

}
