package nz.co.angryoctopus.lgmodeler;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.image.BufferedImage;

import javax.swing.JPanel;

public class ModelView extends JPanel implements MouseListener, MouseMotionListener, ShapeSelectListener {

	private static final Color GRAY_1 = new Color(64,64,64);
	private static final Color GRAY_2 = new Color(96,96,96);
	private static final Color GRAY_3 = new Color(128,128,128);
	
	public static final int X_GRID = 22;
	public static final int Y_GRID =  15;
	public static final int WIDTH = Model.MODEL_SIZE*X_GRID;
	public static final int HEIGHT = Model.MODEL_SIZE*Y_GRID*2;
	public static final int HANDLE_WIDTH = 9;
	
	private static final Color TOP_HANDLE = new Color(83,93,108,192);
	private static final Color SIDE_HANDLE = new Color(55,62,72,192);

	private Shape.Type addShape;
	private int addColor;
	
	private ModelRenderer renderer;
	private Model model;
	private int selectedShape;
	private boolean moveXY;
	private int handle;
	private Point[] handles = new Point[8];
	private LGModeler modler;
	private BufferedImage background;
	private BufferedImage modelImage;
	private boolean preview;
	
	public ModelView(final LGModeler modler){
		this.modler = modler;
		setFocusable(true);
		modler.addShapeSelectListener(this);
		renderer = new ModelRenderer(WIDTH,HEIGHT);
		for(int i = 0; i < handles.length; i++){
			handles[i] = new Point();
		}
		addMouseListener(this);
		addMouseMotionListener(this);
		
		addKeyListener(new KeyAdapter(){
			public void keyPressed(KeyEvent ke){
				if(ke.getKeyCode() == KeyEvent.VK_DELETE && selectedShape >= 0){
					model.removeShape(selectedShape);
					selectedShape = -1;
					modler.modelChanged();
				}
			}
		});
		
		background = new BufferedImage(WIDTH,HEIGHT,BufferedImage.TYPE_INT_ARGB);
		updateBackground();
		
		selectedShape = -1;
		handle = -1;
	}
	
	public void updateBackground(){
		Graphics g = background.getGraphics();
		g.setColor(GRAY_2);
		g.fillRect(0, HEIGHT/2, WIDTH, HEIGHT/2);
		g.drawRect(0, HEIGHT/2, WIDTH - 1, HEIGHT/2 - 1);
		g.drawRect(0, 0, WIDTH - 1, HEIGHT/2 - 1);
		int gh = (HEIGHT)/(Model.MODEL_SIZE*2);
		int gw = (WIDTH)/Model.MODEL_SIZE;
		g.setColor(GRAY_2);
//		FontMetrics fm = g.getFontMetrics();
		for(int i = 0; i < Model.MODEL_SIZE; i++){
			int y = i*gh;
//			String num = Integer.toString(Model.MODEL_SIZE - i);
//			g.drawString(num, -fm.stringWidth(num)-4, y+4);
			g.drawLine(-2, i*gh, gw*Model.MODEL_SIZE, y);
		}
		for(int i = 0; i < Model.MODEL_SIZE; i++){
			g.drawLine(i*gw, 0, i*gw, Model.MODEL_SIZE*gh); 
		}
		g.setColor(GRAY_3);
		for(int i = 0; i <= Model.MODEL_SIZE; i++){
			int y = (i + Model.MODEL_SIZE)*gh;
//			String num = Integer.toString(i);
//			g.drawString(num, -fm.stringWidth(num)-4, y+4);
			g.drawLine(-2, y, gw*Model.MODEL_SIZE, y);
		}
		for(int i = 0; i < Model.MODEL_SIZE; i++){
			g.drawLine(i*gw, Model.MODEL_SIZE*gh, i*gw, Model.MODEL_SIZE*2*gh); 
		}

	}
	
