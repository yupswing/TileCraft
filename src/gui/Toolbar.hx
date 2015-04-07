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

class Toolbar extends SpriteContainer
{

  var _buttons:Array<Button> = new Array<Button>();
  var _buttonsPerRow = 4;
  var _buttonsWidth = 32;
  var _buttonsHeight = 32;
  var _parentScreen:ScreenMain;
  var _selected:Button = null;
  var _selectable:Bool = false;

  var _styleButton:Style;
  var _style:Style;

	public function new (parentScreen:ScreenMain,buttonsPerRow:Int,selectable:Bool, style:Style, styleButton:Style) {
		super();
    _parentScreen = parentScreen;
    _buttonsPerRow = buttonsPerRow;
    _selectable = selectable;
    _style = style;
    _styleButton = styleButton;
	}

  public function getSelected():Button {
    return _selected;
  }

  public function getButtonByIndex(index:Int):Button {
    if (index>=_buttons.length || index<0) return null;
    return _buttons[index];
  }

  public function addButton(id:String,value:Dynamic=null,icon:BitmapData=null,?actionF:Button->Void=null) {
    var button:Button=null;
    //if (icon!=null) {
      button = new Button();
      button.id = id;
      button.value = value;
      button.listen = true;
      button.style = _styleButton;
      button.actionF = onClick;
      button.actionAltF = actionF;
      button.icon = icon;
      if (_buttons.length==0) {
        //set width & height same as first button
        _buttonsWidth = Std.int(button.width);
        _buttonsHeight = Std.int(button.height);
      }
      if (_selectable) {
        button.selectable = true;
        if (_selectable && (_buttons.length==0)) {
          _selected = button;
          button.isSelected = true;
        }
      }
      button.x = Std.int((_buttons.length)%_buttonsPerRow)*(_buttonsWidth+_style.padding)+_style.margin;
      button.y = Std.int((_buttons.length)/_buttonsPerRow)*(_buttonsHeight+_style.padding)+_style.margin;
      addChild(button);
    //}
    _buttons.push(button);
  }

  public function redraw() {
    for (el in _buttons) {
      if (el!=null) el.draw();
    }
  }

  public function onClick(button:Button) {
    if (_selectable && button!=_selected && _selected != null) {
      //deselect previous button
      _selected.isSelected = false;
    }
    button.isSelected = true;
    _selected = button;
    //fire action
    button.actionAlt();

		// var _tfe_x = (event.stageX - this.x - _parentScreen.x) / _parentScreen.currentScale;
		// var _tfe_y = (event.stageY - this.y - _parentScreen.y) / _parentScreen.currentScale;
    //
    // var y = Std.int((_tfe_y-_style.margin) / (_buttonsWidth+_style.padding));
    // var x = Std.int((_tfe_x-_style.margin) / (_buttonsHeight+_style.padding));
    //
    // var index = y*_buttonsPerRow+x;
    // if (index<_buttons.length && _buttons[index] != null) {
    //   if (_selectable) {
    //     _buttons[_selected].isSelected = false;
    //     _buttons[index].isSelected = true;
    //     _selected = index;
    //   }
    //   _buttons[index].click();
    // }

  }


}
