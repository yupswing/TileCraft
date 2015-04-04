package ;

class Model {

	private static inline var MAX_SHAPES = 32;
	public static inline var MODEL_SIZE = 16;

	private var shapes:Array<Shape>;
	private var colors:Array<UInt>;

	public function new(colors:Array<UInt>){
		this.colors = colors.copy();
		this.shapes = new Array<Shape>();
	}

	public function indexOf(shape:Shape):UInt{
		return shapes.indexOf(shape);
	}

	public function getSize():UInt {
		return MODEL_SIZE;
	}

	public function getShapeCount():UInt{
		return shapes.length;
	}

	public function addShape(shape:Shape){
		if(shapes.length < MAX_SHAPES){
			shapes.push(shape);
		}
	}

	public function addShapeAtIndex(index:UInt, shape:Shape){ //toedit
		shapes.insert(index, shape);
	}

	// public function getShape(shape:Shape):Shape {
	// 	return shapes[shapes.indexOf(shape)];
	// }

	public function getShape(index:UInt):Shape {
		return shapes[index];
	}

	public function removeShape(index:UInt):Shape {
    var shape = shapes[index];
		shapes.remove(shape);
    return shape;
	}

	public function getLastShape():Shape {
		return shapes[shapes.length-1];
	}

	public function getColor(index:UInt):UInt {
		return colors[index];
	}

	public function getPalette():Array<UInt> {
		return colors;
	}

	public function setColor(index:UInt, rgb:UInt) {
		colors[index] = rgb;
	}

}
