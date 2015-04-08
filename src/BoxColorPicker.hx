package;

import com.akifox.plik.*;
import gui.*;

class BoxColorPicker extends Box {

    var _colorPicker:ColorPicker;
    var _buttonClose:Button;

    var _width:Float = 0;

  	public function new (width:Float,action:Int->Void,actionClose:Void->Void) {
      var style = Style.box();
  		super(style);

      _width = width;

      _buttonClose = new Button();
      _colorPicker = new ColorPicker(action);
      _colorPicker.x = _width/2-_colorPicker.width/2;

      _buttonClose.style = Style.toolbarMiniButton();
      trace(_buttonClose.style.over_background_color);
      _buttonClose.listen = true;
      _buttonClose.actionF = function(button:Button) { actionClose(); };
      //_buttonClose.text = new Text("Close",14,APP.COLOR_DARK,openfl.text.TextFormatAlign.CENTER);
      _buttonClose.icon = APP.atlasSprites.getRegion(APP.ICON_CLOSE).toBitmapData();
      _buttonClose.x = _colorPicker.width+_colorPicker.x-_buttonClose.width;
      _buttonClose.y = style.padding;
      addChild(_buttonClose);

      _colorPicker.y = style.padding+_buttonClose.height;//+style.offset;
      addChild(_colorPicker);


      draw(width);
  	}

    public function show() {
      _colorPicker.listen = true;
    }

    public function hide() {
      _colorPicker.listen = false;
    }

    public function selector(color:Int) {
      _colorPicker.selector(color);
    }

    public override function destroy() {
      super.destroy();
    }

}
