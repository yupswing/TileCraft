package ;

import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.Screen;
import com.akifox.asynchttp.*;
import motion.Actuate;
import motion.easing.*;
import com.akifox.plik.PLIK;
import com.akifox.plik.Data;
import com.akifox.plik.Gfx;
import com.akifox.plik.Sfx;
import openfl.events.*;
import openfl.display.BitmapData;
import haxe.Timer;
using hxColorToolkit.ColorToolkit;
class APP
{

	///////////////////////////////////////////////////////////////////////////
	// Game Info

	public static inline var APP_NAME = "TileCraft" ;
	public static inline var APP_PACKAGE = "com.akifox.tilecraft" ;
	public static inline var APP_BUILD = CompileTime.readFile("Export/.build");
	public static inline var APP_BUILD_DATE = CompileTime.buildDateString();
	public static inline var APP_VERSION = "1.0.0-alpha3"; //TODEPLOY
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


	///////////////////////////////////////////////////////////////////////////
	// Atlases (faster retrive than asking to cache system)

	public static var atlasSprites:TextureAtlas=null;

	///////////////////////////////////////////////////////////////////////////
	// URLs and FILEs

  public static inline var LINK_UPDATE = "http://akifox.com/tilecraft/get/";
	public static inline var LINK_WWW = "http://akifox.com/tilecraft/";

	///////////////////////////////////////////////////////////////////////////
	// COLORS

	public static inline var FONT_SQUARE:String = "assets/fonts/Square.ttf";
  public static inline var FONT_04B_03:String = "assets/fonts/04B_03.ttf";
  public static inline var FONT_LATO_BOLD:String = "assets/fonts/Lato-Bold.ttf";
  public static inline var FONT_LATO_LIGHT:String = "assets/fonts/Lato-Light.ttf";

	public static inline var COLOR_WHITE:Int = 	0xFFFFFF;
	public static inline var COLOR_LIGHT:Int = 	0xDCDCDC;
	public static inline var COLOR_BLACK:Int = 	0x000000;
	public static inline var COLOR_DARK:Int = 	0x242424;
	public static inline var COLOR_ORANGE:Int = 0xffb500;
	public static inline var COLOR_RED:Int = 	0xcf2d00;
	public static inline var COLOR_GREEN:Int = 	0x98ca00;

	///////////////////////////////////////////////////////////////////////////
	// atlasIcon REGIONS

	public static inline var ICON_POINTER = 'pointer.png';
	public static inline var ICON_DELETE = 'delete.png';
	public static inline var ICON_EYE_OPEN = 'eye_open.png';
	public static inline var ICON_EYE_CLOSED = 'eye_closed.png';
	public static inline var ICON_LOCK_OPEN = 'lock_open.png';
	public static inline var ICON_LOCK_CLOSED = 'lock_closed.png';

	public static inline var ICON_CHECKBOX = 'checkbox.png';
	public static inline var ICON_CHECKBOX_CHECKED = 'checkbox_checked.png';

	public static inline var ICON_NEW = 'new.png';
	public static inline var ICON_OPEN = 'open.png';
	public static inline var ICON_SAVE = 'save.png';
	public static inline var ICON_QUIT = 'quit.png';
	public static inline var ICON_RENDER = 'render.png';

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

	public static function makeColorIcon(size:Int,color:Int):BitmapData {
		var span = 2;
		var round = 8;
		var hole = false;
		if (color==-1) {
			hole = true;
			span += 1;
			color = 0x2a8299;
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

		PLIK.preloadFont(APP.FONT_SQUARE);
    PLIK.preloadFont(APP.FONT_04B_03);
		PLIK.preloadFont(APP.FONT_LATO_LIGHT);
		PLIK.preloadFont(APP.FONT_LATO_BOLD);

		if (APP.atlasSprites==null) APP.atlasSprites = Gfx.getTextureAtlas('sprites.xml');

	}

}
