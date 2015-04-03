package nz.co.angryoctopus.lgmodeler;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JPanel;

public class IconSelectMatrix extends JPanel {
	
	public interface IconSelectListener {
		public void iconSelected(int index);
		public void iconDoubleClicked(int index);
	}
	
	private int selected;
	private int size;
	private Image[] icons;
	private List<IconSelectListener> listeners;
	
	public IconSelectMatrix(final Image[] icons){
		selected = -1;
		this.icons = icons;
		size = icons[0].getWidth(null);
		listeners = new ArrayList<IconSelectListener>();
		addMouseListener(new MouseAdapter(){
			public void mousePressed(MouseEvent me){
				int cols = getWidth()/size;
				selected = (me.getY()/size)*cols + me.getX()/size;
				if(selected >= icons.length){
					selected = icons.length-1;
				}
				for(IconSelectListener listener : listeners){
					if(me.getClickCount() == 2){
						listener.iconDoubleClicked(selected);
					} else {
						listener.iconSelected(selected);
					}
				}
				repaint();
			}
		});
	}
	
	public int getSelected(){
		return selected;
	}
	
	public void addSelectListener(IconSelectListener listener){
		listeners.add(listener);
	}
	
	public void setSelected(int selected){
		this.selected = selected;
		repaint();
	}
	
	public void paint(Graphics g){
		Graphics2D g2d = (Graphics2D)g;
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		int cols = getWidth()/size;
		g.setColor(Color.GRAY);
		g.fillRect(0, 0, getWidth(), getHeight());
		g.setColor(Resources.SELECT_COLOR);
		for(int i = 0; i < icons.length; i++){
			int row = i/cols;
			int col = i%cols;
			if(selected == i){
				g.fillRoundRect(col*size+1, row*size+1, size-2, size-2, 12, 12);
			}
			g.drawImage(icons[i], col*size, row*size, null);
		}
	}

	public void setIcons(Image[] icons) {
		this.icons = icons;
		repaint();
	}
	

}
