package;
import nme.Assets;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxPath;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;


class PlayState extends FlxState
{
	/*
	 * Tile width
	 */
	private var TILE_WIDTH:Int;
	/*
	 * Tile height
	 */
	private var TILE_HEIGHT:Int;
	
	/*
	 * Unit value for action go
	 */
	private var ACTION_GO:Int;
	
	/*
	 * Unit value for action idle
	 */
	private var ACTION_IDLE:Int;
	/*
	 * Unit move speed
	 */
	private var MOVE_SPEED:Int;
	
	/*
	 * Map
	 */
	private var _map:FlxTilemap;
	
	/*
	 * FlxPath
	 */
	private var _path:FlxPath;
	/*
	 * Path Point
	 */
	private var _pathPoint:FlxGroup;
	/*
	 * Goal sprite
	 */
	private var _goal:FlxSprite;
	
	/*
	 * Unit sprite
	 */
	private var _unit:FlxSprite;
	/*
	 * Unit action
	 */
	private var _action:Int;
	/*
	 * Destination
	 */
	private var _destination:Int;
	
	/*
	 * Button to move unit to Goal
	 */
	private var _btnFindPath:FlxButton;
	/*
	 * Button to stop unit
	 */
	private var _btnStopUnit:FlxButton;
	/*
	 * Button to reset unit to start point
	 */
	private var _btnResetUnit:FlxButton;
	/*
	 * Button quit
	 */
	private var _btnQuit:FlxButton;
	/*
	 * Legend
	 */
	private var _legends:FlxText;
	
	public function new()
	{
		TILE_WIDTH = 12;
		TILE_HEIGHT = 12;
		ACTION_GO = 1;
		ACTION_IDLE = 0;
		MOVE_SPEED = 50;
		
		super();
		
		#if !neko
		FlxG.bgColor = 0xff000000;
		#else
		FlxG.bgColor = {rgb: 0x000000, a: 0xff};
		#end
	}
	
	override public function create():Void
	{
		FlxG.framerate = 50;
		FlxG.flashFramerate = 50;
		
		//Load _datamap to _map and add to PlayState
		_map = new FlxTilemap();
		_map.loadMap(Assets.getText("assets/pathfinding_map.txt"), "assets/tiles.png", TILE_WIDTH, TILE_HEIGHT, 0, 1);
		add(_map);
		
		//Add pathHelper
		_pathPoint = new FlxGroup();
		setupPathPoint();
		add(_pathPoint);
		
		//Set goal coordinate and add goal to PlayState
		#if !neko
		_goal = new FlxSprite().makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0xffffff00);
		#else
		_goal = new FlxSprite().makeGraphic(TILE_WIDTH, TILE_HEIGHT, {rgb: 0xffff00, a: 0xff});
		#end
		_goal.x = _map.width - TILE_WIDTH;
		_goal.y = _map.height - TILE_HEIGHT;
		add(_goal);
		
