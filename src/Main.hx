package;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.*;

class Main {
	var _loadingBitmap:Bitmap;

	public function new () {
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, stageReady);
	}

	private function stageReady (event:Event):Void {
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, stageReady);

		// ------------------------------
		// "PRINT" LOADING SPLASH

    Lib.current.stage.color = TileCraft.COLOR_WHITE;
		_loadingBitmap = new Bitmap(openfl.Assets.getBitmapData('assets/graphics/generic/loading.png',false));
		_loadingBitmap.scaleX = _loadingBitmap.scaleY = Lib.current.stage.stageWidth/_loadingBitmap.width;
		_loadingBitmap.smoothing = true;
		_loadingBitmap.x = Lib.current.stage.stageWidth/2-_loadingBitmap.width/2;
		_loadingBitmap.y = Lib.current.stage.stageHeight/2-_loadingBitmap.height/2;
		Lib.current.stage.addChild(_loadingBitmap);

		// give a moment to show the preloader
		Actuate.timer(0.02).onComplete(initialize);
	}

	private function initialize(){
		// ------------------------------
		// SETUP AND PRELOAD

		#if debug
		var _container = new Sprite();
		Lib.current.stage.addChild(_container);
		#else
		var _container = Lib.current.stage;
		#end

		PLIK.initialize(_container,TileCraft.APP_PACKAGE);

		// STYLED GUI
		PLIK.initStyle(openfl.Assets.getText("assets/styles/base.json"));
		//com.akifox.plik.gui.Style.mergeStyleSet(openfl.Assets.getText("assets/styles/light.json")); //TODO light style

		// PREFERENCES
		PLIK.initPref();

		// SET DEFAULT FONT
		PLIK.setDefaultFont(TileCraft.FONT_SQUARE);

		// INITIALIZE GFX
		Gfx.setBasePath("assets/graphics/generic/"); // no multiresolution

		// FIRST RUN
		if (PLIK.getPref('first_run')==1) {
			//FIRST RUN ONLY
			PLIK.setPref('first_run',0);
		}

		// ------------------------------
		// ASSETS
    TileCraft.preloadAssets();

		// ------------------------------
    // DEBUG
   	#if debug
    var performance = new com.akifox.plik.debug.Performance(
    						PLIK.getFont(TileCraft.FONT_SQUARE),
    						openfl.Assets.getBitmapData('assets/debug/akifox_logo_small.png',false),
    						true,
    						true);
    _container.addChild(performance);
    #end

		// ------------------------------
    // REMOVE AND DISPOSE LOADING SPLASH

		Lib.current.stage.removeChild(_loadingBitmap);
		_loadingBitmap.bitmapData.dispose();
		_loadingBitmap=null;
    Lib.current.stage.color = TileCraft.APP_BGCOLOR;

		// ------------------------------
    // FIRST SCREEN

		PLIK.changeScreen(new TileCraft(),PLIK.TRANSITION_ALPHA);

		Lib.current.stage.addEventListener (Event.RESIZE, onResize);
	}

	private function onResize (event:Event):Void {
		PLIK.resize();
	}

}
