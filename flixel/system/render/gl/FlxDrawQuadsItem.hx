package flixel.system.render.gl;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import flixel.system.render.common.DrawItem.FlxHardwareView;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.FlxDrawBaseItem;

import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;

#if !display
import openfl._internal.renderer.RenderSession;
#end

/**
 * ...
 * @author Zaphod
 */
class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{

	public var buffer:Float32Array;
	public var indexes:UInt32Array;
	public var glBuffer:GLBuffer;
	public var glIndexes:GLBuffer;
	
	public var indexBufferDirty:Bool;
	public var vertexBufferDirty:Bool;
	
	/** Current amount of filled data in tiles. */
	public var bufferOffset:Int;
	/** Overall buffer size */
	public var bufferSize:Int;
	
	public var indexCount:Int = 0;
	
	public function new() 
	{
		super();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		ensureElement();
		
		var rect:FlxRect = frame.frame;
		var uv:FlxRect = frame.uv;
		
		var data:Float32Array = buffer;
		var dataIndex:Int = bufferOffset * HardwareRenderer.ELEMENTS_PER_TILE;
		
		// UV
		var uvx:Float = uv.x;
		var uvy:Float = uv.y;
		var uvx2:Float = uv.width;
		var uvy2:Float = uv.height;
		
		// Position
		var x :Float = matrix.__transformX(0, 0); // Top-left
		var y :Float = matrix.__transformY(0, 0);
		var x2:Float = matrix.__transformX(rect.width, 0); // Top-right
		var y2:Float = matrix.__transformY(rect.width, 0);
		var x3:Float = matrix.__transformX(0, rect.height); // Bottom-left
		var y3:Float = matrix.__transformY(0, rect.height);
		var x4:Float = matrix.__transformX(rect.width, rect.height); // Bottom-right
		var y4:Float = matrix.__transformY(rect.width, rect.height);

		var r:Float = 1.0;
		var g:Float = 1.0;
		var b:Float = 1.0;
		var a:Float = 1.0;
		
		if (colored && transform != null)
		{
			if (colored)
			{
				r = transform.redMultiplier;
				g = transform.greenMultiplier;
				b = transform.blueMultiplier;
			}
			
			a = transform.alphaMultiplier;
		}
		
		// Set values
		inline function fillTint():Void
		{
			data[dataIndex++] = r;
			data[dataIndex++] = g;
			data[dataIndex++] = b;
			data[dataIndex++] = a;
		}
		
		// Triangle 1, top-left
		data[dataIndex++] = x;
		data[dataIndex++] = y;
		data[dataIndex++] = uvx;
		data[dataIndex++] = uvy;
		fillTint();
		// Triangle 1, top-right
		data[dataIndex++] = x2;
		data[dataIndex++] = y2;
		data[dataIndex++] = uvx2;
		data[dataIndex++] = uvy;
		fillTint();
		// Triangle 1, bottom-left
		data[dataIndex++] = x3;
		data[dataIndex++] = y3;
		data[dataIndex++] = uvx;
		data[dataIndex++] = uvy2;
		fillTint();
		// Triangle 2, bottom-right
		data[dataIndex++] = x4;
		data[dataIndex++] = y4;
		data[dataIndex++] = uvx2;
		data[dataIndex++] = uvy2;
		fillTint();
		
		bufferOffset++;
		indexCount += 6;
		vertexBufferDirty = true;
	}
	
	override public function render(view:FlxHardwareView):Void 
	{
		view.drawItem(this);
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		bufferOffset = 0;
		indexCount = 0;
	}
	
	private function ensureElement():Void
	{
		if (buffer == null)
		{
			bufferSize = HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER;
			buffer = new Float32Array(HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER * HardwareRenderer.ELEMENTS_PER_TILE);
			indexes = new UInt32Array(HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER * 6);
			
			fillIndexBuffer();
		}
		else if (bufferOffset >= bufferSize)
		{
			var oldBuffer:Float32Array = buffer;
			
			bufferSize += HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER;
			buffer = new Float32Array(bufferSize * HardwareRenderer.ELEMENTS_PER_TILE);
			indexes = new UInt32Array(bufferSize * 6);
			
			var i:Int = 0;
			while (i < oldBuffer.length)
			{
				buffer[i] = oldBuffer[i];
				i++;
			}
			
			fillIndexBuffer();
		}
	}
	
	override public function equals(type:FlxDrawItemType, graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader):Bool
	{
		return (this.graphics == graphic 
			&& this.colored == colored
			&& this.hasColorOffsets == hasColorOffsets
			&& this.blending == blend
			&& this.antialiasing == smooth
			&& this.shader == shader);
	}

	private inline function fillIndexBuffer():Void
	{
		var i:Int = 0;
		var vertexOffset:Int = 0;
		
		while (i < indexes.length)
		{
			indexes[i    ] = vertexOffset;//0;
			indexes[i + 1] = vertexOffset + 1;
			indexes[i + 2] = vertexOffset + 2;
			indexes[i + 3] = vertexOffset + 2;
			indexes[i + 4] = vertexOffset + 1;
			indexes[i + 5] = vertexOffset + 3;
			vertexOffset += 4;
			i += 6;
		}
		
		indexBufferDirty = true;
	}
	
}