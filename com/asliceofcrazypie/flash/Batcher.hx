package com.asliceofcrazypie.flash;

#if flash11
import flash.display3D.Context3DRenderMode;
#end

import com.asliceofcrazypie.flash.jobs.BaseRenderJob;
import flash.display.BlendMode;
import flash.display.Stage;
import flash.display.TriangleCulling;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Vector;
import flixel.FlxGame;
import openfl.display.BitmapData;

import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author Zaphod
 */
class Batcher
{
	/**
	 * Application scale
	 */
	public static var gameScaleX(default, set):Float = 1;
	public static var gameScaleY(default, set):Float = 1;
	
	/**
	 * Application onscreen position
	 */
	public static var gameX(default, set):Float = 0;
	public static var gameY(default, set):Float = 0;
	
	public static var game(default, null):Sprite;
	
	private static var viewports:Array<Viewport>;
	
	public static var numViewports(default, null):Int = 0;
	
	/**
	 * The first viewport.
	 */
	public static var defaultViewport(get, null):Viewport;
	
	#if !flash11
	/**
	 * Helper tilesheet for rendering axis-aligned colored rectangles on native targets.
	 */
	public static var colorsheet:TilesheetStage3D;
	#end
	
	private static var _isInited:Bool = false;
	
	private static inline function get_defaultViewport():Viewport
	{
		if (viewports[0] == null)
		{
			addViewport(0, 0, Lib.current.stage.stageWidth / gameScaleX, Lib.current.stage.stageHeight / gameScaleY, 1, 1);
		}
		
		return viewports[0];
	}
	
	public static function getViewportAt(index:Int):Viewport
	{
		return viewports[index];
	}
	
	public static function addViewport(x:Float, y:Float, width:Float, height:Float, scaleX:Float = 1, scaleY:Float = 1):Viewport
	{
		var viewport:Viewport = new Viewport(x, y, width, height, scaleX, scaleY);
		var index:Int = numViewports;
		viewports[index] = viewport;
		viewport.index = index;
		#if (!FLX_NO_DEBUG || !flash)
		game.addChild(viewport.view);
		#end
		numViewports++;
		return viewport;
	}
	
	public static function addViewportAt(index:Int, x:Float, y:Float, width:Float, height:Float, scaleX:Float = 1, scaleY:Float = 1):Viewport
	{
		var viewport:Viewport = new Viewport(x, y, width, height, scaleX, scaleY);
		setViewportIndex(viewport, index);
		return viewport;
	}
	
	public static function removeViewport(viewport:Viewport, dispose:Bool = true):Void
	{
		var index:Int = viewports.indexOf(viewport);
		removeViewportAt(index, dispose);
	}
	
	public static function removeViewportAt(index:Int, dispose:Bool = true):Void
	{
		if (index >= 0 || index < numViewports)
		{
			var viewport:Viewport = viewports[index];
			#if (!FLX_NO_DEBUG || !flash)
			game.removeChild(viewport.view);
			#end
			if (dispose)	viewport.dispose();
			viewports.splice(index, 1);
			numViewports--;
			updateViewportIndices();
		}
	}
	
	public static function swapViewports(view1:Viewport, view2:Viewport):Void
	{
		var index1:Int = viewports.indexOf(view1);
		var index2:Int = viewports.indexOf(view2);
		swapViewportsAt(index1, index2);
	}
	
	public static function swapViewportsAt(index1:Int, index2:Int):Void
	{
		if (index1 < 0 || index2 < 0 || index1 == index2 || index1 >= numViewports || index2 >= numViewports)	return;
		
		var view1:Viewport = viewports[index1];
		var view2:Viewport = viewports[index2];
		
		viewports[index1] = view2;
		viewports[index2] = view1;
		
		view1.index = index2;
		view2.index = index1;
		#if (!FLX_NO_DEBUG || !flash)
		game.swapChildren(view1.view, view2.view);
		#end
	}
	
	public static function setViewportIndex(viewport:Viewport, index:Int):Void
	{
		viewports.remove(viewport);
		
		if (index < 0)
		{
			index = 0;
		}
		else if (index >= numViewports)
		{
			index = viewports.length;
		}
		
		viewports.insert(index, viewport);
		numViewports = viewports.length;
		#if (!FLX_NO_DEBUG || !flash)
		game.addChildAt(viewport.view, index);
		#end
		updateViewportIndices();
	}
	
	private static inline function updateViewportIndices():Void
	{
		for (i in 0...numViewports)
		{
			viewports[i].index = i; 
		}
	}
	
	private static function set_gameScaleX(value:Float):Float
	{
		gameScaleX = value;
		updateViewports();
		return value;
	}
	
	private static function set_gameScaleY(value:Float):Float
	{
		gameScaleY = value;
		updateViewports();
		return value;
	}
	
	private static function set_gameX(value:Float):Float
	{
		gameX = value;
		updateViewports();
		return value;
	}
	
	private static function set_gameY(value:Float):Float
	{
		gameY = value;
		updateViewports();
		return value;
	}
	
	private static function updateViewports():Void
	{
		
		if (game != null)
		{
			game.scaleX = gameScaleX;
			game.scaleY = gameScaleY;
		}
		
		if (viewports == null)	return;
		
		for (viewport in viewports)
		{
			viewport.update();
		}
	}
	
	/**
	 * Batcher initialization method. It also calls TilesheetStage3D.init() method.
	 */
	public static function init(flxGame:FlxGame, stage3DLevel:Int = 0, antiAliasLevel:Int = 5, initCallback:String->Void = null, renderMode:Dynamic = null, square:Bool = true, batchSize:Int = 0):Void
	{
		if (!_isInited)
		{
			viewports = new Array<Viewport>();
			
			game = new Sprite();
			flxGame.addChild(game);
			var stage:Stage = flxGame.stage;
			
			#if flash11
			TilesheetStage3D.init(stage, stage3DLevel, antiAliasLevel, initCallback, renderMode, square, batchSize);
			TilesheetStage3D.context.renderCallback = render;
			#else
			BaseRenderJob.init(batchSize);
			
			var canvas:BitmapData = new BitmapData(128, 128);
			colorsheet = new TilesheetStage3D(canvas);
			
			initCallback('success');
			#end
			
			_isInited = true;
		}
	}
	
	private static inline function reset():Void
	{
		for (viewport in viewports)
		{
			viewport.reset();
		}
	}
	
	public static inline function render():Void
	{
		#if flash11
		var context = TilesheetStage3D.context;
		#else 
		var context = null;
		#end
		
		for (viewport in viewports)
		{
			viewport.render(context);
		}
	}
	
	public static inline function clear():Void
	{
		#if flash11
		TilesheetStage3D.clear();
		#end
		reset();
	}
}