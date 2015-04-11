package gui;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.display.BitmapData;

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.*;
import com.akifox.plik.atlas.*;
import com.akifox.transform.Transformation;

class Toolbar extends SpriteContainer implements IStyle
{

  var _buttons:Array<Button> = new Array<Button>();
  var _buttonsPerRow = 4;
  var _buttonsWidth = 32;
  var _buttonsHeight = 32;
  var _selected:Button = null;
  var _selectable:Bool = false;

  var _styleButton:Style;
  public var styleButton(get,set):Style;
  private function get_styleButton():Style { return _styleButton; }
  private function set_styleButton(value:Style):Style {
    _styleButton = value;
    for (el in _buttons) el.style = value;
    return value;
  }

  var _style:Style = new Style();
  public var style(get,set):Style;
  private function get_style():Style { return _style; }
  private function set_style(value:Style):Style {
    _style = value;
    this.draw();
    return value;
  }

	public function new (buttonsPerRow:Int, selectable:Bool, style:Style, styleButton:Style) {
		super();
    if (buttonsPerRow<=0) buttonsPerRow = 256; // 1 row only
    _buttonsPerRow = buttonsPerRow;
    _selectable = selectable;
    _style = style;
    _styleButton = styleButton;
    this.draw();
	}

  public function draw() {
    graphics.clear();
    Style.drawBackground(this,_style);
  }

  public function getRows():Int {
    return Math.ceil(_buttons.length/_buttonsPerRow);
  }

  public function getColumns():Int {
    return Std.int(Math.min(_buttonsPerRow,_buttons.length));
  }

  public function getNetWidth():Float {
    return getColumns()*(_buttonsWidth+_style.offset)-_style.offset;
  }

  public function getNetHeight():Float {
    return getRows()*(_buttonsHeight+_style.offset)-_style.offset;
  }

  public function getGrossWidth():Float {
    return getNetWidth()+_style.padding*2;//+_style.outline_size/2;
  }

  public function getGrossHeight():Float {
    return getNetHeight()+_style.padding*2;//+_style.outline_size/2;
  }


  public function getSelected():Button {
    return _selected;
  }

  public function getButtonByIndex(index:Int):Button {
    if (index>=_buttons.length || index<0) return null;
    return _buttons[index];
  }

  public function selectByIndex(index:Int):Button {
    var button = getButtonByIndex(index);
    if (button==null) return null;
    select(button);
    return button;
  }

  private function select(button:Button):Bool {
    if (button==null || !button.selectable) return false;
    if (_selected != null) _selected.isSelected = false;
    _selected = button;
    button.isSelected = true;
    return true;
  }

  public function addButton(id:String,value:Dynamic=null,icon:BitmapData=null,?actionF:Button->Void=null,?actionAltF:Button->Void=null) {
    var button:Button=null;
    if (icon!=null) {
      button = new Button();
      button.id = id;
      button.value = value;
      button.listen = true;
      button.style = _styleButton;
      button.actionF = function(button:Button) {
                          if (_selectable) select(button); //change selected
                          if (actionF!=null) actionF(button); //fire action
                       };
      if (actionAltF!=null) button.actionAltF = actionAltF;
      button.icon = icon;
      if (_buttons.length==0) {
        //set width & height same as first button
        _buttonsWidth = Std.int(button.getGrossWidth());
        _buttonsHeight = Std.int(button.getGrossHeight());
      }
      if (_selectable) {
        button.selectable = true;
        if (_selectable && (_buttons.length==0)) {
          select(button);
        }
      }
      button.x = Std.int((_buttons.length)%_buttonsPerRow)*(_buttonsWidth+_style.offset)+_style.padding;
      button.y = Std.int((_buttons.length)/_buttonsPerRow)*(_buttonsHeight+_style.offset)+_style.padding;
      addChild(button);
    }
    _buttons.push(button);
    this.draw();
  }


}
