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
	}

	public override function initialize():Void {
    trace(rwidth);
    trace(rheight);
    trace(PLIK.adjust(rwidth));
		trace(ModelIO.DEFAULT_PALETTE);


		// CLASS TEST
		// String -> Array<UInt> -> Model (Shapes) -> Array<UInt> -> String
		var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";
		var original = "FAQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zg9MacxpDng7eAoPDwBDEt4BQ97eAQMt3gE.";
		//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";
		//var original = "AgAAAUonAUZZNAc.";
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
		//bp.scaleX = bp.scaleY = 1/4;
		bp.x = rwidth/2-bp.width/2;
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

	//########################################################################################
	//########################################################################################

}
