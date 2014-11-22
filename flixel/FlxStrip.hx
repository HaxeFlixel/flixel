package flixel;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.Vector;

// TODO: document this class

/**
 * 
 */
class FlxStrip extends FlxSprite
{
	public var vertices:Vector<Float>;
	public var indices:Vector<Int>;
	public var uvs:Vector<Float>;
	
	#if FLX_RENDER_BLIT
	private var sprite:Sprite;
	#end
	
	private var bounds:FlxRect;
	private var cameraBounds:FlxRect;
	
	private var drawVertices:Vector<Float>;
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		
		#if FLX_RENDER_BLIT
		sprite = new Sprite();
		#end
		
		bounds = new FlxRect();
		cameraBounds = new FlxRect();
		
		vertices = new Vector<Float>();
		indices = new Vector<Int>();
		uvs = new Vector<Float>();
		
		drawVertices = new Vector<Float>();
	}
	
	override public function destroy():Void 
	{
		#if FLX_RENDER_BLIT
		sprite = null;
		#end
		
		vertices = null;
		indices = null;
		uvs = null;
		
		drawVertices = null;
		
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
		
		var vs:Vector<Float>;
		var idx:Vector<Int>;
		var uvt:Vector<Float>;
		
		var numVertices:Int = Std.int(vertices.length / 2);
		var numTris:Int = Std.int(indices.length / 3);
		
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
			prevNumberOfVertices = Std.int(vs.length / 2);
			#else
			vs = drawVertices;
			idx = indices;
			uvt = uvs;
			vs.splice(0, vs.length);
			#end
			
			for (i in 0...numVertices)
			{
				tempX = _point.x + vertices[2 * i]; tempY = _point.y + vertices[2 * i + 1];
				pushVertex(tempX, tempY, camera, vs);
				
				if (i == 0)
				{
					bounds.set(tempX, tempY, 0, 0);
				}
				else
				{
					inflateBounds(tempX, tempY);
				}
			}
			
			var vis:Bool = cameraBounds.overlaps(bounds);
			
			if (!vis)
			{
				vs.splice(vs.length - numVertices * 2, numVertices * 2);
			}
			else
			{
			#if FLX_RENDER_TILE
				for (i in 0...numVertices)
				{
					uvt.push(uvs[2 * i]);
					uvt.push(uvs[2 * i + 1]);
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
	
	private inline function pushVertex(vx:Float, vy:Float, camera:FlxCamera, vs:Vector<Float>):Void
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