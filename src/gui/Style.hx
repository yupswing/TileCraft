package gui;
using hxColorToolkit.ColorToolkit;


class Style {

    public var padding:Int = 0;
    public var offset:Int = 0; //offset between internal elements
    public var rounded:Int = 0;
    public var minWidth:Int = 0;
    public var minHeight:Int = 0;
    public var outline_size:Int = 0;
    public var bevel:Int = 0;
    public var color:UInt = 0;
    public var font_name:String = "";
    public var font_size:Int = 16;
    public var font_offset_x:Int = 0;
    public var font_offset_y:Int = 0;
    public var background_color:UInt = 0;
    public var over_background_color:UInt = 0;
    public var selected_background_color:UInt = 0;
    public var outline_color:UInt = 0;
    public var over_outline_color:UInt = 0;
    public var selected_outline_color:UInt = 0;

    public function getFullWidth():Int {
      return minHeight + padding*2;
    }
    public function getFullHeight():Int {
      return minWidth + padding*2;
    }

    // public function get(key:String):Dynamic {
    //   return Reflect.getProperty(this, key);
    // }
    //
    // public function getInt(key:String):Int {
    //   var value:Dynamic = get(key);
    //   if (value==null) return -1;
    //   return Std.int(value);
    // }
    //
    // public function getFloat(key:String):Float {
    //   var value:Dynamic = get(key);
    //   if (value==null) return -1;
    //   return cast(value,Float);
    // }
    //
    // public function getColor(key:String):Int {
    //   var value:Dynamic = get(key);
    //   if (value==null) return 0;
    //   return toColor(Std.int(value));
    // }
    //
    // public function getAlpha(key:String):Float {
    //   var value:Dynamic = get(key);
    //   if (value==null) return 0;
    //   return toAlpha(Std.int(value));
    // }
    //
    public static function toColor(color:UInt):UInt {
      if (color<0) return -1;
      return color>>8;
    }

    public static function toAlpha(color:UInt):Float {
      if (color<0) return -1;
      return (color&0xFF)/256;
    }
    //
    // public function getString(key:String):String {
    //   var value:Dynamic = get(key);
    //   if (value==null) return "";
    //   return Std.string(value);
    // }

