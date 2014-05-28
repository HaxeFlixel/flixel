package;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxStringUtil;
import flixel.util.FlxRandom;

class PlayState extends FlxState
{
	private var _mapData:BitmapData;	  // Draw map here, later make tilemap
	private var _rooms:Array<Rectangle>;  // Room array
	private var _halls:Array<Rectangle>;  // Hall array
	private var _leafs:Array<Leaf>;		  // Leaf array
	private var _grpGraphicMap:FlxGroup;  // Map sprite group, stays behind UI
	private var _grpTestMap:FlxGroup;	  // Testing tilemap group, behind all
	private var _grpUI:FlxGroup;		  // UI group, in front of everything
	private var _button:FlxButton;		  // Map creation button
	private var _buttonPlaymap:FlxButton; // Button to switch to play mode
	private var _sprMap:FlxSprite;		  // Sprite that holds scaled map
	private var _map:FlxTilemap;		  // Tilemap for map testing
	private var _player:FlxSprite;		  // Player sprite

	override public function create():Void
	{
		add(_grpGraphicMap = new FlxGroup());
		add(_grpTestMap = new FlxGroup());

		// Create sprite to display map, will be scaled to fill screen
		_sprMap = new FlxSprite(FlxG.width / 2 - FlxG.width / 32, FlxG.height / 2 - FlxG.height / 32).makeGraphic(Std.int(FlxG.width / 16), Std.int(FlxG.height / 16), 0x0);
		_sprMap.scale.x = 16;
		_sprMap.scale.y = 16;

		_grpGraphicMap.add(_sprMap);
		_grpTestMap.visible = false;

		// Add player sprite
		add(_player = new FlxSprite(0, 0, "assets/images/player.png"));
		_player.visible = false;
		_player.width = 14;
		_player.height = 14;
		_player.offset.x = 1;
		_player.offset.y = 1;

		// Setup UI
		add(_grpUI = new FlxGroup());
		_button = new FlxButton(10, 10, "Generate", GenerateMap);
		_buttonPlaymap = new FlxButton(_button.x + _button.width + 10, 10, "Play", PlayMap);
		_grpUI.add(_button);
		_grpUI.add(_buttonPlaymap);

		_buttonPlaymap.visible = false;

		GenerateMap();

		super.create();
	}

	private function PlayMap():Void
	{
		// Switch to play mode
		_grpTestMap.visible = true;
		_grpGraphicMap.visible = false;
		_buttonPlaymap.visible = false;
		_player.visible = true;

		// Turn map data into CSV, then make tilemap out of it
		var newMap:FlxTilemap = new FlxTilemap().loadMap(FlxStringUtil.bitmapToCSV(_mapData), "assets/images/tiles.png", 16, 16, FlxTilemap.AUTO, 0, 0, 1);
		if (_map != null)
		{
			// If old map exists, replace with new one
			var oldMap:FlxTilemap = _map;
			_grpTestMap.replace(oldMap, newMap);
			oldMap.kill();
			oldMap.destroy();
		}
		else
		{
			// If no old map, (first time 'play' is hit), add new map to group
			_grpTestMap.add(newMap);
		}
		_map = newMap;
	}

	private function GenerateMap():Void
	{
		// Reset mapData
		_mapData = new BitmapData(Std.int(_sprMap.width), Std.int(_sprMap.height), false, 0xff000000);

		// Setup the Screen/UI
		_grpTestMap.visible = false;
		_grpGraphicMap.visible = true;
		_player.visible = false;

		// Reset arrays
		_rooms = new Array<Rectangle>();
		_halls = new Array<Rectangle>();
		_leafs = new Array<Leaf>();

		var l:Leaf; // Helper Leaf

		// First, create leaf to be root of all leaves
		var root:Leaf = new Leaf(0, 0, Std.int(_sprMap.width), Std.int(_sprMap.height));
		_leafs.push(root);

		var did_split:Bool = true;
		// Loop through every Leaf in array until no more can be split
		while (did_split)
		{
			did_split = false;
			for (l in _leafs)
			{
				if (l.leftChild == null && l.rightChild == null) // If not split
				{
					// If this leaf is too big, or 75% chance
					if (l.width > Leaf.MAX_LEAF_SIZE || l.height > Leaf.MAX_LEAF_SIZE || FlxRandom.float() > 0.25)
					{
						if (l.split()) // split the leaf!
						{
							// If split worked, push child leafs into vector
							_leafs.push(l.leftChild);
							_leafs.push(l.rightChild);
							did_split = true;
						}
					}
				}
			}
		}

		// Next, iterate through each leaf and create room in each one
		root.createRooms();

		for (l in _leafs)
		{
			// Then draw room and hallway (if there is one)
			if (l.room != null)
			{
				drawRoom(l.room);
			}

			if (l.halls != null && l.halls.length > 0)
			{
				drawHalls(l.halls);
			}
		}

		// Randomly pick room for player to start in
		var startRoom:Rectangle = _rooms[Std.int(Leaf.randomNumber(0, _rooms.length - 1))];
		// And pick random tile for player to start on
		var _playerStart:Point = new Point(Leaf.randomNumber(startRoom.x, startRoom.x + startRoom.width - 1), Leaf.randomNumber(startRoom.y, startRoom.y + startRoom.height - 1));

		// Move the player sprite to random starting location
		_player.x = _playerStart.x * 16 + 1;
		_player.y = _playerStart.y * 16 + 1;

		// Make map Sprite's pixels a copy of map BitmapData
		_sprMap.pixels = _mapData.clone();
		_sprMap.dirty = true;

		_buttonPlaymap.visible = true;
	}

	private function drawHalls(H:Array<Rectangle>):Void
	{
		// add each hall to the hall vector, and draw the hall onto our mapData
		var r:Rectangle;
		for (r in H)
		{
			_halls.push(r);
			_mapData.fillRect(r, 0xFFFFFFFF);
		}
	}

	private function drawRoom(R:Rectangle):Void
	{
		// Add this room to room array, then draw onto mapData
		_rooms.push(R);
		_mapData.fillRect(R, 0xFFFFFFFF);
	}

	override public function update():Void
	{

		if (_grpTestMap.visible)
		{
			if (FlxG.keys.pressed.LEFT)
			{
				_player.velocity.x = -100;
			}
			else if (FlxG.keys.pressed.RIGHT)
			{
				_player.velocity.x = 100;
			}
			else
			{
				_player.velocity.x = 0;
			}

			if (FlxG.keys.pressed.UP)
			{
				_player.velocity.y = -100;
			}
			else if (FlxG.keys.pressed.DOWN)
			{
				_player.velocity.y = 100;
			}
			else
			{
				_player.velocity.y = 0;
			}

			// Check collison with the wall tiles in the map
			FlxG.collide(_player, _map);
		}
		super.update();
	}
}
