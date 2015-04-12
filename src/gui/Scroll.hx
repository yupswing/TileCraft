package gui;

import com.akifox.plik.*;
import openfl.events.MouseEvent;

class Scroll extends Box {

    public override function getNetWidth():Float {
      return _slider.getGrossWidth();
    }

    public override function getNetHeight():Float {
      return _height;
    }

    var _listen:Bool=false;
    public var listen(get,set):Bool;
    private function get_listen():Bool {return _listen;}
    private function set_listen(value:Bool):Bool {
      _listen = value;
      if (value) {
        //hookers on
        addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      } else {
        //hookers off
        removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      }
      return value;
    }

    var _action:Float->Void = null;

    var _height:Float = 0;

    var _valueMax:Float = 1;
    var _valueView:Float = 1;
    var _value:Float = 0; //values goes from _view to _max-_view

    public function setValueMax(value:Float):Float {
      if (value<=0) value = 0;
      _valueMax = value;

      if (_valueMax<_valueView) _valueView = _valueMax;
      setValue(_value); // to check if has to change

      draw();
      return value;
    }

    public function setValueView(value:Float):Float {
      if (value<=0) value = 0;
      _valueView = value;

      if (_valueView>_valueMax) _valueMax = _valueView;
      setValue(_value); // to check if has to change

      draw();
      return value;
    }

    public function setValue(value:Float):Float {
      if (value<=0) value = 0;
      _value = value;

      if (_value>_valueMax-_valueView) _value = _valueMax-_valueView;

      draw();
      if (_action!=null) _action(_value);
      return value;
    }

    var _slider:BoxInert;

  	public function new (height:Float=0,?action:Float->Void=null,?values:Float) {
  		super(Style.scroll());
      _action = action;
      _height = height;

      _slider = new BoxInert(Style.scrollSlider());
      _slider.x = _style.padding;

      setValueMax(values);
      setValueView(values);
      setValue(0);

      draw();
  	}

    public override function destroy() {
      super.destroy();
    }

    var _isSliderOnStage:Bool = false;

    public function drawScroll() {
      if (_valueView>=_valueMax) {
        //no scroll if there is nothing to scroll
        if (_isSliderOnStage) {
          removeChild(_slider);
          _isSliderOnStage = false;
        }
      } else {
        if (!_isSliderOnStage) {
          addChild(_slider);
          _isSliderOnStage = true;
        }
      }
      _slider.draw(0,_height*_valueView/_valueMax);
      _slider.y = _height/_valueMax*_value+_style.padding;
    }

    var _lastdraw:Float = 0;

    public override function draw(?width:Float=0,?height:Float=0,?isSelected:Bool=false) {
      //if (haxe.Timer.stamp()-_lastdraw<0.05 && !forceDraw) return;
      drawScroll();
      _lastdraw = haxe.Timer.stamp();
      super.draw(width,height,isSelected);
    }

    //*****************************************************************
    // Listeners

    private var _isChoosing = false;
    private var _offsetClick:Float = 0;
    private function onMouseMove(event:MouseEvent) {

      if (!_isChoosing) return;
      if (_valueView>=_valueMax) return; //no scroll if there is nothing to scroll

      setValue(event.localY*_valueMax/_height-_valueView/2);
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
      onMouseUp(event);
      onMouseMove(event);
    }
    public function onMouseWheel(event:MouseEvent) {
      if (_valueView>=_valueMax) return; //no scroll if there is nothing to scroll

      setValue(_value+(event.delta*(10*_valueView/_valueMax)));
    }

}
