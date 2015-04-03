package nz.co.angryoctopus.lgmodeler;

public class Base64 {

	private static final byte PAD_CHAR_URL = '.';
	private static final byte PAD_CHAR_REG = '=';

	private final static byte[] ALPHABET_URL = {
	    (byte)'A', (byte)'B', (byte)'C', (byte)'D', (byte)'E', (byte)'F', (byte)'G',
	    (byte)'H', (byte)'I', (byte)'J', (byte)'K', (byte)'L', (byte)'M', (byte)'N',
	    (byte)'O', (byte)'P', (byte)'Q', (byte)'R', (byte)'S', (byte)'T', (byte)'U', 
	    (byte)'V', (byte)'W', (byte)'X', (byte)'Y', (byte)'Z',
	    (byte)'a', (byte)'b', (byte)'c', (byte)'d', (byte)'e', (byte)'f', (byte)'g',
	    (byte)'h', (byte)'i', (byte)'j', (byte)'k', (byte)'l', (byte)'m', (byte)'n',
	    (byte)'o', (byte)'p', (byte)'q', (byte)'r', (byte)'s', (byte)'t', (byte)'u', 
	    (byte)'v', (byte)'w', (byte)'x', (byte)'y', (byte)'z',
	    (byte)'0', (byte)'1', (byte)'2', (byte)'3', (byte)'4', (byte)'5', 
	    (byte)'6', (byte)'7', (byte)'8', (byte)'9', (byte)'-', (byte)'_'
	  };
	
	private final static byte[] ALPHABET_REG = {
	    (byte)'A', (byte)'B', (byte)'C', (byte)'D', (byte)'E', (byte)'F', (byte)'G',
	    (byte)'H', (byte)'I', (byte)'J', (byte)'K', (byte)'L', (byte)'M', (byte)'N',
	    (byte)'O', (byte)'P', (byte)'Q', (byte)'R', (byte)'S', (byte)'T', (byte)'U', 
	    (byte)'V', (byte)'W', (byte)'X', (byte)'Y', (byte)'Z',
	    (byte)'a', (byte)'b', (byte)'c', (byte)'d', (byte)'e', (byte)'f', (byte)'g',
	    (byte)'h', (byte)'i', (byte)'j', (byte)'k', (byte)'l', (byte)'m', (byte)'n',
	    (byte)'o', (byte)'p', (byte)'q', (byte)'r', (byte)'s', (byte)'t', (byte)'u', 
	    (byte)'v', (byte)'w', (byte)'x', (byte)'y', (byte)'z',
	    (byte)'0', (byte)'1', (byte)'2', (byte)'3', (byte)'4', (byte)'5', 
	    (byte)'6', (byte)'7', (byte)'8', (byte)'9', (byte)'+', (byte)'/'
	  };


	
	public static String encodeBase64(byte[] bytes, boolean urlSafe){
		// used 4 base64 chars (24 bits) to encode 3 bytes (24 bits)
		byte[] alpha = urlSafe?ALPHABET_URL:ALPHABET_REG;
		byte pad = urlSafe?PAD_CHAR_URL:PAD_CHAR_REG;
		byte[] dest = new byte[((bytes.length + 2)/3)*4];
		for(int s = 0, d = 0; s < bytes.length; s+=3, d+=4){
			int size = Math.min(bytes.length - s, 3);
			if(size == 3){
				encodeBlock(bytes[s]&0xFF, bytes[s+1]&0xFF, bytes[s+2]&0xFF, dest, d, alpha);
			} else if (size == 2){
				encodeBlock(bytes[s]&0xFF, bytes[s+1]&0xFF, dest, d, alpha, pad);
			} else {
				encodeBlock(bytes[s]&0xFF, dest, d, alpha, pad);
			}
		}
		return new String(dest);
	}
	
	public static byte[] decodeBase64(String src){
		if(src.isEmpty() || src.length()%4 != 0){
			return null;
		}
		
		int len = (src.length()/4)*3;
		int last = src.length()-1;
		while (src.charAt(last) == PAD_CHAR_URL || src.charAt(last) == PAD_CHAR_REG){
			last--;
			len--;
		}
		byte[] dest = new byte[len];
		for(int s = 0, d = 0; s < src.length(); s += 4, d += 3){
			int size = Math.min(last+1 - s, 4);
			int a = decodeChar(src.charAt(s));
			int b = decodeChar(src.charAt(s+1));
			if(size == 4){
				decodeBlock(a, b, decodeChar(src.charAt(s+2)), decodeChar(src.charAt(s+3)), dest, d);
			} else if (size == 3){
				decodeBlock(a, b, decodeChar(src.charAt(s+2)), dest, d);
			} else {
				decodeBlock(a, b, dest, d);
			}
		}
		return dest;
	}
	
	
	private static int decodeChar(char c){
		if (c >= 65 && c <= 90){
			return c - 65;
		} else if (c >= 97 && c <= 122){
			return c - 71;
		} else if (c >= 48 && c <= 57){
			return c + 4;
		} else if (c == '-'){
			return 62;
		} else if (c == '_'){
			return 63;
		} else {
			return -1;
		}
	}
	
	private static void encodeBlock(int a, int b, int c, byte[] dest, int offset, byte[] alpha){
		dest[offset] = (alpha[a>>2]);
		dest[offset + 1] = (alpha[((a<<4)&0x30) | (b >> 4)]);
		dest[offset + 2] = (alpha[((b<<2)&0x3C) | (c >> 6)]);
		dest[offset + 3] = (alpha[c&0x3F]);
	}
	
	private static void encodeBlock(int a, int b, byte[] dest, int offset, byte[] alpha, byte pad){
		dest[offset] = (alpha[a>>2]);
		dest[offset + 1] = (alpha[((a<<4)&0x30) | (b >> 4)]);
		dest[offset + 2] = (alpha[(b<<2)&0x3C]);
		dest[offset + 3] = pad;
	}

	private static void encodeBlock(int a,byte[] dest, int offset, byte[] alpha, byte pad){
		dest[offset] = (alpha[a>>2]);
		dest[offset + 1] = (alpha[(a<<4)&30]);
		dest[offset + 2] = pad;
		dest[offset + 3] = pad;
	}

	private static void decodeBlock(int a, int b, int c, int d, byte[] dest, int offset){
		dest[offset] = (byte)((a<<2) | (b>>4));
		dest[offset+1] = (byte)(((b&0xF)<<4) | (c>>2));
		dest[offset+2] = (byte)(((c&0x3)<<6) | d);
	}

	private static void decodeBlock(int a, int b, int c, byte[] dest, int offset){
		dest[offset] = (byte)((a<<2) | (b>>4));
		dest[offset+1] = (byte)(((b&0xF)<<4) | (c>>2));
	}

	private static void decodeBlock(int a, int b, byte[] dest, int offset){
		dest[offset] = (byte)((a<<2) | (b>>4));
	}
	
}
