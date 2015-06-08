package com.asliceofcrazypie.flash;
import com.asliceofcrazypie.flash.jobs.BaseRenderJob;
import haxe.ds.IntMap;

#if flash11
import com.asliceofcrazypie.flash.jobs.RenderJob;
import com.asliceofcrazypie.flash.jobs.QuadRenderJob;
import com.asliceofcrazypie.flash.jobs.TriangleRenderJob;

import openfl.display3D._shaders.AGLSLShaderUtils;

import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display.BlendMode;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;

/**
 * ...
 * @author Paul M Pepper
 */
class ContextWrapper extends EventDispatcher
{
	public static inline var RESET_TEXTURE:String = 'resetTexture';
	
	public var presented:Bool;
	public var context3D:Context3D;
	public var depth(default, null):Int;
	
	public var renderCallback:Void->Void;
	
	private var stage:Stage;
	private var antiAliasLevel:Int;
	private var baseTransformMatrix:Matrix3D;
	
	private var imagePrograms:IntMap<Program3D>;
	private var noImagePrograms:IntMap<Program3D>;
	
	private var _initCallback:Void->Void;
	
	private var currentRenderJobs:Vector<RenderJob>;
	private var quadRenderJobs:Vector<QuadRenderJob>;
	private var triangleRenderJobs:Vector<TriangleRenderJob>;
	
	private var numCurrentRenderJobs:Int = 0;
	
	//avoid unneeded context changes
	private var currentTexture:Texture;
	private var currentProgram:Program3D;
	
	private var globalMultiplier:Vector<Float>;
	
	public function new(depth:Int, antiAliasLevel:Int = 1)
	{
		super();
		
		globalMultiplier = new Vector<Float>();
		
		this.depth = depth;
		this.antiAliasLevel = antiAliasLevel;
		
		imagePrograms = new IntMap<Program3D>();
		noImagePrograms = new IntMap<Program3D>();
		
		currentRenderJobs = new Vector<RenderJob>();
		quadRenderJobs = new Vector<QuadRenderJob>();
		triangleRenderJobs = new Vector<TriangleRenderJob>();
	}
	
	private function getNoImageProgram(globalColor:Bool = false):Program3D
	{
		var programName:UInt = getNoImageProgramName(globalColor);
		
		if (noImagePrograms.exists(programName))
		{
			return noImagePrograms.get(programName);
		}
		
		var vertexString:String =	"m44 op, va0, vc0   \n" +		// 4x4 matrix transform to output clipspace
									"mov v0, va1 		\n";		// move color transform to fragment shader
		
		var fragmentString:String = null;
		if (globalColor)
		{
			fragmentString =	"mul oc, v0, fc0	\n";	// multiply global color by quad color and put result in output color
		}
		else
		{
			fragmentString =	"mov oc, v0			\n";	// output color
		}
		
		var program:Program3D = assembleAgal(vertexString, fragmentString);
		noImagePrograms.set(programName, program);
		return program;
	}
	
	private function getImageProgram(isRGB:Bool, isAlpha:Bool, smooth:Bool, mipmap:Bool, globalColor:Bool = false):Program3D
	{
		var programName:UInt = getImageProgramName(isRGB, isAlpha, mipmap, smooth, globalColor);
		
		if (imagePrograms.exists(programName))
		{
			return imagePrograms.get(programName);
		}
		
		var vertexString:String = null;
		var fragmentString:String = null;
		
		if (isRGB || isAlpha)
		{
			vertexString =	"mov v0, va1      \n" +		// move uv to fragment shader
							"mov v1, va2      \n" +		// move color transform to fragment shader
							"m44 op, va0, vc0 \n";		// multiply position by transform matrix
		}
		else
		{
			vertexString =	"m44 op, va0, vc0 \n" + 	// 4x4 matrix transform to output clipspace
							"mov v0, va1      \n";  	// pass texture coordinates to fragment program
		}
		
		if (globalColor)
		{
			if (isRGB)
			{
				fragmentString =	"tex ft0, v0, fs0 <???> \n" +	// sample texture
									"mul ft1, v1, fc0		\n" +	// multiple sprite color by global color
									"mul oc, ft0, ft1		\n";	// multiply texture by color
			}
			else if (isAlpha)
			{
				fragmentString = 	"tex ft0, v0, fs0 <???>	\n" +	// sample texture
									"mul ft1, fc0, v1.zzz	\n" +	// multiple sprite alpha by global color
									"mul oc, ft0, ft1		\n";	// multiply texture by color
			}
			else
			{
				fragmentString =	"tex ft0, v0, fs0 <???>	\n" +	// sample texture
									"mul oc, ft0, fc0		\n";	// multiply texture by color
			}
		}
		else
		{
			if (isRGB)
			{
				fragmentString =	"tex ft0, v0, fs0 <???> \n" +	// sample texture
									"mul oc, ft0, v1		\n";	// multiply texture by color
			}
			else if (isAlpha)
			{
				fragmentString = 	"tex ft0, v0, fs0 <???>	\n" +	// sample texture
									"mul oc, ft0, v1.zzzz	\n";	// multiply texture by alpha
			}
			else
			{
				fragmentString = "tex oc, v0, fs0 <???> \n"; 		// sample texture 0
			}
		}
		
		fragmentString = StringTools.replace(fragmentString, "<???>", getTextureLookupFlags(mipmap, smooth));
		
		var program:Program3D = assembleAgal(vertexString, fragmentString);
		imagePrograms.set(programName, program);
		return program;
	}
	
