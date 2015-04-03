package nz.co.angryoctopus.lgmodeler;

public class ModelIO {
	
	private static final int COLOR_COUNT = 16;
	public static final int[] DEFAULT_PALETTE = new int[]{
		0xFFd5f6ff,//
		0xFF4045BB,//
		0xFF3EA5F2,//
		0xFFB3DBEE,//
		0xFF24323F,//
		0xFF395257,//
		0xFF529023,//
		0xFFA6CC33,//
		0xFF514635,//
		0xFFA7702D,//
		0xFFEA903E,//
		0xFFF7E176,//
		0xFFBE3241,//
		0xFFDF7A92,//
		0xFF7e868f,
		0xFFa6b3bc,
	};
	
	private static int countBits(int mask){
		int count = 0;
		for(int i = 0; i < COLOR_COUNT; i++){
			count += ((mask>>i)&0x1);
		}
		return count;
	}
	
	private static boolean bitSet(int mask, int index){
		return ((mask>>index)&1) == 1;
	}

	public static Model loadModel(byte[] src) {
		if(src == null || src.length < 3){
			return null;
		}
		int shapeCount = src[0]&0xFF;
		int colorMask = ((src[1]&0xFF) << 8) | (src[2]&0xFF);
		Model m = new Model(DEFAULT_PALETTE);
		int pos = 3;
		for(int i = 0; i < COLOR_COUNT; i++){
			if(bitSet(colorMask,i)){
				int col = 0xFF000000;
				col |= ((src[pos++]&0xFF)<<16);
				col |= ((src[pos++]&0xFF)<<8);
				col |= ((src[pos++]&0xFF));
				m.setColor(i, col);
			}
		}
		
		Shape.Type[] types = Shape.Type.values();
		for(int i = 0; i < shapeCount; i++){
			int typeCol = src[pos++]&0xFF;
			Shape.Type type = types[typeCol>>4];
			Shape s = new Shape(type);
			s.setColor(typeCol&0xF);
			int x = src[pos++]&0xFF;
			int y = src[pos++]&0xFF;
			int z = src[pos++]&0xFF;
			s.setBoundsX(x>>4, (x&0xF) + 1);
			s.setBoundsY(y>>4, (y&0xF) + 1);
			s.setBoundsZ(z>>4, (z&0xF) + 1);
			m.addShape(s);
		}
		return m;
	}
	
	public static byte[] saveModel(Model model){
		int shapeCount = model.getShapeCount();
		// 2 bytes color map, 15 colors (3 bytes), 1 byte shape count, (1 byte type + color, 3 bytes dimensions)
		int newColorMask = 0;
		for(int i = 0; i < COLOR_COUNT; i++){
			int color = model.getColor(i);
			if(color != DEFAULT_PALETTE[i]){
				newColorMask |= (1<<i);
			}
		}
		int newColors = countBits(newColorMask);
		
		byte[] bin = new byte[3 + newColors*3 + 4*shapeCount];
		bin[0] = (byte)shapeCount;
		bin[1] = (byte)(newColorMask>>8);
		bin[2] = (byte)(newColorMask&0xFF);

		int pos = 3;
		for(int i = 0; i < COLOR_COUNT; i++){
			if(bitSet(newColorMask,i)){
				int c = model.getColor(i);
				bin[pos++] = (byte)((c >> 16)&0xFF);
				bin[pos++] = (byte)((c >> 8)&0xFF);
				bin[pos++] = (byte)(c&0xFF);
			}
		}
		for(int i = 0; i < shapeCount; i++){
			Shape s = model.getShape(i);
			bin[pos++] = (byte)((s.getType().ordinal()<<4) | s.getColor());
			bin[pos++] = (byte)((s.getX1()<<4) | (s.getX2()-1));
			bin[pos++] = (byte)((s.getY1()<<4) | (s.getY2()-1));
			bin[pos++] = (byte)((s.getZ1()<<4) | (s.getZ2()-1));
		}
		return bin;

	}

}
