package;

import openfl.display.BitmapData;


class ModelRenderer {

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


		trace('>>> START RENDERING'); var startRender = haxe.Timer.stamp();
    trace('> BASE FILL'); var start = haxe.Timer.stamp();
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
    trace('< BASE FILL END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);
    trace('> SLICE ELAB START'); var start = haxe.Timer.stamp();

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


		trace('< SLICE ELAB END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);
    trace('> APPLY LIGHT START'); var start = haxe.Timer.stamp();
		if(preview){
			previewLight();
		} else {
			light();
		}
    trace('< APPLY LIGHT END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);

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

		trace('> DRAW BITMAP START'); var start = haxe.Timer.stamp();
    buffer.lock();
    //write to buffer
    for(y in 0...h){
      for (x in 0...w){
        buffer.setPixel32(x,y,color[y*w + x]);
      }
    }
    buffer.unlock();
    trace('< DRAW BITMAP END ' + Std.int((haxe.Timer.stamp()-start)*100)/100);
    trace('<<< TOTAL RENDERING TIME ' + Std.int((haxe.Timer.stamp()-startRender)*100)/100);

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
