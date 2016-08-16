package flixel.system.render.gl;

import openfl.geom.ColorTransform;
import flixel.system.render.common.DrawItem.FlxHardwareView;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.FlxDrawBaseItem;

import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;

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
		/*
		if (smooth == null) smooth = Atlas.smooth;
		var matrix:Matrix = HXP.matrix;
		matrix.identity();
		matrix.scale(scaleX, scaleY);
		matrix.rotate( -angle * HXP.RAD);
		matrix.translate(x, y);
		prepareTileMatrix(rect, layer, matrix.tx, matrix.ty, matrix.a, matrix.b, matrix.c, matrix.d, red, green, blue, alpha, smooth);
		*/
	}
	
	/**
	 * Prepares a tile to be drawn using a matrix
	 * @param  rect   The source rectangle to draw
	 * @param  layer The layer to draw on
	 * @param  tx    X-Axis translation
	 * @param  ty    Y-Axis translation
	 * @param  a     Top-left
	 * @param  b     Top-right
	 * @param  c     Bottom-left
	 * @param  d     Bottom-right
	 * @param  red   Red color value
	 * @param  green Green color value
	 * @param  blue  Blue color value
	 * @param  alpha Alpha value
	 */
	public inline function prepareTileMatrix(rect:Rectangle, layer:Int,
		tx:Float, ty:Float, a:Float, b:Float, c:Float, d:Float,
		red:Float, green:Float, blue:Float, alpha:Float, ?smooth:Bool)
	{
		if (smooth == null) smooth = Atlas.smooth;
		
		var state:DrawState = DrawState.getDrawState(this, _texture, smooth, blend);
		ensureElement();
		
		var data:Float32Array = buffer;
		var dataIndex:Int = bufferOffset * HardwareRenderer.TILE_SIZE;
		
		// UV
		var uvx:Float = rect.x / _texture.width;
		var uvy:Float = rect.y / _texture.height;
		var uvx2:Float = rect.right / _texture.width;
		var uvy2:Float = rect.bottom / _texture.height;
		
		// Transformed position
		var matrix:Matrix = HXP.matrix;
		matrix.setTo(a, b, c, d, tx, ty);
		
		// Position
		var x :Float = matrix.__transformX(0, 0); // Top-left
		var y :Float = matrix.__transformY(0, 0);
		var x2:Float = matrix.__transformX(rect.width, 0); // Top-right
		var y2:Float = matrix.__transformY(rect.width, 0);
		var x3:Float = matrix.__transformX(0, rect.height); // Bottom-left
		var y3:Float = matrix.__transformY(0, rect.height);
		var x4:Float = matrix.__transformX(rect.width, rect.height); // Bottom-right
		var y4:Float = matrix.__transformY(rect.width, rect.height);

		// Set values
		if (!isRGB)
		{
			red = 1;
			green = 1;
			blue = 1;
		}
		if (!isAlpha) alpha = 1;
		
		inline function fillTint():Void
		{
			data[dataIndex++] = red;
			data[dataIndex++] = green;
			data[dataIndex++] = blue;
			data[dataIndex++] = alpha;
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
		state.count++;
		vertexBufferDirty = true;
	}
	
	override public function render(view:FlxHardwareView):Void 
	{
		
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		bufferOffset = 0;
	}
	
	private function ensureElement():Void
	{
		if (buffer == null)
		{
			bufferSize = HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER;
			buffer = new Float32Array(HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER * HardwareRenderer.TILE_SIZE);
			indexes = new UInt32Array(HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER * 6);
			
			fillIndexBuffer();
		}
		else if (bufferOffset >= bufferSize)
		{
			var oldBuffer:Float32Array = buffer;
			
			bufferSize += HardwareRenderer.MINIMUM_TILE_COUNT_PER_BUFFER;
			buffer = new Float32Array(bufferSize * HardwareRenderer.TILE_SIZE);
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