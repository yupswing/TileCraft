package nz.co.angryoctopus.lgmodeler;

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
import java.util.Arrays;


public class ModelRenderer {

	protected static class Slice implements Comparable<Slice>{
		int y1;
		int y2;
		int z1;
		int z2;
		int color;
		byte index;
		float normal;
		
		public void set(int y1, int z1, int y2, int z2, int color, byte index, float normal){
			this.y1 = y1;
			this.z1 = z1;
			this.y2 = y2;
			this.z2 = z2;
			this.color = color;
			this.index = index;
			this.normal = normal;
		}
		
		public void set(Slice l){
			this.y1 = l.y1;
			this.z1 = l.z1;
			this.y2 = l.y2;
			this.z2 = l.z2;
			this.color = l.color;
			this.index = l.index;
			this.normal = l.normal;
		}
		
		public boolean overlaps(Slice s){
			return s.y1 < y2 && s.y2 > y1 && s.z1 < z2 && s.z2 > z1;
		}
		
		public int sub(Slice s, Slice[] slices, int offset){
			// process z2 plane
			if(s.z2 < z2){
				slices[offset++].set(y1,s.z2,y2,z2,color,index,normal);
			}
			// process z1 plane
			if(s.z1 > z1){
				slices[offset++].set(y1,z1,y2,s.z1,color,index,s.normal);
			}
			// process middle
			int top = Math.min(s.z2, z2);
			int bot = Math.max(s.z1, z1);
			if(s.y1 > y1 && s.y2 < y2){
				slices[offset++].set(y1,bot,s.y1,top,color,index,normal);
				slices[offset++].set(s.y2,bot,y2,top,color,index,normal);
			} else if (s.y1 <= y1 && s.y2 < y2){
				slices[offset++].set(s.y2,bot,y2,top,color,index,normal);
			} else if (s.y2 >= y2 && s.y1 > y1){
				slices[offset++].set(y1,bot,s.y1,top,color,index,normal);
			}
			z1 = 0;
			z2 = 0;
			y1 = 0;
			y2 = 0;
			return offset;
		}
		
		@Override
		public int compareTo(Slice s) {
			if(z2 <= s.z1){
				return -1;
			} else if (s.z2 <= z1){
				return 1;
			} else if (s.y1 >= y2){
				return -1;
			} else {
				return 1;
			}
		}
	}
	
	private BufferedImage buffer;
	private int[] color;
	private int[] yDepth;
	private int[] zDepth;
	private byte[] heightMap;
	private byte[] select;
	private float[] norm;
	private int w;
	private int h;
	
	private Slice[] slices = new Slice[64];
	private Slice subSlice = new Slice();
	private int sliceCount;
	
	public ModelRenderer(int w, int h){
		this.w = w;
		this.h = h;
		int h2 = h/2;
		for(int i = 0; i < slices.length; i++){
			slices[i] = new Slice();
		}
		buffer = new BufferedImage(w,h,BufferedImage.TYPE_INT_ARGB);
		color = ((DataBufferInt)(buffer.getRaster().getDataBuffer())).getData();
		yDepth = new int[w*h];
		zDepth = new int[w*h];
		heightMap = new byte[w*h2];
		select = new byte[w*h];
		norm = new float[w*h];
	}
	
