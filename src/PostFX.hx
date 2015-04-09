import openfl.display.BitmapData;
import openfl.geom.Matrix3D;
import openfl.gl.*;
import openfl.utils.*;
import openfl.display.OpenGLView;

class PostFX {

	public static function scale(bitmapdata:BitmapData,factor:Float):BitmapData {

			if (!OpenGLView.isSupported)
				trace("Couldn't get openGL view");


			var shader = "
				/* PASS THRU SHADER */
				#version 120
				varying vec2 vTexCoord;
				uniform sampler2D uImage0;

				void main()
				{
					gl_FragColor = texture2D(uImage0, vTexCoord.xy);
				}";

			ShaderCompositing.init(Std.int(bitmapdata.width*factor), Std.int(bitmapdata.height*factor),true);
			var bp = bitmapdata.clone();
			var composite = ShaderCompositing.uploadLayers ([bp]);

			bp = ShaderCompositing.composite(composite, shader);

			composite.delete();
			composite = null;
			ShaderCompositing.clean();
			return bp;

	}

	// var vertex = "attribute vec4 aPosition;
	// attribute vec2 aTexCoord;
	// varying vec2 vTexCoord;
	// uniform mat4 uMatrix;
	//
	// 			void main(void) {
	// 				//vec4 a = gl_Vertex;
	// 				vTexCoord = vec2 (aTexCoord.x, 1.0-aTexCoord.y); // flip y
	// 				vec4 a = aPosition;
	// 				a.x = a.x * 0.5;
	// 				a.y = a.y * 0.5;
	// 				gl_Position = uMatrix * a;
	// 				gl_Position = uMatrix * aPosition;
	// 			}";

	public static function fxaa(bitmapdata:BitmapData,passes:Int=1):BitmapData {
		if (!OpenGLView.isSupported)
			trace("Couldn't get openGL view");


		var shader = "
			/*
			FXAA fragment shader by Timothy Lottes
			http://timothylottes.blogspot.com/
			GLSL version by Geeks3D
			http://www.geeks3d.com/
			modified and adapted to BGE by Martins Upitis
			http://devlog-martinsh.blogspot.com/
			modified by Simone Cingano
			http://akifox.com

			You need to provide
				vTexCoord: Fragment Coordinates
				uImage0: the Texture
				uImage0Width: the Texture Width
				uImage0Height: the Texture Height
			*/

			#version 120
			varying vec2 vTexCoord;

			uniform sampler2D uImage0; //redered scene texture
			uniform float uImage0Width; //texture width
			uniform float uImage0Height; //texture height

			float width = uImage0Width;
			float height = uImage0Height;

			float FXAA_SUBPIX_SHIFT = 1.0/4.0;
			vec2 rcpFrame = vec2(1.0/width, 1.0/height);
			vec4 posPos = vec4(vTexCoord.st,vTexCoord.st -(rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT)));

