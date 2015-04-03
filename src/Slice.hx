package;

class Slice {

		public var y1:Int;
    public var y2:Int;
    public var z1:Int;
    public var z2:Int;
    public var color:Int;
    public var index:Int;
    public var normal:Float;

    public function new(y1:Int, z1:Int, y2:Int, z2:Int, color:Int, index:Int, normal:Float) {
      this.set(y1, z1, y2, z2, color, index, normal);
    }

		public function set(y1:Int, z1:Int, y2:Int, z2:Int, color:Int, index:Int, normal:Float):Void{
			this.y1 = y1;
			this.z1 = z1;
			this.y2 = y2;
			this.z2 = z2;
			this.color = color;
			this.index = index;
			this.normal = normal;
		}

		// public function new(l:Slice){
		// 	this.y1 = l.y1;
		// 	this.z1 = l.z1;
		// 	this.y2 = l.y2;
		// 	this.z2 = l.z2;
		// 	this.color = l.color;
		// 	this.index = l.index;
		// 	this.normal = l.normal;
		// }

		public function overlaps(s:Slice):Bool{
			return s.y1 < y2 && s.y2 > y1 && s.z1 < z2 && s.z2 > z1;
		}

		public function sub(s:Slice, slices:Array<Slice>, offset:Int):Int{
			// process z2 plane
			if(s.z2 < z2){
				slices[offset++].set(y1,s.z2,y2,z2,color,index,normal);
			}
			// process z1 plane
			if(s.z1 > z1){
				slices[offset++].set(y1,z1,y2,s.z1,color,index,s.normal);
			}
			// process middle
			var top:Int = Std.int(Math.min(s.z2, z2)); //toround
			var bot:Int = Std.int(Math.max(s.z1, z1)); //toround
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

		public function compare(s:Slice):Int {
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
