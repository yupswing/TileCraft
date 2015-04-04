package;

enum Kind {
	CUBE;
	ROUND_CUBE_UP;
	ROUND_CUBE_SIDE;
	CYLINDER_UP;
	CYLINDER_SIDE;
	RAMP_UP;
	RAMP_DOWN;
	ARCH_UP;
	ARCH_DOWN;
	CORNER_SE;
	CORNER_SW;
	CORNER_NW;
	CORNER_NE;
}

class Shape {

  public var kind:Kind;
  public var x1:UInt;
  public var y1:UInt;
  public var x2:UInt;
  public var y2:UInt;
  public var z1:UInt;
  public var z2:UInt;
	public var color:UInt;
	public var enabled:Bool;
	public var locked:Bool;

	public function new(kind:Kind){
		this.kind = kind;
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

	public function getX1():UInt { return this.x1; }
	public function getX2():UInt { return this.x2; }
	public function getY1():UInt { return this.y1; }
	public function getY2():UInt { return this.y2; }
	public function getZ1():UInt { return this.z1; }
	public function getZ2():UInt { return this.z2; }

	public function getKind():Kind {
		return this.kind;
	}

	public function getNormal():Float {
		return 1.0;
	}

	public function getColor():UInt {
		return this.color;
	}

	public function setColor(color:UInt) {
		this.color = color;
	}

	public function setBoundsX(x1:UInt, x2:UInt){
		this.x1 = x1;
		this.x2 = x2;
	}

	public function setBoundsY(y1:UInt, y2:UInt){
		this.y1 = y1;
		this.y2 = y2;
	}

	public function setBoundsZ(z1:UInt, z2:UInt){
		this.z1 = z1;
		this.z2 = z2;
	}



	public function getSlice(x:UInt, gw:UInt, gh:UInt, dest:Slice, palette:Array<Int>, model:Model){
		var dt:Float = (x - x1*gw)/((x2 - x1)*gw);
		dest.index = model.indexOf(this);
		dest.normal = 1.0;
		dest.color = palette[color];
		dest.y1 = y1*gh;
		dest.y2 = y2*gh;
		dest.z1 = z1*gh;
		dest.z2 = z2*gh;
		switch(kind){
		case CUBE:
			//none
		case CYLINDER_UP:
			dt = (dt - 0.5)*2.0;
			dt = Math.sqrt(1.0 - dt*dt)*0.999;
			var y:UInt = Std.int((dest.y1 + dest.y2)/2);
			dest.y1 = Std.int(y - (y2 - y1)*gh*dt*0.5);
			dest.y2 = Std.int(y + (y2 - y1)*gh*dt*0.5);
		case CYLINDER_SIDE:
			dt = (dt - 0.5)*2.0;
			dt = Math.sqrt(1.0 - dt*dt)*0.999;
			var z:UInt = Std.int((dest.z1 + dest.z2)/2);
			dest.z1 = Std.int(z - (z2 - z1)*gh*dt*0.5);
			dest.z2 = Std.int(z + (z2 - z1)*gh*dt*0.5);
			dest.normal = 0.5 + 0.5*dt;
		case ROUND_CUBE_UP:
			var corner:Float = Math.min(x2 - x1, y2 - y1)/4.0;
			var r:Float = corner/(x2 - x1);
			if(dt < r){
				dt /= r;
				dt = 1.0 - Math.sqrt(2.0*dt - dt*dt)*0.999;
				dest.y1 += Std.int(corner*gh*dt);
				dest.y2 -= Std.int(corner*gh*dt);
			} else if (dt > (1.0 - r)){
				dt = (1.0 - dt)/r;
				dt = 1.0 - Math.sqrt(2.0*dt - dt*dt)*0.999;
				dest.y1 += Std.int(corner*gh*dt);
				dest.y2 -= Std.int(corner*gh*dt);
			}
		case ROUND_CUBE_SIDE:
			var corner:Float = Math.min(z2 - z1, x2 - x1)/4.0;
			var r:Float = corner/(x2 - x1);
			if(dt < r){
				dt /= r;
				dt = 1.0 - Math.sqrt(2.0*dt - dt*dt)*0.999;
				dest.z1 += Std.int(corner*gh*dt);
				dest.z2 -= Std.int(corner*gh*dt);
				dest.normal = 0.5 + 0.5*(1.0 - dt);
			} else if (dt > (1.0 - r)){
				dt = (1.0 - dt)/r;
				dt = 1.0 - Math.sqrt(2.0*dt - dt*dt)*0.999;
				dest.z1 += Std.int(corner*gh*dt);
				dest.z2 -= Std.int(corner*gh*dt);
				dest.normal = 0.5 + 0.5*(1.0 - dt);
			}
		case RAMP_UP:
			dest.z2 = Std.int(Math.min(dest.z2, dest.z1 + Std.int(gh*dt*(z2 - z1))+1));
			dest.normal = 0.9;
		case RAMP_DOWN:
			dest.z2 = Std.int(Math.min(dest.z2, dest.z1 + Std.int(gh*(1.0 - dt)*(z2 - z1))+1));
			dest.normal = 0.8;
		case ARCH_UP:
			dest.z1 = dest.z2 - 1 - Std.int(gh*(1.0 - dt)*(z2 - z1));
		case ARCH_DOWN:
			dest.z1 = dest.z2 - 1 - Std.int(gh*dt*(z2 - z1));
		case CORNER_SW:
			dest.y1 = dest.y2 - Std.int(gh*(1.0 - dt)*(y2 - y1));
		case CORNER_SE:
			dest.y1 = dest.y2 - Std.int(gh*dt*(y2 - y1));
		case CORNER_NW:
			dest.y2 = dest.y1 + Std.int(gh*(1.0 - dt)*(y2 - y1));
		case CORNER_NE:
			dest.y2 = dest.y1 + Std.int(gh*dt*(y2 - y1));
		}
	}

  public var centerX(get,never):UInt;
	public function get_centerX():UInt{
		return Std.int((x1 + x2)/2);
	}

  public var centerY(get,never):UInt;
	public function get_centerY():UInt{
		return Std.int((y1 + y2)/2);
	}

}
