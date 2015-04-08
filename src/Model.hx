package ;

class Model {

	private static inline var MAX_SHAPES = 32;
	public static inline var MODEL_SIZE = 16;

	private var shapes:Array<Shape>;
	private var colors:Array<Int>;

	public function new(colors:Array<Int>){
		this.colors = colors.copy();
		this.shapes = new Array<Shape>();
	}

	public function indexOf(shape:Shape):Int{
		return shapes.indexOf(shape);
	}

	public function getSize():Int {
		return MODEL_SIZE;
	}

	public function getShapeCount():Int{
		return shapes.length;
	}

	public function addShape(shape:Shape){
		if(shapes.length < MAX_SHAPES){
			shapes.push(shape);
		}
	}

	public function addShapeAtIndex(index:Int, shape:Shape){ //toedit
		shapes.insert(index, shape);
	}

	// public function getShape(shape:Shape):Shape {
	// 	return shapes[shapes.indexOf(shape)];
	// }

	public function getShape(index:Int):Shape {
		return shapes[index];
	}

	public function removeShape(index:Int):Shape {
    var shape = shapes[index];
		shapes.remove(shape);
    return shape;
	}

	public function getLastShape():Shape {
		return shapes[shapes.length-1];
	}

	public function getColor(index:Int):Int {
		return colors[index]&0xFFFFFF;
	}

	public function getPalette():Array<Int> {
		return colors;
	}

	public function setColor(index:Int, rgb:Int) {
		//colors[index] = ~(0xFFFFFF^rgb); //TODO check why inverted colors
		colors[index] = rgb|0xFF000000; //this two lines are equivalent
	}

}