			vec3 FxaaPixelShader(vec4 posPos, sampler2D tex, vec2 rcpFrame)
			{
			  //posPos   // Output of FxaaVertexShader interpolated across screen
			  //tex      // Input texture.
			  //rcpFrame // Constant {1.0/frameWidth, 1.0/frameHeight}
			  /*---------------------------------------------------------*/
			  #define FXAA_REDUCE_MIN   (1.0/128.0)
			  #define FXAA_REDUCE_MUL   (1.0/8.0)
			  #define FXAA_SPAN_MAX     8.0
			  /*---------------------------------------------------------*/
			  vec3 rgbNW = texture2D(tex, posPos.zw).xyz;
			  vec3 rgbNE = texture2D(tex, posPos.zw + vec2(1.0,0.0)*rcpFrame.xy).xyz;
			  vec3 rgbSW = texture2D(tex, posPos.zw + vec2(0.0,1.0)*rcpFrame.xy).xyz;
			  vec3 rgbSE = texture2D(tex, posPos.zw + vec2(1.0,1.0)*rcpFrame.xy).xyz;
			  vec3 rgbM  = texture2D(tex, posPos.xy).xyz;
			  /*---------------------------------------------------------*/
			  vec3 luma = vec3(0.299, 0.587, 0.114);
			  float lumaNW = dot(rgbNW, luma);
			  float lumaNE = dot(rgbNE, luma);
			  float lumaSW = dot(rgbSW, luma);
			  float lumaSE = dot(rgbSE, luma);
			  float lumaM  = dot(rgbM,  luma);
			  /*---------------------------------------------------------*/
			  float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
			  float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
			  /*---------------------------------------------------------*/
			  vec2 dir;
			  dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
			  dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
			  /*---------------------------------------------------------*/
			  float dirReduce = max(
			    (lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
			    FXAA_REDUCE_MIN);
			  float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
			  dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
			      max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
			      dir * rcpDirMin)) * rcpFrame.xy;
			  /*--------------------------------------------------------*/
			  vec3 rgbA = (1.0/2.0) * (
			  texture2D(tex, posPos.xy + dir * (1.0/3.0 - 0.5)).xyz +
			  texture2D(tex, posPos.xy + dir * (2.0/3.0 - 0.5)).xyz);
			  vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
			  texture2D(tex, posPos.xy + dir * (0.0/3.0 - 0.5)).xyz +
			    texture2D(tex, posPos.xy + dir * (3.0/3.0 - 0.5)).xyz);
			  float lumaB = dot(rgbB, luma);
			  if((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;
			  return rgbB;
			}

			vec4 PostFX(sampler2D tex, vec2 uv)
			{
			  vec4 c = texture2D(tex, uv.xy);
			  vec2 rcpFrame = vec2(1.0/width, 1.0/height);
			  vec3 fxaa = FxaaPixelShader(posPos, tex, rcpFrame);

			  return vec4(fxaa,c.a);
			}

			void main()
			{
			  gl_FragColor = PostFX(uImage0, vTexCoord);
				//gl_FragColor = texture2D(uImage0, vTexCoord.xy);
			}";

		ShaderCompositing.init(bitmapdata.width, bitmapdata.height);
		var bp = bitmapdata.clone();
		for (el in 0...passes) {
			var composite = ShaderCompositing.uploadLayers ([bp]);

			bp = ShaderCompositing.compositeParams(composite, shader,
																							[{name: "uImage0Width", value: bitmapdata.width, type: Float},
																							 {name: "uImage0Height", value: bitmapdata.height, type: Float}]);

			composite.delete();
			composite = null;
		}
		ShaderCompositing.clean ();
		return bp;

	}

