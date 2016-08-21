package flixel.system.render.gl;

import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;

import flixel.system.render.common.DrawItem.FlxHardwareView;
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
	
}