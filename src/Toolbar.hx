package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.PLIK;
import com.akifox.plik.Utils;
import com.akifox.plik.Gfx;
import com.akifox.plik.Text;
import com.akifox.plik.Screen;
import com.akifox.plik.SpriteContainer;
import com.akifox.plik.ShapeContainer;
import com.akifox.transform.Transformation;
import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.atlas.*;

class Button extends ShapeContainer {

    public static var WIDTH = 20;
    public static var HEIGHT = 20;
    public static var OUTER = 8;
    public static var ROUNDED = 8;
    public static var SELECTED = 5;

    var _icon:AtlasRegion;

    var _name = "button";
    var _index = 0;

    var _selected:Bool = false;
    var _f:Int->Void;
    public var selected(get,set):Bool;
    private function get_selected():Bool {return _selected;}
    private function set_selected(value:Bool):Bool {
      _selected = value;
      this.draw();
      return value;
    }

  	public function new (index:Int,name:String,icon:AtlasRegion,f:Int->Void) {
  		super();
      _index = index;
      _name = name;
      _icon = icon;
      _f = f;
      this.draw();
  	}

    public function draw() {
		  graphics.clear();

      graphics.beginFill(0xdddddd);
      if (_selected) graphics.beginFill(0xffffff);
      graphics.drawRoundRect(-OUTER/2,-OUTER/2,WIDTH+OUTER,HEIGHT+OUTER,ROUNDED,ROUNDED);
      graphics.endFill();

      if (_selected) {
          graphics.lineStyle(SELECTED,0xffcf00);
          graphics.drawRoundRect(-OUTER/2,-OUTER/2,WIDTH+OUTER,HEIGHT+OUTER,ROUNDED,ROUNDED);
      }

      _icon.drawNow(graphics);
    }

    public function action() {
      if (_f!=null) _f(_index);
      //else trace('no action for "$_name"');
    }
}


class ColorButton extends Button {

    var _toolbar:ColorToolbar = null;

  	public function new (toolbar:ColorToolbar,colorIndex:Int,f:Int->Void) {
    _toolbar = toolbar;
  		super(colorIndex,'color '+colorIndex,null,f);
  	}

    public override function draw() {
		  graphics.clear();

      if (_index>0) {
        graphics.beginFill(_toolbar.getPaletteColor(_index));
        graphics.drawRoundRect(-Button.OUTER/2,-Button.OUTER/2,Button.WIDTH+Button.OUTER,Button.HEIGHT+Button.OUTER,Button.ROUNDED,Button.ROUNDED);
        graphics.endFill();
      } else {
        //_index==0 is the HOLE
        graphics.beginFill(0xEEEEEE);
        graphics.drawRoundRect(-Button.OUTER/2,-Button.OUTER/2,Button.WIDTH+Button.OUTER,Button.HEIGHT+Button.OUTER,Button.ROUNDED,Button.ROUNDED);

        var h = Std.int(Button.HEIGHT/5);
        var w = Std.int(Button.WIDTH/5);
        for (y in 0...h+1) {
          for (x in 0...w+1) {
            graphics.beginFill(0xEEEEEE);
            if ((x+y)%2==0) graphics.beginFill(0x999999);
            graphics.drawRect(w*x,h*y,w,h);
          }
        }
      }
      graphics.endFill();

      if (_selected) {
          graphics.lineStyle(Button.SELECTED,0xffcf00);
          graphics.drawRoundRect(-Button.OUTER/2,-Button.OUTER/2,Button.WIDTH+Button.OUTER,Button.HEIGHT+Button.OUTER,Button.ROUNDED,Button.ROUNDED);
      }

    }
}


class ColorToolbar extends Toolbar
{

  var _palette:Array<Int> = [for (i in 0...16) 0];

	public function new (parentScreen:ScreenMain,buttonsPerRow:Int) {
		super(parentScreen,buttonsPerRow);
    _selected = 1; // default select is first color after hole
	}

  public function setPalette(palette:Array<Int>) {
    _palette = palette;
    super.redraw();
  }

  public function getPaletteColor(index:Int):Int {
    return _palette[index];
  }

  public override function addButton(name:String,icon:AtlasRegion,f:Int->Void=null) {
    addColorButton(f);
  }

  public function addColorButton(f:Int->Void=null) {
    var button = new ColorButton(this,_buttons.length,f);
    _buttons.push(button);
    addChild(button);
    if (_buttons.length-1==_selected) button.selected = true;
    button.x = Std.int((_buttons.length-1)%_buttonsPerRow)*(Button.WIDTH+_buttonsOffsetX)+_buttonsOffsetZeroX;
    button.y = Std.int((_buttons.length-1)/_buttonsPerRow)*(Button.HEIGHT+_buttonsOffsetY)+_buttonsOffsetZeroY;
  }

}

class Toolbar extends SpriteContainer
{

  var _buttons:Array<Button> = new Array<Button>();
  var _buttonsPerRow = 4;
  var _buttonsOffsetZeroX = 5;
  var _buttonsOffsetZeroY = 5;
  var _buttonsOffsetX = 12;
  var _buttonsOffsetY = 12;
  var _parentScreen:ScreenMain;
  var _selected = 0;

	public function new (parentScreen:ScreenMain,buttonsPerRow:Int) {
		super();
    _parentScreen = parentScreen;
    _buttonsPerRow = buttonsPerRow;
		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

  public function getSelected():String {
    return _buttons[_selected].name;
  }

  public function addButton(name:String,icon:AtlasRegion,f:Int->Void=null) {
    var button = new Button(_buttons.length,name,icon,f);
    _buttons.push(button);
    addChild(button);
    if (_buttons.length-1==_selected) button.selected = true;
    button.x = Std.int((_buttons.length-1)%_buttonsPerRow)*(Button.WIDTH+_buttonsOffsetX)+_buttonsOffsetZeroX;
    button.y = Std.int((_buttons.length-1)/_buttonsPerRow)*(Button.HEIGHT+_buttonsOffsetY)+_buttonsOffsetZeroY;
  }

  public function redraw() {
    for (el in _buttons) {
      el.draw();
    }
  }

  public function onMouseUp(event:MouseEvent) {
		var _tfe_x = (event.stageX - this.x - _parentScreen.x) / _parentScreen.currentScale;
		var _tfe_y = (event.stageY - this.y - _parentScreen.y) / _parentScreen.currentScale;

    var y = Std.int((_tfe_y-_buttonsOffsetZeroX) / (Button.HEIGHT+_buttonsOffsetY));
    var x = Std.int((_tfe_x-_buttonsOffsetZeroY) / (Button.WIDTH+_buttonsOffsetX));

    var index = y*_buttonsPerRow+x;
    if (index<_buttons.length && _buttons[index] != null) {
      _buttons[_selected].selected = false;
      _buttons[index].selected = true;
      _selected = index;
      _buttons[index].action();
    }

  }


}