public static function fxaaOutline(bitmapdata:BitmapData,passes:Int=1,outline:Int=0):BitmapData {
	if (!OpenGLView.isSupported)
		trace("Couldn't get openGL view");

	if (outline==0) outline = 1;

	var shader = "
		/*
		FXAA fragment shader by Timothy Lottes
		http://timothylottes.blogspot.com/
		GLSL version by Geeks3D
		http://www.geeks3d.com/
		modified and adapted to BGE by Martins Upitis
		http://devlog-martinsh.blogspot.com/
		modified by Simone Cingano
		http://akifox.com

		You need to provide
			vTexCoord: Fragment Coordinates
			uImage0: the Texture
			uImage0Width: the Texture Width
			uImage0Height: the Texture Height
		*/

		#version 120
		varying vec2 vTexCoord;

		uniform sampler2D uImage0; //redered scene texture
		uniform float uImage0Width; //texture width
		uniform float uImage0Height; //texture height
		uniform float uOutline; //texture height

		float width = uImage0Width;
		float height = uImage0Height;

		float FXAA_SUBPIX_SHIFT = 1.0/4.0;
		vec2 rcpFrame = vec2(1.0/width, 1.0/height);
		vec4 posPos = vec4(vTexCoord.st,vTexCoord.st -(rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT)));

		vec3 FxaaPixelShader(vec4 posPos, sampler2D tex, vec2 rcpFrame)
		{
			//posPos   // Output of FxaaVertexShader interpolated across screen
			//tex      // Input texture.
			//rcpFrame // Constant {1.0/frameWidth, 1.0/frameHeight}
			/*---------------------------------------------------------*/
			#define FXAA_REDUCE_MIN   (1.0/128.0)
			#define FXAA_REDUCE_MUL   (1.0/8.0)
			#define FXAA_SPAN_MAX     8.0
			/*---------------------------------------------------------*/
			vec3 rgbNW = texture2D(tex, posPos.zw).xyz;
			vec3 rgbNE = texture2D(tex, posPos.zw + vec2(1.0,0.0)*rcpFrame.xy).xyz;
			vec3 rgbSW = texture2D(tex, posPos.zw + vec2(0.0,1.0)*rcpFrame.xy).xyz;
			vec3 rgbSE = texture2D(tex, posPos.zw + vec2(1.0,1.0)*rcpFrame.xy).xyz;
			vec3 rgbM  = texture2D(tex, posPos.xy).xyz;
			/*---------------------------------------------------------*/
			vec3 luma = vec3(0.299, 0.587, 0.114);
			float lumaNW = dot(rgbNW, luma);
			float lumaNE = dot(rgbNE, luma);
			float lumaSW = dot(rgbSW, luma);
			float lumaSE = dot(rgbSE, luma);
			float lumaM  = dot(rgbM,  luma);
			/*---------------------------------------------------------*/
			float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
			float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
			/*---------------------------------------------------------*/
			vec2 dir;
			dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
			dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
			/*---------------------------------------------------------*/
			float dirReduce = max(
				(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
				FXAA_REDUCE_MIN);
			float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
			dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
					max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
					dir * rcpDirMin)) * rcpFrame.xy;
			/*--------------------------------------------------------*/
			vec3 rgbA = (1.0/2.0) * (
			texture2D(tex, posPos.xy + dir * (1.0/3.0 - 0.5)).xyz +
			texture2D(tex, posPos.xy + dir * (2.0/3.0 - 0.5)).xyz);
			vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
			texture2D(tex, posPos.xy + dir * (0.0/3.0 - 0.5)).xyz +
				texture2D(tex, posPos.xy + dir * (3.0/3.0 - 0.5)).xyz);
			float lumaB = dot(rgbB, luma);
			if((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;
			return rgbB;
		}

		vec4 PostFX(sampler2D tex, vec2 uv, float outline)
		{
			vec4 c = texture2D(tex, uv.xy);
			vec2 rcpFrame = vec2(1.0/width, 1.0/height);
			vec3 fxaa = FxaaPixelShader(posPos, tex, rcpFrame);

			// fix for blending issues with alpha
			// it blurs the pixels around
			float alpha = c.a*outline;
			alpha += texture2D(tex, posPos.xy + vec2(1.0,1.0)*rcpFrame.xy).a;
			alpha += texture2D(tex, posPos.xy + vec2(-1.0,1.0)*rcpFrame.xy).a;
			alpha += texture2D(tex, posPos.xy + vec2(-1.0,-1.0)*rcpFrame.xy).a;
			alpha += texture2D(tex, posPos.xy + vec2(1.0,-1.0)*rcpFrame.xy).a;
			// alpha += texture2D(tex, posPos.xy + vec2(2.0,2.0)*rcpFrame.xy).a;
			// alpha += texture2D(tex, posPos.xy + vec2(-2.0,2.0)*rcpFrame.xy).a;
			// alpha += texture2D(tex, posPos.xy + vec2(-2.0,-2.0)*rcpFrame.xy).a;
			// alpha += texture2D(tex, posPos.xy + vec2(2.0,-2.0)*rcpFrame.xy).a;
			// alpha /=(outline+8.0);
			alpha /=(outline+4.0);

			return vec4(fxaa,alpha);
		}

		void main()
		{
			gl_FragColor = PostFX(uImage0, vTexCoord, uOutline);
			//gl_FragColor = texture2D(uImage0, vTexCoord.xy, uOutline);
		}";

		ShaderCompositing.init(bitmapdata.width, bitmapdata.height);
		var bp = bitmapdata.clone();
		for (el in 0...passes) {
			var composite = ShaderCompositing.uploadLayers ([bp]);

			bp = ShaderCompositing.compositeParams(composite, shader,
																							[{name: "uImage0Width", value: bitmapdata.width, type: Float},
																							{name: "uImage0Height", value: bitmapdata.height, type: Float},
																							{name: "uOutline", value: outline, type: Float}]);

			composite.delete();
			composite = null;
		}
		ShaderCompositing.clean ();
		return bp;

	}

}

