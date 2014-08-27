package generate;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRandom;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import play.PlayState;
using flixel.util.FlxSpriteUtil;

class GenerateState extends FlxState
{
	static inline var TILE_SIZE:Int = 16;
	
	public static var mapData:BitmapData;
	
	var rooms:Array<Rectangle>;
	var hallways:Array<Rectangle>;
	var leafs:Array<Leaf>;
	var mapSprite:FlxSprite;
	var mapWidth:Int;
	var mapHeight:Int;

	override public function create():Void
	{
		mapWidth = Std.int(FlxG.width / TILE_SIZE);
		mapHeight = Std.int(FlxG.height / TILE_SIZE);
		
		// Create sprite to display map, will be scaled to fill screen
		mapSprite = new FlxSprite(0, 0);
		mapSprite.makeGraphic(mapWidth, mapHeight, FlxColor.BLACK);
		mapSprite.scale.set(TILE_SIZE, TILE_SIZE);
		mapSprite.screenCenter();
		add(mapSprite);
		
		// Setup UI
		var gutter:Int = 10;
		add(new FlxButton(gutter, gutter, "Generate (G)", generateMap));
		add(new FlxButton(gutter * 2 + 80, gutter, "Play (Space)", play));
		
		if (mapData == null)
		{
			generateMap();
		}
		else
		{
			updateSprite();
		}
	}

	function generateMap():Void
	{
		// Reset mapData
		mapData = new BitmapData(mapWidth, mapHeight, false, FlxColor.BLACK);

		// Reset arrays
		rooms = [];
		hallways = [];
		leafs = [];

		// First, create leaf to be root of all leaves
		var root = new Leaf(0, 0, mapWidth, mapHeight);
		leafs.push(root);

		var didSplit:Bool = true;
		// Loop through every Leaf in array until no more can be split
		while (didSplit)
		{
			didSplit = false;
			
			for (leaf in leafs)
			{
				if (leaf.leftChild == null && leaf.rightChild == null) // If not split
				{
					// If this leaf is too big, or 75% chance
					if (leaf.width > Leaf.MAX_SIZE || leaf.height > Leaf.MAX_SIZE || FlxG.random.float() > 0.25)
					{
						if (leaf.split()) // split the leaf!
						{
							// If split worked, push child leafs into vector
							leafs.push(leaf.leftChild);
							leafs.push(leaf.rightChild);
							didSplit = true;
						}
					}
				}
			}
		}

		// Next, iterate through each leaf and create room in each one
		root.createRooms();

		for (leaf in leafs)
		{
			// Then draw room and hallway (if there is one)
			if (leaf.room != null)
			{
				drawRoom(leaf.room);
			}

			if (leaf.hallways != null && leaf.hallways.length > 0)
			{
				drawHalls(leaf.hallways);
			}
		}
		
		updateSprite();
	}

	function updateSprite():Void
	{
		// Make map Sprite's pixels a copy of map BitmapData
		mapSprite.pixels = mapData.clone();
		mapSprite.dirty = true;
	}
	
	/**
	 * Add each hall to the hall array, and draw the hall onto our mapData
	 */
	function drawHalls(hallRect:Array<Rectangle>):Void
	{
		for (rect in hallRect)
		{
			hallways.push(rect);
			mapData.fillRect(rect, FlxColor.WHITE);
		}
	}

	/**
	 * Add this room to room array, then draw onto mapData
	 */
	function drawRoom(roomRect:Rectangle):Void
	{
		rooms.push(roomRect);
		mapData.fillRect(roomRect, FlxColor.WHITE);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justReleased.G)
		{
			generateMap();
		}
		if (FlxG.keys.justReleased.SPACE)
		{
			play();
		}
	}
	
	function play():Void
	{
		FlxG.switchState(new PlayState());
	}
}