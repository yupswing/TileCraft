package;

import Shape;

class ModelIO {

	private static inline var COLOR_COUNT = 16;
	public static var DEFAULT_PALETTE:Array<Int> = [
		//0xFFd5f6ff, // original hole color
		0xFFFF0000, // new hole color
		0xFF4045BB,
		0xFF3EA5F2,
		0xFFB3DBEE,
		0xFF24323F,
		0xFF395257,
		0xFF529023,
		0xFFA6CC33,
		0xFF514635,
		0xFFA7702D,
		0xFFEA903E,
		0xFFF7E176,
		0xFFBE3241,
		0xFFDF7A92,
		0xFF7e868f,
		0xFFa6b3bc,
	];

	private static function countBits(mask:Int):Int{
		var count:Int = 0;
		for(i in 0...COLOR_COUNT){
			count += ((mask>>i)&0x1);
		}
		return count;
	}

	private static function bitSet(mask:Int, index:Int):Bool{
		return ((mask>>index)&1) == 1;
	}

	public static function loadModel(src:Array<Int>):Model{
		if(src == null || src.length < 3){
			return null;
		}
		var shapeCount:Int = src[0]&0xFF;
		var colorMask:Int = ((src[1]&0xFF) << 8) | (src[2]&0xFF);
		var m:Model = new Model(DEFAULT_PALETTE);
		var pos:Int = 3;
    for(i in 0...COLOR_COUNT){
			if(bitSet(colorMask,i)){
				var col:Int = 0xFF000000;
				col |= ((src[pos++]&0xFF)<<16);
				col |= ((src[pos++]&0xFF)<<8);
				col |= ((src[pos++]&0xFF));
				m.setColor(i, col);
			}
		}

		for(i in 0...shapeCount){
			var typeCol:Int = src[pos++]&0xFF;
			var s:Shape = new Shape(Type.createEnumIndex(Kind,typeCol>>4));
			s.setColor(typeCol&0xF);
			var x:Int = src[pos++]&0xFF;
			var y:Int = src[pos++]&0xFF;
			var z:Int = src[pos++]&0xFF;
			s.setBoundsX(x>>4, (x&0xF) + 1);
			s.setBoundsY(y>>4, (y&0xF) + 1);
			s.setBoundsZ(z>>4, (z&0xF) + 1);
			m.addShape(s);
		}
		return m;
	}

	public static function saveModel(model:Model):Array<Int>{
		var shapeCount:Int = model.getShapeCount();
		// 2 bytes color map, 15 colors (3 bytes), 1 shape:byte count, (1 type:byte + color, 3 bytes dimensions)
		var newColorMask:Int = 0;
		for(i in 0...COLOR_COUNT){
			var color:Int = model.getColor(i);
			if(color != DEFAULT_PALETTE[i]){
				newColorMask |= (1<<i);
			}
		}
		var newColors:Int = countBits(newColorMask);

    var bin:Array<Int> = [for (i in 0...3 + newColors*3 + 4*shapeCount) i];
		bin[0] = shapeCount;
		bin[1] = (newColorMask>>8);
		bin[2] = (newColorMask&0xFF);

		var pos:Int = 3;
		for(i in 0...COLOR_COUNT){
			if(bitSet(newColorMask,i)){
				var c:Int = model.getColor(i);
				bin[pos++] = ((c >> 16)&0xFF);
				bin[pos++] = ((c >> 8)&0xFF);
				bin[pos++] = (c&0xFF);
			}
		}
		for(i in 0...shapeCount){
			var s:Shape = model.getShape(i);
			bin[pos++] = ((Type.enumIndex(s.getKind())<<4) | s.getColor());
			bin[pos++] = ((s.getX1()<<4) | (s.getX2()-1));
			bin[pos++] = ((s.getY1()<<4) | (s.getY2()-1));
			bin[pos++] = ((s.getZ1()<<4) | (s.getZ2()-1));
		}
		return bin;

	}

}
