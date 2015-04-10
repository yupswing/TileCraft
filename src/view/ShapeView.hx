package view;

import gui.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import Shape;

using hxColorToolkit.ColorToolkit;

class ShapeView extends Box {

  private var _shape:Shape = null;
  private var _width:Float = 0;
  private var _list:ShapeViewList;

  private var _icon:Bitmap;

  public function new(list:ShapeViewList,shape:Shape,width:Float=0) {
    _list = list;
    _width = width;
    _shape = shape;
    super(Style.shapeview());

    var buttonStyle = Style.miniButton();

    _icon = new Bitmap(makeIcon());
    _icon.x = _style.padding+buttonStyle.padding;
    _icon.y = _style.padding+buttonStyle.padding;
    addChild(_icon);

    var button:Button;
    button = new Button();
    button.x = _style.padding+_icon.width+_style.offset;
    button.y = _style.padding;
    button.style = buttonStyle;
    button.selectable = true;
    button.listen = true;
    button.actionF = function(button:Button) { trace('lock'); };
    button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_LOCK_OPEN).toBitmapData();
    button.iconSelected = TileCraft.atlasSprites.getRegion(TileCraft.ICON_LOCK_CLOSED).toBitmapData();
    addChild(button);

    button = new Button();
    button.x = _style.padding+(_style.offset+buttonStyle.width)*2;
    button.y = _style.padding;
    button.style = buttonStyle;
    button.selectable = true;
    button.listen = true;
    button.actionF = function(button:Button) { trace('show'); };
    button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_EYE_CLOSED).toBitmapData();
    button.iconSelected = TileCraft.atlasSprites.getRegion(TileCraft.ICON_EYE_OPEN).toBitmapData();
    button.isSelected = true;
    addChild(button);

    button = new Button();
    button.x = _style.padding+(_style.offset+buttonStyle.width)*3;
    button.y = _style.padding;
    button.style = buttonStyle;
    button.selectable = false;
    button.listen = true;
    button.actionF = function(button:Button) { _list.removeShape(_shape); };
    button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_DELETE).toBitmapData();
    addChild(button);

    //draw();
    draw(_width);



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
          // different hue, different saturation, same brightness as original
          dot.hue = shapecolor.hue;
          dot.saturation = shapecolor.saturation;
          //dot.brightness = shapecolor.brightness;
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
