package;
import com.akifox.plik.*;
import com.akifox.plik.gui.*;
import com.akifox.plik.atlas.*;
import openfl.display.BitmapData;
using hxColorToolkit.ColorToolkit;
import com.akifox.asynchttp.*;


class APP {


	public static inline function log(string:String) {
		//trace('>>> $string');
	}

	public static inline function error(string:String) {
		trace('!!! $string');
	}

  public static inline var APP_NAME = "TileCraft" ;
  public static inline var APP_PACKAGE = "com.akifox.tilecraft" ;
  public static inline var APP_BUILD = CompileTime.readFile("Export/.build");
  public static inline var APP_BUILD_DATE = CompileTime.buildDateString();
  public static inline var APP_VERSION = "1.0.0-alpha8dev"; //TODEPLOY
  public static inline var APP_STAGE = "alpha8 dev"; //TODEPLOY
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

	public static inline var DELAY = 0.01;
	private static var _lastDelay:Float = 0;

	public static function isDelayLocked():Bool {
		return haxe.Timer.stamp()-_lastDelay<APP.DELAY;
	}

	public static function updateDelay() {
		_lastDelay = haxe.Timer.stamp();
	}

  //////////////////////////////////////////////////////////////////////////////
  // Atlases (faster retrive than asking to cache system)

  public static var atlasSPRITES:TextureAtlas=null;

  //////////////////////////////////////////////////////////////////////////////
  // URLs and FILEs

	private static inline var URL_SERVICE_VERSION = "http://akifox.com/tilecraft/service/version/";
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
  public static inline var ICON_OPEN = 'open.png';
  public static inline var ICON_DELETE = 'delete.png';
  public static inline var ICON_OK = 'ok.png';
  public static inline var ICON_SAVE = 'save.png';
  public static inline var ICON_QUIT = 'quit.png';
  public static inline var ICON_RENDER = 'render.png';
  public static inline var ICON_CLOSE = 'close.png';
  public static inline var ICON_PALETTE = 'palette.png';
  public static inline var ICON_BASE64_INPUT= 'base64_input.png';
  public static inline var ICON_BASE64_OUTPUT = 'base64_output.png';

  public static inline var ICON_RESIZE = 'resize.png';
  public static inline var ICON_OUTLINE = 'outline.png';
  public static inline var ICON_OUTLINE_NO = 'outline_no.png';

  public static inline var ICON_ROUND0 = 'round_0.png';
  public static inline var ICON_ROUND1 = 'round_1.png';
  public static inline var ICON_ROUND2 = 'round_2.png';
  public static inline var ICON_ROUND3 = 'round_3.png';

  public static inline var ICON_NEW_SHAPE = 'new_shape.png';
  public static inline var ICON_COPY_SHAPE = 'copy_shape.png';

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
  // 'font_name':'"+com.akifox.plik.PLIK.getFont(APP.FONT_SQUARE).fontName+"'',
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

    PLIK.preloadFont(APP.FONT_SQUARE);
    PLIK.preloadFont(APP.FONT_04B_03);
    PLIK.preloadFont(APP.FONT_LATO_LIGHT);
    PLIK.preloadFont(APP.FONT_LATO_BOLD);

    if (APP.atlasSPRITES==null) APP.atlasSPRITES = Gfx.getTextureAtlas('sprites.xml');

  }

	#if app_checkupdates
	public static var onlineVersion:String = APP_VERSION;

	public static function checkVersion(callback:Void->Void) {

		var apiURL = URL_SERVICE_VERSION;

		var request = new AsyncHttpRequest(apiURL + "?v=" + APP_VERSION,
			function(response:AsyncHttpResponse) {
				if (!response.isOK) return;

				var json:Dynamic = response.toJson();
		    	if (json == null || Std.int(json.e) > 0) return;

					APP.onlineVersion = Std.string(json.c.version);
		    	if (APP.onlineVersion != APP_VERSION) callback();

			});

		request.send(); //async send

	}
	#end // app_checkupdates
}
