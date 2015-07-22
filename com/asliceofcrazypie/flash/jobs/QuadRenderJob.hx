package com.asliceofcrazypie.flash.jobs;

import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.display.BlendMode;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Vector;

/**
 * ...
 * @author Zaphod
 */
#if flash11
class QuadRenderJob extends BaseRenderJob
{
	private var constants:Vector<Float>;
	private var numConstants:Int = 0;
	private var numQuads:Int = 0;
	
	public function new() 
	{
		super();
	}
	
	override function initData():Void 
	{
		constants = new Vector<Float>();
	}
	
	private function setVertexConstantsFromNumbers(firstRegister:Int, x:Float, y:Float, z:Float = 0, w:Float = 0):Void 
	{
		var offset:Int = firstRegister << 2; // firstRegister * 4
		constants[offset++] = x;
		constants[offset++] = y;
		constants[offset++] = z;
		constants[offset++] = w;
	}
	
	override public function reset():Void 
	{
		super.reset();
		numQuads = 0;
		numConstants = 0;
	}
}
#else
class QuadRenderJob extends BaseRenderJob
{
	private var tileData:Array<Float>;
	private var dataPosition:Int = 0;
	
	public function new()
	{
		super();
		
	}
	
	override function initData():Void 
	{
		tileData = [];
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		dataPosition = 0;
	}
	
	override public function canAddQuad():Bool
	{
		return true;
	}
}
#end