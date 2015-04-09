package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
#if !mobile
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#end

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.PLIK;
import com.akifox.plik.Utils;
import com.akifox.plik.Gfx;
import com.akifox.plik.Text;
import com.akifox.plik.SpriteContainer;
import com.akifox.plik.ShapeContainer;
import com.akifox.plik.Screen;
import com.akifox.transform.Transformation;
import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.atlas.*;

import format.png.*;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

import Shape;
import gui.*;

//import systools.Dialogs;

using hxColorToolkit.ColorToolkit;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import sys.io.FileInput;
import sys.io.FileOutput;


class ScreenMain extends Screen
{

	var currentModel:Model = Model.makeNew();

	public function new () {
		super();
		cycle = false;
		title = "Main";
		rwidth = 1024;
		rheight = 620;
	}

	//var testPreviewBitmap:Bitmap = null;
	var _outputBitmap:Bitmap = null;
	var _modelBitmap:Bitmap = null;
	var _modelBitmapIsPreview:Bool=true;

	var fxaaModes = [[8,8],[8,8],[8,8]]; //passes + outline
	var renderModes = [0.5,0.25,0.125];
	var renderMode = 0;

	var colorToolbar:Toolbar;

	var currentRenderer = new ModelRenderer(Std.int(320),Std.int(480));

	var backgroundRenderColor = -1;

	public static inline var ACTIONBAR_HEIGHT = 40;
	public static inline var STATUSBAR_HEIGHT = 40;
	public static inline var TOOLBAR_WIDTH = 100;
	public static inline var SHAPELIST_WIDTH = 250;
	public static inline var PREVIEW_WIDTH = 200;
	public static inline var BASE_SPAN = 20;

	//============================================================================

	public function renderModel(preview:Bool=true) {

		// testPreviewBitmap.bitmapData = null;
		// _modelBitmap.bitmapData = null;
		// _outputBitmap.bitmapData = null;

		//Actuate.timer(0.01).onComplete( function() {

			var bpd:BitmapData = currentRenderer.render(currentModel,-1,preview);
			_modelBitmap.bitmapData = bpd;
			_modelBitmap.x = TOOLBAR_WIDTH+(rwidth-TOOLBAR_WIDTH-SHAPELIST_WIDTH-PREVIEW_WIDTH)/2-_modelBitmap.width/2;
			_modelBitmap.y = (rheight-ACTIONBAR_HEIGHT-STATUSBAR_HEIGHT)/2-_modelBitmap.height/2+ACTIONBAR_HEIGHT;
			_modelBitmapIsPreview = preview;

		//});
	}

	public function renderOutput() {
		if (_modelBitmapIsPreview) renderModel(false);
		_outputBitmap.bitmapData = PostFX.scale(PostFX.fxaaOutline(_modelBitmap.bitmapData,fxaaModes[renderMode][0],fxaaModes[renderMode][0]),renderModes[renderMode]);
		_outputBitmap.x = rwidth-PREVIEW_WIDTH-SHAPELIST_WIDTH+(PREVIEW_WIDTH/2-_outputBitmap.width/2);
		_outputBitmap.y = rheight-STATUSBAR_HEIGHT-_outputBitmap.height;
	}
	//============================================================================

	var backgroundRender = new ShapeContainer();

