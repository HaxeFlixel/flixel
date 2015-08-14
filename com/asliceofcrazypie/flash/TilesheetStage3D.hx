package com.asliceofcrazypie.flash;

import com.asliceofcrazypie.flash.jobs.BaseRenderJob;
import com.asliceofcrazypie.flash.jobs.TextureQuadRenderJob;
import com.asliceofcrazypie.flash.jobs.TextureTriangleRenderJob;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.display.BitmapData;
import openfl.display.Tilesheet;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.Lib;
import openfl.text.TextField;

#if flash11
import com.asliceofcrazypie.flash.jobs.QuadRenderJob;
import com.asliceofcrazypie.flash.jobs.TriangleRenderJob;

import flash.errors.Error;
import flash.display3D.Context3D;
import flash.display3D.Context3DRenderMode;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display.Stage;
import flash.display.Graphics;
import flash.display.BlendMode;
import flash.display.TriangleCulling;
import flash.errors.ArgumentError;
import flash.events.ErrorEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;
#end

/**
 * ...
 * @author Paul M Pepper
 */
class TilesheetStage3D extends Tilesheet
{
	public var bitmap(get, null):BitmapData;
	
	public var bitmapWidth(default, null):Int;
	public var bitmapHeight(default, null):Int;
	
	public var originalWidth(default, null):Int;
	public var originalHeight(default, null):Int;
	
	public function new(inImage:BitmapData, premultipliedAlpha:Bool = false, mipmap:Bool = true) 
	{
		originalWidth = inImage.width;
		originalHeight = inImage.height;
		
		#if flash11
		inImage = TextureUtil.fixTextureSize(inImage, _squareTexture);
		#end
		
		super(inImage);
		
		bitmapWidth = inImage.width;
		bitmapHeight = inImage.height;
		
		#if flash11
		this.mipmap = mipmap;
		this.premultipliedAlpha = premultipliedAlpha;
		fallbackMode = FallbackMode.ALLOW_FALLBACK;
		
		if (!_isInited && !Type.enumEq(fallbackMode, FallbackMode.NO_FALLBACK))
		{
			throw new Error('Attemping to create TilesheetStage3D object before Stage3D has initialised.');
		}
		
		if (context != null && context.context3D != null)
		{
			onResetTexture(null);
			context.addEventListener(ContextWrapper.RESET_TEXTURE, onResetTexture);
		}
		#end
	}
	
	public function updateTexture():Void
	{
		#if flash11
		if (texture != null)
		{
			texture.dispose();
		}
		
		onResetTexture(null);
		#end
	}
	
	#if flash11
	private function onResetTexture(e:Event):Void 
	{
		texture = context.uploadTexture(__bitmap, mipmap);
	}
	
	public var premultipliedAlpha(default, null):Bool;
	
	public var mipmap(default, null):Bool;
	
	public var texture(default, null):Texture;
	
	//static vars
	public static var context(default, null):ContextWrapper;
	private static var _isInited:Bool;
	
	//config
	public var fallbackMode:FallbackMode;
	
	//internal
	private static var _stage:Stage;
	private static var _stage3DLevel:Int;
	private static var _initCallback:String->Void;
	private static var _squareTexture:Bool = true;
	
	private static var matrix:Matrix = new Matrix();
	
	private static var flxPoint:FlxPoint = new FlxPoint();
	private static var flxRect1:FlxRect = new FlxRect();
	private static var flxRect2:FlxRect = new FlxRect();
	
