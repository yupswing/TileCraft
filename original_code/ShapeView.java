package nz.co.angryoctopus.lgmodeler;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.Stroke;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;

import javax.swing.JComponent;

public class ShapeView extends JComponent {

	private Stroke outlineStroke = new BasicStroke(1.5f);
	private Color outlineColor = Color.DARK_GRAY;
	private Color fillColor = Color.LIGHT_GRAY;

	private Shape shape;
	private boolean selected;
	private BufferedImage icon;
	private ModelShapeList shapeList;

	public ShapeView(final ModelShapeList shapeList, final Shape shape){
		this.shape = shape;
		this.shapeList = shapeList;
		icon = new BufferedImage(32,32,BufferedImage.TYPE_INT_ARGB);
		updateIcon();
//		MouseAdapter ma = new MouseAdapter(){
//			@Override
//			public void mousePressed(MouseEvent me){
//				int x = me.getX();
//				if(x > 32 && x < 64){
//					shape.setEnabled(!shape.enabled());
//					shapeList.modelChanged();
//					repaint();
//				} else {
//					shapeList.selectShape(shape.getIndex());
//				}
//			}
//		};
//
//		addMouseListener(ma);
	}

	public Shape getShape(){
		return shape;
	}

	public void setSelected(boolean selected){
		this.selected = selected;
		repaint();
	}

	public void paint(Graphics g){
		Graphics2D g2d = (Graphics2D)g;
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		if(selected){
			g2d.setColor(Resources.SELECT_COLOR);
		} else {
			g2d.setColor(fillColor);
		}
		g2d.fillRoundRect(2, 2, getWidth()-4, getHeight()-4, 12, 12);
		g2d.setColor(outlineColor);
		g2d.setStroke(outlineStroke);
		g2d.drawRoundRect(2, 2, getWidth()-4, getHeight()-4, 12, 12);
		g2d.drawImage(icon, 8, 0, null);
		g2d.drawImage(Resources.VISIBLE_ICONS[shape.enabled()?0:1], 40, 0, null);
		g2d.drawImage(Resources.LOCK_ICONS[shape.locked()?1:0], 70, 0, null);
		g2d.drawImage(Resources.DELETE_ICON, getWidth() - 32, 0, null);
	}

	public void update(Graphics g){
		paint(g);
	}

	public void updateIcon(){
		Graphics g = icon.getGraphics();
		if(shape.getColor() == 0){
			g.drawImage(Resources.CLEAR_SHAPE_ICONS[shape.getType().ordinal()+1],0,0,null);
		} else {
			Image src = Resources.SHAPE_ICONS[shape.getType().ordinal()+1];
			g.drawImage(src, 0, 0, null);
			int[] data = ((DataBufferInt)icon.getRaster().getDataBuffer()).getData();
			float[] hsb = new float[3];
			int col = shapeList.getColor(shape.getColor());
			Color.RGBtoHSB((col>>16)&0xFF,(col>>8)&0xFF,col&0xFF,hsb);
			float hue = hsb[0];
			float sat = hsb[1];
			float bright = hsb[2];
			for(int i = 0; i < data.length; i++){
				int rgb = data[i];
				int a = rgb&0xFF000000;
				Color.RGBtoHSB((rgb>>16)&0xFF, (rgb>>8)&0xFF, rgb&0xFF, hsb);
				hsb[0] = hue;
				hsb[1] = sat;
				hsb[2] *= 0.5f + 0.5f*bright;
				data[i] = a | (Color.HSBtoRGB(hsb[0], hsb[1], hsb[2])&0xFFFFFF);
			}
		}
	}




}