	public function renderBackground() {
			backgroundRender.graphics.clear();
			var color = backgroundRenderColor;
			var alpha = 0.9;
			var span = 0; //BASE_SPAN
			if (backgroundRenderColor==-1) {
				//transparent

				APP.makeChessboard(backgroundRender.graphics,Std.int(20*renderModes[renderMode]),0,0,PREVIEW_WIDTH,_outputBitmap.height+span,0xBBBBBB,0xEEEEEE);

			} else {
				backgroundRender.graphics.beginFill(backgroundRenderColor);
				backgroundRender.graphics.drawRect(0,0,
																					PREVIEW_WIDTH,_outputBitmap.height+span);

				var shiftColor:Int=0;
				if (color<0x888888) {
					shiftColor = ColorToolkit.shiftBrighteness(color,30);
				}	else {
					shiftColor = ColorToolkit.shiftBrighteness(color,-30);
				}
				backgroundRender.graphics.beginFill(shiftColor,alpha);
				backgroundRender.graphics.drawRect(PREVIEW_WIDTH/2-_outputBitmap.width/2,span,
							_outputBitmap.width,_outputBitmap.height/2);

				if (color<0x888888) {
					shiftColor = ColorToolkit.shiftBrighteness(color,15);
				}	else {
					shiftColor = ColorToolkit.shiftBrighteness(color,-15);
				}
				backgroundRender.graphics.beginFill(shiftColor,alpha);
				backgroundRender.graphics.drawRect(PREVIEW_WIDTH/2-_outputBitmap.width/2,span+_outputBitmap.height/2,
				_outputBitmap.width,_outputBitmap.height/2);
	}
			backgroundRender.graphics.endFill();

			backgroundRender.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH;
			backgroundRender.y = rheight-STATUSBAR_HEIGHT-backgroundRender.height;
	}

	//============================================================================

	public function renderModeLoop(_) {
		renderMode++;
		if (renderMode>=renderModes.length) renderMode = 0;
		renderOutput();
		renderBackground();
	}

	//============================================================================

	// used when changing model (new, open)
	private function changeModel(model:Model) {
		if (model==null) {
			trace('invalid change model');
			return;
		}
		if (currentModel!=null) currentModel.destroy();
		currentModel = model;
		updatePalette();
		renderModel(false);
		renderOutput();
		trace(currentModel.toPNGString(_outputBitmap.bitmapData));
	}

	public function updatePalette(){
		for (i in 1...16) {
			colorToolbar.getButtonByIndex(i).icon = APP.makeColorIcon(26,currentModel.getColor(i));
		}
	}

	//============================================================================

	public function newModel() {
		changeModel(Model.makeNew());
	}

	public function saveFile():Bool {
		renderOutput();
		var filename:String = saveDialog("TileCraft PNG image","*.png");
		if (filename==null) {
			trace('cancel');
			return false;
		}
		var fo:haxe.io.Output = sys.io.File.write(filename,true);
		fo = currentModel.toPNG(fo,_outputBitmap.bitmapData); //TODO change testFinalRender (maybe include in Model)
		if (fo==null) {
			return false;
		} else {
			fo.close();
			return true;
		}
	}

	public function openFile():Bool {
		var filename:String = openDialog("TileCraft PNG image","*.png");
		if (filename==null) {
			trace('cancel');
			return false;
		}
		var fr = sys.io.File.read(filename,true);
		var model:Model = Model.fromPNG(fr);
		if (fr!=null) fr.close();

		// error
		if (model==null) {
			return false;
		} else {
			// prepare context
			changeModel(model);
			return true;
		}
	}

	private function saveDialog(filetype:String,extension:String):String {
		return "/var/tmp/test.png";
		// var file = Dialogs.saveFile
		// 						( "Select a file please, or type name"
		// 						, "This additional message will only be shown on OSX"
		// 						, "" // initial path, for windows only
		// 						,{ count: 1
		// 						 , descriptions: [filetype]
		// 						 , extensions: [extension]
		// 						}
		// 						);
		// trace(file);
		// if (file!=null) return file;
		// return "";
	}

	private function openDialog(filetype:String,extension:String):String {
		return "/var/tmp/test.png";
		// var files = Dialogs.openFile
		// 						( "Select a file please, or type name"
		// 						, "This additional message will only be shown on OSX"
		// 						,{ count: 1
		// 						 , descriptions: [filetype]
		// 						 , extensions: [extension]
		// 					  }
		// 						);
		// trace(files);
		// if (files==null) return null;
		// return files[0];
	}

	public override function initialize():Void {
    //trace(rwidth);
    // trace(rheight);
    // trace(PLIK.adjust(rwidth));
		// trace(ModelIO.DEFAULT_PALETTE);
		addChild(backgroundRender);

		// saveDialog("TileCraft PNG image","*.png");
		// super.initialize();
		// return;



		// CLASS TEST
		// String -> Array<Int> -> Model (Shapes) -> Array<Int> -> String

		// testPreviewBitmap = new Bitmap(null);
		//addChild(testPreviewBitmap);

		_modelBitmap = new Bitmap(null);
		addChild(_modelBitmap);

		_outputBitmap = new Bitmap(null);
		addChild(_outputBitmap);


		// STATIC INTERFACE ---------------------------------------------

		// currentModel+color toolbar bg
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,0,TOOLBAR_WIDTH,rheight);

