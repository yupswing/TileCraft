package;

import openfl.display.BitmapData;

class Renderer {

	private var buffer:BitmapData;
	private var color:Array<Int>;
	private var yDepth:Array<Int>;
	private var zDepth:Array<Int>;
	private var heightMap:Array<Int>;
	private var select:Array<Int>;
	private var norm:Array<Float>;
	private var w:Int;
	private var h:Int;

	private var slices:Array<Slice>;
	private var subSlice = new Slice();
	private var sliceCount:Int;

	public function new(w:Int, h:Int){
		this.w = w;
		this.h = h;
		var h2:Int = Std.int(h/2);
    slices = [for (i in 0...64) new Slice()];

		buffer = new BitmapData(w,h,true);
		color = [for (i in 0...w*h) 0];
		yDepth = [for (i in 0...w*h) 0];
		zDepth = [for (i in 0...w*h) 0];
		heightMap = [for (i in 0...w*h2) 0];
		select = [for (i in 0...w*h) 0];
		norm = [for (i in 0...w*h) 0];
	}

  public static function arrayIntFill(array:Array<Int>,value:Int,?from:Int,?to:Int=0) {
    if (to<=0 || to>array.length) to = array.length;
    if (from<=0 || from>array.length) from = array.length;
    for (i in from...to) {
      array[i]=value;
    }
  }

  public static function arrayFloatFill(array:Array<Float>,value:Float,?from:Int=0,?to:Int=0) {
    if (to<=0 || to>array.length) to = array.length;
    if (from<=0 || from>array.length) from = array.length;
    for (i in from...to) {
      array[i]=value;
    }
  }

