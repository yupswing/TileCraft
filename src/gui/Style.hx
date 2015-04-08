package gui;
using hxColorToolkit.ColorToolkit;

typedef Property = {
  var kind : Kind;
  var value : Dynamic;

}
enum Kind {
	Int;
	Float;
  String;
}


class Style {

    public function getWidth():Int {
      return height + padding*2 + margin*2;
    }
    public function getHeight():Int {
      return width + padding*2 + margin*2;
    }

    public var margin:Int = 0;
    public var padding:Int = 0;
    public var offset:Int = 0; //offset between internal elements
    public var rounded:Int = 0;
    public var width:Int = 0;
    public var height:Int = 0;
    public var outline_size:Int = 0;
    public var bevel:Int = 0;
    public var color:Int = 0;
    public var font_name:String = "";
    public var font_size:Int = 16;
    public var background_color:Int = 0;
    public var over_background_color:Int = 0;
    public var selected_background_color:Int = 0;
    public var outline_color:Int = 0;
    public var over_outline_color:Int = 0;
    public var selected_outline_color:Int = 0;

    public function get(key:String):Dynamic {
      return Reflect.getProperty(this, key);
    }

    public function getInt(key:String):Int {
      var value:Dynamic = get(key);
      if (value==null) return -1;
      return Std.int(value);
    }

    public function getFloat(key:String):Float {
      var value:Dynamic = get(key);
      if (value==null) return -1;
      return cast(value,Float);
    }

    public function getColor(key:String):Int {
      var value:Dynamic = get(key);
      if (value==null) return 0;
      return toColor(Std.int(value));
    }

    public function getAlpha(key:String):Float {
      var value:Dynamic = get(key);
      if (value==null) return 0;
      return toAlpha(Std.int(value));
    }

    public static function toColor(color:Int):Int {
      return color>>8;
    }

    public static function toAlpha(color:Int):Float {
      return (color&0xFF)/256;
    }

    public function getString(key:String):String {
      var value:Dynamic = get(key);
      if (value==null) return "";
      return Std.string(value);
    }

    public function copy(style:Style) {
      this.width = style.width;
      this.height = style.height;
      this.margin = style.margin;
      this.padding = style.padding;
      this.offset = style.offset;
      this.rounded = style.rounded;
      this.color = style.color;
      this.font_name = style.font_name;
      this.font_size = style.font_size;
      this.outline_size = style.outline_size;
      this.background_color = style.background_color;
      this.over_background_color = style.over_background_color;
      this.selected_background_color = style.selected_background_color;
      this.outline_color = style.outline_color;
      this.over_outline_color = style.over_outline_color;
      this.selected_outline_color = style.selected_outline_color;
    }

    public function new(defaults:Dynamic = null) {
    	set(defaults);
    }

    public function set(values:Dynamic = null):Style {
      if (values==null) return this;
    	for (field in Reflect.fields(values)) {
    		if (Reflect.getProperty(this, field) != null) {
    			Reflect.setProperty(this, field, Reflect.field(values, field));
    		}
    	}
      return this;
    }

    //****************************************************************/

    public static function button():Style {
      return new Style({
        'margin':0,
        'padding':8,
        'rounded':8,
        'width':20,
        'height':20,
        'outline_size':3,
        'bevel':2,
        'background_color':0xddddddFF,
        'over_background_color':0xeeeeeeFF,
        'selected_background_color':0xddddddFF,
        'outline_color':0xaaaaaaFF,
        'over_outline_color':0xffcf00FF,
        'selected_outline_color':0xaaaaaaFF
      });
    }
    public static function miniButton():Style {
      return button().set({
        'padding' : 2,
        'outline_size' : 2,
        'bevel' : 1
      });
    }

    public static function toolbarButton():Style {
      return button().set({
        'padding' : 3,
        'outline_size' : 6,
        'outline_color':0,
        'over_outline_color':0xffd97dFF,
        'selected_outline_color':0xffb500FF
      });
    }

    public static function toolbarMiniButton():Style {
      return toolbarButton().set({
        'padding' : 1,
        'rounded':12,
        'background_color':0xddddddFF,
        'outline_size' : 5,
        'outline_color':0,
        'over_background_color':0xddddddFF,
        'over_outline_color':0xffd97dFF
      });
    }

    public static function toolbarButtonFull():Style {
      return toolbarButton().set({
        'padding' : 0,
        'background_color' : 0,
        'over_background_color':0,
        'over_outline_color':0xffd97dFF,
        'selected_background_color':0xffb500FF
      });
    }

    public static function toolbarMiniButtonFull():Style {
      return toolbarButtonFull().set({
        'outline_size' : 2,
        'background_color' : 0,
        'over_background_color':0,
        'over_outline_color':0xffd97dFF,
        'selected_background_color':0xffb500FF
      });
    }

    public static function toolbar():Style {
      return new Style({
          'padding':1,
          'offset':1,
          'rounded':8,
          'outline_size':0,
          'background_color':0xddddddFF
        });
    }

    public static function colorpicker():Style {
      return new Style({
          'margin':0,
          'padding':20,
          'rounded':8,
          'offset':10,
          'outline_size':0,
          'background_color':0x242424CC
        });
    }

    public static function box():Style {
      return new Style({
          'margin':0,
          'padding':10,
          'rounded':0,
          'offset':10,
          'outline_size':0,
          'background_color':0x242424BB
          //'outline_color':0xffb400CC
        });
    }

    public static function drawBackground(target:openfl.display.DisplayObject,targetStyle:Style,?isSelected:Bool=false,?isOver:Bool=false,?width:Float=0,?height:Float=0) {

      var w = Math.max(target.width+targetStyle.padding*2,width);
      var h = Math.max(target.height+targetStyle.padding*2,height);
      var graphics = target.graphics;

      // draw background
      if (targetStyle.outline_size>0) {
        var outline = targetStyle.outline_color;
        if (isSelected) outline = targetStyle.selected_outline_color;
        if (isOver) outline = targetStyle.over_outline_color;
        var outline_color = toColor(outline);
        var outline_alpha = toAlpha(outline);

        graphics.lineStyle(targetStyle.outline_size,outline_color,outline_alpha);
        graphics.drawRoundRect(0,0,w,h,targetStyle.rounded,targetStyle.rounded);
        graphics.lineStyle(null);
      }

      var background = targetStyle.background_color;
      if (isSelected) background = targetStyle.selected_background_color;
      if (isOver) background = targetStyle.over_background_color;

      var background_color = toColor(background);
      var background_alpha = toAlpha(background);

      if (targetStyle.bevel>0) {
  			var matrix = new openfl.geom.Matrix();
  			matrix.createGradientBox(w,h,90*Math.PI/180);
  			graphics.beginGradientFill(openfl.display.GradientType.LINEAR,[ColorToolkit.shiftBrighteness(background_color,15),ColorToolkit.shiftBrighteness(background_color,-15)],[background_alpha,background_alpha],[0,255],matrix);
  			graphics.drawRoundRect(0,0,w,h,targetStyle.rounded);
  			graphics.endFill();
      }

			graphics.beginFill(background_color,background_alpha);
      if (targetStyle.rounded>0)
			   graphics.drawRoundRect(targetStyle.bevel,targetStyle.bevel,w-targetStyle.bevel*2,h-targetStyle.bevel*2,targetStyle.rounded,targetStyle.rounded);
			else
			   graphics.drawRect(targetStyle.bevel,targetStyle.bevel,w-targetStyle.bevel*2,h-targetStyle.bevel*2);


      graphics.endFill();
    }

}
