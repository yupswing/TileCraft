package;

import openfl.display.BitmapData;


class ModelRenderer {

	private var buffer:BitmapData;
	private var color:Array<UInt>;
	private var yDepth:Array<UInt>;
	private var zDepth:Array<UInt>;
	private var heightMap:Array<UInt>;
	private var select:Array<UInt>;
	private var norm:Array<Float>;
	private var w:UInt;
	private var h:UInt;

	private var slices:Array<Slice>;
	private var subSlice = new Slice();
	private var sliceCount:UInt;

	public function new(w:UInt, h:UInt){
		this.w = w;
		this.h = h;
		var h2:UInt = Std.int(h/2);
    slices = [for (i in 0...64) new Slice()];

		buffer = new BitmapData(w,h,true);
		color = [for (i in 0...w*h) 0];
		yDepth = [for (i in 0...w*h) 0];
		zDepth = [for (i in 0...w*h) 0];
		heightMap = [for (i in 0...w*h2) 0];
		select = [for (i in 0...w*h) 0];
		norm = [for (i in 0...w*h) 0];
	}

  public static function arrayUIntFill(array:Array<UInt>,value:UInt,?from:UInt,?to:UInt=0) {
    if (to<=0 || to>array.length) to = array.length;
    if (from<=0 || from>array.length) from = array.length;
    for (i in from...to) {
      array[i]=value;
    }
  }

  public static function arrayFloatFill(array:Array<Float>,value:Float,?from:UInt=0,?to:UInt=0) {
    if (to<=0 || to>array.length) to = array.length;
    if (from<=0 || from>array.length) from = array.length;
    for (i in from...to) {
      array[i]=value;
    }
  }

