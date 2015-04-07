package gui;

import com.akifox.plik.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
using hxColorToolkit.ColorToolkit;

class Button extends SpriteContainer {


    //*****************************************************************

    var _id:String;
    public var id(get,set):String;
    private function get_id():String {return _id;}
    private function set_id(value:String):String {
      return _id = value;
    }

    //*****************************************************************

    var _value:Dynamic;
    public var value(get,set):Dynamic;
    private function get_value():Dynamic {return _value;}
    private function set_value(value:Dynamic):Dynamic {
      return _value = value;
    }

    //*****************************************************************

    var _style:Style = new Style();
    public var style(get,set):Style;
    private function get_style():Style {return _style;}
    private function set_style(value:Style):Style {
      _style = value;
      this.draw();
      return value;
    }

    //*****************************************************************

    var _actionF:Button->Void;
    public var actionF(get,set):Button->Void;
    private function get_actionF():Button->Void {return _actionF;}
    private function set_actionF(value:Button->Void):Button->Void {
      return _actionF = value;
    }

    //*****************************************************************

    var _actionAltF:Button->Void;
    public var actionAltF(get,set):Button->Void;
    private function get_actionAltF():Button->Void {return _actionAltF;}
    private function set_actionAltF(value:Button->Void):Button->Void {
      return _actionAltF = value;
    }

    //*****************************************************************

    var _text:Text=null;
    public var text(get,set):Text;
    private function get_text():Text {return _text;}
    private function set_text(value:Text):Text {
      if (value==null && _text!=null) removeChild(_text);
      if (value!=null && _text==null) addChild(value);
      _text = value;
      this.draw();
      return value;
    }

    //*****************************************************************

    var _iconBitmap:Bitmap = new Bitmap();
    var _lastIconBitmap:BitmapData = null;

    //*****************************************************************

    var _icon:BitmapData=null;
    public var icon(get,set):BitmapData;
    private function get_icon():BitmapData {return _icon;}
    private function set_icon(value:BitmapData):BitmapData {
      _icon = value;
      this.draw();
      return value;
    }

    //*****************************************************************

    var _iconOver:BitmapData=null;
    public var iconOver(get,set):BitmapData;
    private function get_iconOver():BitmapData {return _iconOver;}
    private function set_iconOver(value:BitmapData):BitmapData {
      _iconOver = value;
      if (_isOver) this.draw();
      return value;
    }

    //*****************************************************************

    var _iconSelected:BitmapData=null;
    public var iconSelected(get,set):BitmapData;
    private function get_iconSelected():BitmapData {return _iconSelected;}
    private function set_iconSelected(value:BitmapData):BitmapData {
      _iconSelected = value;
      if (_isSelected) this.draw();
      return value;
    }

    //*****************************************************************

    var _selectable:Bool = false;
    public var selectable(get,set):Bool;
    private function get_selectable():Bool {return _selectable;}
    private function set_selectable(value:Bool):Bool {
      set_isSelected(false);
      return _selectable = value;
    }

    //*****************************************************************

    var _isOver:Bool = false;
    public var isOver(get,set):Bool;
    private function get_isOver():Bool {return _isOver;}
    private function set_isOver(value:Bool):Bool {
      _isOver = value;
      this.draw();
      return value;
    }

    //*****************************************************************

    var _isSelected:Bool = false;
    public var isSelected(get,set):Bool;
    private function get_isSelected():Bool {return _isSelected;}
    private function set_isSelected(value:Bool):Bool {
      if (!_selectable) return false;
      _isSelected = value;
      this.draw();
      return value;
    }

    //*****************************************************************

    var _listen:Bool=false;
    public var listen(get,set):Bool;
    private function get_listen():Bool {return _listen;}
    private function set_listen(value:Bool):Bool {
      _listen = value;
      if (value) {
        //hookers on
    		addEventListener(MouseEvent.CLICK, onClick);
    		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
    		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      } else {
        //hookers off
    		removeEventListener(MouseEvent.CLICK, onClick);
        removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      }
      return value;
    }

