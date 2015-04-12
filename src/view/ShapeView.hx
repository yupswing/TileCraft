package view;

import com.akifox.plik.gui.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import Shape;

import openfl.events.MouseEvent;

using hxColorToolkit.ColorToolkit;

class ShapeView extends Box {

  private var _shape:Shape = null;
  private var _width:Float = 0;
  private var _height:Float = 0;
  private var _list:ShapeViewList;

  private var _icon:Bitmap;

  var _isSelected:Bool = false;
  public var isSelected(get,set):Bool;
  private function get_isSelected():Bool {return _isSelected;}
  private function set_isSelected(value:Bool):Bool {
    if (_isSelected==value) return value;
    _isSelected = value;
    this.draw(_width,0,_isSelected);
    return value;
  }

  public override function getNetHeight():Float {
    return _height;
  }

  public function new(list:ShapeViewList,shape:Shape,width:Float=0) {
    _list = list;
    _width = width;
    _shape = shape;
    super(Style.getStyle('.box.shapeview'));

    addEventListener(MouseEvent.CLICK,function(e:MouseEvent) { list.select(this); });

    var offset_x:Float = _style.padding;
    var offset_y:Float = _style.padding;

    var buttonStyle = Style.getStyle('.button.miniButton');

    _icon = new Bitmap(makeIcon());
    _icon.x = offset_x+buttonStyle.padding+_style.offset;
    _icon.y = offset_y+buttonStyle.padding;
    addChild(_icon);

    offset_x += (_icon.width+buttonStyle.padding*2+_style.offset)+_style.offset;

    var button:Button;

    button = new Button();

    button.x = offset_x;
    button.y = offset_y;
    button.style = buttonStyle;
    button.selectable = true;
    button.listen = true;
    button.actionF = function(button:Button) { _list.toggleEnabledShape(_shape); };
    button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_EYE_CLOSED).toBitmapData();
    button.iconSelected = TileCraft.atlasSprites.getRegion(TileCraft.ICON_EYE_OPEN).toBitmapData();
    button.isSelected = true;
    addChild(button);

    _height = button.getGrossHeight();

    offset_x += button.getGrossWidth()+_style.offset;

    button = new Button();
    button.x = offset_x;
    button.y = offset_y;
    button.style = buttonStyle;
    button.selectable = true;
    button.listen = true;
    button.actionF = function(button:Button) { _list.toggleLockedShape(_shape); };
    button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_LOCK_OPEN).toBitmapData();
    button.iconSelected = TileCraft.atlasSprites.getRegion(TileCraft.ICON_LOCK_CLOSED).toBitmapData();
    addChild(button);

    offset_x += button.getGrossWidth()+_style.offset;

    button = new Button();
    button.x = offset_x;
    button.y = offset_y;
    button.style = buttonStyle;
    button.selectable = false;
    button.listen = true;
    button.actionF = function(button:Button) { _list.removeShape(_shape); };
    button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_DELETE).toBitmapData();
    addChild(button);

    offset_x += button.getGrossWidth()+_style.offset;

    this.draw(_width,0,_isSelected);
  }

  public function makeIcon():BitmapData {

    //shape has the palette index not the real color
    var shapeColorIndex = _shape.getColor();

    var icon = switch(_shape.getShapeType()) {
      case ShapeType.ROUND_UP: (shapeColorIndex==0?TileCraft.ICON_SHT_ROUND_UP:TileCraft.ICON_SH_ROUND_UP);
      case ShapeType.ROUND_SIDE: (shapeColorIndex==0?TileCraft.ICON_SHT_ROUND_SIDE:TileCraft.ICON_SH_ROUND_SIDE);
      case ShapeType.CYLINDER_UP: (shapeColorIndex==0?TileCraft.ICON_SHT_CYLINDER_UP:TileCraft.ICON_SH_CYLINDER_UP);
      case ShapeType.CYLINDER_SIDE: (shapeColorIndex==0?TileCraft.ICON_SHT_CYLINDER_SIDE:TileCraft.ICON_SH_CYLINDER_SIDE);
      case ShapeType.RAMP_UP: (shapeColorIndex==0?TileCraft.ICON_SHT_RAMP_UP:TileCraft.ICON_SH_RAMP_UP);
      case ShapeType.RAMP_DOWN: (shapeColorIndex==0?TileCraft.ICON_SHT_RAMP_DOWN:TileCraft.ICON_SH_RAMP_DOWN);
      case ShapeType.ARCH_UP: (shapeColorIndex==0?TileCraft.ICON_SHT_ARCH_UP:TileCraft.ICON_SH_ARCH_UP);
      case ShapeType.ARCH_DOWN: (shapeColorIndex==0?TileCraft.ICON_SHT_ARCH_DOWN:TileCraft.ICON_SH_ARCH_DOWN);
      case ShapeType.CORNER_SE: (shapeColorIndex==0?TileCraft.ICON_SHT_CORNER_SE:TileCraft.ICON_SH_CORNER_SE);
      case ShapeType.CORNER_SW: (shapeColorIndex==0?TileCraft.ICON_SHT_CORNER_SW:TileCraft.ICON_SH_CORNER_SW);
      case ShapeType.CORNER_NE: (shapeColorIndex==0?TileCraft.ICON_SHT_CORNER_NE:TileCraft.ICON_SH_CORNER_NE);
      case ShapeType.CORNER_NW: (shapeColorIndex==0?TileCraft.ICON_SHT_CORNER_NW:TileCraft.ICON_SH_CORNER_NW);
      default: (shapeColorIndex==0?TileCraft.ICON_SHT_CUBE:TileCraft.ICON_SH_CUBE);
    };


    var final = TileCraft.atlasSprites.getRegion(icon).toBitmapData();

    if (shapeColorIndex>0) {
      final.lock();
      var shapecolor:hxColorToolkit.spaces.HSB = _list.getColor(shapeColorIndex).toHSB();
      var dot:hxColorToolkit.spaces.HSB;
      for (x in 0...final.width) {
        for (y in 0...final.height) {
          dot = final.getPixel(x,y).toHSB();
          // different hue, different saturation, average brightness with original
          dot.hue = shapecolor.hue;
          dot.saturation = shapecolor.saturation;
          dot.brightness = (dot.brightness+shapecolor.brightness)*0.5;
          final.setPixel(x,y,dot.getColor());

        }
      }
      final.unlock();
    }


    return final;

  }

  public function getShape():Shape {
    return _shape;
  }

}