	public function render(m:Model, selected:Int, preview:Bool):BitmapData {
		var palette:Array<Int> = m.getPalette();

		var start:Float=0;
		APP.log('-- > RENDERING < -------------------------------------------------');
    APP.log('> BASE FILL'); var startRender = start = haxe.Timer.stamp();
    arrayIntFill(color, 0x00000000);
    arrayIntFill(yDepth, 0);
    arrayIntFill(heightMap, 0);
    arrayIntFill(select, -1);
    arrayFloatFill(norm, 1.0);

		for(y in 0...h){
			if(y < h/2){
        arrayIntFill(zDepth, 1, y*w, (y+1)*w);
			} else {
        arrayIntFill(zDepth, 0, y*w, (y+1)*w);
        arrayIntFill(yDepth, Std.int(y - h/2), y*w, (y+1)*w);
			}
		}

    APP.log('< BASE FILL END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);
    APP.log('> SLICE ELAB START'); start = haxe.Timer.stamp();

		var size:Int = m.getSize();
		var gh:Int = Std.int(h/(size*2));
		var gw:Int = Std.int(w/(size));

		var sideNorm:Float = preview ? 0.7 : 1.0;

		var h2:Int = Std.int(h/2);

    var g:Int = 0;
    while(g<size) {
			var xOffset:Int = g*gw;
      var x:Int = xOffset;
      while(x<xOffset+gw) {
				sliceCount = 0;
				// first get all the shapes that occur in the slice
        var index:Int = 0;
        while(index < m.getShapeCount()) {
					var shape:Shape = m.getShapeByIndex(index);
					if(shape.enabled && shape.getX1() <= g && shape.getX2() > g){
						shape.getSlice(x, gw, gh, subSlice, palette, m);
						sub();
						if(shape.getColor() > 0 || index == selected)
							slices[sliceCount++].setFromSlice(subSlice);
					}
          index++;
				}

				if(sliceCount == 0){
          x++;
					continue;
				}
				// TODO it could be better maybe (too much computation)
        sortSlices(slices,Slice.compareY,sliceCount); //preorder by Y
        sortSlices(slices,Slice.compareZ,sliceCount); //preorder by Z
        sortSlices(slices,Slice.compare,sliceCount); //order slices

        var i:Int = 0;
        while(i<sliceCount) {
					var s:Slice = slices[i];
					if(s.z2 <= s.z1){
            i++;
						continue;
					}
					// draw vertical
          var a:Int = s.z1;
					while(a < s.z2){
						var pixel:Int = Std.int((h2 + s.y2 - a - 1)*w + x);
						color[pixel] = s.color;//scaleColor(s.color, 0.8 + a/(h*4));
						select[pixel] = s.index;
						yDepth[pixel] = s.y2-1;
						zDepth[pixel] = a;
						norm[pixel] = sideNorm;
            a++;
					}
					// draw horizontal
          var a:Int = s.y1;
					while(a < s.y2){
						var pixel:Int = Std.int((h2-s.z2+a)*w + x);
						color[pixel] = s.color;//scaleColor(s.color, s.normal*0.6 + (s.z2/h2)*0.4);
						select[pixel] = s.index;
						yDepth[pixel] = a;
						zDepth[pixel] = s.z2;
						heightMap[a*w + x] = s.z2;
						norm[pixel] = s.normal;
            a++;
					}
          i++;
				}
        x++;
			}
      g++;
		}


		APP.log('< SLICE ELAB END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);
    APP.log('> APPLY LIGHT START'); start = haxe.Timer.stamp();
		if(preview){
			previewLight();
		} else {
			light();
		}
    APP.log('< APPLY LIGHT END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);

    // APP.log('BA START');
    // var ba = new openfl.utils.ByteArray();
    // for (i in 0...color.length) {
    //   ba.writeUnsignedInt(color[i]);
    // }
    // APP.log('BA END');
    //
    // buffer.lock();
    // buffer.setPixels(new openfl.geom.Rectangle(0,0,w,h),ba);
    // buffer.unlock();
    // ba = null;
    // APP.log('BP END');

		APP.log('> DRAW BITMAP START'); start = haxe.Timer.stamp();
    buffer.lock();
    //write to buffer
    for(y in 0...h){
      for (x in 0...w){
        buffer.setPixel32(x,y,color[y*w + x]);
      }
    }
    buffer.unlock();
    APP.log('< DRAW BITMAP END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);
    APP.log('<<< TOTAL RENDERING TIME ' + Std.int((haxe.Timer.stamp()-startRender)*100)/100);
		APP.log('-- > END RENDERING < ------------------------------------------------');

    return buffer;
	}

	private function sub() {
		var count:Int = sliceCount;
    var i:Int = 0;
		while(i < count){
			if(slices[i].overlaps(subSlice)){
				sliceCount = slices[i].sub(subSlice, slices, sliceCount);
			}
      i++;
		}
	}

  private static function sortSlices(slices:Array<Slice>,compare:Slice->Slice->Int,count:Int) {
    for (i in 0...count) {
      var smallsub = i;
      for (j in i+1...count) {
        if (compare(slices[j],slices[smallsub])<0) {
          smallsub = j;
        }
      }
      var swap:Slice = slices[i];
      slices[i] = slices[smallsub];
      slices[smallsub] = swap;
    }
  }

	public function getSelect(x:Int, y:Int):Int{
		return select[y*w + x];
	}

	private static function max(a:Int, b:Int):Int {
		return a > b ? a : b;
	}

	private static function min(a:Int, b:Int):Int{
		return a < b ? a : b;
	}

	private static function abs(x:Int):Int {
		return (x + (x >> 31)) ^ (x >> 31);
	}

	private function previewLight(){
    var y:Int = 0;
    while(y < h){
      var x:Int = 0;
      while(x < w){
				var offset:Int = y*w + x;
				color[offset] = scaleColor(color[offset], norm[offset]);
        x++;
			}
      y++;
		}
	}

	private static inline var LIGHT_X_RADIUS:Int = 6;
	private static inline var LIGHT_Y_RADIUS:Int = 10;

	private function light(){
		var h2:Int = Std.int(h/2);
    var y:Int = 0;
		while(y < h){
      var x:Int = 0;
      while(x < w){
				var offset:Int = y*w + x;
				var yp:Int = yDepth[offset];
				var zp:Int = zDepth[offset];
				var shadows:Int = 0;

				var x1:Int = max(0,x-LIGHT_X_RADIUS); // original 7
				var x2:Int = min(w-1,x+LIGHT_X_RADIUS); // original 7
				var y1:Int = max(0,yp-LIGHT_Y_RADIUS); // original 13
				var y2:Int = min(h2-1,Std.int(yp+LIGHT_Y_RADIUS/2)); // original 5

        var i:Int = x1;
        while(i < x2){
          var j:Int = y1;
          while(j < y2){
						if((heightMap[j*w +i ]&0xFF) > zp + abs(x-i)*2){
							shadows++;
						}
            j++;
					}
          i++;
				}
				var shadow:Float = SHADOW_TABLE[shadows];
				if(zp == 0 && shadows > 0){
					// ground with no surface
					color[offset] = Std.int((1.0 - shadow)*255)<<24;
				} else {
					// ground with surface
					color[offset] = scaleColor(color[offset], shadow*norm[offset]+ zp*0.2/h2);
				}
        x++;
			}
      y++;
		}
	}

  private static inline var SHADOW_TABLE_LENGTH = 256;
	private static var SHADOW_TABLE:Array<Float> = [for(i in 0...SHADOW_TABLE_LENGTH) 1.0-Math.pow(i/SHADOW_TABLE_LENGTH, 0.5)*0.5];


	public function scaleColor(rgb:Int, v:Float):Int{
		v = Math.min(v,1.0);
		var a:Int = rgb & 0xFF000000;
		var r:Int = Std.int(((rgb>>16)&0xFF)*v);
		var g:Int = Std.int(((rgb>>8)&0xFF)*v);
		var b:Int = Std.int((rgb&0xFF)*v);
		return a | (r<<16) | (g<<8) | b;
	}

}

class Slice {
	public var y1:Int;
  public var y2:Int;
  public var z1:Int;
  public var z2:Int;
  public var color:Int;
  public var index:Int;
  public var normal:Float;

  public function new() {
		//nothing
  }

	public function toString():String {
		return '[Slice ($y1,$y2-$z1,$z2)]';
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

	public function setFromSlice(l:Slice){
		this.y1 = l.y1;
		this.z1 = l.z1;
		this.y2 = l.y2;
		this.z2 = l.z2;
		this.color = l.color;
		this.index = l.index;
		this.normal = l.normal;
	}

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

	public static function compareY(s1:Slice,s2:Slice):Int {
		if (s1.y1<s2.y1) return -1;
		return 1;
	}

	public static function compareZ(s1:Slice,s2:Slice):Int {
		if (s1.z1<s2.z1) return -1;
		return 1;
	}

	public static function compare(s1:Slice,s2:Slice):Int {
		if(s1.z2 <= s2.z1){
			return -1;
		} else if (s2.z2 <= s1.z1){
			return 1;
		} else if (s2.y1 >= s1.y2){
			return -1;
		} else {
			return 1;
		}
	}
}