    //*****************************************************************

  	public function new () {
  		super();
      addChild(_iconBitmap);
      _id = "generic_button";
  	}

    public override function destroy() {
      _lastIconBitmap = null;
      if (_listen) set_listen(false);
      super.destroy();
    }

    public function draw() {
		  graphics.clear();

      var tw = 0;
      var th = 0;
      var iw = 0;
      var ih = 0;
      var spans = 1;
      if (_text!=null) {
        tw = Std.int(_text.width);
        th = Std.int(_text.height);
        spans+=1;
      }
      if (_icon!=null) {
        iw = Std.int(_icon.width);
        ih = Std.int(_icon.height);
        spans+=1;
      }

      var iy_offset = 0;
      var ty_offset = 0;
      if (th>ih) {
        iy_offset = Std.int((th-ih)/2);
      } else {
        ty_offset = Std.int((ih-th)/2);
      }

      var h = Math.max(th,ih) + _style.margin*2 + _style.padding*2;
      var w = tw+iw + _style.margin*2 + _style.padding*spans;
      // graphics.beginFill(0xFF0000);
      // graphics.drawRect(0,0,w,h);
      // graphics.endFill();

      // draw background
      var outline_color = _style.outline_color;
      if (_isSelected) outline_color = _style.selected_outline_color;
      if (_isOver) outline_color = _style.over_outline_color;

      graphics.lineStyle(_style.outline_size,outline_color);
      graphics.drawRoundRect(_style.margin,_style.margin,w-_style.margin*2,h-_style.margin*2,_style.rounded,_style.rounded);
      graphics.lineStyle(null);



      var bg_color = _style.background_color;
      if (_isSelected) bg_color = _style.selected_background_color;
      if (_isOver) bg_color = _style.over_background_color;

			var matrix = new openfl.geom.Matrix();
			matrix.createGradientBox(w-_style.margin,h-_style.margin,90*Math.PI/180);
			graphics.beginGradientFill(openfl.display.GradientType.LINEAR,[ColorToolkit.shiftBrighteness(bg_color,15),ColorToolkit.shiftBrighteness(bg_color,-15)],[1,1],[0,255],matrix);
			graphics.drawRoundRect(_style.margin,_style.margin,w-_style.margin*2,h-_style.margin*2,_style.rounded);
			graphics.endFill();

      var bevel_size = 2;

			graphics.beginFill(bg_color);
			graphics.drawRoundRect(_style.margin+bevel_size,_style.margin+bevel_size,w-(_style.margin+bevel_size)*2,h-(_style.margin+bevel_size)*2,_style.rounded,_style.rounded);
			graphics.endFill();

      var object_x = _style.margin + _style.padding;
      var object_y = _style.margin + _style.padding;

      // draw icon
      if (_icon!=null) {
        var bp:BitmapData = _icon;
        if (_isOver && _iconOver != null) bp = _iconOver;
        if (_isSelected && _iconSelected != null) bp = _iconSelected;
        if (bp!=_lastIconBitmap) {
            _iconBitmap.bitmapData = bp;
            _lastIconBitmap = bp;
        }
        _iconBitmap.x = object_x;
        _iconBitmap.y = object_y + iy_offset;
      }

      // position text
      if (_text!=null) {
        object_x += iw + _style.padding;
        _text.x = object_x;
        _text.y = object_y + ty_offset;
      }

    }

    private function onClick(event:MouseEvent) {
      this.click();
    }

    private function onMouseOver(event:MouseEvent) {
      this.set_isOver(true);
    }

    private function onMouseOut(event:MouseEvent) {
      this.set_isOver(false);
    }

    public function select() {
      if (!_selectable) return;
      trace('select!');
      set_isSelected(!_isSelected);
    }

    public function click() {
      select();
      action();
    }

    public function action() {
      if (_actionF!=null) _actionF(this);
    }

    public function actionAlt() {
      if (_actionAltF!=null) _actionAltF(this);
    }
}
