
package nz.co.angryoctopus.lgmodeler;

import java.util.ArrayList;
import java.util.List;

import javax.swing.plaf.metal.MetalBorders.PaletteBorder;

public class Model {

	private static final int MAX_SHAPES = 32;
	public static final int MODEL_SIZE = 16;

	private List<Shape> shapes;
	private int[] colors;
	
	public Model(int[] colors){
		this.colors = colors.clone();
		shapes = new ArrayList<Shape>();
	}
	
	public int indexOf(Shape shape){
		return shapes.indexOf(shape);
	}
	
	public int getSize(){
		return MODEL_SIZE;
	}
	
	public int getShapeCount(){
		return shapes.size();
	}
		
	public void addShape(Shape shape){
		if(shapes.size() < MAX_SHAPES){
			shapes.add(shape);
		}
	}

	public Shape getShape(int shape) {
		return shapes.get(shape);
	}

	public Shape removeShape(int index) {
		return shapes.remove(index);
	}
	
	public void addShape(int index, Shape shape){
		shapes.add(index, shape);
	}

	public Shape getLastShape() {
		return shapes.get(shapes.size()-1);
	}

	public int getColor(int index) {
		return colors[index];
	}

	public int[] getPalette() {
		return colors;
	}

	public void setColor(int index, int rgb) {
		colors[index] = rgb;
	}
	
}
