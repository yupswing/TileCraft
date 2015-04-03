package nz.co.angryoctopus.lgmodeler;

import java.awt.Color;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JPanel;

public class ModelShapeList extends JPanel implements ShapeSelectListener {
	
	private static final int ITEM_HEIGHT = 32;
	
	private Model model;
	private List<ShapeView> shapeViews;
	private ShapeView selected;
	private LGModeler modler;
	
	public ModelShapeList(final LGModeler modler){
		this.modler = modler;
		modler.addShapeSelectListener(this);
		shapeViews = new ArrayList<ShapeView>();
		setBackground(Color.GRAY);
		setLayout(null);
		MouseAdapter ma = new MouseAdapter(){
			@Override
			public void mouseDragged(MouseEvent me){
				if(selected != null){
					int index = getIndex(me.getY());
					if(index < 0){
						index = 0;
					} else if (index >= shapeViews.size()){
						index = shapeViews.size()-1;
					}
					if(index != model.indexOf(selected.getShape())){
						Shape s = model.removeShape(model.indexOf(selected.getShape()));
						model.addShape(index, s);
						modler.modelChanged();
						selectShape(index);
					}
				}
			}
			@Override
			public void mousePressed(MouseEvent me){
				int index = getIndex(me.getY());
				if(index >= shapeViews.size()){
					index = -1;
				}
				if(index >= 0 && me.getX() > 42 && me.getX() < 70){
					Shape s = shapeViews.get(index).getShape();
					s.setEnabled(!s.enabled());
					modler.modelChanged();
				} else if(index >= 0 && me.getX() > 72 && me.getX() < 100){
					Shape s = shapeViews.get(index).getShape();
					s.setLocked(!s.locked());
					modler.modelChanged();
				} else if (index >= 0 && me.getX() > getWidth() - 32){
					selectShape(-1);
					model.removeShape(index);
					modler.modelChanged();
				} else {
					if(index >= shapeViews.size()){
						index = -1;
					}
					selectShape(index);
				}
			}
			
		};
		addMouseMotionListener(ma);
		addMouseListener(ma);
	}
	
	private int getIndex(int y){
		return Math.max(-1,(model.getShapeCount()-1) - y/ITEM_HEIGHT);
	}
	
	private int getY(int index){
		return ((model.getShapeCount() - 1) - index)*ITEM_HEIGHT;
	}
	
	public Shape getSelectedShape(){
		return selected == null ? null : selected.getShape();
	}
	
	public int getColor(int index){
		return model.getColor(index);
	}
	
	public void setModel(Model model){
		this.model = model;
		shapeViews.clear();
		removeAll();
		for(int i = 0; i < model.getShapeCount(); i++){
			ShapeView sv = new ShapeView(this, model.getShape(i));
			sv.setBounds(0,getY(i),getWidth(),ITEM_HEIGHT);
			shapeViews.add(sv);
			add(sv);
		}
		repaint();
	}

	@Override
	public void shapeSelected(int index) {
		if(selected != null){
			selected.setSelected(false);
			selected = null;
		}
		if(index >= 0){
			selected = shapeViews.get(index);
			selected.setSelected(true);
		}
		
	}
	
	public void modelChanged(){
		modler.modelChanged();
	}

	public void selectShape(int index) {
		if(index >= 0 && model.getShape(index).locked()){
			index = -1;
		}
		modler.selectShape(index);
	}
}