	public BufferedImage renderOut(int w, int h){
		BufferedImage out = new BufferedImage(w,h,BufferedImage.TYPE_INT_ARGB);
		Graphics2D g = (Graphics2D)out.getGraphics();
		g.setRenderingHint(RenderingHints.KEY_ALPHA_INTERPOLATION, RenderingHints.VALUE_ALPHA_INTERPOLATION_QUALITY);
		g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
		g.drawImage(renderer.render(model, -1, false), 0, 0, w, h, null);
		return out;
	}

	public void setModel(Model model){
		this.model = model;
		modelImage = renderer.render(model, -1, false);
		repaint();
	}
	
	public void paint(Graphics g){
		int w = getWidth();
		int h = getHeight();
		int x1 = (w - WIDTH)/2;
		int y1 = (h - HEIGHT)/2;
		g.setColor(GRAY_1);
		g.fillRect(0, 0, w, h);
		g.translate(x1, y1);
		g.drawImage(background, 0, 0, null);
		if(model != null){
			if(selectedShape >= 0){
				Shape s = model.getShape(selectedShape);
				int h2 = (HEIGHT)/2;
				int cw = (WIDTH)/16;
				int ch = (HEIGHT)/32;
				Rectangle rect = new Rectangle();
				rect.x = s.getX1()*cw;
				rect.width = s.getX2()*cw - rect.x;
				rect.y = h2 - (- s.getY1())*ch;
				rect.height = (h2 - (- s.getY2())*ch) - rect.y;
				int color = model.getColor(s.getColor());
				g.setColor(new Color((color>>16)&0xFF, ((color)>>8)&0xFF, color&0xFF,64));
				g.fillRect(rect.x, rect.y, rect.width, rect.height);
				rect.y = h2 - (s.getZ2())*ch;
				rect.height = (h2 - (s.getZ1())*ch) - rect.y;
				g.fillRect(rect.x, rect.y, rect.width, rect.height);
			}
			
			BufferedImage img = renderer.render(model,selectedShape,preview);
			g.drawImage(img, 0, 0, WIDTH, HEIGHT, null);
		}
		g.setColor(new Color(255,255,255,128));
		if(selectedShape != -1 && model != null && model.getShape(selectedShape) != null){
			g.drawLine(handles[0].x,handles[0].y,handles[1].x,handles[1].y);
			g.drawLine(handles[2].x,(handles[2].y+handles[4].y)/2,handles[3].x,(handles[3].y + handles[5].y)/2);
			g.drawLine(handles[6].x,handles[6].y,handles[7].x,handles[7].y);
			
			g.drawLine(handles[0].x,handles[0].y,handles[6].x,handles[6].y);
			g.drawLine(handles[1].x,handles[1].y,handles[7].x,handles[7].y);
//			g.drawRect(left,top,right - left,bot - top);
			int hw2 = HANDLE_WIDTH/2;
			for(int i = 0; i < handles.length; i++){
				if(handle == i){
					g.setColor(Color.RED);
				} else {
					if(i < 4){
						g.setColor(TOP_HANDLE);
					} else {
						g.setColor(SIDE_HANDLE);
					}
				}
				g.fillRect(handles[i].x-hw2, handles[i].y-hw2, HANDLE_WIDTH, HANDLE_WIDTH);
			}
		}
	}
	
	public void update(Graphics g){
		paint(g);
	}

	public int clampSize(int v){
		if(v < 0){
			return 0;
		} else if (v > Model.MODEL_SIZE){
			return Model.MODEL_SIZE;
		} else {
			return v;
		}
	}
	
	public int clamp(int val, int min, int max){
		if (val < min){
			return min;
		} else if (val > max){
			return max;
		} else {
			return val;
		}
	}

