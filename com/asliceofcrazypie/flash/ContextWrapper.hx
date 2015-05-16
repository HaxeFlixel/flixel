package com.asliceofcrazypie.flash;

#if flash11
import com.asliceofcrazypie.flash.jobs.RenderJob;
import com.asliceofcrazypie.flash.jobs.QuadRenderJob;
import com.asliceofcrazypie.flash.jobs.TriangleRenderJob;

import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
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
	
	public var programRGBASmooth:Program3D;
	public var programRGBSmooth:Program3D;
	public var programASmooth:Program3D;
	public var programSmooth:Program3D;
	public var programRGBA:Program3D;
	public var programRGB:Program3D;
	public var programA:Program3D;
	public var program:Program3D;
	
	private var vertexDataRGBA:ByteArray;
	private var vertexData:ByteArray;
	
	private var fragmentDataRGBASmooth:ByteArray;
	private var fragmentDataRGBSmooth:ByteArray;
	private var fragmentDataASmooth:ByteArray;
	private var fragmentDataSmooth:ByteArray;
	private var fragmentDataRGBA:ByteArray;
	private var fragmentDataRGB:ByteArray;
	private var fragmentDataA:ByteArray;
	private var fragmentData:ByteArray;
	
	private var _initCallback:Void->Void;
	
	private var currentRenderJobs:Vector<RenderJob>;
	private var quadRenderJobs:Vector<QuadRenderJob>;
	private var triangleRenderJobs:Vector<TriangleRenderJob>;
	
	private var numCurrentRenderJobs:Int = 0;
	
	//avoid unneeded context changes
	private var currentTexture:Texture;
	private var currentProgram:Program3D;
	
	public function new(depth:Int, antiAliasLevel:Int = 1)
	{
		super();
		
		this.depth = depth;
		this.antiAliasLevel = antiAliasLevel;
		
		//vertex shader data
		var vertexRawDataRGBA:Array<Int> = 	[ -96, 1, 0, 0, 0, -95, 0, 24, 0, 0, 0, 0, 0, 15, 3, 0, 0, 0, -28, 0, 0, 0, 0, 0, 0, 0, -28, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 4, 1, 0, 0, -28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 15, 4, 2, 0, 0, -28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var vertexRawData:Array<Int> = 		[ -96, 1, 0, 0, 0, -95, 0, 24, 0, 0, 0, 0, 0, 15, 3, 0, 0, 0, -28, 0, 0, 0, 0, 0, 0, 0, -28, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 4, 1, 0, 0, -28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		
		//fragment shaders
		var fragmentRawDataRGBASmooth:Array<Int> = 	[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 16, 3, 0, 0, 0, 2, 0, 15, 2, 1, 0, 0, -28, 2, 0, 0, 0, 1, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 2, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var fragmentRawDataRGBSmooth:Array<Int> = 	[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 16, 3, 0, 0, 0, 1, 0, 15, 2, 1, 0, 0, -28, 2, 0, 0, 0, 1, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 1, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var fragmentRawDataASmooth:Array<Int> = 	[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 16, 3, 0, 0, 0, 1, 0, 8, 2, 1, 0, 0, -1, 2, 0, 0, 0, 1, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 1, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var fragmentRawDataSmooth:Array<Int> = 		[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 16, 0, 0, 0, 0, 0, 0, 15, 3, 1, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var fragmentRawDataRGBA:Array<Int> = 		[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 15, 2, 1, 0, 0, -28, 2, 0, 0, 0, 1, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 2, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var fragmentRawDataRGB:Array<Int> = 		[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 2, 0, 15, 2, 1, 0, 0, -28, 2, 0, 0, 0, 1, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 2, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var fragmentRawDataA:Array<Int> = 			[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 1, 0, 8, 2, 1, 0, 0, -1, 2, 0, 0, 0, 1, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 1, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		var fragmentRawData:Array<Int> = 			[ -96, 1, 0, 0, 0, -95, 1, 40, 0, 0, 0, 1, 0, 15, 2, 0, 0, 0, -28, 4, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 3, 1, 0, 0, -28, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		
		vertexDataRGBA = 	rawDataToBytes(vertexRawDataRGBA);
		vertexData = 		rawDataToBytes(vertexRawData);
		
		fragmentDataRGBASmooth = 	rawDataToBytes(fragmentRawDataRGBASmooth);
		fragmentDataRGBSmooth = 	rawDataToBytes(fragmentRawDataRGBSmooth);
		fragmentDataASmooth = 		rawDataToBytes(fragmentRawDataASmooth);
		fragmentDataSmooth = 		rawDataToBytes(fragmentRawDataSmooth);
		fragmentDataRGBA = 			rawDataToBytes(fragmentRawDataRGBA);
		fragmentDataRGB = 			rawDataToBytes(fragmentRawDataRGB);
		fragmentDataA = 			rawDataToBytes(fragmentRawDataA);
		fragmentData = 				rawDataToBytes(fragmentRawData);
		
		currentRenderJobs = new Vector<RenderJob>();
		quadRenderJobs = new Vector<QuadRenderJob>();
		triangleRenderJobs = new Vector<TriangleRenderJob>();
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
	
	public inline function init(stage:Stage, initCallback:Void->Void = null, renderMode:Context3DRenderMode):Void
	{
		if (context3D == null)
		{
			if (renderMode == null)
			{
				renderMode = Context3DRenderMode.AUTO;
			}
			
			this.stage = stage;
			this._initCallback = initCallback;
			stage.stage3Ds[depth].addEventListener(Event.CONTEXT3D_CREATE, initStage3D);
			stage.stage3Ds[depth].addEventListener(ErrorEvent.ERROR, initStage3DError);
			stage.stage3Ds[depth].requestContext3D(Std.string(renderMode));
			
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
	
	public inline function renderJob(job:RenderJob):Void
	{
		if (context3D != null && !presented)
		{
			job.render(this);
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
				
				//init programs
				programRGBASmooth = context3D.createProgram();
				programRGBASmooth.upload(vertexDataRGBA, fragmentDataRGBASmooth);
				
				programRGBSmooth = context3D.createProgram();
				programRGBSmooth.upload(vertexDataRGBA, fragmentDataRGBSmooth);
				
				programASmooth = context3D.createProgram();
				programASmooth.upload(vertexDataRGBA, fragmentDataASmooth);
				
				programSmooth = context3D.createProgram();
				programSmooth.upload(vertexData, fragmentDataSmooth);
				
				programRGBA = context3D.createProgram();
				programRGBA.upload(vertexDataRGBA, fragmentDataRGBA);
				
				programRGB = context3D.createProgram();
				programRGB.upload(vertexDataRGBA, fragmentDataRGB);
				
				programA = context3D.createProgram();
				programA.upload( vertexDataRGBA, fragmentDataA);
				
				program = context3D.createProgram();
				program.upload(vertexData, fragmentData);
				
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
	
	public function uploadTexture(image:BitmapData):Texture
	{
		return TextureUtil.uploadTexture(image, context3D);
	}
	
	private inline function doSetProgram(program:Program3D):Void
	{
		if (context3D != null && program != currentProgram)
		{
			context3D.setProgram(program);
			currentProgram = program;
		}
	}
	
	public function setProgram(isRGB:Bool, isAlpha:Bool, smooth:Bool):Void
	{
		if (smooth)
		{
			if (isRGB && isAlpha)
			{
				doSetProgram(programRGBASmooth);
			}
			else if (isRGB)
			{
				doSetProgram(programRGBSmooth);
			}
			else if (isAlpha)
			{
				doSetProgram(programASmooth);
			}
			else
			{
				doSetProgram(programSmooth);
			}
		}
		else
		{
			if (isRGB && isAlpha)
			{
				doSetProgram(programRGBA);
			}
			else if (isRGB)
			{
				doSetProgram(programRGB);
			}
			else if (isAlpha)
			{
				doSetProgram(programA);
			}
			else
			{
				doSetProgram(program);
			}
		}
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