	public inline function setTexture(texture:Texture):Void
	{
		if (context3D != null)
		{
			if (texture != currentTexture)
			{
				context3D.setTextureAt(0, texture);
				currentTexture = texture;
			}
		}
	}
	
	public inline function init(stage:Stage, initCallback:Void->Void = null, renderMode:Dynamic):Void
	{
		if (context3D == null)
		{
			if (renderMode == null)
			{
				renderMode = Context3DRenderMode.AUTO;
			}
			
			BlendModeUtil.initBlendFactors();
			
			this.stage = stage;
			this._initCallback = initCallback;
			stage.stage3Ds[depth].addEventListener(Event.CONTEXT3D_CREATE, initStage3D);
			stage.stage3Ds[depth].addEventListener(ErrorEvent.ERROR, initStage3DError);
			stage.stage3Ds[depth].requestContext3D(renderMode);
			
			stage.addEventListener(Event.EXIT_FRAME, onRender, false, -0xFFFFFE);
		}
		else
		{
			if (initCallback != null)
			{
				initCallback();
			}
		}
	}
	
	private function onRender(e:Event):Void 
	{
		render();
		
		if (renderCallback != null)
		{
			renderCallback();
		}
		
		present();
	}
	
	public inline function render():Void
	{
		if (context3D != null && !presented)
		{
			setMatrix(baseTransformMatrix);
			setScissor(null);
			
			for (job in currentRenderJobs)
			{
				renderJob(job);
			}
		}
	}
	
	public inline function renderJob(job:BaseRenderJob, colored:Bool = false):Void
	{
		if (context3D != null && !presented)
		{
			job.render(this, colored);
		}
	}
	
	public inline function present():Void
	{
		if (context3D != null && !presented)
		{
			presented = true;
			context3D.present();
		}
	}
	
	private function initStage3D(e:Event):Void 
	{
		if (context3D != null)
		{
			if (stage.stage3Ds[depth].context3D != context3D)
			{
				context3D = null; //this context has been lost, get new context
			}
		}
		
		if (context3D == null)
		{
			context3D = stage.stage3Ds[depth].context3D;			
			
			if (context3D != null)
			{
				context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				
				baseTransformMatrix = new Matrix3D();
				
				stage.addEventListener(Event.RESIZE, onStageResize); //listen for future stage resize events
				
				imagePrograms = new IntMap<Program3D>();
				noImagePrograms = new IntMap<Program3D>();
				
				onStageResize(null); //init the base transform matrix
				
				clear();
				
				//upload textures
				dispatchEvent(new Event(RESET_TEXTURE));
			}
		}
		
		if (this._initCallback != null)
		{
			this._initCallback();
			this._initCallback = null; //only call once
		}
	}
	
	private function initStage3DError(e:Event):Void 
	{
		
	}
	