	public BufferedImage render(Model m, int selected, boolean preview){
		int[] palette = m.getPalette();
		
		Arrays.fill(color, 0x00000000);
		Arrays.fill(yDepth, 0);
		Arrays.fill(heightMap, (byte)0);
		Arrays.fill(select, (byte)-1);
		Arrays.fill(norm, 1.0f);
		for(int y = 0; y < h; y++){
			if(y < h/2){
				Arrays.fill(zDepth, y*w, (y+1)*w, 1);
			} else {
				Arrays.fill(zDepth, y*w, (y+1)*w, 0);
				Arrays.fill(yDepth, y*w, (y+1)*w, y - h/2);
			}
		}
		
		int size = m.getSize();
		int gh = h/(size*2);
		int gw = w/(size);
		
		float sideNorm = preview ? 0.7f : 1.0f;
		
		int h2 = h/2;
		
		for(int g = 0; g < size; g++){
			final int xOffset = g*gw;
			for(int x = xOffset; x < xOffset + gw; x++){
				sliceCount = 0;
				// first get all the shapes that occur in the slice
				for(int index = 0; index < m.getShapeCount(); index++){
					Shape shape = m.getShape(index);
					if(shape.enabled() && shape.getX1() <= g && shape.getX2() > g){
						if(shape.getColor() == 0 && index != selected){
							shape.getSlice(x, gw, gh, subSlice, palette, m);
							sub();
						} else {
							shape.getSlice(x, gw, gh, subSlice, palette, m);
							sub();
							slices[sliceCount++].set(subSlice);
						}
					}
				}
				
				if(sliceCount == 0){
					continue;
				}
				
				Arrays.sort(slices, 0, sliceCount);
				
				for(int i = 0; i < sliceCount; i++){
					Slice s = slices[i];
					if(s.z2 <= s.z1){
						continue;
					}
					// draw vertical
					for(int a = s.z1; a < s.z2; a++){
						int pixel = (h2 + s.y2 - a - 1)*w + x;
						color[pixel] = s.color; //scaleColor(s.color, 0.8f + a/(float)(h*4));
						select[pixel] = s.index;
						yDepth[pixel] = (int)s.y2-1;
						zDepth[pixel] = a;
						norm[pixel] = sideNorm;
					}
					// draw horizontal
					for(int a = s.y1; a < s.y2; a++){
						int pixel = (h2-s.z2+a)*w + x;
						color[pixel] = s.color; // scaleColor(s.color, s.normal*0.6f + (s.z2/(float)h2)*0.4f);
						select[pixel] = s.index;
						yDepth[pixel] = a;
						zDepth[pixel] = (int)s.z2;
						heightMap[a*w + x] = (byte)s.z2;
						norm[pixel] = s.normal;
					}
				}
			}			
		}
		if(preview){
			previewLight();
		} else {
			light();
		}
		
		return buffer;
	}
	
	private void sub(){
		int count = sliceCount;
		for(int i = 0; i < count; i++){
			if(slices[i].overlaps(subSlice)){
				sliceCount = slices[i].sub(subSlice, slices, sliceCount);
			}
		}
	}
	
	public int select(int x, int y){
		return select[y*w + x];
	}
	
	private static final int max(int a, int b){
		return a > b ? a : b;
	}
	
	private static final int min(int a, int b){
		return a < b ? a : b;
	}
	
	private static final int abs(int x){
		return (x + (x >> 31)) ^ (x >> 31);
	}
	
	private void previewLight(){
		for(int y = 0; y < h; y++){
			for(int x = 0; x < w; x++){
				final int offset = y*w + x;
				color[offset] = scaleColor(color[offset], norm[offset]);
			}
		}
	}
	
	private void light(){
		final int h2 = h/2;
		for(int y = 0; y < h; y++){
			for(int x = 0; x < w; x++){
				final int offset = y*w + x;
				final int yp = yDepth[offset];
				final int zp = zDepth[offset];
				int shadows = 0;
				final int x1 = max(0,x-7);
				final int x2 = min(w-1,x+7);
				final int y1 = max(0,yp-13);
				final int y2 = min(h2-1,yp+5);
				for(int i = x1; i < x2; i++){
					for(int j = y1; j < y2; j++){
						if((heightMap[j*w +i ]&0xFF) > zp + abs(x-i)*2){
							shadows++;
						}
					}
				}
				float shadow = SHADOW_TABLE[shadows];
				if(zp == 0 && shadows > 0){
					color[offset] = (int)((1.0f - shadow)*255)<<24;
				} else {
					color[offset] = scaleColor(color[offset], shadow*norm[offset] + zp*0.2f/h2);
				}
			}
		}
	}


	
	private static final float[] SHADOW_TABLE = new float[256];
	static {
		for(int i = 0; i < SHADOW_TABLE.length; i++){
			SHADOW_TABLE[i] = 1.0f - (float)Math.pow(i/(float)SHADOW_TABLE.length, 0.5)*0.5f;
		}
	}

	
	public int scaleColor(int rgb, float v){
		v = Math.min(v,1.0f);
		int a = rgb & 0xFF000000;
		int r = (int)(((rgb>>16)&0xFF)*v);
		int g = (int)(((rgb>>8)&0xFF)*v);
		int b = (int)((rgb&0xFF)*v);
		return a | (r<<16) | (g<<8) | b;
	}

}