	@Override
	public void mouseDragged(MouseEvent me) {
		int x = me.getX() - (getWidth() - WIDTH)/2;
		int y = me.getY() - (getHeight() - HEIGHT)/2;
		if(handle >= 0){
			Shape s = model.getShape(selectedShape);
			int xg = clampSize((x + X_GRID/2)/X_GRID);
			int y1 = clampSize((y + Y_GRID/2)/Y_GRID - 16 + s.getZ2());
			int z1 = clampSize(16 - (y + Y_GRID/2)/Y_GRID + s.getY2());
			if(handle%2 == 0){
				// a left handle	
				if(xg < s.getX2() && xg != s.getX1()){
					s.setX1(xg);
					shapeSelected(selectedShape);
				}
			} else {
				if(xg > s.getX1() && xg != s.getX2()){
					s.setX2(xg);
					shapeSelected(selectedShape);
				}
			}
			if(handle < 2){
				// a top handle
				if(y1 < s.getY2() && y1 != s.getY1()){
					s.setY1(y1);
					shapeSelected(selectedShape);
				}
			} else if(handle < 4){
				// a mid upper handle
				if(y1 > s.getY1() && y1 != s.getY2()){
					s.setY2(y1);
					shapeSelected(selectedShape);
				}
			} else if(handle < 6){
				// mid lower handle
				if(z1 > s.getZ1() && z1 != s.getZ2()){
					s.setZ2(z1);
					shapeSelected(selectedShape);
				}
			} else {
				// a bottom handle
				if(z1 < s.getZ2() && z1 != s.getZ1()){
					s.setZ1(z1);
					shapeSelected(selectedShape);
				}
			}
			
		} else if (selectedShape >= 0){
			int xg = clampSize((x + X_GRID/2)/X_GRID);
			Shape s = model.getShape(selectedShape);
			int deltaX = xg - s.getCenterX();
			boolean changed = false;
			if(deltaX != 0 && s.getX1() + deltaX >= 0 && s.getX2() + deltaX <= Model.MODEL_SIZE){
				s.setX1(s.getX1() + deltaX);
				s.setX2(s.getX2() + deltaX);
				changed = true;
			}
			if(moveXY){
				int zg = s.getZ2();
				int yg = clampSize((y + Y_GRID/2)/Y_GRID - 16 + zg);
				int deltaY = yg - (s.getY2() + s.getY1())/2;
				if(deltaY != 0 && s.getY1() + deltaY >= 0 && s.getY2() + deltaY <= Model.MODEL_SIZE){
					s.setY1(s.getY1() + deltaY);
					s.setY2(s.getY2() + deltaY);
					changed = true;
				}
			} else {
				int yg = s.getY2();
				int zg = clampSize(16 - (y + Y_GRID/2)/Y_GRID + yg);
				int deltaZ = zg - (s.getZ2() + s.getZ1())/2;
				if(deltaZ != 0 && s.getZ1() + deltaZ >= 0 && s.getZ2() + deltaZ <= Model.MODEL_SIZE){
					s.setZ1(s.getZ1() + deltaZ);
					s.setZ2(s.getZ2() + deltaZ);
					changed = true;
				}
			}
			if(changed){
				shapeSelected(selectedShape);
			}
		}
		
	}


	@Override
	public void mouseMoved(MouseEvent me) {
		int x = me.getX() - (getWidth() - WIDTH)/2;
		int y = me.getY() - (getHeight() - HEIGHT)/2;
		if(addShape != null){
			int xg = clamp((x + X_GRID/2)/X_GRID, 1, Model.MODEL_SIZE-1);
			if(xg != model.getLastShape().getCenterX()){
				model.getLastShape().setX1(xg-1);
				model.getLastShape().setX2(xg+1);
				repaint();
			}
			
			int zg = 1;
			int yg = clamp((y + Y_GRID/2)/Y_GRID - 16 + zg, 1, Model.MODEL_SIZE-1);
			model.getLastShape().setBoundsZ(zg-1, zg+1);
			if(yg != model.getLastShape().getCenterY()){
				model.getLastShape().setY1(yg-1);
				model.getLastShape().setY2(yg+1);
			}
			shapeSelected(model.getShapeCount()-1);
		}
	}


	@Override
	public void mouseClicked(MouseEvent me) {
		
	}