		//Set and add unit to PlayState
		#if !neko
		_unit  = new FlxSprite(0, 0).makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0xffff0000);
		#else
		_unit  = new FlxSprite(0, 0).makeGraphic(TILE_WIDTH, TILE_HEIGHT, {rgb: 0xff0000, a: 0xff});
		#end
		_action = ACTION_IDLE;
		_destination = 0;
		//_unit.drag.x = _unit.drag.y = MOVE_SPEED * 8;
		_unit.maxVelocity.x = _unit.maxVelocity.y = MOVE_SPEED;
		add(_unit);
		
		//Add button move to goal to PlayState
		_btnFindPath = new FlxButton(320, 10, "Move To Goal", moveToGoal);
		add(_btnFindPath);
		
		//Add button stop unit to PlayState
		_btnStopUnit = new FlxButton(320, 30, "Stop Unit", stopUnit);
		add(_btnStopUnit);
		
		//Add button reset unit to PlayState
		_btnResetUnit = new FlxButton(320, 50, "Reset Unit", resetUnit);
		add(_btnResetUnit);
		
		//Add button quit to PlayState
		_btnQuit = new FlxButton(320, 70, "Quit", backToMenu);
		add(_btnQuit);
		
		//Add label for legend
		_legends = new FlxText(320, 90, 100, "Click in map to\nplace or\nremove tile\n\nLegends:\nRed:Unit\nYellow:Goal\nBlue:Wall\nWhite:Path");
		add(_legends);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		_map = null;
		_path = null;
		_pathPoint = null;
		_goal = null;
		_unit = null;
		_btnFindPath = null;
		_btnStopUnit = null;
		_btnResetUnit = null;
		_btnQuit = null;
		_legends = null;
	}
	
	override public function update():Void
	{
		super.update();
		
		FlxG.collide(_map, _unit);
		
		//Check mouse pressed
		if (FlxG.mouse.justPressed() && _action == ACTION_IDLE) 
		{
			//Get data map coordinate
			var mx:Int = Std.int(FlxG.mouse.screenX / TILE_WIDTH);
			var my:Int = Std.int(FlxG.mouse.screenY / TILE_HEIGHT);
			
			//Change tile toogle
			_map.setTile(mx, my, 1 - _map.getTile(mx, my), true);
		}
		
		switch (_action)
		{
			case ACTION_GO:
				//Move unit for the first time
				if (_unit.velocity.x == 0 && _unit.velocity.y == 0)
				{
					updateVelocity();
				}
				
				//Check if x unit same with x destination
				if (Math.round(_unit.x) == _path.nodes[_destination].x)
				{
					//Update x to avoid collision
					_unit.x = _path.nodes[_destination].x;
					_unit.velocity.x = 0;
				}
				
				if (Math.round(_unit.y) == _path.nodes[_destination].y)
				{
					//Update y to avoid collision
					_unit.y = _path.nodes[_destination].y;
					_unit.velocity.y = 0;
				}
				
				//Check if coordinate unit same with coordinate destination
				if (Math.round(_unit.x) == _path.nodes[_destination].x && Math.round(_unit.y) == _path.nodes[_destination].y)
				{
					//Check if destination is final goal
					if (_destination < _path.nodes.length - 1)
					{
						//Update destination and velocity
						_destination++;
						updateVelocity();
					}
					else
					{
						//Update coordinate to avoid collision
						_unit.x = _path.nodes[_destination].x;
						_unit.y = _path.nodes[_destination].y;
						
						//Stop unit
						_action = ACTION_IDLE;
						_unit.velocity.x = _unit.velocity.y = 0;
					}
				}
			case ACTION_IDLE:
				_unit.velocity.x = _unit.velocity.y = 0;
		}
	}
	
	private function moveToGoal():Void
	{
		//Find path to goal
		_path = _map.findPath(new FlxPoint(_unit.x, _unit.y), new FlxPoint(_goal.x, _goal.y), true);
		
		//Check find path
		if (_path != null)
		{
			for (i in 0...(_path.nodes.length))
			{
				//if (_path.nodes[i] != null)
				//{
					//make path coordinate so unit not collide with wall
					_path.nodes[i].x -= _path.nodes[i].x % TILE_WIDTH;
					_path.nodes[i].y -= _path.nodes[i].y % TILE_WIDTH;
					showHelper(Std.int(_path.nodes[i].x), Std.int(_path.nodes[i].y));
				//}
			}
			
			//set unit to move
			_destination = 0;
			_action = ACTION_GO;
		}
	}
	
	private function stopUnit():Void
	{
		//Stop unit
		_unit.x -= _unit.x % TILE_WIDTH;
		_unit.y -= _unit.y % TILE_HEIGHT;
		_action = ACTION_IDLE;
		
		//Hide pathHelper
		_pathPoint.setAll("exists", false);
	}
	
	private function resetUnit():Void
	{
		//Reset _unit position & make unit idle
		_unit.x = 0;
		_unit.y = 0;
		_action = ACTION_IDLE;
		
		//Hide pathHelper
		_pathPoint.setAll("exists", false);
	}
	
	private function backToMenu():Void
	{
		FlxG.switchState(new MenuState());
	}
	
	private function setupPathPoint():Void 
	{
		//Add 100 FlxSprite and set exist to false in PathHelper
		for (i in 0...100)
		{
			#if !neko
			_pathPoint.add(new FlxSprite(0, 0).makeGraphic(TILE_WIDTH, TILE_HEIGHT, 0xffffffff));
			#else
			_pathPoint.add(new FlxSprite(0, 0).makeGraphic(TILE_WIDTH, TILE_HEIGHT, {rgb: 0xffffff, a: 0xff}));
			#end
			_pathPoint.members[i].exists = false;
		}
	}
	
	private function showHelper(X:Int, Y:Int):Void
	{
		//Set first available to show
		if (_pathPoint.getFirstAvailable() != null)
		{
			cast(_pathPoint.getFirstAvailable(), FlxSprite).x = X;
			cast(_pathPoint.getFirstAvailable(), FlxSprite).y = Y;
			cast(_pathPoint.getFirstAvailable(), FlxSprite).exists = true;
		}
	}
	
	private function updateVelocity():Void
	{
		//Set velocity to move to target
		var pointAngle:Float = getAngle(_path.nodes[_destination].x, _path.nodes[_destination].y, _unit.x, _unit.y);
		_unit.velocity.x = Math.cos(pointAngle * Math.PI / 180) * MOVE_SPEED;
		_unit.velocity.y = Math.sin(pointAngle * Math.PI / 180) * MOVE_SPEED;
	}
	
	/*
	 * Get Angle
	 */
	private function getAngle(X2:Float, Y2:Float, X1:Float, Y1:Float):Float 
	{
		var angleDegree:Float;
		var angleRadian:Float;

		angleDegree = Math.atan((Y2 - Y1) / (X2 - X1));
		if (X2 < X1) 
		{
			angleDegree += Math.PI;
		}
		angleRadian = Math.round(angleDegree * 360 / (2 * Math.PI));
		return angleRadian;
	}
}