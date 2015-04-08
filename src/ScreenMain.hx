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

import openfl.display.Bitmap;
import openfl.display.BitmapData;

import Shape;
import gui.*;

import systools.Dialogs;

using hxColorToolkit.ColorToolkit;


class ScreenMain extends Screen
{

	var _model:Model;

	public function new () {
		super();
		cycle = false;
		title = "Main";
		rwidth = 1024;
		rheight = 620;
	}

	var model:Model;

	var testPreviewBitmap:Bitmap;
	var testFinalBitmap:Bitmap;
	var testRenderBitmap:Bitmap;

	var rendererPreview:ModelRenderer;
	var rendererFinal:ModelRenderer;

	public static inline var ACTIONBAR_HEIGHT = 40;
	public static inline var STATUSBAR_HEIGHT = 40;
	public static inline var TOOLBAR_WIDTH = 100;
	public static inline var SHAPELIST_WIDTH = 250;
	public static inline var PREVIEW_WIDTH = 200;
	public static inline var BASE_SPAN = 20;

	public function renderTest() {

		//testPreviewBitmap.bitmapData = null;
		//testRenderBitmap.bitmapData = wait;
		//testRenderBitmap.x = rwidth/2-testRenderBitmap.width/2;
		//testRenderBitmap.y = rheight/2-testRenderBitmap.height/2;
		//testFinalBitmap.bitmapData = null;

		trace(model.getPalette());

		Actuate.timer(0.01).onComplete( function() {

			// testPreviewBitmap.bitmapData = rendererPreview.render(model,-1,true);
			// testPreviewBitmap.x = rwidth/2-testPreviewBitmap.width/2+PLIK.adjust(650);
			// testPreviewBitmap.y = rheight/2-testPreviewBitmap.height/2;

			var bpd = rendererFinal.render(model,-1,false);
			testRenderBitmap.bitmapData = bpd;
			testRenderBitmap.x = TOOLBAR_WIDTH+(rwidth-TOOLBAR_WIDTH-SHAPELIST_WIDTH-PREVIEW_WIDTH)/2-testRenderBitmap.width/2;
			testRenderBitmap.y = (rheight-ACTIONBAR_HEIGHT-STATUSBAR_HEIGHT)/2-testRenderBitmap.height/2+ACTIONBAR_HEIGHT;

			//testFinalBitmap.bitmapData = PostFX.scale(PostFX.fxaaOutline(bpd,8,8),0.25);
			testFinalBitmap.bitmapData = PostFX.scale(PostFX.fxaaOutline(bpd,8,8),0.125);
			testFinalBitmap.x = rwidth-PREVIEW_WIDTH-SHAPELIST_WIDTH+(PREVIEW_WIDTH/2-testFinalBitmap.width/2);
			testFinalBitmap.y = rheight-STATUSBAR_HEIGHT-BASE_SPAN-testFinalBitmap.height;
		});
	}