	public function onStageResize(e:Event):Void 
	{
		if (context3D != null)
		{
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, TilesheetStage3D.antiAliasing, false);
			
			baseTransformMatrix.identity();
			baseTransformMatrix.appendTranslation( -stage.stageWidth * 0.5, -stage.stageHeight * 0.5, 0);
			baseTransformMatrix.appendScale(2 / stage.stageWidth, -2 / stage.stageHeight, 1);
			setMatrix(baseTransformMatrix);
		}
	}
	
	public inline function clear():Void
	{
		clearJobs();
		
		if (context3D != null)
		{
			context3D.clear(0, 0, 0, 1);
		}
		
		presented = false;
	}
	
	private inline function clearJobs():Int
	{
		for (renderJob in quadRenderJobs)
		{
			renderJob.reset();
			QuadRenderJob.returnJob(renderJob);
		}
		
		for (renderJob in triangleRenderJobs)
		{
			renderJob.reset();
			TriangleRenderJob.returnJob(renderJob);
		}
		
		var numJobs:Int = currentRenderJobs.length;
		untyped currentRenderJobs.length = 0;
		untyped quadRenderJobs.length = 0;
		untyped triangleRenderJobs.length = 0;
		
		numCurrentRenderJobs = 0;
		
		return numJobs;
	}
	
	public function uploadTexture(image:BitmapData, mipmap:Bool = true):Texture
	{
		return TextureUtil.uploadTexture(image, context3D, mipmap);
	}
	
	private inline function doSetProgram(program:Program3D):Void
	{
		if (context3D != null && program != currentProgram)
		{
			context3D.setProgram(program);
			currentProgram = program;
		}
	}
	
	public function setImageProgram(isRGB:Bool, isAlpha:Bool, smooth:Bool, mipmap:Bool = true, globalColor:Bool = false):Void
	{
		var program:Program3D = getImageProgram(isRGB, isAlpha, smooth, mipmap, globalColor);
		doSetProgram(program);
	}
	
	public function setNoImageProgram(globalColor:Bool = false):Void
	{
		var program:Program3D = getNoImageProgram(globalColor);
		doSetProgram(program);
	}
	
	private function assembleAgal(vertexString:String, fragmentString:String, result:Program3D = null):Program3D
	{
		if (context3D == null)	return null;
		
		if (result == null) 
		{
			result = context3D.createProgram();
		}
		
		var vertexByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.VERTEX, vertexString);
		var fragmentByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT, fragmentString);
		
		result.upload(vertexByteCode, fragmentByteCode);
		return result;
	}
	
	private function getNoImageProgramName(globalColor:Bool):UInt
	{
		var bitField:UInt = 0;
		if (globalColor) bitField |= 0x0001;
		return bitField;
	}
	
	private function getImageProgramName(rgb:Bool, alpha:Bool, mipMap:Bool, smoothing:Bool, globalColor:Bool = false):UInt
	{
		var repeat:Bool = true;
		var bitField:UInt = 0;
		
		if (rgb) bitField |= 0x0001;
		if (alpha) bitField |= 0x0002;
		if (mipMap) bitField |= 0x0004;
		if (repeat) bitField |= 0x0008;
		if (smoothing) bitField |= 0x0010;
		if (globalColor) bitField |= 0x0020;
		
		return bitField;
	}
	
	private function getTextureLookupFlags(mipMapping:Bool, smoothing:Bool):String
	{
		var repeat:Bool = true; // making it default for now (to make things simpler)
		
		var options:Array<String> = ["2d", repeat ? "repeat" : "clamp"];
		
		if (smoothing == false) {
			options.push("nearest");
			options.push(mipMapping ? "mipnearest" : "mipnone");
		}
		else {
			options.push("linear");
			options.push(mipMapping ? "miplinear" : "mipnone");
		}
		
		return "<" + options.join("") + ">";
	}
	
	public function setMatrix(matrix:Matrix3D):Void
	{
		if (context3D != null)
		{
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
		}
	}
	
	public function setScissor(rect:Rectangle):Void
	{
		if (context3D != null)
		{
			context3D.setScissorRectangle(rect);
		}
	}
	
	public inline function setBlendMode(blendMode:BlendMode, premultipliedAlpha:Bool):Void
	{
		BlendModeUtil.applyToContext(blendMode, this, premultipliedAlpha);
	}
	
	public function setColorMultiplier(r:Float, g:Float, b:Float, a:Float):Void
	{
		if (context3D != null)
		{
			globalMultiplier[0] = r;
			globalMultiplier[1] = g;
			globalMultiplier[2] = b;
			globalMultiplier[3] = a;
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, globalMultiplier);
		}
	}
	
	public function addQuadJob(job:QuadRenderJob):Void
	{
		currentRenderJobs.push(job);
		quadRenderJobs.push(job);
		
		numCurrentRenderJobs++;
	}
	
	public function addTriangleJob(job:TriangleRenderJob):Void
	{
		currentRenderJobs.push(job);
		triangleRenderJobs.push(job);
		
		numCurrentRenderJobs++;
	}
	
	private static inline function rawDataToBytes(rawData:Array<Int>):ByteArray 
	{
		var bytes:ByteArray = new ByteArray();
		bytes.endian = Endian.LITTLE_ENDIAN;
		
		for (n in rawData)
		{
			bytes.writeByte(n);
		}
		
		return bytes;
	}
	
	//misc methods
	public static inline function clearArray<T>(array:Array<T>):Void
	{
		#if cpp
           array.splice(0, array.length);
        #else
           untyped array.length = 0;
        #end
	}
}
#end