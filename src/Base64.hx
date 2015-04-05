package;
using StringTools;

class Base64 {


	private static inline var ALPHABET_URL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  private static inline var PAD_CHAR_URL = '.';
	private static inline var ALPHABET_REG = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	private static inline var PAD_CHAR_REG = '=';

	public static function encodeBase64(bytes:Array<Int>, ?urlSafe:Bool=false):String{
		// used 4 base64 chars (24 bits) to encode 3 bytes (24 bits)
		var alpha:String = (urlSafe?ALPHABET_URL:ALPHABET_REG);
		var pad:String = (urlSafe?PAD_CHAR_URL:PAD_CHAR_REG);

		var dest:StringBuf = new StringBuf();//StringTools.lpad("","A",Std.int(((bytes.length + 2)/3)*4));// = new byte[((bytes.length + 2)/3)*4];
    var s:Int = 0;
    var d:Int = 0;
		do {
			var size:Int = Std.int(Math.min(bytes.length - s, 3));
			if(size == 3){
				encodeBlockA(bytes[s]&0xFF, bytes[s+1]&0xFF, bytes[s+2]&0xFF, dest, d, alpha);
			} else if (size == 2){
				encodeBlockB(bytes[s]&0xFF, bytes[s+1]&0xFF, dest, d, alpha, pad);
			} else {
				encodeBlockC(bytes[s]&0xFF, dest, d, alpha, pad);
			}
      s+=3;
      d+=4;
		} while(s<bytes.length);
		return dest.toString();
	}

	public static function decodeBase64(src:String):Array<Int>{
		if(src == "" || src.length%4 != 0){
			return null;
		}

		var len:Int = Std.int((src.length/4)*3);
		var last:Int = src.length-1;
		while (src.charAt(last) == PAD_CHAR_URL || src.charAt(last) == PAD_CHAR_REG){
			last--;
			len--;
		}
		var dest:Array<Int> = new Array<Int>();
    var s:Int = 0;
    var d:Int = 0;
		do{
			var size:Int = Std.int(Math.min(last+1 - s, 4));
			var a:Int = decodeChar(src.charCodeAt(s));
			var b:Int = decodeChar(src.charCodeAt(s+1));
			if(size == 4){
				decodeBlockA(a, b, decodeChar(src.charCodeAt(s+2)), decodeChar(src.charCodeAt(s+3)), dest, d);
			} else if (size == 3){
				decodeBlockB(a, b, decodeChar(src.charCodeAt(s+2)), dest, d);
			} else {
				decodeBlockC(a, b, dest, d);
			}
      s+=4;
      d+=3;
		} while (s<src.length);
		return dest;
	}


	private static function decodeChar(c:Int):Int{
		if (c >= 65 && c <= 90){
			return c - 65;
		} else if (c >= 97 && c <= 122){
			return c - 71;
		} else if (c >= 48 && c <= 57){
			return c + 4;
		} else if (c == '-'.charCodeAt(0)){
			return 62;
		} else if (c == '_'.charCodeAt(0)){
			return 63;
		} else {
			return -1;
		}
	}

	private static function encodeBlockA(a:Int, b:Int, c:Int, dest:StringBuf, offset:Int, alpha:String){
		dest.addChar((alpha.charCodeAt(a>>2)));
		dest.addChar((alpha.charCodeAt(((a<<4)&0x30) | (b >> 4))));
		dest.addChar((alpha.charCodeAt(((b<<2)&0x3C) | (c >> 6))));
		dest.addChar((alpha.charCodeAt(c&0x3F)));
	}

	private static function encodeBlockB(a:Int, b:Int, dest:StringBuf, offset:Int, alpha:String, pad:String){
		dest.addChar((alpha.charCodeAt(a>>2)));
		dest.addChar((alpha.charCodeAt(((a<<4)&0x30) | (b >> 4))));
		dest.addChar((alpha.charCodeAt((b<<2)&0x3C)));
		dest.addChar(pad.charCodeAt(0));
	}

	private static function encodeBlockC(a:Int,dest:StringBuf, offset:Int, alpha:String, pad:String){
		dest.addChar((alpha.charCodeAt(a>>2)));
		dest.addChar((alpha.charCodeAt((a<<4)&0x30)));
		dest.addChar(pad.charCodeAt(0));
		dest.addChar(pad.charCodeAt(0));
	}

	private static function decodeBlockA(a:Int, b:Int, c:Int, d:Int, dest:Array<Int>, offset:Int){
		dest.push(((a<<2) | (b>>4)));
		dest.push((((b&0xF)<<4) | (c>>2)));
		dest.push((((c&0x3)<<6) | d));
	}

	private static function decodeBlockB(a:Int, b:Int, c:Int, dest:Array<Int>, offset:Int){
		dest.push(((a<<2) | (b>>4)));
		dest.push((((b&0xF)<<4) | (c>>2)));
	}

	private static function decodeBlockC(a:Int, b:Int, dest:Array<Int>, offset:Int){
		dest.push(((a<<2) | (b>>4)));
	}

}
