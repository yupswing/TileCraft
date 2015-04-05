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
import Toolbar;


class ScreenMain extends Screen
{

	var _model:Model;

	public function new () {
		super();
		cycle = false;
		title = "Main";
		rwidth = 1024;
		rheight = 576;
	}

	public function getColor(index:Int) {
		if (_model==null) return 0;
		return _model.getColor(index);
	}

	public override function initialize():Void {
    trace(rwidth);
    trace(rheight);
    trace(PLIK.adjust(rwidth));
		trace(ModelIO.DEFAULT_PALETTE);


		// CLASS TEST
		// String -> Array<Int> -> Model (Shapes) -> Array<Int> -> String
		// stupid guy
		//var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";
		// complex shape
		var original = "FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";
		// home
		//var original = "DAAACGneAQlLXCgIS1wBW0dcv19Her9ri1y_b4t6v2mLzJ1ZR7ydCEusmgBpXiVAaaxH";
		// random stuff
		//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";
		//var original = "AQAAAUpJCA.."; //just a cube
		//var original = "AgAAAUonAUZZNAc.";
		// farm
		//var original = "EgAC____OxK8AUo0qwFLq5oBO828AQgeVSI5IlUDOd1VAwGKARIxegEiMYgBATGqAQE2EYgBOCM0GDYUJZs2IzS8FgUWmjbudwI27xKJ";
		//var original = "AQAEAGb_QFYjAQ..";
		var decoded = Base64.decodeBase64(original);
		var model = _model = ModelIO.loadModel(decoded);
		var demodel = ModelIO.saveModel(model);
		var reencoded = Base64.encodeBase64(demodel,true);

		trace('original:',original);
		trace('decoded:',decoded);
		trace('model:',model);
		trace('demodel:',demodel);
		trace('reencoded:',reencoded);

		var passed:Bool = true;
		if (original!=reencoded) passed = false;
		// END TEST

		var ren = new ModelRenderer(Std.int(352),Std.int(480));
		var bpd = ren.render(model,-1,true);
		var bp = new Bitmap(bpd);
		bp.smoothing = true;
		bp.x = rwidth/2-bp.width/2+PLIK.adjust(650);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var ren = new ModelRenderer(Std.int(352),Std.int(480));
		var bpd = ren.render(model,-1,false);
		var bp = new Bitmap(bpd);
		bp.smoothing = true;
		bp.x = rwidth/2-bp.width/2;
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var bp = new Bitmap(bpd);
		bp.smoothing = true;
		bp.scaleX = bp.scaleY = 0.25;
		bp.x = rwidth/2-bp.width/2-PLIK.adjust(550);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		graphics.beginFill(0x242424,0.95);
		graphics.drawRect(0,0,103,rheight);

		var toolbar = new Toolbar(this,2);
		toolbar.addButton("pointer",				APP.atlasSprites.getRegion(APP.ICON_POINTER));
		toolbar.addButton("sh_cube",				APP.atlasSprites.getRegion(APP.ICON_SH_CUBE));
		toolbar.addButton("sh_round_up",		APP.atlasSprites.getRegion(APP.ICON_SH_ROUND_UP));
		toolbar.addButton("sh_round_side",	APP.atlasSprites.getRegion(APP.ICON_SH_ROUND_SIDE));
		toolbar.addButton("sh_cylinder_up",	APP.atlasSprites.getRegion(APP.ICON_SH_CYLINDER_UP));
		toolbar.addButton("sh_cylinder_side",APP.atlasSprites.getRegion(APP.ICON_SH_CYLINDER_SIDE));
		toolbar.addButton("sh_ramp_up",			APP.atlasSprites.getRegion(APP.ICON_SH_RAMP_UP));
		toolbar.addButton("sh_ramp_down",		APP.atlasSprites.getRegion(APP.ICON_SH_RAMP_DOWN));
		toolbar.addButton("sh_arch_up",			APP.atlasSprites.getRegion(APP.ICON_SH_ARCH_UP));
		toolbar.addButton("sh_arch_down",		APP.atlasSprites.getRegion(APP.ICON_SH_ARCH_DOWN));
		toolbar.addButton("sh_corner_se",		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_SE));
		toolbar.addButton("sh_corner_sw",		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_SW));
		toolbar.addButton("sh_corner_ne",		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_NE));
		toolbar.addButton("sh_corner_nw",		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_NW));

		toolbar.x = 20;
		toolbar.y = 30;
		addChild(toolbar);

		var colorToolbar = new ColorToolbar(this,2);
		colorToolbar.setPalette(_model.getPalette());
		for (i in 0...16) {
			colorToolbar.addColorButton(function(colorIndex:Int) { trace(_model.getColor(colorIndex)); });
		}
		colorToolbar.x = 20;
		colorToolbar.y = toolbar.y + toolbar.height + 20;
		addChild(colorToolbar);

		var text = new Text(APP.APP_NAME,PLIK.adjustInt(100),APP.COLOR_BLACK);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = rwidth/2;
		text.t.y = PLIK.adjust(60);
		addChild(text);

		text = new Text("TEST "+(passed?"PASSED":"NOT PASSED"),PLIK.adjustInt(50),APP.COLOR_BLACK);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = rwidth/2;
		text.t.y = PLIK.adjust(120);
		addChild(text);

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

	//########################################################################################
	//########################################################################################

}
