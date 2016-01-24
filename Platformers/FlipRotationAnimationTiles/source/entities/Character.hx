package entities;
import flash.geom.Rectangle;
import flixel.addons.display.FlxExtendedSprite;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.FlxG;
import haxe.io.Path;
import haxe.Json;
import openfl.Assets;

/**
 * ...
 * @author MrCdK
 */
class Character extends FlxExtendedSprite
{
	public var collisionMap:FlxRect;
	public var maxBounds:FlxRect;
	
	public var controllable:Bool = false;
	
	public var anim:String;
	
	public var name:String = "";
	
	public function new(Name:String, X:Float = 0, Y:Float = 0, ?JsonPath:String, ?SimpleGraphic:Dynamic)
	{
		super(X, Y, SimpleGraphic);
		name = Name;
		
		parseJson(JsonPath);

		facing = FlxObject.DOWN;

		drag.x = maxVelocity.x * 4;
		drag.y = maxVelocity.y * 4;
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (controllable)
		{
			acceleration.set(0, 0);
			
			if (FlxG.keys.anyPressed([RIGHT, D]))
			{
				acceleration.x = drag.x;
				facing = FlxObject.RIGHT;
			}
			else if (FlxG.keys.anyPressed([LEFT, A]))
			{
				acceleration.x = -drag.x;
				facing = FlxObject.LEFT;
			}
			
			if (FlxG.keys.anyPressed([UP, W]))
			{
				acceleration.y = -drag.y;
				facing = FlxObject.UP;
			}
			else if (FlxG.keys.anyPressed([DOWN, S]))
			{
				acceleration.y = drag.y;
				facing = FlxObject.DOWN;
			}
		}
		checkBoundsMap();
		resolveAnimation();
		super.update(elapsed);
	}
	
	public function setBoundsMap(boundsMap:FlxRect)
	{
		maxBounds = boundsMap;
	}
	
	/**
	* Check bounds of map
	*/
	private function checkBoundsMap():Void
	{
		if (maxBounds == null)
		{
			return;
		}
		
		if (x + collisionMap.x < maxBounds.x)
		{
			x = maxBounds.x - collisionMap.x;
			acceleration.x = 0;
		}
		else if ((x + collisionMap.x + collisionMap.width) > (maxBounds.x + maxBounds.width))
		{
			x = (maxBounds.x + maxBounds.width) - collisionMap.width - collisionMap.x;
			acceleration.x = 0;
		}

		if (y + collisionMap.y < maxBounds.y)
		{
			y = maxBounds.y - collisionMap.y;
			acceleration.y = 0;
		}
		else if ((y + collisionMap.y + collisionMap.height) > (maxBounds.y + maxBounds.height))
		{
			y = (maxBounds.y + maxBounds.height) - collisionMap.height - collisionMap.y;
			acceleration.y = 0;
		}
	}
	
	private function resolveAnimation()
	{
		anim = "idle_";
		
		if (velocity.x != 0 || velocity.y != 0)
		{
			anim = "walking_";
			if (velocity.x > 0)
			{
				facing = FlxObject.RIGHT;
			} else if (velocity.x < 0)
			{
				facing = FlxObject.LEFT;
			}
			if (velocity.y > 0)
			{
				facing = FlxObject.DOWN;
			} else if (velocity.y < 0)
			{
				facing = FlxObject.UP;
			}			
		}
		switch (facing)
		{
			case FlxObject.UP:
				anim += "up";
				
			case FlxObject.DOWN:
				anim += "down";
				
			case FlxObject.LEFT:
				anim += "left";
				
			case FlxObject.RIGHT:
				anim += "right";
				
			default:
				anim += "down";
		}			
		
		if (animation.name != anim)
		{
			animation.play(anim);
		}
	}
	
	private function parseJson(file:String)
	{
		var filePath:Path = new Path(file);
		var fileStr:String = Assets.getText(file);
		if (fileStr == null)
		{
			throw 'The file {$file} doesn\'t exist!';
		}
		
		var json = Json.parse(fileStr);
		
		// sprite
		var texture:String = filePath.dir + "/" + json.sprite.texture;
		var frameWidth:Int = Std.int(json.sprite.framewidth);
		var frameHeight:Int = Std.int(json.sprite.frameheight);
		this.loadGraphic(texture, true, frameWidth, frameHeight);
		
		// velocity
		var maxX:Float = json.velocity.max_x;
		var maxY:Float = json.velocity.max_y;
		this.maxVelocity.set(maxX, maxY);
		
		// collision
		var x:Float = json.collision.x;
		var y:Float = json.collision.y;
		var w:Float = json.collision.width;
		var h:Float = json.collision.height;
		this.offset.set(x, y);
		this.width = w;
		this.height = h;
		
		// collision_map
		x = json.collision_map.x;
		y = json.collision_map.y;
		w = json.collision_map.width;
		h = json.collision_map.height;
		collisionMap = FlxRect.get(x, y, w, h);

		// animations
		var v_def:Int = json.animations.velocities.def;
		var v_idl:Int = json.animations.velocities.idle;
		var v_wal:Int = json.animations.velocities.walking;
		var v_run:Int = json.animations.velocities.running;
		
		var tmp:Int;
		for (dir in Reflect.fields(json.animations.frames))
		{
			var d = Reflect.field(json.animations.frames, dir);
			for (type in Reflect.fields(d))
			{
				var t = Reflect.field(d, type);
				switch (type)
				{
					case "def":
						tmp = v_def;
						
					case "idle":
						tmp = v_idl;
						
					case "walking":
						tmp = v_wal;
						
					case "running":
						tmp = v_run;
						
					default:
						tmp = v_def;
				}
				animation.add(type + "_" + dir, t, tmp, true);
			}
		}
	}
}
