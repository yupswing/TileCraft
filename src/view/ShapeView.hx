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

  private var _show:Button;
  private var _lock:Button;

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

    _show = new Button();
    _show.x = offset_x;
    _show.y = offset_y;
    _show.style = buttonStyle;
    _show.selectable = true;
    _show.listen = true;
    _show.actionF = function(button:Button) { _list.toggleEnabledShape(_shape); };
    _show.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_EYE_CLOSED).toBitmapData();
    _show.iconSelected = TileCraft.atlasSprites.getRegion(TileCraft.ICON_EYE_OPEN).toBitmapData();
    _show.isSelected = _shape.enabled;
    addChild(_show);

    _height = _show.getGrossHeight();

    offset_x += _show.getGrossWidth()+_style.offset;

    _lock = new Button();
    _lock.x = offset_x;
    _lock.y = offset_y;
    _lock.style = buttonStyle;
    _lock.selectable = true;
    _lock.listen = true;
    _lock.actionF = function(button:Button) { _list.toggleLockedShape(_shape); };
    _lock.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_LOCK_OPEN).toBitmapData();
    _lock.iconSelected = TileCraft.atlasSprites.getRegion(TileCraft.ICON_LOCK_CLOSED).toBitmapData();
    _lock.isSelected = _shape.locked;
    addChild(_lock);

    offset_x += _lock.getGrossWidth()+_style.offset;

    var _delete = new Button();
    _delete.x = offset_x;
    _delete.y = offset_y;
    _delete.style = buttonStyle;
    _delete.selectable = false;
    _delete.listen = true;
    _delete.actionF = function(button:Button) { _list.removeShape(_shape); };
    _delete.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_DELETE).toBitmapData();
    addChild(_delete);

    //offset_x += _delete.getGrossWidth()+_style.offset;

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

  public function update() {
    // update color, shape and status
    if (_icon.bitmapData!=null) _icon.bitmapData.dispose();
    _icon.bitmapData = makeIcon();
    _show.isSelected = _shape.enabled;
    _lock.isSelected = _shape.locked;
  }

}
