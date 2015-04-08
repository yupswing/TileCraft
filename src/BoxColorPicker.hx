package;

import com.akifox.plik.*;
import gui.*;

class BoxColorPicker extends Box {

    var _colorPicker:ColorPicker;
    var _buttonClose:Button;

  	public function new (action:Int->Void,actionClose:Void->Void) {
      var style = Style.box();
  		super(style);

      _buttonClose = new Button();
      _colorPicker = new ColorPicker(action);

      _buttonClose.style = Style.miniButton();
      _buttonClose.listen = true;
      _buttonClose.actionF = function(button:Button) { actionClose(); };
      _buttonClose.text = new Text("Close",14,APP.COLOR_DARK,openfl.text.TextFormatAlign.CENTER);
      _buttonClose.icon = APP.atlasSprites.getRegion(APP.ICON_OK).toBitmapData();
      _buttonClose.x = _colorPicker.width+style.padding-_buttonClose.width;
      _buttonClose.y = style.padding;
      addChild(_buttonClose);

      _colorPicker.x = style.padding;
      _colorPicker.y = style.padding+_buttonClose.height+style.offset;
      addChild(_colorPicker);


      draw();
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
