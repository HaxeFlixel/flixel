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
	public var vertices:#if flash Vector #else Array #end<Float>;
	/**
	 * A Vector of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices:#if flash Vector #else Array #end<Int>;
	/**
	 * A Vector of normalized coordinates used to apply texture mapping.
	 */
	public var uvs:#if flash Vector #else Array #end<Float>;
	
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
		
		#if flash
		var vs:Vector<Float>;
		var idx:Vector<Int>;
		var uvt:Vector<Float>;
		#else
		var vs:Array<Float>;
		var idx:Array<Int>;
		var uvt:Array<Float>;
		#end
		
		var num1:Int = 2 * Std.int(vertices.length / 2);
		var num2:Int = 2 * Std.int(uvs.length / 2);
		
		var numVertices:Int = FlxMath.minInt(num1, num2);
		
		#if FLX_RENDER_TILE
		var drawItem:FlxDrawTrianglesItem;
		var prevNumberOfVertices:Int;
		#end
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			getScreenPosition(_point, camera);
			
			cameraBounds.set(0, 0, camera.width, camera.height);
			
			#if FLX_RENDER_TILE
			drawItem = camera.getDrawTrianglesItem(graphic, antialiasing);
			
			vs = drawItem.vertices;
			idx = drawItem.indices;
			uvt = drawItem.uvt;
			prevNumberOfVertices = drawItem.numVertices;
			#else
			vs = drawVertices;
			idx = indices;
			uvt = uvs;
			vs.splice(0, vs.length);
			#end
			
			var i:Int = 0;
			while (i < numVertices)
			{
				tempX = _point.x + vertices[i]; tempY = _point.y + vertices[i + 1];
				pushVertex(tempX, tempY, camera, vs);
				
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
				#if flash
				vs.length = vs.length - numVertices;
				#else
				vs.splice(vs.length - numVertices, numVertices);
				#end
			}
			else
			{
			#if FLX_RENDER_TILE
				for (i in 0...numVertices)
				{
					uvt.push(uvs[i]);
				}
				
				for (i in 0...indices.length)
				{
					idx.push(indices[i] + prevNumberOfVertices);
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
	
	private inline function pushVertex(vx:Float, vy:Float, camera:FlxCamera, vs:#if flash Vector #else Array #end<Float>):Void
	{
		#if FLX_RENDER_TILE
		vx *= camera.totalScaleX;
		vy *= camera.totalScaleY;
		#end
		
		vs.push(vx);
		vs.push(vy);
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