	/**
	 * Initialization of all the inner stuff for the rendering (getting stage3d context, creating pools of render jobs, etc.)
	 * 
	 * @param	stage				flash Stage instance.
	 * @param	stage3DLevel		the level of stage3d to use for rendering (on flash11).
	 * @param	antiAliasLevel		Antialising level to use for rendering (on flash11).
	 * @param	initCallback		The method which will be called after initialization of inner stuff.
	 * @param	renderMode			Rendering mode.
	 * @param	batchSize			The max size of batches, used for drawTriangles calls. Should be more than 0 and no more than TriangleRenderJob.MAX_QUADS_PER_BUFFER
	 */
	public static function init(stage:Stage, stage3DLevel:Int = 0, antiAliasLevel:Int = 5, initCallback:String->Void = null, renderMode:Dynamic = null, square:Bool = true, batchSize:Int = 0):Void
	{
		if (!_isInited)
		{
			_isInited = true;
			
			_stage = stage;
			_stage3DLevel = stage3DLevel;
			_initCallback = initCallback;
			_squareTexture = square;
			
			BaseRenderJob.init(batchSize);
			
			#if flash11
			antiAliasing = antiAliasLevel;
			
			if (stage3DLevel < 0 || stage3DLevel >= Std.int(stage.stage3Ds.length))
			{
				throw new ArgumentError('stage3D depth of ' + stage3DLevel + ' out of bounds 0-' + (stage.stage3Ds.length - 1));
			}
			
			context = new ContextWrapper(stage3DLevel);
			context.init(stage, onContextInit, renderMode);
			#else
			onContextInit();
			#end
		}
	}
	
	private static function onContextInit():Void 
	{
		if (_initCallback != null)
		{
			#if flash11
			_initCallback(context.context3D == null ? 'failure' : 'success');
			#else
			_initCallback('success');
			#end
			_initCallback = null;
		}
	}
	
	public static inline function clear():Void
	{
		if (context != null)
		{
			context.clear();
		}
	}
	
	// TODO: support culling...
	/**
	 * Renders a set of triangles, typically to distort bitmaps and give them a three-dimensional appearance.
	 * Works like graphics.drawTriangles().
	 * 
	 * @param	vertices	A Vector of Numbers where each pair of numbers is treated as a coordinate location (an x, y pair). The vertices parameter is required.
	 * @param	indices		A Vector of integers or indexes, where every three indexes define a triangle. 
	 * @param	uvtData		A Vector of normalized coordinates used to apply texture mapping.
	 * @param	culling		Specifies whether to render triangles that face in a specified direction. 
	 * @param	colors		A Vector of integers where each value is used for vertex color tinting.
	 * @param	blending	Blend mode used for the draw call.
	 */
	public function drawTriangles(graphics:Graphics, vertices:Vector<Float>, indices:Vector<Int> = null, uvtData:Vector<Float> = null, culling:TriangleCulling = null, colors:Vector<Int> = null, smooth:Bool = false, blending:BlendMode = null):Void
	{
		if (context != null && context.context3D != null && !Type.enumEq(fallbackMode, FallbackMode.FORCE_FALLBACK))
		{
			var isColored:Bool = (colors != null && colors.length > 0);
			
			var dataPerVertice:Int = (isColored) ? 8 : 4;
			
			var numIndices:Int = indices.length;
			var numVertices:Int = Std.int(vertices.length / 2);
			
			var renderJob:TextureTriangleRenderJob = BaseRenderJob.textureTriangles.getJob();
			renderJob.set(this, isColored, isColored, smooth, blending);
			
			if (numIndices + renderJob.numIndices > TriangleRenderJob.MAX_INDICES_PER_BUFFER)
			{
				throw ("Number of indices shouldn't be more than " + TriangleRenderJob.MAX_INDICES_PER_BUFFER);
			}
			
			if (numVertices + renderJob.numIndices > TriangleRenderJob.MAX_VERTEX_PER_BUFFER)
			{
				throw ("Number of vertices shouldn't be more than " + TriangleRenderJob.MAX_VERTEX_PER_BUFFER);
			}
			
			renderJob.addTriangles(vertices, indices, uvtData, colors);
			context.addTriangleJob(renderJob);
		}
		else if(!Type.enumEq(fallbackMode, FallbackMode.NO_FALLBACK))
		{
			graphics.drawTriangles(vertices, indices, uvtData, culling);
		}
	}
	
