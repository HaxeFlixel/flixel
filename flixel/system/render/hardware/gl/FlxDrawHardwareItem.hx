package flixel.system.render.hardware.gl;

import flixel.system.render.hardware.FlxHardwareView;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;

import flixel.system.render.common.FlxDrawBaseItem;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawHardwareItem<T> extends FlxDrawBaseItem<T>
{
	public var buffer:Float32Array;
	public var indexes:UInt32Array;
	
	public var glBuffer:GLBuffer;
	public var glIndexes:GLBuffer;
	
	public var indexBufferDirty:Bool;
	public var vertexBufferDirty:Bool;
	
	public var vertexPos:Int = 0;
	public var indexPos:Int = 0;
	
	public function new() 
	{
		super();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		
		buffer = null;
		indexes = null;
		
		// TODO: delete buffers via gl.deleteBuffer();
		glBuffer = null;
		glIndexes = null;
	}
	
	override public function render(view:FlxHardwareView):Void 
	{
		view.drawItem(this);
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		indexPos = 0;
		vertexPos = 0;
	}
	
	// Set values
	private inline function addTexturedVertexData(x:Float, y:Float, u:Float, v:Float, r:Float = 1.0, g:Float = 1.0, b:Float = 1.0, a:Float = 1.0):Void
	{
		buffer[vertexPos++] = x;
		buffer[vertexPos++] = y;
		buffer[vertexPos++] = u;
		buffer[vertexPos++] = v;
		buffer[vertexPos++] = r;
		buffer[vertexPos++] = g;
		buffer[vertexPos++] = b;
		buffer[vertexPos++] = a;
	}
	
	private inline function addNonTexturedVertexData(x:Float, y:Float, r:Float = 1.0, g:Float = 1.0, b:Float = 1.0, a:Float = 1.0):Void
	{
		buffer[vertexPos++] = x;
		buffer[vertexPos++] = y;
		buffer[vertexPos++] = r;
		buffer[vertexPos++] = g;
		buffer[vertexPos++] = b;
		buffer[vertexPos++] = a;
	}
	
	override private function get_numVertices():Int
	{
		return Std.int(vertexPos / elementsPerVertex);
	}
	
	override private function get_numTriangles():Int
	{
		return Std.int(indexPos / 3);
	}
	
	override function get_elementsPerVertex():Int 
	{
		return (graphics != null) ? HardwareRenderer.ELEMENTS_PER_TEXTURED_VERTEX : HardwareRenderer.ELEMENTS_PER_NONTEXTURED_VERTEX;
	}
	
	override function get_elementsPerTile():Int 
	{
		return (graphics != null) ? HardwareRenderer.ELEMENTS_PER_TEXTURED_TILE : HardwareRenderer.ELEMENTS_PER_NONTEXTURED_TILE;
	}
	
}