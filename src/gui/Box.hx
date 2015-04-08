package gui;

import com.akifox.plik.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
using hxColorToolkit.ColorToolkit;

class Box extends SpriteContainer {


    //*****************************************************************

    var _id:String;
    public var id(get,set):String;
    private function get_id():String {return _id;}
    private function set_id(value:String):String {
      return _id = value;
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

  	public function new (style:Style) {
  		super();
      _style = style;
      _id = "generic_box";
  	}

    public override function destroy() {
      super.destroy();
    }

    public function draw() {
		  graphics.clear();

      var w:Float = this.width+_style.padding*2;
      var h:Float = this.height+_style.padding*2;

      if (_style.outline_size>0) {
        graphics.lineStyle(_style.outline_size,_style.outline_color);
        graphics.drawRoundRect(0,0,w,h,_style.rounded,_style.rounded);
        graphics.lineStyle(null);
      }

			graphics.beginFill(_style.background_color);
      graphics.drawRoundRect(0,0,w,h,_style.rounded,_style.rounded);
			graphics.endFill();
    }

}