	override public function drawTiles(graphics:Graphics, tileData:Array<Float>, smooth:Bool = false, flags:Int = 0, count:Int = -1):Void
	{
		if (context != null && context.context3D != null && !Type.enumEq(fallbackMode, FallbackMode.FORCE_FALLBACK))
		{
			//parse flags
			var isMatrix:Bool = (flags & Tilesheet.TILE_TRANS_2x2) > 0;
			var isScale:Bool = (flags & Tilesheet.TILE_SCALE) > 0;
			var isRotation:Bool = (flags & Tilesheet.TILE_ROTATION) > 0;
			var isRGB:Bool = (flags & Tilesheet.TILE_RGB) > 0;
			var isAlpha:Bool = (flags & Tilesheet.TILE_ALPHA) > 0;
			var isBlendAdd:Bool = (flags & Tilesheet.TILE_BLEND_ADD) > 0;
			var isBlendMultiply:Bool = (flags & Tilesheet.TILE_BLEND_MULTIPLY) > 0;
			var isBlendScreen:Bool = (flags & Tilesheet.TILE_BLEND_SCREEN) > 0;
			var isRect:Bool = (flags & Tilesheet.TILE_RECT) > 0;
			var isOrigin:Bool = (flags & Tilesheet.TILE_ORIGIN) > 0;
			
			var scale:Float = 1;
			var rotation:Float = 0;
			var cosRotation:Float = 1;
			var sinRotation:Float = 0;
			var r:Float = 1;
			var g:Float = 1;
			var b:Float = 1;
			var a:Float = 1;
			
			var rect:Rectangle;
			var origin:Point;
			var uv:Rectangle;
			var tileId:Int;
			
			//determine data structure based on flags
			var tileDataPerItem:Int = 3;
			var dataPerVertice:Int = 4;
			
			var xOff:Int = 0;
			var yOff:Int = 1;
			var tileIdOff:Int = 2;
			var scaleOff:Int = 0;
			var rotationOff:Int = 0;
			var matrixOff:Int = 0;
			var matrixPos:Int = 0;
			var rOff:Int = 0;
			var gOff:Int = 0;
			var bOff:Int = 0;
			var aOff:Int = 0;
			
			if (isRect) { tileDataPerItem = isOrigin ? 8 : 6; }
			
			if (isMatrix) 
			{ 
				matrixOff = tileDataPerItem; tileDataPerItem += 4; 
			}
			else
			{
				if (isScale) { scaleOff = tileDataPerItem; tileDataPerItem++; }
				if (isRotation) { rotationOff = tileDataPerItem; tileDataPerItem++; }
			}
			
			if (isRGB) 
			{
				rOff = tileDataPerItem;
				gOff = tileDataPerItem + 1;
				bOff = tileDataPerItem + 2;
				tileDataPerItem += 3;
				dataPerVertice += 3;
			}
			
			if (isAlpha) 
			{
				aOff = tileDataPerItem; 
				tileDataPerItem++;
				dataPerVertice++;
			}
			
			var totalCount = count;
			
			if (count < 0) 
			{	
				totalCount = tileData.length;
			}
			
			var numItems:Int = Std.int(totalCount / tileDataPerItem);
			
			if (numItems == 0)
			{
				return;
			}
			
			if (totalCount % tileDataPerItem != 0)
			{
				throw new ArgumentError('tileData length must be a multiple of ' + tileDataPerItem);
			}
			
			var renderJob:TextureQuadRenderJob;
			
			var tileDataPos:Int = 0;
			
			var transform_tx:Float, transform_ty:Float, transform_a:Float, transform_b:Float, transform_c:Float, transform_d:Float;
			
			///////////////////
			// for each item //
			///////////////////
			var maxNumItems:Int = TextureQuadRenderJob.limit;
			var startItemPos:Int = 0;
			var numItemsThisLoop:Int = 0;
			
			var blend:BlendMode = BlendMode.NORMAL;
			if (isBlendAdd)
			{
				blend = BlendMode.ADD;
			}
			else if (isBlendMultiply)
			{
				blend = BlendMode.MULTIPLY;
			}
			else if (isBlendScreen)
			{
				blend = BlendMode.SCREEN;
			}
			
			while (tileDataPos < totalCount)
			{
				numItemsThisLoop = numItems > maxNumItems ? maxNumItems : numItems;
				numItems -= numItemsThisLoop;
				
				renderJob = BaseRenderJob.textureQuads.getJob();
				renderJob.set(this, isRGB, isAlpha, smooth, blend);
				
				for (i in 0...numItemsThisLoop)
				{
					rect = null;
					origin = null;
					uv = null;
					
					r = g = b = a = 1.0;
					
					if (isRect) 
					{ 
						rect = __rectTile;
						origin = __point;
						
						rect.setTo(	tileData[tileDataPos + 2], 
									tileData[tileDataPos + 3], 
									tileData[tileDataPos + 4], 
									tileData[tileDataPos + 5]);
						
						if (isOrigin)
						{
							origin.setTo(	tileData[tileDataPos + 6] / rect.width, 
											tileData[tileDataPos + 7] / rect.height);
						}
						else
						{
							origin.setTo(0, 0);
						}
						
						uv = __rectUV;
						uv.setTo(rect.left / __bitmapWidth, rect.top / __bitmapHeight, rect.right / __bitmapWidth, rect.bottom / __bitmapHeight);
					}
					else
					{
						tileId = Std.int(tileData[tileDataPos + tileIdOff]);
						origin = __centerPoints[tileId];
						uv = __tileUVs[tileId];
						rect = __tileRects[tileId];
					}
					
					//calculate transforms
					transform_tx = tileData[tileDataPos + xOff];
					transform_ty = tileData[tileDataPos + yOff];
					
					if (isMatrix)
					{
						matrixPos = tileDataPos + matrixOff;
						transform_a = tileData[matrixPos++];
						transform_b = tileData[matrixPos++];
						transform_c = tileData[matrixPos++];
						transform_d = tileData[matrixPos++];
					}
					else
					{
						if (isScale)
						{
							scale = tileData[tileDataPos + scaleOff];
						}
						
						if (isRotation)
						{
							rotation = -tileData[tileDataPos + rotationOff];
							cosRotation = Math.cos(rotation);
							sinRotation = Math.sin(rotation);
						}
						
						transform_a = scale * cosRotation;
						transform_c = scale * -sinRotation;
						transform_b = scale * sinRotation;
						transform_d = scale * cosRotation;
					}
					
					if (isRGB)
					{
						r = tileData[tileDataPos + rOff];
						g = tileData[tileDataPos + gOff];
						b = tileData[tileDataPos + bOff];
					}
					
					if (isAlpha)
					{
						a = tileData[tileDataPos + aOff];
					}
					
					matrix.setTo(transform_a, transform_b, transform_c, transform_d, transform_tx, transform_ty);
					
					flxPoint.copyFromFlash(origin);
					flxRect1.copyFromFlash(rect);
					flxRect2.copyFromFlash(uv);
					renderJob.addQuad(flxRect1, flxPoint, flxRect2, matrix, r, g, b, a);
					
					tileDataPos += tileDataPerItem;
				}
				
				//push vertices into jobs list
				context.addQuadJob(renderJob);
			}//end while
		}
		else if(!Type.enumEq(fallbackMode, FallbackMode.NO_FALLBACK))
		{
			super.drawTiles(graphics, tileData, smooth, flags, count);
		}
	}
	
	public static var antiAliasing(default, set):Int;
	
	private static inline function set_antiAliasing(value:Int):Int
	{
		antiAliasing = value > 0 ? value < 16 ? value : 16 : 0; //limit value to 0-16
		
		if (context != null && context.context3D != null)
		{
			context.onStageResize(null);
		}
		
		return antiAliasing;
	}
	
	public static var driverInfo(get, never):String;
	
	private static function get_driverInfo():String
	{
		if (context != null && context.context3D != null)
		{
			return context.context3D.driverInfo;
		}
		
		return '';
	}
	
	public function dispose():Void
	{
		this.fallbackMode = null;
		
		if (this.texture != null)
		{
			this.texture.dispose();
			this.texture = null;
		}
		
		if (this.__bitmap != null)
		{
			this.__bitmap.dispose();
			this.__bitmap = null;
		}
		
		__ids = null;
		__indices = null;
		__uvs = null;
		__vertices = null;
	}
	#else
	public function dispose():Void
	{
		
	}
	#end
	
	private function get_bitmap():BitmapData
	{
		return __bitmap;
	}
}

#if flash11
enum FallbackMode
{
	NO_FALLBACK;
	ALLOW_FALLBACK;
	FORCE_FALLBACK;
}
#end