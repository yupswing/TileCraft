package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if !mobile
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#end

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.*;
import com.akifox.plik.atlas.*;
import com.akifox.transform.Transformation;

import format.png.*;

import Shape;
import com.akifox.plik.gui.*;
import view.*;
#if !flash
import postfx.*;
#end

//import systools.Dialogs; //TODO temporary disabled because it crashes the app when the dialog close (MAC64)

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
#if sys
import sys.io.FileInput;
import sys.io.FileOutput;
#end

using StringTools;
using hxColorToolkit.ColorToolkit;


class TileCraft extends Screen
{


	public static inline function logger(string:String) {
		trace('>>> $string');
	}

	public static inline function error(string:String) {
		trace('!!! $string');
	}

	public var currentModel:Model = Model.makeNew();
	var currentShapeViewList:ShapeViewList;


	public function new () {
		super();
		cycle = false;
		title = "Main";
		rwidth = 950;
		rheight = 650;
	}

	var _outputView:OutputView = null;
	var _modelView:ModelView = null;
	var _modelIsPreviewMode:Bool=true;

	public static var fxaaModes = [[8,8],[8,8],[8,1]]; //passes + outline
	public static var renderModes = [0.5,0.25,0.125];
	var renderMode = 0;

	var colorToolbar:Toolbar;
	var toolbar:Toolbar;

	public static inline var RENDER_WIDTH = 320;
	public static inline var RENDER_HEIGHT = 480;

	var currentRenderer = new Renderer(RENDER_WIDTH,RENDER_HEIGHT);

	public static inline var ACTIONBAR_HEIGHT = 40;
	public static inline var STATUSBAR_HEIGHT = 40;
	public static inline var TOOLBAR_WIDTH = 100;
	public static inline var SHAPELIST_WIDTH = 150;
	public static inline var PREVIEW_WIDTH = 200;
	public static inline var BASE_SPAN = 20;

	var _lastRenderModelTime:Float = 0;

	//============================================================================

	public function renderModel(preview:Bool=true) {
		#if (!v2 || neko)
		preview=true;//TODO POSTFX need support for OpenFL3
		#end
		//TODO this should be part of ModelView

		// avoid too many calls at once
		if (preview && haxe.Timer.stamp()-_lastRenderModelTime<0.05) return;

		// _modelView.setBitmapData(null); //TODO show some kind of modal while rendering

		var bpd:BitmapData = currentRenderer.render(currentModel,-1,preview);
		_modelView.setBitmapData(bpd);
		_modelIsPreviewMode = preview;

		_lastRenderModelTime = haxe.Timer.stamp();
	}

	public function renderOutput(?changeScale=false) {
		#if (v2 && !flash) //TODO POSTFX need support for OpenFL3

		//TODO show some kind of modal while rendering
		if (_modelIsPreviewMode) renderModel(false);
		_outputView.setBitmapData(PostFX.scale(PostFX.fxaaOutline(_modelView.getBitmapData(),
																															getRenderFxaaPasses(),
																															getRenderFxaaOutline()),
																					 getOutputScale()));
		if (changeScale) _outputView.drawBackground();
		#end
	}

	//============================================================================

	//============================================================================

	public function renderModeLoop(_) {
		renderMode++;
		if (renderMode>=renderModes.length) renderMode = 0;
		renderOutput(true);
	}

	// used by outputview
	public function getOutputScale():Float {
		return renderModes[renderMode];
	}

	public function getRenderFxaaPasses():Int {
		return fxaaModes[renderMode][0];
	}

	public function getRenderFxaaOutline():Int {
		return fxaaModes[renderMode][1];
	}

	//============================================================================

	// used when changing model (new, open)
	private function changeModel(model:Model) {
		if (model==null) {
			//TODO report the problem to the user (CHECK ALL PROJECT FOR THIS KIND OF MISSING FEEDBACKS)
			TileCraft.error('invalid change model');
			return;
		}
		if (currentModel!=null) currentModel.destroy();
		currentModel = model;
		updatePalette();
		updateShapeList();
		renderModel(false);
		renderOutput();
		//TileCraft.logger(currentModel.toPNGString(_outputBitmap.bitmapData)); //TODO should be a TextField to output this on request
	}