    public function copy(style:Style) {
      this.minWidth = style.minWidth;
      this.minHeight = style.minHeight;
      this.padding = style.padding;
      this.offset = style.offset;
      this.rounded = style.rounded;
      this.color = style.color;
      this.font_name = style.font_name;
      this.font_size = style.font_size;
      this.font_offset_x = style.font_offset_x;
      this.font_offset_y = style.font_offset_y;
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
        'padding':10,
        'offset':5,
        'rounded':8,
        'minWidth':5,
        'minHeight':5,

        // 'font_name':com.akifox.plik.PLIK.getFont(TileCraft.FONT_SQUARE).fontName,
        // 'font_offset_x':1,
        // 'font_offset_y':1,
        'font_name':com.akifox.plik.PLIK.getFont(TileCraft.FONT_LATO_BOLD).fontName,

        'font_size':18,
        'color':0xFFFFFFFF,

        'outline_size':3,
        'bevel':2,
        'background_color':0x3d4246ff,
        'over_background_color':0x575a5eff,
        'selected_background_color':0x3d4246ff,
        'outline_color':0,
        'over_outline_color':0xffb50088,
        'selected_outline_color':0xaaaaaaFF
      });
    }

    public static function miniButton():Style {
      return button().set({
        'padding' : 2,
        'bevel' : 0,
        'rounded':24,
        'font_size':12,
        'color':0xFFFFFFFF,
        'outline_size' : 0,
        'background_color':0,
        'over_background_color':0x464646FF,
        'selected_background_color':0x353535FF,
        'outline_color':0,
        'over_outline_color':0,
        'selected_outline_color':0
      });
    }

    public static function miniButtonClose():Style {
      return miniButton().set({
        'background_color':0xDADADAFF,
        'over_background_color':0xF2F2F2FF
      });
    }

    public static function toolbarButton():Style {
      return button().set({
        'padding' : 5,
        'bevel':1,
        'outline_size' : 3,
        'outline_color':0,
        'over_outline_color':0,
        'selected_outline_color':0xffb500FF
      });
    }

    public static function toolbarMiniButton():Style {
      return toolbarButton().set({
        'padding' : 3,
        'rounded':12
      });
    }

    public static function toolbarButtonFull():Style {
      return toolbarButton().set({
        'padding' : 0,
        'bevel':2,
        'outline_size' : 6,
        'minWidth': 20+toolbarButton().padding*2,
        'minHeight': 20+toolbarButton().padding*2,
        'background_color' : 0,
        'over_background_color':0,
        'selected_background_color':0,
        'over_outline_color':0xffb500DD
      });
    }

    public static function toolbarMiniButtonFull():Style {
      return toolbarMiniButton().set({
        'padding' : 0,
        'bevel':2,
        'outline_size' : 4,
        'minWidth': 20+toolbarMiniButton().padding*2,
        'minHeight': 20+toolbarMiniButton().padding*2,
        'background_color' : 0,
        'over_background_color':0,
        'selected_background_color':0,
        'over_outline_color':0xffb500DD
      });
    }

    public static function toolbar():Style {
      return new Style({
          'padding':5,
          'offset':5,
          'rounded':8,
          'outline_size':0,
          'background_color':0
        });
    }

    public static function colorpicker():Style {
      return new Style({
          'padding':20,
          'rounded':8,
          'offset':10,
          'outline_size':0,
          'background_color':0x242424CC
        });
    }

    public static function box():Style {
      return new Style({
          'padding':10,
          'rounded':0,
          'offset':10,
          'outline_size':0,
          'background_color':0x242424BB
          //'outline_color':0xffb400CC
        });
    }

    public static function shapeview():Style {
      return box().set({
          'rounded':8,
          'padding':-1,
          'offset':6,
          'background_color':0x000000BB,
          'selected_background_color':0x666666BB
        });
    }

    public static function shapeviewlist():Style {
      return box().set({
          'padding':5,
          'offset':2,
          'background_color':0
        });
    }

    public static function scroll():Style {
      return new Style({
          'padding':5,
          'rounded':12,
          'outline_size':0,
          'background_color':0x46464666
        });
    }

    public static function scrollSlider():Style {
      return new Style({
          'padding':0,
          'rounded':12,
          'minWidth':10,
          'bevel':1,
          'background_color':0x242424ff,
          'outline_size':2,
          'outline_color':0xdfdfdf66
        });
    }

    public static function drawBackground(target:IStyle,targetStyle:Style,?isSelected:Bool=false,?isOver:Bool=false,?width:Float=0,?height:Float=0) {

      var w = Math.max(target.getNetWidth(),targetStyle.minWidth)+targetStyle.padding*2;
      var h = Math.max(target.getNetHeight(),targetStyle.minHeight)+targetStyle.padding*2;
      if (width>0) w = width;
      if (height>0) h = height;
      #if v2
      var graphics = target.graphics;
      #else
      var graphics:openfl.display.Graphics = Reflect.getProperty(target, 'graphics');
      #end

      // draw background
      if (targetStyle.outline_size>0) {
        var outline = targetStyle.outline_color;
        if (isSelected) outline = targetStyle.selected_outline_color;
        var outline_color = toColor(outline);
        var outline_alpha = toAlpha(outline);

        graphics.lineStyle(targetStyle.outline_size,outline_color,outline_alpha);
        graphics.drawRoundRect(0,0,w,h,targetStyle.rounded,targetStyle.rounded);
        #if v2
        graphics.lineStyle(null);
        #else
        graphics.lineStyle(null,null);
        #end


        if (isOver) {
          outline_color = toColor(targetStyle.over_outline_color);
          outline_alpha = toAlpha(targetStyle.over_outline_color);

          if (outline_alpha>0) {
            graphics.lineStyle(targetStyle.outline_size,outline_color,outline_alpha);
            graphics.drawRoundRect(0,0,w,h,targetStyle.rounded,targetStyle.rounded);
            #if v2
            graphics.lineStyle(null);
            #else
            graphics.lineStyle(null,null);
            #end
          }
        }

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
  			graphics.drawRoundRect(0,0,w,h,targetStyle.rounded,targetStyle.rounded);
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
