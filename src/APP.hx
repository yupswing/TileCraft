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
import haxe.Timer;
class APP
{

	///////////////////////////////////////////////////////////////////////////
	// Game Info

	public static inline var APP_NAME = "TileCraft" ;
	public static inline var APP_PACKAGE = "com.akifox.tilecraft" ;
	public static inline var APP_BUILD = CompileTime.readFile("Export/.build");
	public static inline var APP_BUILD_DATE = CompileTime.buildDateString();
	public static inline var APP_VERSION = "0.2.0"; //TODEPLOY
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
  public static inline var FONT_04B_03:String = "assets/fonts/Square.ttf";

	public static inline var COLOR_WHITE:Int = 	0xFFFFFF;
	public static inline var COLOR_LIGHT:Int = 	0xDCDCDC;
	public static inline var COLOR_BLACK:Int = 	0x000000;
	public static inline var COLOR_DARK:Int = 	0x242424;
	public static inline var COLOR_ORANGE:Int = 0xffb500;
	public static inline var COLOR_RED:Int = 	0xcf2d00;
	public static inline var COLOR_GREEN:Int = 	0x98ca00;

	///////////////////////////////////////////////////////////////////////////
	// atlasIcon REGIONS

	public static inline var ICON_POIntER = 'poInter.png';
	public static inline var ICON_DELETE = 'delete.png';
	public static inline var ICON_EYE_OPEN = 'eye_open.png';
	public static inline var ICON_EYE_CLOSED = 'eye_closed.png';
	public static inline var ICON_LOCK_OPEN = 'lock_open.png';
	public static inline var ICON_LOCK_CLOSED = 'lock_closed.png';
	public static inline var ICON_ROUND1 = 'round_01.png';
	public static inline var ICON_ROUND2 = 'round_02.png';
	public static inline var ICON_ROUND3 = 'round_03.png';
	public static inline var ICON_ROUND4 = 'round_04.png';
	public static inline var ICON_SHAPE0 = 'shape0.png';
	public static inline var ICON_SHAPE0_OUTLINE = 'shape0_outline.png';
	public static inline var ICON_SHAPE1 = 'shape1.png';
	public static inline var ICON_SHAPE1_OUTLINE = 'shape1_outline.png';
	public static inline var ICON_SHAPE2 = 'shape2.png';
	public static inline var ICON_SHAPE2_OUTLINE = 'shape2_outline.png';
	public static inline var ICON_SHAPE3 = 'shape3.png';
	public static inline var ICON_SHAPE3_OUTLINE = 'shape3_outline.png';
	public static inline var ICON_SHAPE4 = 'shape4.png';
	public static inline var ICON_SHAPE4_OUTLINE = 'shape4_outline.png';
	public static inline var ICON_SHAPE5 = 'shape5.png';
	public static inline var ICON_SHAPE5_OUTLINE = 'shape5_outline.png';
	public static inline var ICON_SHAPE6 = 'shape6.png';
	public static inline var ICON_SHAPE6_OUTLINE = 'shape6_outline.png';
	public static inline var ICON_SHAPE7 = 'shape7.png';
	public static inline var ICON_SHAPE7_OUTLINE = 'shape7_outline.png';
	public static inline var ICON_SHAPE8 = 'shape8.png';
	public static inline var ICON_SHAPE8_OUTLINE = 'shape8_outline.png';
	public static inline var ICON_SHAPE9 = 'shape9.png';
	public static inline var ICON_SHAPE9_OUTLINE = 'shape9_outline.png';
	public static inline var ICON_SHAPE10 = 'shape10.png';
	public static inline var ICON_SHAPE10_OUTLINE = 'shape10_outline.png';
	public static inline var ICON_SHAPE11 = 'shape11.png';
	public static inline var ICON_SHAPE11_OUTLINE = 'shape11_outline.png';
	public static inline var ICON_SHAPE12 = 'shape12.png';
	public static inline var ICON_SHAPE12_OUTLINE = 'shape12_outline.png';

	///////////////////////////////////////////////////////////////////////////
	// MEMORY MANAGEMENT

	public static function preloadAssets():Void {

		PLIK.preloadFont(APP.FONT_SQUARE);
    PLIK.preloadFont(APP.FONT_04B_03);

		if (APP.atlasSprites==null) APP.atlasSprites = Gfx.getTextureAtlas('sprites.xml');

	}

}
