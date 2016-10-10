package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public static inline var SPEED:Int = 64;
	
	public var tilemap:FlxTilemap;
	public var distmap:FlxTilemap;
	public var distances:Array<Int>;
	public var mcguffin:FlxPoint;
	public var mcguffinSprite:FlxSprite;
	
	public var seekers:FlxTypedGroup<Seeker>;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		bgColor = FlxColor.WHITE;
		super.create();
		makeTiles();
		
		openSubState(new InstructionState());
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.DELETE)
		{
			var seeker = seekers.getFirstAlive();
			seeker.kill();
		}
		else if (FlxG.keys.justPressed.SPACE)
			placeSeeker();
		
		if (FlxG.mouse.pressed)
			clickTile(1);
		else if (FlxG.mouse.pressedRight)
			clickTile(0);
		else if (FlxG.mouse.pressedMiddle)
			placeMcguffin(FlxG.mouse.x, FlxG.mouse.y);
		
		updateSeekers();
	}
	
	private function updateSeekers():Void
	{
		FlxG.collide(tilemap, seekers);
		
		for (seeker in seekers)
		{
			if (!seeker.moving)
			{
				var tx:Int = Std.int((seeker.x-seeker.offset.x) / 16);
				var ty:Int = Std.int((seeker.y-seeker.offset.y) / 16);
				
				var bestX:Int = 0;
				var bestY:Int = 0;
				var bestDist:Float = Math.POSITIVE_INFINITY;
				var neighbors:Array<Array<Float>> = [[999, 999, 999], [999, 999, 999], [999, 999, 999]];
				for (yy in -1...2)
				{
					for (xx in -1...2)
					{
						var theX:Int = tx + xx;
						var theY:Int = ty + yy;
						
						if (theX >= 0 && theY < distmap.widthInTiles) 
						{
							if (theY >= 0 && theY < distmap.heightInTiles) 
							{
								if (xx == 0 || yy == 0)
								{
									var distance:Float = distances[theY * distmap.widthInTiles + theX];
									neighbors[yy + 1][xx + 1] = distance;
									if (distance > 0)
									{
										if (distance < bestDist || (bestX == 0 && bestY == 0))
										{
											bestDist = distance;
											bestX = xx;
											bestY = yy;
										}
									}
								}
							}
						}
					}
				}
				
				if (!(bestX == 0 && bestY == 0))
				{
					seeker.moveTo((tx * 16) + (bestX * 16) + seeker.offset.x, (ty * 16) + (bestY * 16) + seeker.offset.y, SPEED);
				}
			}
		}
	}
	
	private function placeSeeker():Void
	{
		var x:Float = FlxG.mouse.x - (FlxG.mouse.x % 16);
		var y:Float = FlxG.mouse.y - (FlxG.mouse.y % 16);
		
		var seeker = seekers.recycle(Seeker);
		seeker.reset(x, y);
	}
	
	private function placeMcguffin(X:Float, Y:Float):Void
	{
		mcguffin.x = Std.int(X / 16);
		mcguffin.y = Std.int(Y / 16);
		
		mcguffinSprite.x = Std.int(mcguffin.x * 16);
		mcguffinSprite.y = Std.int(mcguffin.y * 16);
		
		updateDistance();
	}
	
	private function updateDistance():Void
	{
		var startX:Int = Std.int((mcguffin.y * tilemap.widthInTiles) + mcguffin.x);
		var endX:Int = 0;
		if (startX == endX)
			endX = 1;
			
		var tempDistances = tilemap.computePathDistance(startX, endX, NONE, false);
		
		if (tempDistances == null)
			return;
		else
			distances = tempDistances; // safe to assign
		
		var maxDistance:Int = 1;
		for (dist in distances) 
		{
			if (dist > maxDistance)
				maxDistance = dist;
		}
		
		for (i in 0...distances.length) 
		{
			var disti:Int = 0;
			if (distances[i] < 0) 
				disti = 1000;
			else
				disti = Std.int(999 * (distances[i] / maxDistance));
				
			distmap.setTileByIndex(i, disti, true);
		}
	}
	
	private function clickTile(value:Int):Void
	{
		var tx:Int = Std.int(FlxG.mouse.x / 16);
		var ty:Int = Std.int(FlxG.mouse.y / 16);
		tilemap.setTile(tx, ty, value, true);
		
		tilemap.setTileProperties(0, FlxObject.NONE);
		tilemap.setTileProperties(1, FlxObject.ANY);
		
		updateDistance();
	}
	
	private function makeTiles():Void
	{
		tilemap = new FlxTilemap();
		distmap = new FlxTilemap();
		tilemap.scale.set(16, 16);
		distmap.scale.set(16, 16);
		
		var tw:Int = Std.int(FlxG.width / 16);
		var th:Int = Std.int(FlxG.height / 16);
		
		var arr:Array<Int> = [];
		var arr2:Array<Int> = [];
		for (ww in 0...tw)
		{
			for (hh in 0...th)
			{
				arr.push(0);
				arr2.push(0);
			}
		}
		
		tilemap.loadMapFromArray(arr, tw, th, "assets/images/tileset.png", 1, 1);
		distmap.loadMapFromArray(arr2, tw, th, "assets/images/heat.png", 1, 1);
		add(distmap);
		
		tilemap.setTileProperties(0, FlxObject.NONE);
		tilemap.setTileProperties(1, FlxObject.ANY);
		
		seekers = new FlxTypedGroup<Seeker>();
		add(seekers);
		
		mcguffin = FlxPoint.get();
		mcguffinSprite = new FlxSprite(0, 0, "assets/images/mcguffin.png");
		add(mcguffinSprite);
		
		placeMcguffin(0, 0);
	}
}