		// action toolbar bg
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,0,rwidth,ACTIONBAR_HEIGHT);

		// shapelist
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(rwidth-SHAPELIST_WIDTH,0,rwidth,rheight);

		// preview
		graphics.beginFill(0x242424,0.8);
		graphics.drawRect(rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH,0,rwidth-SHAPELIST_WIDTH,rheight);

		// status bar
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,rheight-STATUSBAR_HEIGHT,rwidth,rheight);

		// var button = new Button();
		// button.x = 130;
		// button.y = 100;
		// button.style = Style.button();
		// button.selectable = true;
		// button.listen = true;
		// button.actionF = function(button:Button) { trace(button); };
		// button.text = new Text("Button test",18,APP.COLOR_DARK,openfl.text.TextFormatAlign.CENTER);
		// button.icon = APP.atlasSprites.getRegion(APP.ICON_CHECKBOX).toBitmapData();
		// button.iconSelected = APP.atlasSprites.getRegion(APP.ICON_CHECKBOX_CHECKED).toBitmapData();
		// addChild(button);

		// MODEL TOOLBAR ---------------------------------------------

		var toolbar = new Toolbar(2,true,Style.toolbar(),Style.toolbarButton());
		toolbar.addButton("pointer",null,					APP.atlasSprites.getRegion(APP.ICON_POINTER).toBitmapData());
		toolbar.addButton("sh_cube",null,					APP.atlasSprites.getRegion(APP.ICON_SH_CUBE).toBitmapData());
		toolbar.addButton("sh_round_up",null,			APP.atlasSprites.getRegion(APP.ICON_SH_ROUND_UP).toBitmapData());
		toolbar.addButton("sh_round_side",null,		APP.atlasSprites.getRegion(APP.ICON_SH_ROUND_SIDE).toBitmapData());
		toolbar.addButton("sh_cylinder_up",null,	APP.atlasSprites.getRegion(APP.ICON_SH_CYLINDER_UP).toBitmapData());
		toolbar.addButton("sh_cylinder_side",null,APP.atlasSprites.getRegion(APP.ICON_SH_CYLINDER_SIDE).toBitmapData());
		toolbar.addButton("sh_ramp_up",null,			APP.atlasSprites.getRegion(APP.ICON_SH_RAMP_UP).toBitmapData());
		toolbar.addButton("sh_ramp_down",null,		APP.atlasSprites.getRegion(APP.ICON_SH_RAMP_DOWN).toBitmapData());
		toolbar.addButton("sh_arch_up",null,			APP.atlasSprites.getRegion(APP.ICON_SH_ARCH_UP).toBitmapData());
		toolbar.addButton("sh_arch_down",null,		APP.atlasSprites.getRegion(APP.ICON_SH_ARCH_DOWN).toBitmapData());
		toolbar.addButton("sh_corner_se",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_SE).toBitmapData());
		toolbar.addButton("sh_corner_sw",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_SW).toBitmapData());
		toolbar.addButton("sh_corner_ne",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_NE).toBitmapData());
		toolbar.addButton("sh_corner_nw",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_NW).toBitmapData());

		toolbar.x = TOOLBAR_WIDTH/2-toolbar.width/2;
		toolbar.y = ACTIONBAR_HEIGHT+10;
		addChild(toolbar);


		// COLOR TOOLBAR ---------------------------------------------
		colorToolbar = new Toolbar(2,true,Style.toolbar(),Style.toolbarButtonFull());

		//---

		var colorPickerAction = function(color:Int) {
			var button:Button = colorToolbar.getSelected();
			var index:Int = cast(button.value,Int);
			if (index==0) return; //hole
			button.icon = APP.makeColorIcon(26,color);
			currentModel.setColor(index,color);
			renderModel(true);
		}

		//---

		_colorPicker = new BoxColorPicker(rwidth-TOOLBAR_WIDTH-SHAPELIST_WIDTH-PREVIEW_WIDTH,colorPickerAction,function() {hideColorPicker();});
		_colorPicker.x = TOOLBAR_WIDTH;
		_colorPicker.y = rheight-STATUSBAR_HEIGHT-_colorPicker.height;

		//---

		var colorToolbarAction = function(button:Button) {
				var value:Int = cast(button.value,Int);
				if (value==0) {
					hideColorPicker();
					return; //hole
				}
				//Lib.current.stage.color = currentModel.getColor(value);
				if (_colorPickerOnStage) showColorPicker(currentModel.getColor(value));
		};

		var colorToolbarActionAlt = function(button:Button) {
				var value:Int = cast(button.value,Int);
				if (value==0) return; //hole
				showColorPicker(currentModel.getColor(value));
		};

		//---

		//colorToolbar.setPalette(currentModel.getPalette());
		colorToolbar.addButton('palette0',0,APP.makeColorIcon(26,-1),colorToolbarAction);
		for (i in 1...16) {
			colorToolbar.addButton('palette$i',i,APP.makeColorIcon(26,currentModel.getColor(i)),colorToolbarAction,colorToolbarActionAlt);
		}
		colorToolbar.selectByIndex(1);
		colorToolbar.x = TOOLBAR_WIDTH/2-colorToolbar.width/2;
		colorToolbar.y = toolbar.y + toolbar.height + BASE_SPAN;
		addChild(colorToolbar);


		// ACTION TOOLBAR ---------------------------------------------

		var actionToolbarAction = function(button:Button) { trace("NOT IMPLEMENTED"); }
		var actionToolbar = new Toolbar(0,false,Style.toolbar(),Style.toolbarButton());
		actionToolbar.addButton("new",null,			APP.atlasSprites.getRegion(APP.ICON_NEW).toBitmapData(),
																						function(_) {
																							newModel();
																						});
		actionToolbar.addButton("open",null,		APP.atlasSprites.getRegion(APP.ICON_OPEN).toBitmapData(),
																						function(_) { openFile(); });
		actionToolbar.addButton("save",null,		APP.atlasSprites.getRegion(APP.ICON_SAVE).toBitmapData(),
																						function(_) { saveFile(); });
		actionToolbar.addButton("-");
		actionToolbar.addButton("render",null,	APP.atlasSprites.getRegion(APP.ICON_RENDER).toBitmapData(),
																						function(_) { renderModel(false); renderOutput(); });
		actionToolbar.addButton("-");
		actionToolbar.addButton("copy",null,		APP.atlasSprites.getRegion(APP.ICON_COPY).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("paste",null,	APP.atlasSprites.getRegion(APP.ICON_PASTE).toBitmapData(),	actionToolbarAction);
		actionToolbar.addButton("-");
		actionToolbar.addButton("quit",null,		APP.atlasSprites.getRegion(APP.ICON_QUIT).toBitmapData(),
																						function(_) {
																							// BOOL isError
																							//if (Dialogs.confirm(APP.APP_NAME,"Do you really want to quit?",false))
																								PLIK.quit();
																						});
		actionToolbar.x = TOOLBAR_WIDTH+BASE_SPAN;
		actionToolbar.y = ACTIONBAR_HEIGHT/2-actionToolbar.height/2;
		addChild(actionToolbar);


		// PREVIEW TOOLBAR ---------------------------------------------

		var previewColorToolbarAction = function(button:Button) {
			backgroundRenderColor = cast(button.value,Int);
			renderBackground();
		};

		var previewColorToolbar = new Toolbar(0,true,Style.toolbar(),Style.toolbarMiniButtonFull());
		previewColorToolbar.addButton('preview0',-1,APP.makeColorIcon(24,-1),previewColorToolbarAction);
		previewColorToolbar.addButton('preview1',0,APP.makeColorIcon(24,0),previewColorToolbarAction);
		previewColorToolbar.addButton('preview2',0xFFFFFF,APP.makeColorIcon(24,0xFFFFFF),previewColorToolbarAction);
		previewColorToolbar.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH+BASE_SPAN/2;
		previewColorToolbar.y = rheight-STATUSBAR_HEIGHT/2-previewColorToolbar.height/2;
		addChild(previewColorToolbar);

		var previewActionToolbar = new Toolbar(0,false,Style.toolbar(),Style.toolbarMiniButton());
		previewActionToolbar.addButton('resize',0,APP.atlasSprites.getRegion(APP.ICON_RESIZE).toBitmapData(),renderModeLoop);
		previewActionToolbar.addButton('save',0,APP.atlasSprites.getRegion(APP.ICON_SAVE).toBitmapData());
																						//function(_){ saveFile(); });
		previewActionToolbar.x = rwidth-SHAPELIST_WIDTH-BASE_SPAN/2-previewActionToolbar.width;
		previewActionToolbar.y = rheight-STATUSBAR_HEIGHT/2-previewActionToolbar.height/2;
		addChild(previewActionToolbar);

		// APP TITLE ---------------------------------------------

		var text = new Text("TILECRAFT",18,APP.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER,APP.FONT_SQUARE);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = TOOLBAR_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2;
		addChild(text);

		var text = new Text("alpha4",8,APP.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER,APP.FONT_LATO_BOLD);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = TOOLBAR_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2+11;
		addChild(text);

		// ---------------------------------------------

		// EXAMPLE MODELS

		// stupid guy
		//var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";

		// complex shape
		var original = "FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";
		//var original = "Ff___wAAQEW7PqXys9vuJDI_OVJXUpAjpswzUUY1p3At____9-F2vjJB33qSfoaPprO8Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";
		//var original = "FQQGOTt7PqXy____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zg9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";
		// home
		//var original = "DAAACGneAQk8XCgIPF0SWzdcv183er9rjFy_b4x6v2mMzJ1ZN7ydCDysmgBpXiVAaaxH";

		// random stuff
		//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";

		//var original = "AQAAAUpJCA.."; //just a cube

		// farm
		//var original = "E____wAA____PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJB33qSfoaPprO8OxK8AUo0qwFLq5oBO828ATgjNBg5IlUDOd1VAwgeVSIBigESMXoBIjGIAQExqgEBUYgAMzYRiAE2FCWbNiM0vBYFFpo27ncCNt40BA..";

		// ---------------------------------------------

		changeModel(Model.fromString(original));

		//init background image
		renderBackground();

		super.initialize(); // init_super at the end
	}

	public override function unload():Void {
		super.unload();
	}

	public override function start() {
		super.start();  // call resume
	}

	public override function hold():Void {
		super.hold();

		// HOOKERS OFF
	}

	public override function resume():Void {
		super.resume();

    // HOOKERS ON

	}

	var _colorPicker:BoxColorPicker;
	var _colorPickerOnStage:Bool = false;

	private function showColorPicker(color:Int) {
		_colorPicker.selector(color);
		if (_colorPickerOnStage) return;
		addChild(_colorPicker);
		_colorPicker.show();
		_colorPickerOnStage = true;
	}

	private function hideColorPicker() {
		if (!_colorPickerOnStage) return;
		_colorPicker.hide();
		removeChild(_colorPicker);
		_colorPickerOnStage = false;
	}

	private override function update(delta:Float):Void {

	}

	public override function resize() {

	}

	//########################################################################################
	//########################################################################################

	// 	var cbtext: String = systools.Clipboard.getText();
	// trace("Current text on clipboard: "+ cbtext);
	//
	// systools.Clipboard.clear();
	// trace("Cleared clipboard");
	//
	// cbtext = systools.Clipboard.getText();
	// trace("Current text on clipboard: "+ cbtext);
	//
	// trace("Setting clipboard text to: Hello World");
	// systools.Clipboard.setText("Hello World");
	//
	// cbtext = systools.Clipboard.getText();
	// trace("Current text on clipboard: "+ cbtext);
	//
	// systools.Clipboard.clear();
	// trace("Cleared clipboard (again)");
	//
	// cbtext = systools.Clipboard.getText();
	// trace("Current text on clipboard: "+ cbtext);

}
