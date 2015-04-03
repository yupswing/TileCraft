package nz.co.angryoctopus.lgmodeler;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Point;
import java.awt.RenderingHints;
import java.awt.Stroke;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.IOException;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;

public class Resources {

	public static void init() {
		ClassLoader cl = Thread.currentThread().getContextClassLoader();
//		SHAPE_ICONS = new Image[]{
//				new ImageIcon(cl.getResource("cube.png")).getImage(),
//				new ImageIcon(cl.getResource("cylinder_up.png")).getImage()
//		};
		VISIBLE_ICONS = splitStrip("eye_icons.png");
		LOCK_ICONS = splitStrip("lock_icons.png");
//		SHARP_ICON = new ImageIcon(cl.getResource("sharp.png")).getImage();
//		ROUND_ICON = new ImageIcon(cl.getResource("round.png")).getImage();
		Image[][] icons = splitGrid("shape_icons.png",2);
		SHAPE_ICONS = icons[0];
		CLEAR_SHAPE_ICONS = icons[1];
		ROUND_ICONS = splitStrip("round_icons.png");
		DELETE_ICON = new ImageIcon(cl.getResource("delete.png")).getImage();
	}
	
	public static Font SMALL_FONT = new Font("sans serif", Font.BOLD, 8);
	public static Font MEDIUM_FONT = new Font("sans serif", Font.BOLD, 12);
	
	public static Image[] SHAPE_ICONS;
	public static Image[] CLEAR_SHAPE_ICONS;
	public static Image[] ROUND_ICONS;
	public static Image[] VISIBLE_ICONS;
	public static Image[] LOCK_ICONS;
	public static Image SHARP_ICON;
	public static Image ROUND_ICON;
	public static Image DELETE_ICON;
	
	public static Image[] getColorIcons(Model model){
		Stroke outlineStroke = new BasicStroke(2.0f);
		Stroke holeStroke = new BasicStroke(2.0f,BasicStroke.CAP_BUTT,BasicStroke.JOIN_ROUND,19.0f,new float[]{3.0f,1.0f},0.0f);
		Color holeColor = new Color(213, 246, 255);
		Color holeStrokeColor = new Color(0,102,128);
		
		Image[] icons = new Image[16];
		for(int i = 0; i < 16; i++){
			BufferedImage icon = new BufferedImage(32,32,BufferedImage.TYPE_INT_ARGB);
			icons[i] = icon;
			Graphics2D g2d = (Graphics2D)icon.getGraphics();
			g2d.setFont(Resources.SMALL_FONT);
			g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
			if(i == 0){
				g2d.setStroke(holeStroke);
				g2d.setColor(holeColor);
				g2d.fillRoundRect(4, 4, 24, 24, 8, 8);
				g2d.setColor(holeStrokeColor);
				g2d.drawRoundRect(4, 4, 24, 24, 8, 8);
				Rectangle2D bounds = g2d.getFontMetrics().getStringBounds("Hole", g2d);
				g2d.drawString("Hole",16-(int)bounds.getCenterX(),16-(int)bounds.getCenterY());
			} else {
				g2d.setStroke(outlineStroke);
				Color c = new Color(model.getColor(i));
				g2d.setColor(c);
				g2d.fillRoundRect(4, 4, 24, 24, 8, 8);
				g2d.setPaint(new GradientPaint(new Point(0,4),c.brighter(),new Point(0,32+4), c.darker()));
				g2d.drawRoundRect(4, 4, 24, 24, 8, 8);
			}
		}
		return icons;
	}
	
	public static final Color SELECT_COLOR = new Color(85,153,255);

	private static Image[][] splitGrid(String src, int rows){
		Image[][] icons = null;
		try {
			ClassLoader cl = Thread.currentThread().getContextClassLoader();
			BufferedImage img = ImageIO.read(cl.getResourceAsStream(src));
			int size = img.getHeight()/rows;
			icons = new Image[rows][img.getWidth()/size];
			for(int row = 0; row < icons.length; row++){
				for(int i = 0; i < icons[row].length; i++){
					icons[row][i] = img.getSubimage(i*size,row*size,size,size);
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return icons;
	}
	
	private static Image[] splitStrip(String src){
		Image[] icons = null;
		try {
			ClassLoader cl = Thread.currentThread().getContextClassLoader();
			BufferedImage img = ImageIO.read(cl.getResourceAsStream(src));
			icons = new Image[img.getWidth()/img.getHeight()];
			for(int i = 0; i < icons.length; i++){
				int s = img.getHeight();
				icons[i] = img.getSubimage(i*s,0,s,s);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return icons;
	}
	
}
