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


class ScreenMain extends Screen
{

	public function new () {
		super();
		cycle = false;
		title = "Main";
		rwidth = 1024;
		rheight = 576;
	}

	public override function initialize():Void {
    trace(rwidth);
    trace(rheight);
    trace(PLIK.adjust(rwidth));
		trace(ModelIO.DEFAULT_PALETTE);


		// CLASS TEST
		// String -> Array<Int> -> Model (Shapes) -> Array<Int> -> String
		//var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";
		var original = "FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";
		//var original = "DAAACGneAQlLXCgIS1wBW0dcv19Her9ri1y_b4t6v2mLzJ1ZR7ydCEusmgBpXiVAaaxH";
		//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";
		//var original = "AQAAAUpJCA.."; //cube
		//var original = "AgAAAUonAUZZNAc.";
		//var original = "EgAC____OxK8AUo0qwFLq5oBO828AQgeVSI5IlUDOd1VAwGKARIxegEiMYgBATGqAQE2EYgBOCM0GDYUJZs2IzS8FgUWmjbudwI27xKJ";
		var decoded = Base64.decodeBase64(original);
		var model = ModelIO.loadModel(decoded);
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
		bp.x = rwidth/2-bp.width/2+PLIK.adjust(700);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var ren = new ModelRenderer(Std.int(352),Std.int(480));
		var bpd = ren.render(model,-1,false);
		var bp = new Bitmap(bpd);
		bp.smoothing = true;
		bp.x = rwidth/2-bp.width/2-PLIK.adjust(50);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var bp = new Bitmap(bpd);
		bp.smoothing = true;
		bp.scaleX = bp.scaleY = 0.5;
		bp.x = rwidth/2-bp.width/2-PLIK.adjust(610);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var bp = new Bitmap(bpd);
		bp.smoothing = true;
		bp.scaleX = bp.scaleY = 0.25;
		bp.x = rwidth/2-bp.width/2-PLIK.adjust(900);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var text = new Text(APP.APP_NAME,PLIK.adjustInt(100),APP.COLOR_BLACK);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = rwidth/2;
		text.t.y = PLIK.adjust(150);
		addChild(text);

		text = new Text("TEST "+(passed?"PASSED":"NOT PASSED"),PLIK.adjustInt(50),APP.COLOR_BLACK);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = rwidth/2;
		text.t.y = PLIK.adjust(270);
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
