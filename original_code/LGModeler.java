package nz.co.angryoctopus.lgmodeler;

import java.applet.Applet;
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;
import javax.swing.JColorChooser;
import javax.swing.JLabel;
import javax.swing.UIManager;
import javax.swing.UIManager.LookAndFeelInfo;

import nz.co.angryoctopus.lgmodeler.IconSelectMatrix.IconSelectListener;

public class LGModeler extends Applet {
	
	private static final String house = "DAAACGneAQlLXCgIS1wBW0dcv19Her9ri1y_b4t6v2mLzJ1ZR7ydCEusmgBpXiVAaaxH";
	private static final String factory = "CgAACC1cAAg2zgBIfGxKCS1sGAA2fBZIXkUMSJrNRQh4vDRIi7wmCJq8aA..";
	
	private ModelView modelView;
	private ModelShapeList shapeList;
	private IconSelectMatrix newShapeSelect;
	private Model model;
	private IconSelectMatrix colorSelect;
	private List<ShapeSelectListener> listeners;
//	private IconSelectMatrix edgeRoundSelect;
	
	public LGModeler(){
		listeners = new ArrayList<ShapeSelectListener>();
	}
	
	public String getSrc(){
		byte[] bin = ModelIO.saveModel(model);
		return "http://www.angryoctopus.co.nz/lgmodler/index.php?model=" + Base64.encodeBase64(bin,true);
	}
	
	public String getImage(){
		BufferedImage img = modelView.renderOut(64,96);
		
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try {
			ImageIO.write(img, "PNG", out);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return "data:image/png;base64," + Base64.encodeBase64(out.toByteArray(),false);
	}
	
	public Model getModel(){
		return model;
	}
	
	public void modelChanged(){
		modelView.setModel(model);
		shapeList.setModel(model);
	}
	
	public void selectShape(int index){
		newShapeSelect.setSelected(0);
		updateAddShape();
		for(ShapeSelectListener listener : listeners){
			listener.shapeSelected(index);
		}
		if(index >= 0){
			colorSelect.setSelected(shapeList.getSelectedShape().getColor());
		}
	}
	
	@Override
	public void init(){
		
		try {
		    for (LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
		        if ("Nimbus".equals(info.getName())) {
		            UIManager.setLookAndFeel(info.getClassName());
		            break;
		        }
		    }
		} catch (Exception e) {
		    // If Nimbus is not available, you can set the GUI to another look and feel.
		}
		
		Resources.init();
		
		setLayout(null);
		
		setBackground(Color.GRAY);

		JLabel addShape = new JLabel("Primitives");
		addShape.setBounds(4,4,120,24);
		add(addShape);
		
		newShapeSelect = new IconSelectMatrix(Resources.SHAPE_ICONS);
		newShapeSelect.setBounds(0,32,128,160);
		newShapeSelect.setSelected(0);
		newShapeSelect.addSelectListener(new IconSelectListener(){
			@Override
			public void iconSelected(int index) {
				updateAddShape();
				for(ShapeSelectListener listener : listeners){
					listener.shapeSelected(-1);
				}
			}

			@Override
			public void iconDoubleClicked(int index) {
				
			}
		});
		add(newShapeSelect);
	
//		JLabel roundEdges = new JLabel("Round");
//		roundEdges.setBounds(4,172,128,24);
//		add(roundEdges);
//		
//		edgeRoundSelect = new IconSelectMatrix(Resources.ROUND_ICONS);
//		edgeRoundSelect.setBounds(0,190,128,32);
//		edgeRoundSelect.setSelected(0);
//		add(edgeRoundSelect);
		
		JLabel color = new JLabel("Color");
		color.setBounds(4,196,120,24);
		add(color);
		

		String modelSrc = getParameter("model");
//		modelSrc = factory;
		if(modelSrc != null){
			model = ModelIO.loadModel(Base64.decodeBase64(modelSrc));
		}
		if(model == null){
			model = new Model(ModelIO.DEFAULT_PALETTE);
		}
		
		colorSelect = new IconSelectMatrix(Resources.getColorIcons(model));
		colorSelect.setSelected(1);
		colorSelect.setBounds(0,224,128,128);
		colorSelect.addSelectListener(new IconSelectListener(){
			@Override
			public void iconSelected(int index) {
				Shape selected = shapeList.getSelectedShape();
				if(selected != null){
					selected.setColor(index);
					modelChanged();
				} else {
					updateAddShape();
				}
			}

			@Override
			public void iconDoubleClicked(int index) {
				if(index > 0){
					Color color = JColorChooser.showDialog(modelView, "Select Color", new Color(model.getColor(index)));
					if(color != null){
						model.setColor(index, color.getRGB());
						colorSelect.setIcons(Resources.getColorIcons(model));
						modelChanged();
					}
				}
			}
		});
		add(colorSelect);

		
		modelView = new ModelView(this);
		modelView.setBounds(128,0,544,600);
		add(modelView);
		
		shapeList = new ModelShapeList(this);
		shapeList.setBounds(672,0,128,600);
		add(shapeList);
//		addShape(Shape.Type.CUBE,0,0,0,4,4,8,1);
//		addShape(Shape.Type.DOME_UP,1,3,1,2,3,1,0);
		//addCube(2,2,2,4,4,4,0);
		
		modelView.setModel(model);
		shapeList.setModel(model);
	}
	
	public void updateAddShape(){
		int index = newShapeSelect.getSelected();
		if(index == 0){
			modelView.setAddShape(null,0);
		} else {
//			shapeList.selectShape(-1);
			modelView.setAddShape(Shape.Type.values()[index-1],colorSelect.getSelected());
		}

	}

	protected void addShapeSelectListener(ShapeSelectListener listener) {
		listeners.add(listener);
	}

	

}