	//============================================================================

	// Listeners
	// TODO here should be all common calls to dispatch
	// TODO "events" between   Model/Shape <--> ModelView/ShapeView/ColorPickerView

	// public function addShape(shape:Shape) {
	//
	// }
	//
	// public function removeShape(shape:Shape) {
	//
	// }

	// CALL WHEN SOMETHING CHANGE THE MODEL
	public function updateModel() {
		renderModel(false);
	}

	public function updateShapeType(shapeType:ShapeType) {
		var shape = currentShapeViewList.getSelectedShape();
		if (shape==null) return;
		shape.shapeType = shapeType;
		updateShape(shape);
		updateModel();
	}

	public function updateShapeSelect(shape:Shape) {
		currentShapeViewList.selectByShape(shape);
		if (shape!=null) {
			colorToolbar.selectByIndex(shape.color);
			toolbar.select(toolbar.getButtonByValue(shape.shapeType));
		}
	}

	public function deselect() {
		hideColorPicker();
		currentShapeViewList.deselect();
	}

	public function getColor(index:Int):Int {
		if (currentModel==null) return -1;
		return currentModel.getColor(index);
	}

	public function updatePalette(){
		for (i in 1...16) {
			colorToolbar.getButtonByIndex(i).icon = TileCraft.makeColorIcon(colorToolbar.styleButton,
																																			currentModel.getColor(i));
		}
	}

	public function updateShape(shape:Shape) {
		currentShapeViewList.updateShape(shape);
	}

	public function updateColor(colorIndex:Int) {
		currentShapeViewList.updateColor(colorIndex);
	}

	public function updateShapeList(){
		currentShapeViewList.removeAll();
		for (i in 0...currentModel.getShapeCount()) {
			currentShapeViewList.add(currentModel.getShapeByIndex(i));
		}
	}

	//============================================================================

	public function newModel() {
		changeModel(Model.makeNew());
	}

	public function saveFile():Bool {
		#if sys
		// Render the _outputBitmap (TODO need to be better, maybe this system in ModelView)
		renderOutput();

		// Determine the file path
		var filename:String = saveDialog("TileCraft PNG image","*.png");
		if (filename==null) {
			TileCraft.logger('User canceled the dialog');
			return false;
		}

		// Get FileOutput
		var fo:haxe.io.Output = null;
		try { fo = sys.io.File.write(filename,true); }
		catch (e:Dynamic){
			TileCraft.error('File write error $e');
			fo = null;
		}

		// Export the model
		fo = currentModel.toPNG(fo,_outputView.getBitmapData());

		// Check if everything is ok
		if (fo==null) {
			TileCraft.error('Unable to save the Model to "$filename"');
			return false;
		} else {
			try { fo.close(); } catch(e:Dynamic) {}
			return true;
		}
		#else
		return false;
		#end
	}

	public function openFile():Bool {
		#if sys
		// Determine the file path
		var filename:String = openDialog("TileCraft PNG image","*.png");
		if (filename==null) {
			TileCraft.logger('User canceled the dialog');
			return false;
		}

		// Get FileInput
		var fr:FileInput = null;
		try { fr = sys.io.File.read(filename,true); }
		catch (e:Dynamic){ TileCraft.error('File read error $e'); fr = null; }

		// Import the model
		var model:Model = Model.fromPNG(fr);

		// Close the FileInput
		if (fr!=null) try { fr.close(); } catch(e:Dynamic) {}

		// Check if everything is ok
		if (model==null) {
			TileCraft.error('Unable to load the model "$filename"');
			return false;
		} else {
			// prepare context
			changeModel(model);
			return true;
		}
		#else
		return false;
		#end
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
		// TileCraft.logger('SAVE DIALOG RESPONSE: '+file);
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
		// TileCraft.logger('OPENDIALOG RESPONSE: '+files);
		// if (files==null) return null;
		// return files[0];
	}

