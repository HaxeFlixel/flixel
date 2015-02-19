package flixel;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.Vector;

/**
 * A very basic rendering component which uses drawTriangles.
 * You have access to vertices, indices and uvs vectors which are used as data storages for rendering.
 * The whole FlxGraphic object is used as a texture for this sprite.
 * Use these links for more info about drawTriangles method:
 * http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html#drawTriangles%28%29
 * http://help.adobe.com/en_US/as3/dev/WS84753F1C-5ABE-40b1-A2E4-07D7349976C4.html
 * http://www.flashandmath.com/advanced/p10triangles/index.html
 * 
 * WARNING: This class is EXTREMELY slow on flash target!
 */
class FlxStrip extends FlxSprite
{
	/**
	 * A Vector of Floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 */
	public var vertices:DrawData<Float>;
	/**
	 * A Vector of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices:DrawData<Int>;
	/**
	 * A Vector of normalized coordinates used to apply texture mapping.
	 */
	public var uvs:DrawData<Float>;
	
	public var colors:DrawData<Int>;
	
	#if FLX_RENDER_BLIT
	/**
	 * Internal var, used for rendering in blit render mode (as a Graphic object source)
	 */
	private var sprite:Sprite;
	/**
	 * Internal var, used for rendering in blit render mode (since data for rendering may be modified by the engine)
	 */
	private var drawVertices:Vector<Float>;
	#end
	
	/**
	 * Internal helper var, which helps to calculate bounding box for sprite and detect if the sprite is visible on the screen.
	 */
	private var bounds:FlxRect;
	/**
	 * Internal var, which represents camera's view port.
	 */
	private var cameraBounds:FlxRect;
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		
		#if FLX_RENDER_BLIT
		sprite = new Sprite();
		drawVertices = new Vector<Float>();
		#end
		
		bounds = new FlxRect();
		cameraBounds = new FlxRect();
		
		vertices = new #if flash Vector #else Array #end<Float>();
		indices = new #if flash Vector #else Array #end<Int>();
		uvs = new #if flash Vector #else Array #end<Float>();
		colors = new #if flash Vector #else Array #end<Int>();
	}
	
	override public function destroy():Void 
	{
		#if FLX_RENDER_BLIT
		sprite = null;
		drawVertices = null;
		#end
		
		vertices = null;
		indices = null;
		uvs = null;
		colors = null;
		
		bounds = null;
		cameraBounds = null;
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		if (alpha == 0 || graphic == null || vertices == null)
		{
			return;
		}
		
		var graph:FlxGraphic = null;
		var tempX:Float, tempY:Float;
		
		var vs:DrawData<Float>;
		var idx:DrawData<Int>;
		var uvt:DrawData<Float>;
		
		var verticesLength:Int = vertices.length;
		var UVsLength:Int = uvs.length;
		
		#if FLX_RENDER_TILE
		var drawItem:FlxDrawTrianglesItem;
		var prevNumberOfVertices:Int;
		var prevIndicesLength:Int;
		var prevColorsLength:Int;
		var numberOfVertices:Int = Std.int(verticesLength / 2);
		var numColors:Int = colors.length;
		var cols:DrawData<Int>;
		#end
		var prevVerticesLength:Int;
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			getScreenPosition(_point, camera);
			
			cameraBounds.set(0, 0, camera.width, camera.height);
			
			#if FLX_RENDER_TILE
			drawItem = camera.getDrawTrianglesItem(graphic, antialiasing, numColors > 0, _blendInt);
			
			cameraBounds.width *= camera.totalScaleX;
			cameraBounds.height *= camera.totalScaleY;
			
			vs = drawItem.vertices;
			idx = drawItem.indices;
			uvt = drawItem.uvt;
			cols = drawItem.colors;
			prevVerticesLength = vs.length;
			prevIndicesLength = idx.length;
			prevColorsLength = cols.length;
			prevNumberOfVertices = drawItem.numVertices;
			#else
			vs = drawVertices;
			idx = indices;
			uvt = uvs;
			vs.splice(0, vs.length);
			prevVerticesLength = 0;
			#end
			
			var i:Int = 0;
			var currentVertexPosition:Int = prevVerticesLength;
			while (i < verticesLength)
			{
				tempX = _point.x + vertices[i]; tempY = _point.y + vertices[i + 1];
				
				#if FLX_RENDER_TILE
				tempX *= camera.totalScaleX;
				tempY *= camera.totalScaleY;
				#end
				
				vs[currentVertexPosition++] = tempX;
				vs[currentVertexPosition++] = tempY;
				
				if (i == 0)
				{
					bounds.set(tempX, tempY, 0, 0);
				}
				else
				{
					inflateBounds(tempX, tempY);
				}
				
				i += 2;
			}
			
			var vis:Bool = cameraBounds.overlaps(bounds);
			if (!vis)
			{
				vs.splice(vs.length - verticesLength, verticesLength);
			}
			else
			{
			#if FLX_RENDER_TILE
				for (i in 0...verticesLength)
				{
					uvt[prevVerticesLength + i] = uvs[i];
				}
				
				for (i in 0...indices.length)
				{
					idx[prevIndicesLength + i] = indices[i] + prevNumberOfVertices;
				}
				
				if (numColors > 0)
				{
					for (i in 0...numberOfVertices)
					{
						cols[prevColorsLength + i] = colors[i];
					}
				}
			#else
				sprite.graphics.clear();
				sprite.graphics.beginBitmapFill(graphic.bitmap, null, false, antialiasing);
				sprite.graphics.drawTriangles(vs, idx, uvt);
				sprite.graphics.endFill();
				camera.buffer.draw(sprite);
				
				#if !FLX_NO_DEBUG
				if (FlxG.debugger.drawDebug)
				{
					var gfx:Graphics = beginDrawDebug(camera);
					gfx.lineStyle(1, FlxColor.BLUE, 0.5);
					gfx.drawTriangles(vs, idx);
					endDrawDebug(camera);
				}
				#end
			#end
			}
		}
	}
	
	private function inflateBounds(x:Float, y:Float):Void 
	{
		if (x < bounds.x) 
		{
			bounds.width += bounds.x - x;
			bounds.x = x;
		}
		
		if (y < bounds.y) 
		{
			bounds.height += bounds.y - y;
			bounds.y = y;
		}
		
		if (x > bounds.x + bounds.width) 
		{
			bounds.width = x - bounds.x;
		}
		
		if (y > bounds.y + bounds.height) 
		{
			bounds.height = y - bounds.y;
		}
	}
}