class ShaderCompositing {

	private static var fb_texture : GLTexture;
	private static var fb_framebuffer : GLFramebuffer;
	private static var fb_renderbuffer : GLRenderbuffer;
	private static var fb_vertexShader : GLShader;

	private static var viewport_width:Int = 0;
	private static var viewport_height:Int = 0;
	private static var viewport_force:Bool = false;

	public static function init (maxWidth:Int, maxHeight:Int, ?forceViewport:Bool=false, ?vertexSource:String="") : Void {

				viewport_width = maxWidth;
				viewport_height = maxHeight;
				viewport_force = forceViewport;

				fb_texture = GL.createTexture ();
        GL.bindTexture (GL.TEXTURE_2D, fb_texture);
        GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
        GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
        GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
        GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);

        GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, maxWidth, maxHeight, 0, GL.RGBA, GL.UNSIGNED_BYTE, null);

        fb_framebuffer = GL.createFramebuffer ();
        GL.bindFramebuffer (GL.FRAMEBUFFER, fb_framebuffer);

        GL.framebufferTexture2D (GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, fb_texture, 0);

        fb_renderbuffer = GL.createRenderbuffer();
        GL.bindRenderbuffer (GL.RENDERBUFFER, fb_renderbuffer);
        GL.renderbufferStorage (GL.RENDERBUFFER, GL.DEPTH_COMPONENT, maxWidth, maxHeight);

        GL.framebufferRenderbuffer (GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, fb_renderbuffer);

        var status = GL.checkFramebufferStatus (GL.FRAMEBUFFER);
        switch (status) {

            case GL.FRAMEBUFFER_COMPLETE:

            default:
				throw ("FrameBuffer error");

        }

        GL.bindFramebuffer (GL.FRAMEBUFFER, null);


				if (vertexSource=="") vertexSource ="
					attribute vec4 aPosition;
					attribute vec2 aTexCoord;
					varying vec2 vTexCoord;
					uniform mat4 uMatrix;
					void main (void) {
						vTexCoord = vec2 (aTexCoord.x, 1.0-aTexCoord.y); // flip y
						gl_Position = uMatrix * aPosition;
					}";

		fb_vertexShader = GLUtils.compileShader (vertexSource, GL.VERTEX_SHADER);

	}

	public static function uploadLayers (layers:Array<BitmapData>) : LayerGroup {

		var textures = new Array<GLTexture>();

		for (layer in layers) {

			var texture = GL.createTexture ();

			GL.bindTexture (GL.TEXTURE_2D, texture);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, layer.width, layer.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, new UInt8Array (
					#if !v2
					//TODO maybe not working on NEXT
					layer.clone().getPixels(new openfl.geom.Rectangle(0,0,layer.width,layer.height))
					#else
					BitmapData.getRGBAPixels(layer.clone())
					#end
			));
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
			GL.bindTexture (GL.TEXTURE_2D, null);

			textures.push (texture);

		}

		return new LayerGroup (textures, layers[0].width, layers[0].height);

	}

	public static function composite (group:LayerGroup, fragmentShader:String) : BitmapData {

		return compositeMulti (group, fragmentShader, null, null);

	}

	public static function compositeParams (group:LayerGroup, fragmentShader:String, params:Array<{name:String, value:Dynamic, type:UniformType}>) : BitmapData {

		return compositeMulti (group, fragmentShader, null, params);

	}

	public static function compositePerLayerParams (group:LayerGroup, fragmentShader:String, perLayerParams:Array<Array<{name:String, value:Dynamic, type:UniformType}>>) : BitmapData {

		return compositeMulti (group, fragmentShader, perLayerParams, null);

	}

	public static function compositeMulti (group:LayerGroup, fragmentShader:String, perLayerParams:Array<Array<{name:String, value:Dynamic, type:UniformType}>>, params:Array<{name:String, value:Dynamic, type:UniformType}>) : BitmapData {

    var width = group.width;
    var height = group.height;

		if (viewport_force) {
      width = viewport_width;
			height = viewport_height;
		}

		GL.bindFramebuffer (GL.FRAMEBUFFER, fb_framebuffer);

		var program = GLUtils.createProgram (fb_vertexShader, fragmentShader);
		GL.useProgram (program);

		var vertexAttribute = GL.getAttribLocation (program, "aPosition");
		var textureAttribute = GL.getAttribLocation (program, "aTexCoord");
		var matrixUniform = GL.getUniformLocation (program, "uMatrix");
		var imageUniform = GL.getUniformLocation (program, "uImage0");

		GL.enableVertexAttribArray (vertexAttribute);
		GL.enableVertexAttribArray (textureAttribute);
		GL.uniform1i (imageUniform, 0);

		var sendUnis = function (params:Array<{name:String, value:Dynamic, type:UniformType}>) : Void {

			for (param in params) {

				var uni = GL.getUniformLocation (program, param.name);

				switch (param.type) {

					case Int:
						GL.uniform1i (uni, cast param.value);

					case Float:
						GL.uniform1f (uni, cast param.value);

					case Int2:
						GL.uniform2iv (uni, cast param.value);

					case Float2:
						GL.uniform2fv (uni, cast param.value);

					case Int3:
						GL.uniform3iv (uni, cast param.value);

					case Float3:
						GL.uniform3fv (uni, cast param.value);

					case Int4:
						GL.uniform4iv (uni, cast param.value);

					case Float4:
						GL.uniform4fv (uni, cast param.value);

				}

			}

		};

		if (params != null) {

			sendUnis (params);

		}

		GL.viewport (0, 0, width, height);

		GL.clearColor (0, 0, 0, 0.0);
		GL.clear (GL.COLOR_BUFFER_BIT);

    GL.blendEquationSeparate(GL.FUNC_ADD,GL.FUNC_ADD);
		GL.blendFuncSeparate(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ZERO);
		//GL.blendFunc(GL.ONE_MINUS_DST_ALPHA,GL.DST_ALPHA); //TODO this blending is better but still need to change FXAA to support ALPHA channel
		GL.enable (GL.BLEND);

		GL.uniformMatrix4fv (matrixUniform, false, group.matrix);

		GL.bindBuffer (GL.ARRAY_BUFFER, group.buffer);
		#if v2
		GL.vertexAttribPointer (vertexAttribute, 3, GL.FLOAT, false, 5 * Float32Array.SBYTES_PER_ELEMENT, 0);
		GL.vertexAttribPointer (textureAttribute, 2, GL.FLOAT, false, 5 * Float32Array.SBYTES_PER_ELEMENT, 3 * Float32Array.SBYTES_PER_ELEMENT);
		#else
		GL.vertexAttribPointer (vertexAttribute, 3, GL.FLOAT, false, 5 * Float32Array.BYTES_PER_ELEMENT, 0);
		GL.vertexAttribPointer (textureAttribute, 2, GL.FLOAT, false, 5 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		#end

		var layerIndex = 0;
		for (texture in group.textures) {

			if (perLayerParams != null) {

				sendUnis (perLayerParams [layerIndex]);

			}

			GL.activeTexture (GL.TEXTURE0);
			GL.bindTexture (GL.TEXTURE_2D, texture);
			GL.enable (GL.TEXTURE_2D);

			GL.drawArrays (GL.TRIANGLE_STRIP, 0, 4);

			layerIndex++;

		}

    var size:Int = width * height;

		#if v2
    var result_rgba = new ByteArray (size*4);
		#else
		//TODO not working on NEXT
		var result_rgba = new ArrayBufferView(size*4);
		#end
    GL.readPixels (0, 0, width, height, GL.RGBA, GL.UNSIGNED_BYTE, result_rgba);

    var result_argb = new ByteArray (size*4);
		for (i in 0...size) {

			#if v2
			var r = result_rgba.readUnsignedByte ();
			var g = result_rgba.readUnsignedByte ();
			var b = result_rgba.readUnsignedByte ();
			var a = result_rgba.readUnsignedByte ();
			#else
			//TODO not working on NEXT
			var r = result_rgba.getUInt32(i*4+0);
			var g = result_rgba.getUInt32(i*4+1);
			var b = result_rgba.getUInt32(i*4+2);
			var a = result_rgba.getUInt32(i*4+3);
			#end

			result_argb.writeByte (a);
			result_argb.writeByte (r);
			result_argb.writeByte (g);
			result_argb.writeByte (b);

		}
		result_argb.position = 0;

		var res = new BitmapData (width, height, true);
		res.setPixels (res.rect, result_argb);

		GL.bindFramebuffer (GL.FRAMEBUFFER, null);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		GL.deleteProgram (program);

		return res;

	}

	public static function clean () : Void {

		GL.deleteRenderbuffer (fb_renderbuffer);
		GL.deleteFramebuffer (fb_framebuffer);
		GL.deleteTexture (fb_texture);

	}

}

