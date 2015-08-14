package com.asliceofcrazypie.flash;
import com.asliceofcrazypie.flash.jobs.*;
import haxe.ds.IntMap;

#if flash11
import com.asliceofcrazypie.flash.jobs.QuadRenderJob;
import com.asliceofcrazypie.flash.jobs.TriangleRenderJob;

import com.adobe.utils.extended.AGALMiniAssembler;

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
	public var baseTransformMatrix:Matrix3D;
	
	private var triangleImagePrograms:IntMap<Program3D>;
	private var triangleNoImagePrograms:IntMap<Program3D>;
	
	private var quadImagePrograms:IntMap<Program3D>;
	private var quadNoImagePrograms:IntMap<Program3D>;
	
	private var _initCallback:Void->Void;
	
	private var currentRenderJobs:Vector<BaseRenderJob>;
	private var quadRenderJobs:Vector<TextureQuadRenderJob>;
	private var triangleRenderJobs:Vector<TextureTriangleRenderJob>;
	
	private var numCurrentRenderJobs:Int = 0;
	
	//avoid unneeded context changes
	private var currentTexture:Texture;
	private var currentProgram:Program3D;
	private var currentBlendMode:BlendMode;
	
	private var firstTextureSet:Bool = false;
	private var firstProgramSet:Bool = false;
	private var firstBlendModeSet:Bool = false;
	
	private var globalMultiplier:Vector<Float>;
	
	public function new(depth:Int, antiAliasLevel:Int = 1)
	{
		super();
		
		globalMultiplier = new Vector<Float>();
		
		this.depth = depth;
		this.antiAliasLevel = antiAliasLevel;
		
		triangleImagePrograms = new IntMap<Program3D>();
		triangleNoImagePrograms = new IntMap<Program3D>();
		
		quadImagePrograms = new IntMap<Program3D>();
		quadNoImagePrograms = new IntMap<Program3D>();
		
		currentRenderJobs = new Vector<BaseRenderJob>();
		quadRenderJobs = new Vector<TextureQuadRenderJob>();
		triangleRenderJobs = new Vector<TextureTriangleRenderJob>();
	}
	
	private function getTriangleNoImageProgram(globalColor:Bool = false):Program3D
	{
		var programName:UInt = getNoImageProgramName(globalColor);
		
		if (triangleNoImagePrograms.exists(programName))
		{
			return triangleNoImagePrograms.get(programName);
		}
		
		var vertexString:String =	"m44 op, va0, vc124   \n" +		// 4x4 matrix transform to output clipspace
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
		triangleNoImagePrograms.set(programName, program);
		return program;
	}
	
	private function getTriangleImageProgram(isRGB:Bool, isAlpha:Bool, smooth:Bool, mipmap:Bool, globalColor:Bool = false):Program3D
	{
		var programName:UInt = getImageProgramName(isRGB, isAlpha, mipmap, smooth, globalColor);
		
		if (triangleImagePrograms.exists(programName))
		{
			return triangleImagePrograms.get(programName);
		}
		
		var vertexString:String = null;
		var fragmentString:String = null;
		
		if (isRGB || isAlpha)
		{
			vertexString =	"mov v0, va1      \n" +		// move uv to fragment shader
							"mov v1, va2      \n" +		// move color transform to fragment shader
							"m44 op, va0, vc124 \n";		// multiply position by transform matrix
		}
		else
		{
			vertexString =	"m44 op, va0, vc124 \n" + 	// 4x4 matrix transform to output clipspace
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
									"mul ft0.w, ft0.w, v1.x \n" + 	// multiple texture alpha by sprite alpha
									"mul oc, ft0, fc0		\n";	// multiply texture color by global color
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
									"mul ft0.w, ft0.w, v1.x \n" + 	// multiply texture by alpha
									"mov oc, ft0			\n";	// set output color
			}
			else
			{
				fragmentString =	"tex ft0, v0, fs0 <???> \n" + 
									"mov oc, ft0			\n"; 		// sample texture 0
			}
		}
		
		fragmentString = StringTools.replace(fragmentString, "<???>", getTextureLookupFlags(mipmap, smooth));
		
		var program:Program3D = assembleAgal(vertexString, fragmentString);
		triangleImagePrograms.set(programName, program);
		return program;
	}
	
	private function getQuadNoImageProgram(globalColor:Bool = false):Program3D
	{
		var programName:UInt = getNoImageProgramName(globalColor);
		
		if (quadNoImagePrograms.exists(programName))
		{
			return quadNoImagePrograms.get(programName);
		}
		
		var vertexString:String =
			// Pivot
				"mov vt2, vc[va0.z]			\n" + // originX, originY, width, height
				"sub vt0.z, va0.x, vt2.x	\n" +
				"sub vt0.w, va0.y, vt2.y	\n" +
			// Width and height
				"mul vt0.z, vt0.z, vt2.z	\n" +
				"mul vt0.w, vt0.w, vt2.w	\n" +
			// Tranformation
				"mov vt2, vc[va0.z+1]		\n" + // a, b, c, d
				"mul vt1.z, vt0.z, vt2.x	\n" + // pos.x * a
				"mul vt1.w, vt0.w, vt2.z	\n" + // pos.y * c
				"add vt0.x, vt1.z, vt1.w	\n" + // X
				"mul vt1.z, vt0.z, vt2.y	\n" + // pos.x * b
				"mul vt1.w, vt0.w, vt2.w	\n" + // pos.y * d
				"add vt0.y, vt1.z, vt1.w	\n" + // Y			
			// Translation
				"mov vt2, vc[va0.z+2]		\n" + // x, y, 0, 0
				"add vt0.x, vt0.x, vt2.x	\n" +
				"add vt0.y, vt0.y, vt2.y	\n" +
				"mov vt0.zw, va0.ww			\n" +
			// Projection
//				"m44 op, vt0, vc124\n" +
				"dp4 op.x, vt0, vc124		\n" +
				"dp4 op.y, vt0, vc125		\n" +
				"dp4 op.z, vt0, vc126		\n" +
				"dp4 op.w, vt0, vc127		\n" +
			// Passing color
				"mov v0, vc[va0.z+3]		\n";	// red, green, blue, alpha	
		
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
		quadNoImagePrograms.set(programName, program);
		return program;
	}
	
	private function getQuadImageProgram(smooth:Bool, mipmap:Bool, globalColor:Bool = false):Program3D
	{
		var programName:UInt = getImageProgramName(true, true, mipmap, smooth, globalColor);
		
		if (quadImagePrograms.exists(programName))
		{
			return quadImagePrograms.get(programName);
		}
		
		var vertexString:String =
			// Pivot
				"mov vt2, vc[va0.z]\n" + // originX, originY, width, height
				"sub vt0.z, va0.x, vt2.x\n" +
				"sub vt0.w, va0.y, vt2.y\n" +
			// Width and height
				"mul vt0.z, vt0.z, vt2.z\n" +
				"mul vt0.w, vt0.w, vt2.w\n" +
			// Tranformation
				"mov vt2, vc[va0.z+1]\n" + // a, b, c, d
				"mul vt1.z, vt0.z, vt2.x\n" + // pos.x * a
				"mul vt1.w, vt0.w, vt2.z\n" + // pos.y * c
				"add vt0.x, vt1.z, vt1.w\n" + // X
				"mul vt1.z, vt0.z, vt2.y\n" + // pos.x * b
				"mul vt1.w, vt0.w, vt2.w\n" + // pos.y * d
				"add vt0.y, vt1.z, vt1.w\n" + // Y			
			// Translation
				"mov vt2, vc[va0.z+2]\n" + // x, y, 0, 0
				"add vt0.x, vt0.x, vt2.x\n" +
				"add vt0.y, vt0.y, vt2.y\n" +
				"mov vt0.zw, va0.ww\n" +
			// Projection
//				"m44 op, vt0, vc124\n" +
				"dp4 op.x, vt0, vc124\n" +
				"dp4 op.y, vt0, vc125\n" +
				"dp4 op.z, vt0, vc126\n" +
				"dp4 op.w, vt0, vc127\n" +
			// UV correction and passing out
				"mov vt2, vc[va0.z+3]\n" + // uvScaleX, uvScaleY, uvOffsetX, uvOffsetY
				"mul vt1.x, va0.x, vt2.x\n" +
				"mul vt1.y, va0.y, vt2.y\n" +
				"add vt1.x, vt1.x, vt2.z\n" +
				"add vt1.y, vt1.y, vt2.w\n" +
				"mov v0, vt1.xy\n" +
			// Passing color
				"mov v1, vc[va0.z+4]\n";// red, green, blue, alpha
		
		var fragmentString:String = null;
		
		if (globalColor)
		{
			fragmentString =
				"tex ft0, v0, fs0 <???>\n" +
				"mul ft0, ft0, v1\n" +
				"mul oc, ft0, fc0\n";
		}
		else
		{
			fragmentString =
				"tex ft0, v0, fs0 <???>\n" +
				"mul oc, ft0, v1\n";
		}
		
		fragmentString = StringTools.replace(fragmentString, "<???>", getTextureLookupFlags(mipmap, smooth));
		
		var program:Program3D = assembleAgal(vertexString, fragmentString);
		quadImagePrograms.set(programName, program);
		return program;
	}
	
	public inline function setTexture(texture:Texture):Void
	{
		if (context3D != null)
		{
			if (texture != currentTexture || !firstTextureSet)
			{
				context3D.setTextureAt(0, texture);
				currentTexture = texture;
				firstTextureSet = true;
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
		else if (initCallback != null)
		{
			initCallback();
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
		if (context3D != null && stage.stage3Ds[depth].context3D != context3D)
		{
			context3D = null; //this context has been lost, get new context
		}
		
		if (context3D == null)
		{
			context3D = stage.stage3Ds[depth].context3D;		
			
			if (context3D != null)
			{
				TextureQuadRenderJob.initContextData(this);
				ColorQuadRenderJob.initContextData(this);
				
				context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				
				baseTransformMatrix = new Matrix3D();
				
				stage.addEventListener(Event.RESIZE, onStageResize); //listen for future stage resize events
				
				triangleImagePrograms = new IntMap<Program3D>();
				triangleNoImagePrograms = new IntMap<Program3D>();
				
				quadImagePrograms = new IntMap<Program3D>();
				quadNoImagePrograms = new IntMap<Program3D>();
				
				onStageResize(null); // init the base transform matrix
				
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
		
		currentTexture = null;
		currentProgram = null;
		currentBlendMode = null;
		
		firstTextureSet = false;
		firstProgramSet = false;
		firstBlendModeSet = false;
		
		presented = false;
	}
	
	private inline function clearJobs():Int
	{
		for (renderJob in quadRenderJobs)
		{
			renderJob.reset();
			BaseRenderJob.textureQuads.returnJob(renderJob);
		}
		
		for (renderJob in triangleRenderJobs)
		{
			renderJob.reset();
			BaseRenderJob.textureTriangles.returnJob(renderJob);
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
	
	public inline function doSetProgram(program:Program3D):Void
	{
		if (context3D != null && program != currentProgram)
		{
			context3D.setProgram(program);
			currentProgram = program;
		}
	}
	
	public function setTriangleImageProgram(isRGB:Bool, isAlpha:Bool, smooth:Bool, mipmap:Bool = true, globalColor:Bool = false):Void
	{
		var program:Program3D = getTriangleImageProgram(isRGB, isAlpha, smooth, mipmap, globalColor);
		doSetProgram(program);
	}
	
	public function setTriangleNoImageProgram(globalColor:Bool = false):Void
	{
		var program:Program3D = getTriangleNoImageProgram(globalColor);
		doSetProgram(program);
	}
	
	public function setQuadImageProgram(smooth:Bool, mipmap:Bool = true, globalColor:Bool = false):Void
	{
		var program:Program3D = getQuadImageProgram(smooth, mipmap, globalColor);
		doSetProgram(program);
	}
	
	public function setQuadNoImageProgram(globalColor:Bool = false):Void
	{
		var program:Program3D = getQuadNoImageProgram(globalColor);
		doSetProgram(program);
	}
	
	private function assembleAgal(vertexString:String, fragmentString:String, result:Program3D = null):Program3D
	{
		if (context3D == null)	return null;
		
		if (result == null) 
		{
			result = context3D.createProgram();
		}
		
		var assembler = new AGALMiniAssembler();
		var vertexByteCode = assembler.assemble(cast Context3DProgramType.VERTEX, vertexString);
		var fragmentByteCode = assembler.assemble(cast Context3DProgramType.FRAGMENT, fragmentString);
		
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
		//var repeat:Bool = true; // making it default for now (to make things simpler)
		var repeat:Bool = false; // making it default for now (to make things simpler)
		
		var options:Array<String> = ["2d", repeat ? "repeat" : "clamp"];
		
		if (smoothing == false) 
		{
			options.push("nearest");
			options.push(mipMapping ? "mipnearest" : "mipnone");
		}
		else 
		{
			options.push("linear");
			options.push(mipMapping ? "miplinear" : "mipnone");
		}
		
		return "<" + options.join(",") + ">";
	}
	
	public function setMatrix(matrix:Matrix3D):Void
	{
		if (context3D != null)
		{
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 124, matrix, true);
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
		if (blendMode != currentBlendMode || !firstBlendModeSet)
		{
			BlendModeUtil.applyToContext(blendMode, this, premultipliedAlpha);
			currentBlendMode = blendMode;
			firstBlendModeSet = true;
		}
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
	
	public function addQuadJob(job:TextureQuadRenderJob):Void
	{
		currentRenderJobs.push(job);
		quadRenderJobs.push(job);
		
		numCurrentRenderJobs++;
	}
	
	public function addTriangleJob(job:TextureTriangleRenderJob):Void
	{
		currentRenderJobs.push(job);
		triangleRenderJobs.push(job);
		
		numCurrentRenderJobs++;
	}
}
#end