package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVector;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public var tilemap:FlxTilemap;
	public var distmap:FlxTilemap;
	public var distances:Array<Int> = null;
	public var mcguffin:FlxPoint;
	public var mcguffinSprite:FlxSprite;
	
	public var SPEED:Int = 64;
	public var group_seekers:FlxGroup;
	private var vec:FlxVector = new FlxVector();
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		bgColor = FlxColor.WHITE;
		super.create();
		makeTiles();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		if (FlxG.keys.justPressed.DELETE) {
			var seeker = group_seekers.getFirstAlive();
			seeker.kill();
		}else if (FlxG.keys.justPressed.SPACE) {
			placeSeeker();
		}
		
		if (FlxG.mouse.pressed) {
			clickTile(1);
		}else if (FlxG.mouse.pressedRight) {
			clickTile(0);
		}else if (FlxG.mouse.pressedMiddle) {
			placeMcguffin(FlxG.mouse.x,FlxG.mouse.y);
		}
		updateSeekers();
	}
	
	private function updateSeekers():Void {
		FlxG.collide(tilemap, group_seekers);
		
		var seeker:Seeker;
		for (basic in group_seekers.members) {
			seeker = cast basic;
			if (!seeker.moving)
			{
				var tx:Int = Std.int((seeker.x-seeker.offset.x) / 16);
				var ty:Int = Std.int((seeker.y-seeker.offset.y) / 16);
				
				var bestX:Int = 0;
				var bestY:Int = 0;
				var bestDist:Float = Math.POSITIVE_INFINITY;
				var neighbors:Array<Array<Float>> = [[999, 999, 999], [999, 999, 999], [999, 999, 999]];
				for (yy in -1...1 + 1) {
					for (xx in -1...1 + 1) {
						var theX:Int = tx + xx;
						var theY:Int = ty + yy;
						
						if (theX >= 0 && theY < distmap.widthInTiles) {
							if (theY >= 0 && theY < distmap.heightInTiles) {
								if(xx == 0 || yy == 0){
									var distance:Float = distances[theY * distmap.widthInTiles + theX];
									neighbors[yy+1][xx+1] = distance;
									if (distance > 0) {
										if(distance < bestDist || (bestX == 0 && bestY == 0))
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
	
	private function placeSeeker():Void {
		var tx:Int = Std.int(FlxG.mouse.x / 16);
		var ty:Int = Std.int(FlxG.mouse.y / 16);
		
		var seeker:Seeker = cast group_seekers.getFirstDead();
		if(seeker == null){
			seeker = new Seeker(tx * 16, ty * 16, "assets/images/seeker.png");
			seeker.offset.x = 2;
			seeker.offset.y = 2;
			seeker.x += 2;
			seeker.y += 2;
			seeker.width = 12;
			seeker.height = 12;
			seeker.solid = true;
		}else {
			seeker.reset(tx * 16, ty * 16);
			seeker.offset.x = 2;
			seeker.offset.y = 2;
			seeker.x += 2;
			seeker.y += 2;
			seeker.width = 12;
			seeker.height = 12;
		}
		group_seekers.add(seeker);
	}
	
	private function placeMcguffin(X:Float,Y:Float):Void {
		mcguffin.x = Std.int(X / 16);
		mcguffin.y = Std.int(Y / 16);
		
		mcguffinSprite.x = Std.int(mcguffin.x * 16);
		mcguffinSprite.y = Std.int(mcguffin.y * 16);
		
		updateDistance();
	}
	
	private function updateDistance():Void {
		var startX:Int = Std.int((mcguffin.y * tilemap.widthInTiles) + mcguffin.x);
		var endX:Int = 0;
		if (startX == endX) {
			endX = 1;
		}
		
		distances = tilemap.computePathDistance(startX, endX, true, false);
		
		var maxDistance:Int = 1;
		for (dist in distances) {
			if (dist > maxDistance) {
				maxDistance = dist;
			}
		}
		
		for (i in 0...distances.length) {
			var disti:Int = 0;
			if (distances[i] < 0) {
				disti = 1000;
			}else{
				disti = Std.int(999*(distances[i] / maxDistance));
			}
			distmap.setTileByIndex(i, disti, true);
		}
	}
	
	private function clickTile(value:Int):Void {
		var tx:Int = Std.int(FlxG.mouse.x / 16);
		var ty:Int = Std.int(FlxG.mouse.y / 16);
		tilemap.setTile(tx, ty, value, true);
		
		tilemap.setTileProperties(0, FlxObject.NONE);
		tilemap.setTileProperties(1, FlxObject.ANY);
		
		updateDistance();
	}
	
	private function makeTiles():Void {
		tilemap = new FlxTilemap();
		distmap = new FlxTilemap();
		tilemap.scaleX = 16;
		tilemap.scaleY = 16;
		distmap.scaleX = 16;
		distmap.scaleY = 16;
		
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
		
		tilemap.widthInTiles = tw;
		tilemap.heightInTiles = th;
		distmap.widthInTiles = tw;
		distmap.heightInTiles = th;
		
		tilemap.loadMap(arr, "assets/images/tileset.png", 1, 1);
		distmap.loadMap(arr2, "assets/images/heat.png", 1, 1);
		add(distmap);
		//add(tilemap);
		
		tilemap.setTileProperties(0, FlxObject.NONE);
		tilemap.setTileProperties(1, FlxObject.ANY);
		tilemap.solid = true;
		
		group_seekers = new FlxGroup();
		add(group_seekers);
		
		mcguffin = new FlxPoint(0, 0);
		mcguffinSprite = new FlxSprite(0, 0, "assets/images/mcguffin.png");
		add(mcguffinSprite);
		
		placeMcguffin(0, 0);
	}
}