	public override function initialize():Void {


		// VIEWS -------------------------------------------------------------------

		_outputView = new OutputView(this,PREVIEW_WIDTH);
		_outputView.t.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_LEFT);
		_outputView.t.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH;
		_outputView.t.y = rheight-STATUSBAR_HEIGHT;
		_outputView.addEventListener(MouseEvent.CLICK,function(e:MouseEvent) { renderOutput(); });
		addChild(_outputView);

		_modelView = new ModelView(this,RENDER_WIDTH,RENDER_HEIGHT);
		_modelView.x = TOOLBAR_WIDTH+(rwidth-TOOLBAR_WIDTH-SHAPELIST_WIDTH-PREVIEW_WIDTH)/2-RENDER_WIDTH/2-ModelView.PADDING;
		_modelView.y = (rheight-ACTIONBAR_HEIGHT-STATUSBAR_HEIGHT)/2-RENDER_HEIGHT/2+ACTIONBAR_HEIGHT-ModelView.PADDING;
		addChild(_modelView);


		// STATIC INTERFACE --------------------------------------------------------

		// currentModel+color toolbar bg
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,0,
											TOOLBAR_WIDTH,rheight);

		// action toolbar bg
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,0,
											rwidth,ACTIONBAR_HEIGHT);

		// shapelist
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(rwidth-SHAPELIST_WIDTH,
											0,rwidth,rheight);

		// preview
		graphics.beginFill(0x242424,0.8);
		graphics.drawRect(rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH,
											0,rwidth-SHAPELIST_WIDTH,rheight);

		// status bar
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,rheight-STATUSBAR_HEIGHT,
											rwidth,rheight);

		// model
		graphics.beginFill(0x808080,1);
		graphics.drawRect(TOOLBAR_WIDTH,ACTIONBAR_HEIGHT,
										  rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH-TOOLBAR_WIDTH,rheight-STATUSBAR_HEIGHT-ACTIONBAR_HEIGHT);




		// BUTTON TEST CASES -------------------------------------------------------

		// var button = new Button("TEST");
		// button.x = 130;
		// button.y = 100;
		// button.style = Style.getStyle('button');
		// button.selectable = true;
		// button.listen = true;
		// button.actionF = function(button:Button) { TileCraft.logger(button.toString()); };
		// button.makeText("Button test");
		// button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_CHECKBOX).toBitmapData();
		// button.iconSelected = TileCraft.atlasSprites.getRegion(TileCraft.ICON_CHECKBOX_CHECKED).toBitmapData();
		// addChild(button);
		//
		// var button = new Button("TEST2");
		// button.x = 130;
		// button.y = 150;
		// button.style = Style.getStyle('button');
		// button.listen = true;
		// button.makeText("Button test");
		// addChild(button);
		//
		// var button = new Button("TEST3");
		// button.x = 130;
		// button.y = 200;
		// button.style = Style.getStyle('button');
		// button.listen = true;
		// button.icon = TileCraft.atlasSprites.getRegion(TileCraft.ICON_CHECKBOX).toBitmapData();
		// addChild(button);
		//
		// var button = new Button("TEST4");
		// button.x = 130;
		// button.y = 250;
		// button.style = Style.getStyle('button');
		// button.listen = true;
		// addChild(button);

		// MODEL TOOLBAR --------------------------------------------------------

		var shapeTypeSelector = function(button:Button) {
			var shapeType:ShapeType = cast(button.value,ShapeType);
			updateShapeType(shapeType);
		};
		var pointerSelector = function(button:Button) {
			deselect();
		}
		toolbar = new Toolbar(2,true,Style.getStyle('.toolbar'),Style.getStyle('.button.toolbarButton'));
		toolbar.addButton("pointer",null,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_POINTER).toBitmapData(),	pointerSelector);
		toolbar.addButton("cube",
											ShapeType.CUBE,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_CUBE).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("round_up",
											ShapeType.ROUND_UP,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_ROUND_UP).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("round_side",
											ShapeType.ROUND_SIDE,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_ROUND_SIDE).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("cylinder_up",
											ShapeType.CYLINDER_UP,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_CYLINDER_UP).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("cylinder_side",
											ShapeType.CYLINDER_SIDE,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_CYLINDER_SIDE).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("ramp_up",
											ShapeType.RAMP_UP,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_RAMP_UP).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("ramp_down",
											ShapeType.RAMP_DOWN,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_RAMP_DOWN).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("arch_up",
											ShapeType.ARCH_UP,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_ARCH_UP).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("arch_down",
											ShapeType.ARCH_DOWN,
												TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_ARCH_DOWN).toBitmapData(),
												shapeTypeSelector);
		toolbar.addButton("corner_se",
											ShapeType.CORNER_SE,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_CORNER_SE).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("corner_sw",
											ShapeType.CORNER_SW,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_CORNER_SW).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("corner_nw",
											ShapeType.CORNER_NW,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_CORNER_NW).toBitmapData(),
											shapeTypeSelector);
		toolbar.addButton("corner_ne",
											ShapeType.CORNER_NE,
											TileCraft.atlasSprites.getRegion(TileCraft.ICON_SH_CORNER_NE).toBitmapData(),
											shapeTypeSelector);

		toolbar.x = TOOLBAR_WIDTH/2-toolbar.getGrossWidth()/2;
		toolbar.y = ACTIONBAR_HEIGHT+10;
		addChild(toolbar);


		// COLOR TOOLBAR --------------------------------------------------------

		colorToolbar = new Toolbar(2,true,Style.getStyle('.toolbar'),Style.getStyle('.button.toolbarButton.toolbarButtonFull'));

		//---

		var colorPickerAction = function(color:Int) {
			var button:Button = colorToolbar.getSelected();
			var index:Int = cast(button.value,Int);
			if (index==0) return; //hole
			button.icon = TileCraft.makeColorIcon(colorToolbar.styleButton,
																						color);
			currentModel.setColor(index,color);
			updateColor(index);
			renderModel(true);
		}

		//---

		_colorPicker = new ColorPickerView(rwidth-TOOLBAR_WIDTH-SHAPELIST_WIDTH-PREVIEW_WIDTH,colorPickerAction,function() {hideColorPicker();});
		_colorPicker.x = TOOLBAR_WIDTH;
		_colorPicker.y = rheight-_colorPicker.getGrossHeight();

		//---

		var colorToolbarAction = function(button:Button) {
				var value:Int = cast(button.value,Int);
				// change shape color
		    var shape:Shape = currentShapeViewList.getSelectedShape();
			  if (shape!=null) {
			    shape.color = value;
					updateShape(shape);
			    updateModel();
				}

				if (value==0) {
					//hole
					hideColorPicker();
				} else if (_colorPickerOnStage) {
					showColorPicker(currentModel.getColor(value));
				}

		};

		var colorToolbarActionAlt = function(button:Button) {
				var value:Int = cast(button.value,Int);
				if (value==0) return; //hole
				showColorPicker(currentModel.getColor(value));
		};

		//---

		//colorToolbar.setPalette(currentModel.getPalette());
		colorToolbar.addButton('palette0',0,
													 TileCraft.makeColorIcon(colorToolbar.styleButton,
																									 -1),
													 colorToolbarAction);
		for (i in 1...16) {
			colorToolbar.addButton('palette$i',i,
														 TileCraft.makeColorIcon(colorToolbar.styleButton,
																										 currentModel.getColor(i)),
														 colorToolbarAction,colorToolbarActionAlt);
		}
		colorToolbar.selectByIndex(1);
		colorToolbar.x = TOOLBAR_WIDTH/2-colorToolbar.getGrossWidth()/2;
		colorToolbar.y = toolbar.y + toolbar.height + BASE_SPAN;
		addChild(colorToolbar);


		// ACTION TOOLBAR ----------------------------------------------------------

		var actionToolbarAction = function(button:Button) { TileCraft.logger("NOT IMPLEMENTED"); }
		var actionToolbar = new Toolbar(0,false,Style.getStyle('.toolbar'),Style.getStyle('.button.toolbarButton'));
		actionToolbar.addButton("new",null,			TileCraft.atlasSprites.getRegion(TileCraft.ICON_NEW).toBitmapData(),
																						function(_) {
																							newModel();
																						});
		actionToolbar.addButton("open",null,		TileCraft.atlasSprites.getRegion(TileCraft.ICON_OPEN).toBitmapData(),
																						function(_) { openFile(); });
		actionToolbar.addButton("save",null,		TileCraft.atlasSprites.getRegion(TileCraft.ICON_SAVE).toBitmapData(),
																						function(_) { saveFile(); });
		actionToolbar.addButton("-");
		actionToolbar.addButton("render",null,	TileCraft.atlasSprites.getRegion(TileCraft.ICON_RENDER).toBitmapData(),
																						function(_) { renderOutput(); });
		actionToolbar.addButton("-");
		actionToolbar.addButton("copy",null,		TileCraft.atlasSprites.getRegion(TileCraft.ICON_COPY).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("paste",null,	TileCraft.atlasSprites.getRegion(TileCraft.ICON_PASTE).toBitmapData(),	actionToolbarAction);
		actionToolbar.addButton("-");
		actionToolbar.addButton("quit",null,		TileCraft.atlasSprites.getRegion(TileCraft.ICON_QUIT).toBitmapData(),
																						function(_) {
																							// BOOL isError
																							//if (Dialogs.confirm(TileCraft.APP_NAME,"Do you really want to quit?",false))
																								PLIK.quit();
																						});
		actionToolbar.x = TOOLBAR_WIDTH+BASE_SPAN;
		actionToolbar.y = ACTIONBAR_HEIGHT/2-actionToolbar.getGrossHeight()/2;
		addChild(actionToolbar);


		// PREVIEW TOOLBAR ---------------------------------------------------------

		var previewColorToolbarAction = function(button:Button) {
			_outputView.setBackgroundColor(cast(button.value,Int));
		};

		var previewColorToolbar = new Toolbar(0,true,Style.getStyle('.toolbar'),Style.getStyle('.button.toolbarButton.toolbarMiniButton.toolbarMiniButtonFull'));
		previewColorToolbar.addButton('preview0',-1,
																  TileCraft.makeColorIcon(previewColorToolbar.styleButton,
																													-1),
																	previewColorToolbarAction);
		previewColorToolbar.addButton('preview1',0xFFFFFF,
																	TileCraft.makeColorIcon(previewColorToolbar.styleButton,
																													0xCCCCCC),
																	previewColorToolbarAction);
		previewColorToolbar.addButton('preview2',0,
															    TileCraft.makeColorIcon(previewColorToolbar.styleButton,
																													0x333333),
																	previewColorToolbarAction);
		previewColorToolbar.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH+BASE_SPAN/2;
		previewColorToolbar.y = rheight-STATUSBAR_HEIGHT/2-previewColorToolbar.getGrossHeight()/2;
		addChild(previewColorToolbar);

		var previewActionToolbar = new Toolbar(0,false,Style.getStyle('.toolbar'),Style.getStyle('.button.toolbarButton.toolbarMiniButton'));
		previewActionToolbar.addButton('resize',0,TileCraft.atlasSprites.getRegion(TileCraft.ICON_RESIZE).toBitmapData(),renderModeLoop);
		previewActionToolbar.addButton('save',0,TileCraft.atlasSprites.getRegion(TileCraft.ICON_SAVE).toBitmapData());
																						//function(_){ saveFile(); });
		previewActionToolbar.x = rwidth-SHAPELIST_WIDTH-BASE_SPAN/2-previewActionToolbar.getGrossWidth();
		previewActionToolbar.y = rheight-STATUSBAR_HEIGHT/2-previewActionToolbar.getGrossHeight()/2;
		addChild(previewActionToolbar);

		// APP TITLE ---------------------------------------------------------------

		var text = new Text(TileCraft.APP_NAME.toUpperCase(),18,TileCraft.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER,TileCraft.FONT_SQUARE);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = TOOLBAR_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2;
		addChild(text);

		var text = new Text(TileCraft.APP_STAGE.toUpperCase(),9,TileCraft.COLOR_WHITE,openfl.text.TextFormatAlign.CENTER,TileCraft.FONT_LATO_BOLD);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = TOOLBAR_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2+12;
		addChild(text);
				// -------------------------------------------------------------------------

		currentShapeViewList = new ShapeViewList(this,SHAPELIST_WIDTH,rheight-ACTIONBAR_HEIGHT-STATUSBAR_HEIGHT);
		currentShapeViewList.x = rwidth-SHAPELIST_WIDTH;
		currentShapeViewList.y = ACTIONBAR_HEIGHT;
		addChild(currentShapeViewList);

		// -------------------------------------------------------------------------

		// EXAMPLE MODELS

		// stupid guy
		//var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";

		// complex shape
		var original = "Ff//1fb/QEW7PqXys9vuJDI/OVJXUpAjpswzUUY1p3At////9+F2vjJB33qSfoaPprO8Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq+8B";

		// question mark
		//var original = "BgAABmdnAUY5Z19ASGd9ADVnCwZnZ1ZgNWfP";

		// 32 shapes (scroll shapeview test)
		//var original = "HwAAFjxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVBh5FVRxVRO8cqkTvwQFWAcHvzQHBVs0BwQEBAVKa3gFSAc0BUu9FAVI0EgFSvO8BQu-aAUpF7wFKI6sBM81nAQ..";

		// home
		//var original = "DAAACGneAQk8XCgIPF0SWzdcv183er9rjFy_b4x6v2mMzJ1ZN7ydCDysmgBpXiVAaaxH";

		// random stuff
		//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";

		//var original = "AQAAAUpJCA.."; //just a cube

		// farm
		//var original = "E____wAA____PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJB33qSfoaPprO8OxK8AUo0qwFLq5oBO828ATgjNBg5IlUDOd1VAwgeVSIBigESMXoBIjGIAQExqgEBUYgAMzYRiAE2FCWbNiM0vBYFFpo27ncCNt40BA..";

		// -------------------------------------------------------------------------

		// set the example test model
		changeModel(Model.fromString(original));

		//init background image
		_outputView.drawBackground();

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

	private override function update(delta:Float):Void {

	}

	public override function resize() {

	}

	//############################################################################

	var _colorPicker:ColorPickerView;
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

		//out of preview
		if (_modelIsPreviewMode) { //TODO unified system to handle preview mode
			renderModel(false);
			renderOutput();
		}
	}

	//############################################################################
	//############################################################################

	// TODO implement this CLIPBOARD systools example

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

	///////////////////////////////////////////////////////////////////////////
	// APP Resources and properties

	public static inline var APP_NAME = "TileCraft" ;
	public static inline var APP_PACKAGE = "com.akifox.tilecraft" ;
	public static inline var APP_BUILD = CompileTime.readFile("Export/.build");
	public static inline var APP_BUILD_DATE = CompileTime.buildDateString();
	public static inline var APP_VERSION = "1.0.0-alpha7dev"; //TODEPLOY
	public static inline var APP_STAGE = "alpha7 dev"; //TODEPLOY
	public static inline var APP_PLATFORM =
	#if debug "dev"
  #elseif flash "swf"
  #elseif ios "ios"
  #elseif android	"and"
	#elseif mac "mac"
  #elseif windows "win"
  #elseif linux "lnx"
  #elseif web "web"
  #else "---"
  #end;
	public static inline var APP_BGCOLOR = 0xEEEEEE ;

	//////////////////////////////////////////////////////////////////////////////
	// Atlases (faster retrive than asking to cache system)

	public static var atlasSprites:TextureAtlas=null;

	//////////////////////////////////////////////////////////////////////////////
	// URLs and FILEs

  public static inline var LINK_UPDATE = "http://akifox.com/tilecraft/get/";
	public static inline var LINK_WWW = "http://akifox.com/tilecraft/";

	//////////////////////////////////////////////////////////////////////////////
	// COLORS

	public static inline var FONT_SQUARE:String = "assets/fonts/Square.ttf";
  public static inline var FONT_04B_03:String = "assets/fonts/04B_03.TTF";
  public static inline var FONT_LATO_BOLD:String = "assets/fonts/Lato-Bold.ttf";
  public static inline var FONT_LATO_LIGHT:String = "assets/fonts/Lato-Light.ttf";

	public static inline var COLOR_WHITE:Int = 	0xFFFFFF;
	public static inline var COLOR_LIGHT:Int = 	0xDCDCDC;
	public static inline var COLOR_BLACK:Int = 	0x000000;
	public static inline var COLOR_DARK:Int = 	0x242424;
	public static inline var COLOR_ORANGE:Int = 0xffb500;
	public static inline var COLOR_RED:Int = 	0xcf2d00;
	public static inline var COLOR_GREEN:Int = 	0x98ca00;

	//////////////////////////////////////////////////////////////////////////////
	// atlasIcon REGIONS

	public static inline var ICON_POINTER = 'pointer.png';
	public static inline var ICON_EYE_OPEN = 'eye_open.png';
	public static inline var ICON_EYE_CLOSED = 'eye_closed.png';
	public static inline var ICON_LOCK_OPEN = 'lock_open.png';
	public static inline var ICON_LOCK_CLOSED = 'lock_closed.png';

	public static inline var ICON_CHECKBOX = 'checkbox.png';
	public static inline var ICON_CHECKBOX_CHECKED = 'checkbox_checked.png';

	public static inline var ICON_NEW = 'new.png';
	public static inline var ICON_COPY = 'copy.png';
	public static inline var ICON_PASTE = 'paste.png';
	public static inline var ICON_OPEN = 'open.png';
	public static inline var ICON_DELETE = 'delete.png';
	public static inline var ICON_OK = 'ok.png';
	public static inline var ICON_SAVE = 'save.png';
	public static inline var ICON_QUIT = 'quit.png';
	public static inline var ICON_RENDER = 'render.png';
	public static inline var ICON_CLOSE = 'close.png';
	public static inline var ICON_RESIZE = 'resize.png';
	public static inline var ICON_PALETTE = 'palette.png';

	public static inline var ICON_ROUND0 = 'round_0.png';
	public static inline var ICON_ROUND1 = 'round_1.png';
	public static inline var ICON_ROUND2 = 'round_2.png';
	public static inline var ICON_ROUND3 = 'round_3.png';

	public static inline var ICON_SH_CUBE = 'sh_cube.png';
	public static inline var ICON_SH_ROUND_UP = 'sh_round_up.png';
	public static inline var ICON_SH_ROUND_SIDE = 'sh_round_side.png';
	public static inline var ICON_SH_CYLINDER_UP = 'sh_cylinder_up.png';
	public static inline var ICON_SH_CYLINDER_SIDE = 'sh_cylinder_side.png';
	public static inline var ICON_SH_RAMP_UP = 'sh_ramp_up.png';
	public static inline var ICON_SH_RAMP_DOWN = 'sh_ramp_down.png';
	public static inline var ICON_SH_ARCH_UP = 'sh_arch_up.png';
	public static inline var ICON_SH_ARCH_DOWN = 'sh_arch_down.png';
	public static inline var ICON_SH_CORNER_SE = 'sh_corner_se.png';
	public static inline var ICON_SH_CORNER_SW = 'sh_corner_sw.png';
	public static inline var ICON_SH_CORNER_NE = 'sh_corner_ne.png';
	public static inline var ICON_SH_CORNER_NW = 'sh_corner_nw.png';

	public static inline var ICON_SHT_CUBE = 'sht_cube.png';
	public static inline var ICON_SHT_ROUND_UP = 'sht_round_up.png';
	public static inline var ICON_SHT_ROUND_SIDE = 'sht_round_side.png';
	public static inline var ICON_SHT_CYLINDER_UP = 'sht_cylinder_up.png';
	public static inline var ICON_SHT_CYLINDER_SIDE = 'sht_cylinder_side.png';
	public static inline var ICON_SHT_RAMP_UP = 'sht_ramp_up.png';
	public static inline var ICON_SHT_RAMP_DOWN = 'sht_ramp_down.png';
	public static inline var ICON_SHT_ARCH_UP = 'sht_arch_up.png';
	public static inline var ICON_SHT_ARCH_DOWN = 'sht_arch_down.png';
	public static inline var ICON_SHT_CORNER_SE = 'sht_corner_se.png';
	public static inline var ICON_SHT_CORNER_SW = 'sht_corner_sw.png';
	public static inline var ICON_SHT_CORNER_NE = 'sht_corner_ne.png';
	public static inline var ICON_SHT_CORNER_NW = 'sht_corner_nw.png';


