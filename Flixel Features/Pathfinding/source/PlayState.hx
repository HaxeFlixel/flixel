package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import openfl.Assets;

class PlayState extends FlxState
{
	/**
	 * Tile width
	 */
	private static inline var TILE_WIDTH:Int = 12;
	/**
	 * Tile height
	 */
	private static inline var TILE_HEIGHT:Int = 12;
	/**
	 * Unit value for action go
	 */
	private static inline var ACTION_GO:Int = 1;
	/**
	 * Unit value for action idle
	 */
	private static inline var ACTION_IDLE:Int = 0;
	/**
	 * Unit move speed
	 */
	private static inline var MOVE_SPEED:Int = 50;
	
	private static inline var INSTRUCTION_1:String = "Click in map to place or remove a tile.";
	private static inline var INSTRUCTION_2:String = "No path found!";
	
	/**
	 * Map
	 */
	private var _map:FlxTilemap;
	/**
	/**
	 * Goal sprite
	 */
	private var _goal:FlxSprite;
	/**
	 * Unit sprite
	 */
	private var _unit:FlxSprite;
	/**
	 * Unit action
	 */
	private var _action:Int;
	/**
	 * Destination
	 */
	private var _destination:Int;
	/**
	 * Button to move unit to Goal
	 */
	private var _findPathButton:FlxButton;
	/**
	 * Button to stop unit
	 */
	private var _stopUnitButton:FlxButton;
	/**
	 * Button to reset unit to start point
	 */
	private var _resetUnitButton:FlxButton;
	/**
	 * Instructions
	 */
	private var _instructions:FlxText;
	/**
	 * Path to follow
	 */
	private var path:FlxPath;
	
	override public function create():Void
	{
		// Load _datamap to _map and add to PlayState
		_map = new FlxTilemap();
		_map.loadMap(Assets.getText("assets/pathfinding_map.txt"), "assets/tiles.png", TILE_WIDTH, TILE_HEIGHT, 0, 1);
		add(_map);
		
		// Add a visual seperation between map and GUI
		var seperator:FlxSprite = new FlxSprite(_map.widthInTiles * TILE_WIDTH, 0);
		seperator.makeGraphic(Std.int(FlxG.width - seperator.width), FlxG.height, FlxColor.GRAY);
		add(seperator);
		
		// Set goal coordinate and add goal to PlayState
		_goal = new FlxSprite();
		_goal.makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0xffffff00);
		_goal.x = _map.width - TILE_WIDTH;
		_goal.y = _map.height - TILE_HEIGHT;
		add(_goal);
		
		// Set and add unit to PlayState
		_unit = new FlxSprite(0, 0);
		_unit.makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0xffff0000);
		_action = ACTION_IDLE;
		_destination = 0;
		_unit.maxVelocity.x = _unit.maxVelocity.y = MOVE_SPEED;
		add(_unit);
		
		var buttonX:Float = FlxG.width - 90;
		
		// Add button move to goal to PlayState
		_findPathButton = new FlxButton(buttonX, 10, "Move To Goal", moveToGoal);
		add(_findPathButton);
		
		// Add button stop unit to PlayState
		_stopUnitButton = new FlxButton(buttonX, 30, "Stop Unit", stopUnit);
		add(_stopUnitButton);
		
		// Add button reset unit to PlayState
		_resetUnitButton = new FlxButton(buttonX, 50, "Reset Unit", resetUnit);
		add(_resetUnitButton);
		
		// Add some texts
		var textWidth:Int = 85;
		var textX:Int = FlxG.width - textWidth - 5;
		
		_instructions = new FlxText(textX, 90, textWidth, INSTRUCTION_1);
		add(_instructions);
		
		var legends:FlxText = new FlxText(textX, 140, textWidth, "Legends:\nRed: Unit\nYellow: Goal\nBlue: Wall\nWhite: Path");
		add(legends);
		
		path = new FlxPath();
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_map = null;
		_goal = null;
		_unit = null;
		_findPathButton = null;
		_stopUnitButton = null;
		_resetUnitButton = null;
		_instructions = null;
	}
	
	override public function draw():Void
	{
		super.draw();
		
		// To draw path
		if ((path != null) && !path.finished)
		{
			path.drawDebug();
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Set unit to collide with map
		FlxG.collide(_unit, _map);
		
		// Check mouse pressed and unit action
		if (FlxG.mouse.justPressed) 
		{
			// Get data map coordinate
			var mx:Int = Std.int(FlxG.mouse.screenX / TILE_WIDTH);
			var my:Int = Std.int(FlxG.mouse.screenY / TILE_HEIGHT);
			
			// Change tile toogle
			_map.setTile(mx, my, 1 - _map.getTile(mx, my), true);
		}
		
		// Check if reach goal
		if (_action == ACTION_GO)
		{
			if (path.finished)
			{
				resetUnit();
				stopUnit();
			}
		}
	}
	
	private function moveToGoal():Void
	{
		// Find path to goal from unit to goal
		var pathPoints:Array<FlxPoint> = _map.findPath(FlxPoint.get(_unit.x + _unit.width / 2, _unit.y + _unit.height / 2), FlxPoint.get(_goal.x + _goal.width / 2, _goal.y + _goal.height / 2));
		
		// Tell unit to follow path
		if (pathPoints != null) 
		{
			path.start(_unit, pathPoints);
			_action = ACTION_GO;
			_instructions.text = INSTRUCTION_1;
		}
		else 
		{
			_instructions.text = INSTRUCTION_2;
		}
	}
	
	private function stopUnit():Void
	{
		// Stop unit and destroy unit path
		_action = ACTION_IDLE;
		path.cancel();
		_unit.velocity.x = _unit.velocity.y = 0;
	}
	
	private function resetUnit():Void
	{
		// Reset _unit position
		_unit.x = 0;
		_unit.y = 0;
		
		// Stop unit
		if (_action == ACTION_GO)
		{
			stopUnit();
		}
	}
}