enum UniformType {

	Int;
	Float;
	Int2;
	Float2;
	Int3;
	Float3;
	Int4;
	Float4;

}

class LayerGroup {

	public var textures : Array<GLTexture>;
	public var width : Int;
	public var height : Int;
	public var buffer : GLBuffer;
	public var matrix : Float32Array;

	public function new (textures:Array<GLTexture>, width:Int, height:Int) {

		this.textures = textures;
		this.width = width;
		this.height = height;

		var data = [

			width, height, 0, 1, 1,
			0, height, 0, 0, 1,
			width, 0, 0, 1, 0,
			0, 0, 0, 0, 0

		];

		buffer = GL.createBuffer ();
		GL.bindBuffer (GL.ARRAY_BUFFER, buffer);
		GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast data), GL.STATIC_DRAW);
		GL.bindBuffer (GL.ARRAY_BUFFER, null);

		var matrix_3d = Matrix3D.createOrtho (0, width, height, 0, -1000, 1000);
		#if v2
		//TODO maybe not working on NEXT
		matrix = Float32Array.fromMatrix (matrix_3d);
		#else
		matrix = Float32Array.fromMatrix(matrix_3d);
		#end

	}

	public function delete () : Void {

		for (texture in textures) {

			GL.deleteTexture (texture);

		}

		GL.deleteBuffer (buffer);

	}

}

/**
 * Modified lime.utils.GLUtils
 * The MIT License (MIT) Copyright (c) 2013-2014 OpenFL contributors
 */
class GLUtils {

	public static function compileShader (source:String, type:Int):GLShader {

		var shader = GL.createShader (type);
		GL.shaderSource (shader, source);
		GL.compileShader (shader);

		if (GL.getShaderParameter (shader, GL.COMPILE_STATUS) == 0) {

			switch (type) {

				case GL.VERTEX_SHADER: throw "Error compiling vertex shader";
				case GL.FRAGMENT_SHADER: throw "Error compiling fragment shader";
				default: throw "Error compiling unknown shader type";

			}

		}

		return shader;

	}

	public static function createProgram (vertexShader:GLShader, fragmentSource:String):GLProgram {

		var fragmentShader = compileShader (fragmentSource, GL.FRAGMENT_SHADER);

		var program = GL.createProgram ();
		GL.attachShader (program, vertexShader);
		GL.attachShader (program, fragmentShader);
		GL.linkProgram (program);

		if (GL.getProgramParameter (program, GL.LINK_STATUS) == 0) {

			throw "Unable to initialize the shader program.";

		}

		return program;

	}

}