	public override function initialize():Void {
    trace(rwidth);
    trace(rheight);
    trace(PLIK.adjust(rwidth));
		trace(ModelIO.DEFAULT_PALETTE);


		// CLASS TEST
		// String -> Array<Int> -> Model (Shapes) -> Array<Int> -> String

		// EXAMPLE MODELS

		// stupid guy
		//var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";

		// complex shape
		var original = "FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";
		var original = "Ff___wAAQEW7PqXys9vuJDI_OVJXUpAjpswzUUY1p3At____9-F2vjJB33qSfoaPprO8Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";

		// home
		//var original = "DAAACGneAQk8XCgIPF0SWzdcv183er9rjFy_b4x6v2mMzJ1ZN7ydCDysmgBpXiVAaaxH";

		// random stuff
		//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";

		//var original = "AQAAAUpJCA.."; //just a cube

		// farm
		//var original = "EwAC____OxK8AUo0qwFLq5oBO828ATgjNBg5IlUDOd1VAwgeVSIBigESMXoBIjGIAQExqgEBUYgAMzYRiAE2FCWbNiM0vBYFFpo27ncCNt40BA..";

		var decoded = Base64.decodeBase64(original);
		model = _model = ModelIO.loadModel(decoded);
		var demodel = ModelIO.saveModel(model);
		var reencoded = Base64.encodeBase64(demodel,true);

		// trace('original:',original);
		// trace('decoded:',decoded);
		// trace('model:',model);
		// trace('demodel:',demodel);
		// trace('reencoded:',reencoded);

		var passed:Bool = true;
		if (original!=reencoded) passed = false;

		trace(' IN ' + original);
		trace('OUT ' + reencoded);
		trace('comparison test passed: ' + passed);
		trace('-----------------------------------');

		// END TEST

		//var b:openfl.utils.ByteArray = bpd_fx.encode("png", 1);
		//trace("data:image/png;base64,"+haxe.crypto.Base64.encode(b));

		// Saving the BitmapData to a file
		// var b:openfl.utils.ByteArray = bpd_fx.bitmapData.encode("png", 1);
		// var fo:sys.io.FileOutput = sys.io.File.write("test_out.png", true);
		// fo.writeString(b.toString());
		// fo.close();

		rendererPreview = new ModelRenderer(Std.int(320),Std.int(480));
		rendererFinal = new ModelRenderer(Std.int(320),Std.int(480));

		testPreviewBitmap = new Bitmap(null);
		addChild(testPreviewBitmap);

		testRenderBitmap = new Bitmap(null);
		addChild(testRenderBitmap);

		testFinalBitmap = new Bitmap(null);
		addChild(testFinalBitmap);


		// STATIC INTERFACE ---------------------------------------------

		// model+color toolbar bg
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
		var colorToolbar = new Toolbar(2,true,Style.toolbar(),Style.toolbarButtonFull());

		//---

		var colorPickerAction = function(color:Int) {
			var button:Button = colorToolbar.getSelected();
			var index:Int = cast(button.value,Int);
			if (index==0) return; //hole
			button.icon = APP.makeColorIcon(26,color);
			_model.setColor(index,color);
			renderTest();
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
				Lib.current.stage.color = _model.getColor(value);
				if (_colorPickerOnStage) showColorPicker(_model.getColor(value));
		};

		var colorToolbarActionAlt = function(button:Button) {
				var value:Int = cast(button.value,Int);
				if (value==0) return; //hole
				showColorPicker(_model.getColor(value));
		};

		//---

		//colorToolbar.setPalette(_model.getPalette());
		colorToolbar.addButton('palette0',0,APP.makeColorIcon(26,-1),colorToolbarAction);
		for (i in 1...16) {
			colorToolbar.addButton('palette$i',i,APP.makeColorIcon(26,_model.getColor(i)),colorToolbarAction,colorToolbarActionAlt);
		}
		colorToolbar.selectByIndex(1);
		colorToolbar.x = TOOLBAR_WIDTH/2-colorToolbar.width/2;
		colorToolbar.y = toolbar.y + toolbar.height + BASE_SPAN;
		addChild(colorToolbar);


		// ACTION TOOLBAR ---------------------------------------------

		var actionToolbarAction = function(button:Button) { trace("NOT IMPLEMENTED"); }
		var actionToolbar = new Toolbar(0,false,Style.toolbar(),Style.toolbarButton());
		actionToolbar.addButton("new",null,			APP.atlasSprites.getRegion(APP.ICON_NEW).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("open",null,		APP.atlasSprites.getRegion(APP.ICON_OPEN).toBitmapData(),		function(_) {

			var cbtext: String = systools.Clipboard.getText();
		trace("Current text on clipboard: "+ cbtext);

		systools.Clipboard.clear();
		trace("Cleared clipboard");

		cbtext = systools.Clipboard.getText();
		trace("Current text on clipboard: "+ cbtext);

		trace("Setting clipboard text to: Hello World");
		systools.Clipboard.setText("Hello World");

		cbtext = systools.Clipboard.getText();
		trace("Current text on clipboard: "+ cbtext);

		systools.Clipboard.clear();
		trace("Cleared clipboard (again)");

		cbtext = systools.Clipboard.getText();
		trace("Current text on clipboard: "+ cbtext);

		});
		actionToolbar.addButton("save",null,		APP.atlasSprites.getRegion(APP.ICON_SAVE).toBitmapData(),		function(_) {

		Dialogs.message("neko-systools","Hello World!",false);
		trace("confirm: "+Dialogs.confirm("neko-systools","Please confirm?",false));
		Dialogs.message("neko-systools","Message error test", true);
		trace("confirm error: "+Dialogs.confirm("neko-systools","Confirm error test", true));
		var result = Dialogs.folder
			( "Select a folder"
			, "This additional message will only be shown on OSX"
			);
		trace(result);	var filters: FILEFILTERS =
			{ count: 2
			, descriptions: ["Text files", "JPEG files"]
			, extensions: ["*.txt","*.jpg;*.jpeg"]
			};
		var result = Dialogs.openFile
			( "Select a file please!"
			, "Please select one or more files, so we can see if this method works"
			, filters
			);
		trace(result);

		var result = Dialogs.saveFile
			( "Select a file please!"
			, "Please select one or more files, so we can see if this method works"
			, Sys.getCwd()
			, filters
			);
		trace(result);

		});
		actionToolbar.addButton("-");
		actionToolbar.addButton("render",null,	APP.atlasSprites.getRegion(APP.ICON_RENDER).toBitmapData(),	function(_) {renderTest();});
		actionToolbar.addButton("-");
		actionToolbar.addButton("copy",null,		APP.atlasSprites.getRegion(APP.ICON_COPY).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("paste",null,	APP.atlasSprites.getRegion(APP.ICON_PASTE).toBitmapData(),	actionToolbarAction);
		actionToolbar.addButton("-");
		actionToolbar.addButton("quit",null,		APP.atlasSprites.getRegion(APP.ICON_QUIT).toBitmapData(),		actionToolbarAction);
		actionToolbar.x = TOOLBAR_WIDTH+BASE_SPAN;
		actionToolbar.y = ACTIONBAR_HEIGHT/2-actionToolbar.height/2;
		addChild(actionToolbar);


		// PREVIEW TOOLBAR ---------------------------------------------

		var previewColorToolbar = new Toolbar(0,true,Style.toolbar(),Style.toolbarMiniButtonFull());
		previewColorToolbar.addButton('preview0',0,APP.makeColorIcon(18,-1),colorToolbarAction);
		previewColorToolbar.addButton('preview1',0,APP.makeColorIcon(18,0),colorToolbarAction);
		previewColorToolbar.addButton('preview2',0,APP.makeColorIcon(18,0xFFFFFF),colorToolbarAction);
		previewColorToolbar.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH+BASE_SPAN/2;
		previewColorToolbar.y = rheight-STATUSBAR_HEIGHT/2-previewColorToolbar.height/2;
		addChild(previewColorToolbar);

		var previewActionToolbar = new Toolbar(0,false,Style.toolbar(),Style.toolbarMiniButton());
		previewActionToolbar.addButton('resize',0,APP.atlasSprites.getRegion(APP.ICON_RESIZE).toBitmapData());
		previewActionToolbar.addButton('save',0,APP.atlasSprites.getRegion(APP.ICON_SAVE).toBitmapData());
		previewActionToolbar.x = rwidth-SHAPELIST_WIDTH-BASE_SPAN/2-previewActionToolbar.width;
		previewActionToolbar.y = rheight-STATUSBAR_HEIGHT/2-previewActionToolbar.height/2;
		addChild(previewActionToolbar);

		// APP TITLE ---------------------------------------------

		var text = new Text("TILECRAFT",16,APP.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER,APP.FONT_SQUARE);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = TOOLBAR_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2;
		addChild(text);

		// ---------------------------------------------

		super.initialize(); // init_super at the end

	}

	public override function unload():Void {
		super.unload();
	}

	public override function start() {
		super.start();  // call resume
		renderTest();
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

}
