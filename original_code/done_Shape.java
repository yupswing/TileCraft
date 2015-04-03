package nz.co.angryoctopus.lgmodeler;

import nz.co.angryoctopus.lgmodeler.ModelRenderer.Slice;

public class Shape {

	public enum Type {
		CUBE,
		ROUND_CUBE_UP,
		ROUND_CUBE_SIDE,
		CYLINDER_UP,
		CYLINDER_SIDE,
		RAMP_UP,
		RAMP_DOWN,
		ARCH_UP,
		ARCH_DOWN,
		CORNER_SE,
		CORNER_SW,
		CORNER_NW,
		CORNER_NE
	}
	
	private Type type;
	private int x1;
	private int y1;
	private int x2;
	private int y2;
	private int z1;
	private int z2;
	private int color;
	private boolean enabled;
	private boolean locked;
	
	public Shape(Type type){
		this.type = type;
		x1 = 0;
		y1 = 0;
		z1 = 0; 
		x2 = 1;
		y2 = 1;
		z2 = 1;
		color = 1;
		enabled = true;
		locked = false;
	}
	
	public boolean enabled(){
		return enabled;
	}
	
	public boolean locked(){
		return locked;
	}
	
	public void setEnabled(boolean enabled){
		this.enabled = enabled;
	}
	
	public void setLocked(boolean locked){
		this.locked = locked;
	}
	
	public void setColor(int color){
		this.color = color;
	}
	
	public float getNormal(){
		return 1.0f;
	}
	
	public int getColor(){
		return color;
	}
	
	public void setBoundsX(int x1, int x2){
		this.x1 = x1;
		this.x2 = x2;
	}
	
	public void setBoundsY(int y1, int y2){
		this.y1 = y1;
		this.y2 = y2;
	}
	
	public void setBoundsZ(int z1, int z2){
		this.z1 = z1;
		this.z2 = z2;
	}
	
	public void getSlice(int x, int gw, int gh, Slice dest, int[] palette, Model model){
		float dt = (x - x1*gw)/(float)((x2 - x1)*gw);
		dest.index = (byte)model.indexOf(this);
		dest.normal = 1.0f;
		dest.color = palette[color];
		dest.y1 = y1*gh;
		dest.y2 = y2*gh;
		dest.z1 = z1*gh;
		dest.z2 = z2*gh;
		switch(type){
		case CUBE:
			
			break;
		case CYLINDER_UP:
		{
			dt = (dt - 0.5f)*2.0f;
			dt = (float)Math.sqrt(1.0f - dt*dt)*0.999f;
			int y = (dest.y1 + dest.y2)/2;
			dest.y1 = (int)(y - (y2 - y1)*gh*dt*0.5f);
			dest.y2 = (int)(y + (y2 - y1)*gh*dt*0.5f);
			break;
		}
		case CYLINDER_SIDE:
		{
			dt = (dt - 0.5f)*2.0f;
			dt = (float)Math.sqrt(1.0f - dt*dt)*0.999f;
			int z = (dest.z1 + dest.z2)/2;
			dest.z1 = (int)(z - (z2 - z1)*gh*dt*0.5f);
			dest.z2 = (int)(z + (z2 - z1)*gh*dt*0.5f);
			dest.normal = 0.5f + 0.5f*dt;
			break;
		}
		case ROUND_CUBE_UP:
		{
			float corner = Math.min(x2 - x1, y2 - y1)/4.0f;
			float r = corner/(x2 - x1);
			if(dt < r){
				dt /= r;
				dt = 1.0f - (float)Math.sqrt(2.0f*dt - dt*dt)*0.999f;
				dest.y1 += (int)(corner*gh*dt);
				dest.y2 -= (int)(corner*gh*dt);
			} else if (dt > (1.0 - r)){
				dt = (1.0f - dt)/r;
				dt = 1.0f - (float)Math.sqrt(2.0f*dt - dt*dt)*0.999f;
				dest.y1 += (int)(corner*gh*dt);
				dest.y2 -= (int)(corner*gh*dt);
			}
			break;
		}
		case ROUND_CUBE_SIDE:
		{
			float corner = Math.min(z2 - z1, x2 - x1)/4.0f;
			float r = corner/(x2 - x1);
			if(dt < r){
				dt /= r;
				dt = 1.0f - (float)Math.sqrt(2.0f*dt - dt*dt)*0.999f;
				dest.z1 += (int)(corner*gh*dt);
				dest.z2 -= (int)(corner*gh*dt);
				dest.normal = 0.5f + 0.5f*(1.0f - dt);
			} else if (dt > (1.0 - r)){
				dt = (1.0f - dt)/r;
				dt = 1.0f - (float)Math.sqrt(2.0f*dt - dt*dt)*0.999f;
				dest.z1 += (int)(corner*gh*dt);
				dest.z2 -= (int)(corner*gh*dt);
				dest.normal = 0.5f + 0.5f*(1.0f - dt);
			}
			break;
		
		}
		case RAMP_UP:
		{
			dest.z2 = Math.min(dest.z2, dest.z1 + (int)(gh*dt*(z2 - z1))+1);
			dest.normal = 0.9f;
			break;
		}
		case RAMP_DOWN:
		{
			dest.z2 = Math.min(dest.z2, dest.z1 + (int)(gh*(1.0f - dt)*(z2 - z1))+1);
			dest.normal = 0.8f;
			break;
		}
		case ARCH_UP:
		{
			dest.z1 = dest.z2 - 1 - (int)(gh*(1.0f - dt)*(z2 - z1));
			break;
		}
		case ARCH_DOWN:
		{
			dest.z1 = dest.z2 - 1 - (int)(gh*dt*(z2 - z1));
			break;
		}
		case CORNER_SW:
		{
			dest.y1 = dest.y2 - (int)(gh*(1.0f - dt)*(y2 - y1));
			break;
		}
		case CORNER_SE:
		{
			dest.y1 = dest.y2 - (int)(gh*dt*(y2 - y1));
			break;
		}
		case CORNER_NW:
		{
			dest.y2 = dest.y1 + (int)(gh*(1.0f - dt)*(y2 - y1));
			break;
		}
		case CORNER_NE:
		{
			dest.y2 = dest.y1 + (int)(gh*dt*(y2 - y1));
			break;
		}
		}
	}
	
	public int getX1(){
		return x1;
	}
	
	public int getX2() {
		return x2;
	}

	public int getY1(){
		return y1;
	}
	
	public int getY2(){
		return y2;
	}
	
	public int getZ1(){
		return z1;
	}
	
	public int getZ2(){
		return z2;
	}

	public void setX1(int x) {
		this.x1 = x;
	}
	
	public void setX2(int x){
		this.x2 = x;
	}

	public void setY1(int y) {
		this.y1 = y;
	}
	
	public void setY2(int y){
		this.y2 = y;
	}

	public void setZ1(int z) {
		this.z1 = z;
	}

	public void setZ2(int z) {
		this.z2 = z;
	}

	public Type getType() {
		return type;
	}

	public int getCenterX() {
		return (x1 + x2)/2;
	}

	public int getCenterY() {
		return (y1 + y2)/2;
	}

}
