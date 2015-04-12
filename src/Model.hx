package ;

import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.BytesBuffer;

using StringTools;

import Shape;

class Model {

	//============================================================================

	private static inline var MAX_SHAPES = 32;
	public static inline var MODEL_SIZE = 16;

	private static inline var COLOR_COUNT = 16;
	public static var DEFAULT_PALETTE:Array<Int> = [
		0xFFd5f6ff, // original hole color
		//0xFFFF0000, // TODO change this as new hole color
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

	//============================================================================

	private var shapes:Array<Shape>;
	private var colors:Array<Int>;

	public function new(colors:Array<Int>){
		this.colors = colors.copy();
		this.shapes = new Array<Shape>();
	}

	public function getSize():Int {
		return MODEL_SIZE;
	}

	public function getShapeCount():Int{
		return shapes.length;
	}

	public function getIndexOfShape(shape:Shape):Int{
		return shapes.indexOf(shape);
	}

	public function addShape(shape:Shape){
		if(shapes.length < MAX_SHAPES){
			shapes.push(shape);
		}
	}

	public function addShapeAtIndex(index:Int, shape:Shape){ //toedit
		shapes.insert(index, shape);
	}

	public function getShapeByIndex(index:Int):Shape {
		return shapes[index];
	}

	public function removeShape(shape:Shape):Shape {
    return removeShapeByIndex(getIndexOfShape(shape));
	}

	public function removeShapeByIndex(index:Int):Shape {
		if (index<-1) return null;
    var shape = shapes[index];
		shapes.remove(shape);
    return shape;
	}

	public function getLastShape():Shape {
		return shapes[shapes.length-1];
	}

	//============================================================================

	public function getColor(index:Int):Int {
		return colors[index]&0xFFFFFF;
	}

	public function getPalette():Array<Int> {
		return colors;
	}

	public function setColor(index:Int, rgb:Int) {
		//colors[index] = ~(0xFFFFFF^rgb);
		colors[index] = rgb|0xFF000000; //this two lines are equivalent
	}

	public function destroy() {
		//TODO unload everything possible
	}

	//============================================================================

	public static function makeNew():Model {
		return new Model(DEFAULT_PALETTE);
	}

	//============================================================================
	// BYTES I/O

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

	public static function fromBytes(bytes:Bytes):Model{
		if(bytes == null || bytes.length < 3){
			return null;
		}
		var shapeCount:Int = bytes.get(0)&0xFF;
		var colorMask:Int = ((bytes.get(1)&0xFF) << 8) | (bytes.get(2)&0xFF);
		var model:Model = new Model(DEFAULT_PALETTE);
		var pos:Int = 3;
    for(i in 0...COLOR_COUNT){
			if(bitSet(colorMask,i)){
				var col:Int = 0xFF000000;
				col |= ((bytes.get(pos++)&0xFF)<<16);
				col |= ((bytes.get(pos++)&0xFF)<<8);
				col |= ((bytes.get(pos++)&0xFF));
				model.setColor(i, col);
			}
		}

		for(i in 0...shapeCount){
			var typeCol:Int = bytes.get(pos++)&0xFF;
			var s:Shape = new Shape(Type.createEnumIndex(ShapeType,typeCol>>4));
			s.setColor(typeCol&0xF);
			var x:Int = bytes.get(pos++)&0xFF;
			var y:Int = bytes.get(pos++)&0xFF;
			var z:Int = bytes.get(pos++)&0xFF;
			s.setBoundsX(x>>4, (x&0xF) + 1);
			s.setBoundsY(y>>4, (y&0xF) + 1);
			s.setBoundsZ(z>>4, (z&0xF) + 1);
			model.addShape(s);
		}
		return model;
	}

	public function toBytes():Bytes{
		var shapeCount:Int = this.getShapeCount();
		// 2 bytes color map, 15 colors (3 bytes), 1 shape:byte count, (1 type:byte + color, 3 bytes dimensions)
		var newColorMask:Int = 0;
		for(i in 0...COLOR_COUNT){
			var color:Int = this.getColor(i);
			if(color != DEFAULT_PALETTE[i]){
				newColorMask |= (1<<i);
			}
		}
		var newColors:Int = countBits(newColorMask);

		//LENGTH = 3 + newColors*3 + 4*shapeCount;
		var bytesBuffer = new BytesBuffer();

		bytesBuffer.addByte(shapeCount);
		bytesBuffer.addByte(newColorMask>>8);
		bytesBuffer.addByte(newColorMask&0xFF);

		var pos:Int = 3;
		for(i in 0...COLOR_COUNT){
			if(bitSet(newColorMask,i)){
				var c:Int = this.getColor(i);
				bytesBuffer.addByte((c >> 16)&0xFF);
				bytesBuffer.addByte((c >> 8)&0xFF);
				bytesBuffer.addByte(c&0xFF);
			}
		}
		for(i in 0...shapeCount){
			var s:Shape = this.getShapeByIndex(i);
			bytesBuffer.addByte((Type.enumIndex(s.getShapeType())<<4) | s.getColor());
			bytesBuffer.addByte((s.getX1()<<4) | (s.getX2()-1));
			bytesBuffer.addByte((s.getY1()<<4) | (s.getY2()-1));
			bytesBuffer.addByte((s.getZ1()<<4) | (s.getZ2()-1));
		}
		return bytesBuffer.getBytes();

	}

	//============================================================================
	// STRING I/O

	public static var BASE64_URLFRIENDLY_REPLACE = [['=','.'],['+','-'],['/','_']];

	public static function fromString(base64model:String):Model {

		// (Possibles) URL-friendly chars replaced with standard ones
		for (el in BASE64_URLFRIENDLY_REPLACE) base64model = base64model.replace(el[1],el[0]);

		var model:Model=null;
		try {
			// decode the base64 string to bytes and feed fromBytes
			// to fetch the Model instance
			model = Model.fromBytes(haxe.crypto.Base64.decode(base64model));
		} catch (e:Dynamic){
			// malformed string or other input errors
			TileCraft.error('ERROR Decoding Base64: $e');
		}

		//#if debug //TODO debug only
		var reencoded = model.toString();
		TileCraft.logger('-- > LOAD MODEL < ------------------------------------------------');
		TileCraft.logger('Base64 Model IN:  ' + base64model);
		TileCraft.logger('Base64 Model OUT: ' + reencoded);
		TileCraft.logger((base64model==reencoded?"> TEST PASSED":"> TEST FAILED   *!*!*!* WARNING *!*!*!*"));
		TileCraft.logger('------------------------------------------------------------------');
		//#end

		return model;
	}

	public function toString(?urlEncode=false):String {

		// get the Model instance in bytes representation
		// and encode those bytes in Base64
		var base64model = haxe.crypto.Base64.encode(this.toBytes());

		if (urlEncode) {
			// Replace standard Base64 chars with URL-friendly ones
			// The fromString(string) supports boths inputs (URL-friendly + standard)
			for (el in BASE64_URLFRIENDLY_REPLACE) base64model = base64model.replace(el[0],el[1]);
		}
		return base64model;
	}

	public function toPNGString(bitmapData:openfl.display.BitmapData):String {
		var bytesOutput:BytesOutput = new BytesOutput();
		bytesOutput = cast(this.toPNG(bytesOutput,bitmapData),BytesOutput);

		if (bytesOutput==null) return "";
		return "data:image/png;base64,"+haxe.crypto.Base64.encode(bytesOutput.getBytes());
	}

	//============================================================================
	// PNG I/O
	// Image file (final output) & model data included in a private chunk

	private static inline var PNG_TILECRAFT_CHUNK = "tcMa";

	public static function fromPNG(input:Input):Model {
		if (input==null) return null;
		var isValid:Bool = false;
		var bytes:Bytes = null;
		try {
			// Read the file
			var data = new format.png.Reader(input).read();

			// cycle the chunks to find the TileCraft chunk 'tcMa'
			for (chunk in data) {
				switch(chunk) {
				case CUnknown(id,data):
					if (id==PNG_TILECRAFT_CHUNK) {
						// Found the chunk:
						// Get the Model data from the chunk data
						bytes = data;
						isValid = true;
					}
				default:
				}
			}
		}catch(e:Dynamic) {
			// read error
			TileCraft.error('Unable to import model from PNG: $e');
			if (input!=null) input.close();
			input = null;
			return null;
		}

		// Chunk not found: there was no private TileCraft chunk
		if (!isValid) {
			TileCraft.error('Unable to import model from PNG: No TileCraft chunk in PNG');
			return null;
		}

		// create a model from model bytes data
		return Model.fromBytes(bytes);

	}

	public function toPNG(output:Output,bitmapData:openfl.display.BitmapData):Output {
		if (output==null || bitmapData==null) return null;

		// encode the bitmapData to PNG format
		#if (v2 && !flash)
									 // openfl.utils.ByteArray to Bytes (thru String)
		var pngBytes = Bytes.ofString(bitmapData.encode("png", 1).toString());
		#else
		var pngBytes = Bytes.ofString(bitmapData.encode(new openfl.geom.Rectangle(0,0,bitmapData.width,bitmapData.height),
																										new openfl.display.PNGEncoderOptions(),
																										new openfl.utils.ByteArray()).toString());
		#end

		/* Add a chunk before the end
		   CHUNK ID is "tcMa" ('tc' TileCraft (Ancillary, Private) + 'M' Model + 'a' Model Version (Safe to copy)
		   CHUNK DATA is the model data ( got from model.toBytes() ) */
		var pngData = new format.png.Reader(new BytesInput(pngBytes)).read();
		var end = pngData.last();
		//remove the IEND chunk (last chunk)
		pngData.remove(end);
		// insert the private chunk 'tcMa' with the model data (at the end)
		pngData.add(format.png.Data.Chunk.CUnknown(PNG_TILECRAFT_CHUNK,this.toBytes()));
		// add the IEND chunk (at the end)
		pngData.add(end);
		end = null;

		try {
			// write the png to a haxe.io.Output
			new format.png.Writer(output).write(pngData);

		} catch (e:Dynamic) {
			// write error
			TileCraft.error("Unable to export model to PNG: $e");
			if (output!=null) output.close();
			output = null;
		}
		return output;
	}

}