// TODO check it out
// 'font_name':'"+com.akifox.plik.PLIK.getFont(TileCraft.FONT_SQUARE).fontName+"'',
// 'font_offset_x':1,
// 'font_offset_y':1,

	//############################################################################

	public static function makeChessboard(graphics:openfl.display.Graphics,size:Int,offset_x:Int,offset_y:Int,width:Float,height:Float,color0:Int,color1:Int) {
			var gridX = Math.ceil(width/size);
			var gridY = Math.ceil(height/size);
			for (y in 0...gridY) {
				for (x in 0...gridX) {
					if ((x+y)%2==0) graphics.beginFill(color0);
					else graphics.beginFill(color1);
					graphics.drawRect(size*x+offset_x,size*y+offset_y,(size*x+size>width?width-size*x:size),(size*y+size>height?height-size*y:size));
				}
			}
	}

	public static function makeColorIcon(style:Style,color:Int):BitmapData {
		var span = style.bevel;
		var size:Int = style.minWidth;
		var round = style.rounded;
		var hole = false;
		if (color==-1) {
			hole = true;
			span += 1;
			color = 0xBBBBBB;
		}

		var shape = new openfl.display.Shape();
		var matrix = new openfl.geom.Matrix();
		matrix.createGradientBox(size,size,90*Math.PI/180);
		shape.graphics.beginGradientFill(openfl.display.GradientType.LINEAR,[ColorToolkit.shiftBrighteness(color,25),ColorToolkit.shiftBrighteness(color,-25)],[1,1],[0,255],matrix);
		shape.graphics.drawRoundRect(0,0,size,size,round);
		shape.graphics.endFill();

		if (hole) {
			var grid = 5;
			var div = (size-span*2)/grid;
			for (y in 0...grid) {
				for (x in 0...grid) {
					if ((x+y)%2==0) shape.graphics.beginFill(0x999999);
					else shape.graphics.beginFill(0xEEEEEE);
					shape.graphics.drawRect(div*x+span,div*y+span,div,div);
				}
			}
		} else {
			shape.graphics.beginFill(color);
			shape.graphics.drawRoundRect(span,span,size-span*2,size-span*2,round);
			shape.graphics.endFill();
		}

		var bd = new BitmapData(size,size,true,0);
		bd.draw(shape);
		shape = null;
		return bd;

	};


	///////////////////////////////////////////////////////////////////////////
	// MEMORY MANAGEMENT

	public static function preloadAssets():Void {

		PLIK.preloadFont(TileCraft.FONT_SQUARE);
    PLIK.preloadFont(TileCraft.FONT_04B_03);
		PLIK.preloadFont(TileCraft.FONT_LATO_LIGHT);
		PLIK.preloadFont(TileCraft.FONT_LATO_BOLD);

		if (TileCraft.atlasSprites==null) TileCraft.atlasSprites = Gfx.getTextureAtlas('sprites.xml');

	}

}