	@Override
	public void mouseEntered(MouseEvent me) {
		if(addShape != null){
			Shape s = new Shape(addShape);
			s.setBoundsX(7, 9);
			s.setBoundsY(7, 9);
			s.setBoundsZ(7, 9);
			s.setColor(addColor);
//			s.setRound(addRound);
			model.addShape(s);
			mouseMoved(me);
			repaint();
		}
	}
	
	public Rectangle getTop(Shape s){
		int h2 = (HEIGHT)/2;
		int cw = (WIDTH)/16;
		int ch = (HEIGHT)/32;
		Rectangle rect = new Rectangle();
		rect.x = s.getX1()*cw;
		rect.width = s.getX2()*cw - rect.x;
		rect.y = h2 - (s.getZ2() - s.getY1())*ch;
		rect.height = (h2 - (s.getZ2() - s.getY2())*ch) - rect.y;
		return rect;
	}
	
	public Rectangle getSide(Shape s){
		int s2 = (HEIGHT)/2;
		int cw = (WIDTH)/16;
		int ch = (HEIGHT)/32;
		Rectangle rect = new Rectangle();
		rect.x = s.getX1()*cw;
		rect.width = s.getX2()*cw - rect.x;
		rect.y = s2 - (s.getZ2() - s.getY2())*ch;
		rect.height = (s2 - (s.getZ1() - s.getY2())*ch) - rect.y;
		return rect;
	}


	@Override
	public void mouseExited(MouseEvent me) {
		if(addShape != null){
			model.removeShape(model.getShapeCount()-1);
			selectedShape = -1;
			repaint();
		}
	}

	@Override
	public void shapeSelected(int index) {
		selectedShape = index;
		if(selectedShape >= 0){
			Shape s = model.getShape(selectedShape);
			Rectangle top = getTop(s);
			Rectangle side = getSide(s);
			handles[0].y = top.y;
			handles[1].y = handles[0].y;
			handles[2].y = side.y - HANDLE_WIDTH/2;
			handles[3].y = handles[2].y;
			handles[4].y = side.y + HANDLE_WIDTH/2;
			handles[5].y = handles[4].y;
			handles[6].y = side.y + side.height;
			handles[7].y = handles[6].y;
			int leftX = top.x;
			int rightX = top.x + top.width;
			for(int i = 0; i < handles.length; i+=2){
				handles[i].x = leftX;
				handles[i+1].x = rightX;
			}
		}
		repaint();
	}

	private int getHandle(int x, int y){
		if(selectedShape < 0){
			return -1;
		}
		int hw2 = HANDLE_WIDTH/2;
		for(int i = 0; i < handles.length; i++){
			Point h = handles[i];
			if(x > h.x - hw2 && x < h.x + hw2 && y > h.y - hw2 && y < h.y + hw2){
				return i;
			}
		}
		return -1;
	}
	
	@Override
	public void mousePressed(MouseEvent me) {
		requestFocusInWindow();
		int x = me.getX() - (getWidth() - WIDTH)/2;
		int y = me.getY() - (getHeight() - HEIGHT)/2;
		
		if(addShape != null){
			modler.modelChanged();
			mouseEntered(me);
			mouseMoved(me);
		} else {
			handle = getHandle(x,y);
			if(handle < 0){
				if(x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT){
					selectedShape = renderer.select(x,y);
				} else {
					selectedShape = -1;
				}
				if(selectedShape >= 0 && model.getShape(selectedShape).locked()){
					selectedShape = -1;
				}
				modler.selectShape(selectedShape);
				if(selectedShape >= 0){
					Rectangle top = getTop(model.getShape(selectedShape));
					moveXY = top.contains(x,y); 
					preview = true;
				}
			} else {
				preview = true;
			}
		}
		
		repaint();
	}
	
	public void setAddShape(Shape.Type type, int color){
		this.addShape = type;
		this.addColor = color;
		selectedShape = -1;
		preview = type != null;
		repaint();
	}


	@Override
	public void mouseReleased(MouseEvent me) {
		preview = addShape != null;
		handle = -1;
		repaint();
	}

	
}
