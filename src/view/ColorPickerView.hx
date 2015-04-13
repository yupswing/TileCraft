package view;

import com.akifox.plik.gui.*;

class ColorPickerView extends Box {

  var _colorPicker:ColorPicker;
  var _buttonClose:Button;

  var _width:Float = 0;

	public function new (width:Float,action:Int->Void,actionClose:Void->Void) {
    var style = Style.getStyle('.box');
		super(style);

    _buttonClose = new Button();
    _colorPicker = new ColorPicker(Style.getStyle('.colorpicker'),action);

    _colorPicker.y = style.padding+style.offset; // special to keep the button on the spectrum
    addChild(_colorPicker);

    _buttonClose.style = Style.getStyle('.button.miniButton.miniButtonClose');
    _buttonClose.listen = true;
    _buttonClose.actionF = function(button:Button) { actionClose(); };
    //_buttonClose.text = new Text("Close",14,APP.COLOR_DARK,openfl.text.TextFormatAlign.CENTER);
    _buttonClose.icon = APP.atlasSPRITES.getRegion(APP.ICON_CLOSE).toBitmapData();
    _buttonClose.y = style.padding;
    addChild(_buttonClose);


    updateWidth(width);
	}

  public function updateWidth(width:Float) {
    _width = width;
    _colorPicker.x = _width/2-_colorPicker.width/2;
    _buttonClose.x = _colorPicker.width+_colorPicker.x-_buttonClose.width+10;
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

  public override function getNetWidth():Float {
    return _colorPicker.getGrossWidth();
  }

  public override function getNetHeight():Float {
    return _colorPicker.getGrossHeight();
  }

}
