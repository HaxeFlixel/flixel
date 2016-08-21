package flixel.system.render.gl;

import flixel.system.render.common.FlxDrawBaseItem;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Shader;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

#if !display
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
#end

/**
 * ...
 * @author Yanrishatum
 */
class HardwareRenderer extends DisplayObject implements IFlxDestroyable
{
	public static inline var MAX_INDICES_PER_BUFFER:Int = 98298;
	public static inline var MAX_VERTEX_PER_BUFFER:Int = 65532;		// (MAX_INDICES_PER_BUFFER * 4 / 6)
	public static inline var MAX_QUADS_PER_BUFFER:Int = 16383;		// (MAX_VERTEX_PER_BUFFER / 4)
	public static inline var MAX_TRIANGLES_PER_BUFFER:Int = 21844;	// (MAX_VERTEX_PER_BUFFER / 3)
	
	public static inline var ELEMENTS_PER_VERTEX:Int = 8;
	public static inline var ELEMENTS_PER_TILE:Int = 8 * 4;
	public static inline var INDICES_PER_TILE:Int = 6;
	public static inline var MINIMUM_TILE_COUNT_PER_BUFFER:Int = 10;
	public static inline var BYTES_PER_ELEMENT:Int = 4;
	
	// TODO: add batch size limit...
	// and use this var...
	public static var MAX_BATCH_SIZE:Int = 2000;
	
	// TODO: make batching for triangle rendering switchable ON/OFF???
	public static var BATCH_TRIANGLES:Bool = true;
	
	private static var texturedTileShader:TileShader;

	private var states:Array<FlxDrawHardwareItem<Dynamic>>;
	private var stateNum:Int;
	
	#if !flash
	private var __height:Int;
	private var __width:Int;
	#end

	public function new(width:Int, height:Int)
	{
		super();
		
		#if !flash
		__width = width;
		__height = height;
		#end
		
		if (texturedTileShader == null) 
			texturedTileShader = new TileShader();
		
		states = [];
		stateNum = 0;
	}
	
	public function destroy():Void
	{
		// TODO: implement it...
	}

	public function clear():Void
	{
		// TODO: clear states...
		stateNum = 0;
	}

	public function drawItem(item:FlxDrawHardwareItem<Dynamic>):Void
	{
		states[stateNum++] = item;
	}
	
	#if !flash
	@:access(openfl.geom.Rectangle)
	override private function __getBounds(rect:Rectangle, matrix:Matrix):Void 
	{
		var bounds = Rectangle.__temp;
		bounds.setTo(0, 0, __width, __height);
		bounds.__transform(bounds, matrix);
		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);	
	}
	
	override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool 
	{
		if (!hitObject.visible || __isMask) 
			return false;
		
		if (mask != null && !mask.__hitTestMask(x, y))
			return false;
		
		__getWorldTransform();
		
		var px = __worldTransform.__transformInverseX(x, y);
		var py = __worldTransform.__transformInverseY(x, y);
		
		if (px > 0 && py > 0 && px <= __width && py <= __height) 
		{
			if (stack != null && !interactiveOnly) 
			{
				stack.push (hitObject);	
			}
			
			return true;
		}
		
		return false;
		
	}
	
	override private function get_height():Float 
	{	
		return __height;	
	}
	
	override private function set_height(value:Float):Float 
	{	
		return __height = Std.int(value);	
	}
	
	override private function get_width():Float 
	{	
		return __width;	
	}
	
	override private function set_width(value:Float):Float 
	{	
		return __width = Std.int(value);	
	}
	
	override public function __renderGL(renderSession:RenderSession):Void 
	{
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		
		renderSession.shaderManager.setShader(texturedTileShader);
		gl.uniform1f(texturedTileShader.data.uAlpha.index, this.__worldAlpha);
		gl.uniformMatrix4fv(texturedTileShader.data.uMatrix.index, false, renderer.getMatrix(this.__worldTransform));
		
		var blend:BlendMode = null;
		var texture:BitmapData = null;
		
		var i:Int = 0;
		
		while (i < stateNum)
		{
			var state:FlxDrawHardwareItem<Dynamic> = states[i];
			
			if (blend != state.blending)
			{
				renderSession.blendModeManager.setBlendMode(state.blending);
				blend = state.blending;
			}
			
			if (texture != state.graphics.bitmap)
			{
				texture = state.graphics.bitmap;
				gl.bindTexture(gl.TEXTURE_2D, texture.getTexture(gl));
			}
			
			if (texture != null)
			{
				if (state.antialiasing) 
				{
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);	
				} 
				else 
				{
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				}
			}
			
			if (state.glBuffer == null)
			{
				state.glBuffer = gl.createBuffer();
				state.glIndexes = gl.createBuffer();
			}
			
			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, state.glIndexes);
			
			if (state.indexBufferDirty)
			{
				state.indexBufferDirty = false;
				gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, state.indexes, gl.DYNAMIC_DRAW);
			}
			
			gl.bindBuffer(gl.ARRAY_BUFFER, state.glBuffer);
			
			if (state.vertexBufferDirty)
			{
				state.vertexBufferDirty = false;
				gl.bufferData(gl.ARRAY_BUFFER, state.buffer, gl.DYNAMIC_DRAW);
			}
			
			gl.vertexAttribPointer(texturedTileShader.data.aPosition.index, 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 0);
			
			if (texture != null)
			{
				gl.vertexAttribPointer(texturedTileShader.data.aTexCoord.index, 2, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);
			}
			
			gl.vertexAttribPointer(texturedTileShader.data.aColor.index, 4, gl.FLOAT, false, 8 * Float32Array.BYTES_PER_ELEMENT, 4 * Float32Array.BYTES_PER_ELEMENT);
			
			gl.drawElements(gl.TRIANGLES, state.indexPos, gl.UNSIGNED_INT, 0);
			
			i++;
		}
	}
	#end
	
}