	public function render(m:Model, selected:UInt, preview:Bool):BitmapData {
		var palette:Array<UInt> = m.getPalette();


    trace('FILL');
    arrayUIntFill(color, 0x00000000);
    arrayUIntFill(yDepth, 0);
    arrayUIntFill(heightMap, 0);
    arrayUIntFill(select, -1);
    arrayFloatFill(norm, 1.0);

		for(y in 0...h){
			if(y < h/2){
        arrayUIntFill(zDepth, 1, y*w, (y+1)*w);
			} else {
        arrayUIntFill(zDepth, 0, y*w, (y+1)*w);
        arrayUIntFill(yDepth, Std.int(y - h/2), y*w, (y+1)*w);
			}
		}
    trace('SLICE START');

		var size:UInt = m.getSize();
		var gh:UInt = Std.int(h/(size*2));
		var gw:UInt = Std.int(w/(size));

		var sideNorm:Float = preview ? 0.7 : 1.0;

		var h2:UInt = Std.int(h/2);

    var g:UInt = 0;
    while(g<size) {
			var xOffset:UInt = g*gw;
      var x:UInt = xOffset;
      while(x<xOffset+gw) {
				sliceCount = 0;
				// first get all the shapes that occur in the slice
        var index:UInt = 0;
        while(index < m.getShapeCount()) {
					var shape:Shape = m.getShape(index);
					if(shape.enabled && shape.getX1() <= g && shape.getX2() > g){
						if(shape.getColor() == 0 && index != selected){
							shape.getSlice(x, gw, gh, subSlice, palette, m);
							sub();
						} else {
							shape.getSlice(x, gw, gh, subSlice, palette, m);
							sub();
							slices[sliceCount++].setFromSlice(subSlice);
						}
					}
          index++;
				}

				if(sliceCount == 0){
          x++;
					continue;
				}

        sortSlices(slices,Slice.compare,sliceCount);

        var i:UInt = 0;
        while(i<sliceCount) {
					var s:Slice = slices[i];
					if(s.z2 <= s.z1){
            i++;
						continue;
					}
					// draw vertical
          var a:UInt = s.z1;
					while(a < s.z2){
						var pixel:UInt = Std.int((h2 + s.y2 - a - 1)*w + x);
						color[pixel] = s.color; //scaleColor(s.color, 0.8f + a/(Float)(h*4));
						select[pixel] = s.index;
						yDepth[pixel] = s.y2-1;
						zDepth[pixel] = a;
						norm[pixel] = sideNorm;
            a++;
					}
					// draw horizontal
          var a:UInt = s.y1;
					while(a < s.y2){
						var pixel:UInt = Std.int((h2-s.z2+a)*w + x);
						color[pixel] = s.color; // scaleColor(s.color, s.normal*0.6f + (s.z2/(Float)h2)*0.4f);
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


    trace('LIGHT START');
    var start = haxe.Timer.stamp();
		if(preview){
			previewLight();
		} else {
			light();
		}
    trace('LIGHT END ' + (haxe.Timer.stamp()-start));

    // trace('BA START');
    // var ba = new openfl.utils.ByteArray();
    // for (i in 0...color.length) {
    //   ba.writeUnsignedInt(color[i]);
    // }
    // trace('BA END');
    //
    // buffer.lock();
    // buffer.setPixels(new openfl.geom.Rectangle(0,0,w,h),ba);
    // buffer.unlock();
    // ba = null;
    // trace('BP END');

    trace('BP START');
    buffer.lock();
    //write to buffer
    for(y in 0...h){
      for (x in 0...w){
        buffer.setPixel32(x,y,color[y*w + x]);
      }
    }
    buffer.unlock();
    trace('BP END');

    return buffer;
	}

	private function sub() {
		var count:UInt = sliceCount;
    var i:UInt = 0;
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
        if (compare(slices[j],slices[smallsub])<=0) {
          smallsub = j;
        }
      }
      var swap:Slice = slices[i];
      slices[i] = slices[smallsub];
      slices[smallsub] = swap;
    }
  }

	public function getSelect(x:UInt, y:UInt):UInt{
		return select[y*w + x];
	}

	private static function max(a:UInt, b:UInt):UInt {
		return a > b ? a : b;
	}

	private static function min(a:UInt, b:UInt):UInt{
		return a < b ? a : b;
	}

	private static function abs(x:UInt):UInt {
		return (x + (x >> 31)) ^ (x >> 31);
	}

	private function previewLight(){
    var y:UInt = 0;
    while(y < h){
      var x:UInt = 0;
      while(x < w){
				var offset:UInt = y*w + x;
				color[offset] = scaleColor(color[offset], norm[offset]);
        x++;
			}
      y++;
		}
	}

	private function light(){
		var h2:UInt = Std.int(h/2);
    var y:UInt = 0;
		while(y < h){
      var x:UInt = 0;
      while(x < w){
				var offset:UInt = y*w + x;
				var yp:UInt = yDepth[offset];
				var zp:UInt = zDepth[offset];
				var shadows:UInt = 0;
				var x1:UInt = max(0,x-7);
				var x2:UInt = min(w-1,x+7);
				var y1:UInt = max(0,yp-13);
				var y2:UInt = min(h2-1,yp+5);
        var i:UInt = x1;
        while(i < x2){
          var j:UInt = y1;
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
					color[offset] = Std.int((1.0 - shadow)*255)<<24;
				} else {
					color[offset] = scaleColor(color[offset], shadow*norm[offset] + zp*0.2/h2);
				}
        x++;
			}
      y++;
		}
	}

  private static inline var SHADOW_TABLE_LENGTH = 256;
	private static var SHADOW_TABLE:Array<Float> = [for(i in 0...SHADOW_TABLE_LENGTH) 1.0-Math.pow(i/SHADOW_TABLE_LENGTH, 0.5)*0.5];


	public function scaleColor(rgb:UInt, v:Float):UInt{
		v = Math.min(v,1.0);
		var a:UInt = rgb & 0xFF000000;
		var r:UInt = Std.int(((rgb>>16)&0xFF)*v);
		var g:UInt = Std.int(((rgb>>8)&0xFF)*v);
		var b:UInt = Std.int((rgb&0xFF)*v);
		return a | (r<<16) | (g<<8) | b;
	}

}
