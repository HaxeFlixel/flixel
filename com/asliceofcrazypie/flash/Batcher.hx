package com.asliceofcrazypie.flash;

import com.asliceofcrazypie.flash.jobs.QuadRenderJob;
import com.asliceofcrazypie.flash.jobs.RenderJob;
import com.asliceofcrazypie.flash.jobs.TriangleRenderJob;
import flash.display.BlendMode;
import flash.display3D.Context3DRenderMode;
import flash.display.Stage;
import flash.display.TriangleCulling;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Vector;
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
	
	private static var viewports:Array<Viewport> = [];
	
	public static var numViewports(default, null):Int;
	
	/**
	 * The first viewport.
	 */
	public static var defaultViewport(get, null):Viewport;
	
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
		for (viewport in viewports)
		{
			viewport.update();
		}
	}
	
	/**
	 * Batcher initialization method. It also calls TilesheetStage3D.init() method.
	 */
	public static function init(stage:Stage, stage3DLevel:Int = 0, antiAliasLevel:Int = 5, initCallback:String->Void = null, renderMode:Context3DRenderMode = null, batchSize:Int = 0):Void
	{
		if (!_isInited)
		{
			TilesheetStage3D.init(stage, stage3DLevel, antiAliasLevel, initCallback, renderMode, batchSize);
			TilesheetStage3D.context.renderCallback = render;
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
		var context = TilesheetStage3D.context;
		for (viewport in viewports)
		{
			viewport.render(context);
		}
	}
	
	public static inline function clear():Void
	{
		TilesheetStage3D.clear();
		reset();
	}
}