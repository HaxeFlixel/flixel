package flixel.phys.classic;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.phys.IFlxBody;
import flixel.phys.IFlxSpace;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.ds.Vector;

class FlxClassicSpace implements IFlxSpace {
	
	public var iterationCount : Int;
	
	private var bodies : Array<FlxClassicBody>;
	private var world : FlxCollideWorld;
	
	public function new(?worldSize : FlxRect, iterationCount : Int = 1, worldDivisionX = 6, worldDivisionY = 6)
	{
		this.iterationCount = iterationCount;
		bodies = new Array<FlxClassicBody>();
		
		if (worldSize == null)
		{
			worldSize = FlxRect.weak(0, 0, FlxG.width, FlxG.height);
		}
		
		world = new FlxCollideWorld(worldSize, worldDivisionX, worldDivisionY);
	}
	
	public function add(body : IFlxBody) : Void
	{
		var _body = cast(body, FlxClassicBody);
		if (bodies.indexOf(_body) == -1)
		{
			bodies.push(_body);
		}
	}
	
	public function remove(body : IFlxBody) : Void
	{
		var _body = cast(body, FlxClassicBody);
		bodies.remove(_body);
	}
	
	public function step(elapsed : Float) : Void
	{
		for (obj in bodies)
		{
			obj.updateBody(elapsed);
		}
		for (i in 0...iterationCount)
		{
			world.addArray(bodies);
			world.collideWorld();
			world.clear();
		}
		for (obj in bodies)
		{
			obj.parent.x = obj.x;
			obj.parent.y = obj.y;
			obj.parent.angle = obj.angle;
		}
	}
	
	public function createBody(parent : FlxObject) : FlxClassicBody
	{
		var body = new FlxClassicBody(parent);
		body.space = this;
		parent.body = body;
		add(body);
		return body;
	}
	
	public function destroy()
	{
		bodies = null;
		
		world.destroy();
	}
	
}



class FlxCollideWorld
{
	private var _worldSize : FlxRect;
	private var _worldDivisionX : Int;
	private var _worldDivisionY : Int;
	
	private var _world : Vector<Vector<FlxWorldPart>>;
	
	public function new(worldSize : FlxRect, worldDivisionX : Int, worldDivisionY : Int)
	{
		_world = new Vector<Vector<FlxWorldPart>>(_worldDivisionY = worldDivisionY);
		for (i in 0..._world.length)
		{
			_world[i] = new Vector<FlxWorldPart>(_worldDivisionX = worldDivisionX);
			for (j in 0..._world[i].length)
			{
				_world[i][j] = new FlxWorldPart();
			}
		}
		
		_worldSize = FlxRect.get();
		_worldSize.copyFrom(worldSize);
		worldSize.putWeak();
	}
	
	public function addArray(bodies : Array<FlxClassicBody>)
	{
		for (body in bodies)
		{
			var x = Math.floor((body.x - _worldSize.x) / (_worldSize.width/_worldDivisionX));
			var y = Math.floor((body.y - _worldSize.y) / (_worldSize.height/_worldDivisionY));
			
			if (x < 0 && body._hull.left > _worldSize.left)
			{
				x = 0;
			}
			
			if (y < 0 && body._hull.top > _worldSize.top)
			{
				y = 0;
			}
			
			if (x < 0 || y < 0 || x >= _worldDivisionX || y >= _worldDivisionY)
				continue;
				
			_world[y][x].addObject(body);
		}
	}
	
	public function collideWorld()
	{
		for (y in 0..._worldDivisionY)
		{
			for (x in 0..._worldDivisionX)
			{
				var mainListIterator = _world[y][x].mainHead;
				var mainTail = _world[y][x].mainTail;
				var priorityHead = _world[y][x].priorityHead;
				var priorityTail = _world[y][x].priorityTail;
				var temporaryObjects : Bool = false;
				
				while (mainListIterator != priorityHead)
				{
					if (mainListIterator == mainTail)
					{
						temporaryObjects = true;
					}
					
					if (mainListIterator.object == null)
					{
						mainListIterator = mainListIterator.next;
						continue;
					}
						
					var object = mainListIterator.object;
					for (i in x...Math.floor(Math.min(((object._hull.right - _worldSize.x) / (_worldSize.width / _worldDivisionX )) + 1, _worldDivisionX)))
					{
						if (i == x && temporaryObjects)
							continue;
						var secondIterator = i == x  ? mainListIterator.next : _world[y][i].mainHead;
						while (secondIterator != (temporaryObjects ? _world[y][i].mainTail : _world[y][i].priorityHead))
						{
							if (secondIterator.object == null)
							{
								secondIterator = secondIterator.next;
								continue;
							}
								
							var secondObject = secondIterator.object;
							if ((object.collisionGroup & secondObject.collisionMask) != 0 && (object.collisionMask & secondObject.collisionGroup) != 0 && object._hull.overlaps(secondObject._hull))
							{
								FlxSeparate.separate(object, secondObject);
								object.updateHull();
								secondObject.updateHull();
							}
							secondIterator = secondIterator.next;
						}
					}
					
					if ((object._hull.bottom - _worldSize.y) / (_worldSize.height / _worldDivisionY) > y + 1 && y != _worldDivisionY - 1)
					{
						_world[y + 1][x].addObject(object, true);
					}
					
					if (temporaryObjects)
					{
						if (mainTail == mainListIterator)
						{
							mainListIterator.object = null;
							mainListIterator = mainListIterator.next;
						}
						else
						{
							mainTail.next = mainListIterator.next;
							mainListIterator.next = null;
							mainListIterator.destroy();
							mainListIterator = mainTail.next;
						}
					}
					else
					{
						mainListIterator = mainListIterator.next;
					}
				}
			}
		}
		
		for (y in 0..._worldDivisionY)
		{
			for (x in 0..._worldDivisionX)
			{
				var mainListIterator = _world[y][x].mainHead;
				var temporaryObjects : Bool = false;
				var priorityObjects : Bool = false;
				
				while (mainListIterator != null)
				{
					if (mainListIterator == _world[y][x].mainTail || mainListIterator == _world[y][x].priorityTail)
					{
						temporaryObjects = true;
					}
					
					if (mainListIterator == _world[y][x].priorityHead)
					{
						priorityObjects = true;
						temporaryObjects = false;
					}
					
					if (mainListIterator.object == null)
					{
						mainListIterator = mainListIterator.next;
						continue;
					}
					
					var object = mainListIterator.object;
					for (i in x...Math.floor(Math.min(((object._hull.right - _worldSize.x) / (_worldSize.width / _worldDivisionX )) + 1, _worldDivisionX)))
					{
						if (i == x && priorityObjects)
							continue;
						var secondIterator = (i == x) ? _world[y][i].priorityHead : (priorityObjects ? _world[y][i].mainHead : _world[y][i].priorityHead);
						while (secondIterator != (priorityObjects ? (temporaryObjects ? _world[y][i].mainTail : _world[y][i].priorityHead) : (temporaryObjects ? _world[y][i].priorityTail : null)))
						{
							if (secondIterator.object == null)
							{
								secondIterator = secondIterator.next;
								continue;
							}
							var secondObject = secondIterator.object;
							if ((object.collisionGroup & secondObject.collisionMask) != 0 && (object.collisionMask & secondObject.collisionGroup) != 0 && object._hull.overlaps(secondObject._hull))
							{
								FlxSeparate.separate(object, secondObject);
								object.updateHull();
								secondObject.updateHull();
							}
							secondIterator = secondIterator.next;
						}
					}
					
					if ((object._hull.bottom - _worldSize.y) / (_worldSize.height / _worldDivisionY) > y + 1 && y != _worldDivisionY - 1)
					{
						_world[y + 1][x].addObject(object, true);
					}
					
					if (temporaryObjects)
					{
						if (priorityObjects)
						{
							if (_world[y][x].priorityTail == mainListIterator)
							{
								mainListIterator.object = null;
								mainListIterator = mainListIterator.next;
							}
							else
							{
								_world[y][x].priorityTail.next = mainListIterator.next;
								mainListIterator.next = null;
								mainListIterator.destroy();
								mainListIterator = _world[y][x].priorityTail.next;
							}
						}
						else
						{
							if (_world[y][x].mainTail == mainListIterator)
							{
								mainListIterator.object = null;
								mainListIterator = mainListIterator.next;
							}
							else
							{
								_world[y][x].mainTail.next = mainListIterator.next;
								mainListIterator.next = null;
								mainListIterator.destroy();
								mainListIterator = _world[y][x].mainTail.next;
							}
						}
					}
					else
					{
						mainListIterator = mainListIterator.next;
					}
				}
			}
		}
	}
	
	/*public function updateBodyLocations()
	{
		for (j in 0..._worldDivisionY)
		{
			for (i in 0..._worldDivisionX)
			{
				var beforeMainIterator = null;
				var mainIterator = _world[j][i].mainHead;
				
				while (mainIterator != _world[j][i].priorityTail)
				{
					if (mainIterator.object == null)
					{
						beforeMainIterator = mainIterator;
						mainIterator = mainIterator.next;
						continue;
					}
					
					var body = mainIterator.object;
					
					//BUG : Out of bounds
					var x = Math.floor((body.x - _worldSize.x) / (_worldSize.width/_worldDivisionX));
					var y = Math.floor((body.y - _worldSize.y) / (_worldSize.height/_worldDivisionY));
					
					if (body.x + body.width > _worldSize.left)
					{
						x = 0;
					}
					
					if (body.y + body.height > _worldSize.top)
					{
						y = 0;
					}
					
					if (j != y || i != x)
					{
						var removedElement : FlxLinkedListNew = null;
						
						if (beforeMainIterator == null)
						{
							if (mainIterator.next == _world[j][i].mainTail)
							{
								var temp = FlxLinkedListNew.recycle();
								temp.object = mainIterator.object;
								removedElement = temp;
								mainIterator.object = null;
								
								beforeMainIterator = mainIterator;
								mainIterator = mainIterator.next;
							}
							else
							{
								removedElement = mainIterator;
								mainIterator = mainIterator.next;
								_world[j][i].mainHead = mainIterator;
							}
						}
						else if (mainIterator == _world[j][i].priorityHead)
						{
							if (mainIterator.next == _world[j][i].priorityTail)
							{
								var temp = FlxLinkedListNew.recycle();
								temp.object = mainIterator.object;
								removedElement = temp;
								mainIterator.object = null;
								
								beforeMainIterator = mainIterator;
								mainIterator = mainIterator.next;
							}
							else
							{
								var next = mainIterator.next;
								removedElement = mainIterator;
								mainIterator = next;
								_world[j][i].priorityHead = mainIterator;
								beforeMainIterator.next = mainIterator;
							}
						}
						else
						{
							beforeMainIterator.next = mainIterator.next;
							removedElement = mainIterator;
							mainIterator = mainIterator.next;
						}
						
						if (x < 0 || x >= _worldDivisionX)
						{
							removedElement.next = _outOfBounds;
							_outOfBounds = removedElement;
							continue;
						}
						
						if (y < 0 || y >= _worldDivisionY)
						{
							removedElement.next = _outOfBounds;
							_outOfBounds = removedElement;
							continue;
						}
						
						_world[y][x].moveObject(removedElement);
						continue;
					}
					beforeMainIterator = mainIterator;
					mainIterator = mainIterator.next;
				}
			}
		}
		
		var beforeMainIterator : FlxLinkedListNew = null;
		var mainIterator : FlxLinkedListNew = _outOfBounds;
		while (mainIterator != null)
		{
			var body = mainIterator.object;
			
			var x = Math.floor((body.x - _worldSize.x) / (_worldSize.width/_worldDivisionX));
			var y = Math.floor((body.y - _worldSize.y) / (_worldSize.height / _worldDivisionY));
			
			if (x < 0)
			{
				if (body.x + body.width > _worldSize.left)
				{
					x = 0;
				}
				else
				{
					beforeMainIterator = mainIterator;
					mainIterator = mainIterator.next;
					continue;
				}
			}
			else if (x >= _worldDivisionX)
			{
				beforeMainIterator = mainIterator;
				mainIterator = mainIterator.next;
				continue;
			}
			
			if (y < 0)
			{
				if (body.y + body.height > _worldSize.top)
				{
					y = 0;
				}
				else
				{
					beforeMainIterator = mainIterator;
					mainIterator = mainIterator.next;
					continue;
				}
			}
			else if (y >= _worldDivisionY)
			{
				beforeMainIterator = mainIterator;
				mainIterator = mainIterator.next;
				continue;
			}
			
			if (beforeMainIterator == null)
			{
				_outOfBounds = mainIterator.next;
				_world[y][x].moveObject(mainIterator);
				mainIterator = _outOfBounds;
			}
			else
			{
				beforeMainIterator.next = mainIterator.next;
				_world[y][x].moveObject(mainIterator);
				mainIterator = beforeMainIterator.next;
			}
		}
	}*/
	
	public function clear()
	{
		for (worldVector in _world)
		{
			for (worldPart in worldVector)
			{
				worldPart.clear();
			}
		}
	}
	
	public function destroy()
	{
		for (worldVector in _world)
		{
			for (worldPart in worldVector)
			{
				worldPart.destroy();
			}
		}
		_worldSize.put();
		_worldSize = null;
		_world = null;
	}
}

class FlxWorldPart
{
	public var mainHead : FlxLinkedListNew;
	public var mainTail : FlxLinkedListNew;
	
	public var priorityHead : FlxLinkedListNew;
	public var priorityTail : FlxLinkedListNew;
	
	public function new()
	{
		mainHead = FlxLinkedListNew.recycle();
		mainTail = FlxLinkedListNew.recycle();
		priorityHead = FlxLinkedListNew.recycle();
		priorityTail = FlxLinkedListNew.recycle();
		
		mainHead.next = mainTail;
		mainTail.next = priorityHead;
		priorityHead.next = priorityTail;
	}
	
	public function addObject (body : FlxClassicBody, isTemporary : Bool = false)
	{	
		var insertAfter = body.kinematic ? (isTemporary ? priorityTail : priorityHead) : (isTemporary ? mainTail : mainHead);
		
		if (insertAfter.object != null)
		{
			var nextObject = FlxLinkedListNew.recycle();
			nextObject.object = body;
			nextObject.next = insertAfter.next;
			insertAfter.next = nextObject;
		}
		else
		{
			insertAfter.object = body;
		}
	}
	
	public function moveObject (listElement : FlxLinkedListNew)
	{
		var insertAfter = listElement.object.kinematic ? priorityHead : mainHead;
		if (insertAfter.object == null)
		{
			insertAfter.object = listElement.object;
			listElement.next = null;
			listElement.destroy();
		}
		else
		{
			listElement.next = insertAfter.next;
			insertAfter.next = listElement;
		}
	}
	
	public function destroy()
	{
		mainHead.destroy();
	}
	
	public function clear()
	{
		mainHead.destroy();
		
		mainHead = FlxLinkedListNew.recycle();
		mainTail = FlxLinkedListNew.recycle();
		priorityHead = FlxLinkedListNew.recycle();
		priorityTail = FlxLinkedListNew.recycle();
		
		mainHead.next = mainTail;
		mainTail.next = priorityHead;
		priorityHead.next = priorityTail;
	}
}

class FlxSeparate
{
	/**
	 * This value dictates the maximum number of pixels two objects have to intersect before collision stops trying to separate them.
	 * Don't modify this unless your objects are passing through eachother.
	 */
	public static var SEPARATE_BIAS:Float	= 4;
	/**
	 * Generic value for "left" Used by facing, allowCollisions, and touching.
	 */
	public static inline var LEFT:Int	= 0x0001;
	/**
	 * Generic value for "right" Used by facing, allowCollisions, and touching.
	 */
	public static inline var RIGHT:Int	= 0x0010;
	/**
	 * Generic value for "up" Used by facing, allowCollisions, and touching.
	 */
	public static inline var UP:Int		= 0x0100;
	/**
	 * Generic value for "down" Used by facing, allowCollisions, and touching.
	 */
	public static inline var DOWN:Int	= 0x1000;
	/**
	 * Special-case constant meaning no collisions, used mainly by allowCollisions and touching.
	 */
	public static inline var NONE:Int	= 0;
	/**
	 * Special-case constant meaning up, used mainly by allowCollisions and touching.
	 */
	public static inline var CEILING:Int	= UP;
	/**
	 * Special-case constant meaning down, used mainly by allowCollisions and touching.
	 */
	public static inline var FLOOR:Int	= DOWN;
	/**
	 * Special-case constant meaning only the left and right sides, used mainly by allowCollisions and touching.
	 */
	public static inline var WALL:Int	= LEFT | RIGHT;
	/**
	 * Special-case constant meaning any direction, used mainly by allowCollisions and touching.
	 */
	public static inline var ANY:Int	= LEFT | RIGHT | UP | DOWN;
	
	private static var _firstSeparateFlxRect:FlxRect = FlxRect.get();
	private static var _secondSeparateFlxRect:FlxRect = FlxRect.get();
	
	/**
	 * The main collision resolution function in flixel.
	 * 
	 * @param	Object1 	Any FlxObject.
	 * @param	Object2		Any other FlxObject.
	 * @return	Whether the objects in fact touched and were separated.
	 */
	public static function separate(Object1:FlxClassicBody, Object2:FlxClassicBody):Bool
	{
		var separatedX:Bool = separateX(Object1, Object2);
		var separatedY:Bool = separateY(Object1, Object2);
		if (separatedX || separatedY)
		{
			if (Object1.callback != null)
			{
				Object1.callback(Object1, Object2);
			}
			if (Object2.callback != null)
			{
				Object2.callback(Object2, Object1);
			}
			return true;
		}
		
		return false;
	}
	
	/**
	 * The X-axis component of the object separation process.
	 * 
	 * @param	Object1 	Any FlxObject.
	 * @param	Object2		Any other FlxObject.
	 * @return	Whether the objects in fact touched and were separated along the X axis.
	 */
	public static function separateX(Object1:FlxClassicBody, Object2:FlxClassicBody):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = Object1.kinematic;
		var obj2immovable:Bool = Object2.kinematic;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		
		//If one of the objects is a tilemap, just pass it off.
		/*if (Object1.flixelType == TILEMAP)
		{
			return cast(Object1, FlxBaseTilemap<Dynamic>).overlapsWithCallback(Object2, separateX);
		}
		if (Object2.flixelType == TILEMAP)
		{
			return cast(Object2, FlxBaseTilemap<Dynamic>).overlapsWithCallback(Object1, separateX, true);
		}*/
		
		//First, get the two object deltas
		var overlap:Float = 0;
		var obj1delta:Float = Object1.x - Object1.last.x;
		var obj2delta:Float = Object2.x - Object2.last.x;
		
		if (obj1delta != obj2delta)
		{
			//Check if the X hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.set(Object1.x - ((obj1delta > 0) ? obj1delta : 0), Object1.last.y, Object1.width + obj1deltaAbs, Object1.height);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(Object2.x - ((obj2delta > 0) ? obj2delta : 0), Object2.last.y, Object2.width + obj2deltaAbs, Object2.height);
			
			if ((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = Object1.x + Object1.width - Object2.x;
					if ((overlap > maxOverlap) || ((Object1.allowCollisions & RIGHT) == 0) || ((Object2.allowCollisions & LEFT) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= RIGHT;
						Object2.touching |= LEFT;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = Object1.x - Object2.width - Object2.x;
					if ((-overlap > maxOverlap) || ((Object1.allowCollisions & LEFT) == 0) || ((Object2.allowCollisions & RIGHT) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= LEFT;
						Object2.touching |= RIGHT;
					}
				}
			}
		}
		
		//Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1v:Float = Object1.velocity.x;
			var obj2v:Float = Object2.velocity.x;
			
			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.x = Object1.x - overlap;
				Object2.x += overlap;
				
				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass) / Object1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass) / Object2.mass) * ((obj1v > 0) ? 1 : -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.x = average + obj1velocity * Object1.elasticity;
				Object2.velocity.x = average + obj2velocity * Object2.elasticity;
			}
			else if (!obj1immovable)
			{
				Object1.x = Object1.x - overlap;
				Object1.velocity.x = obj2v - obj1v * Object1.elasticity;
			}
			else if (!obj2immovable)
			{
				Object2.x += overlap;
				Object2.velocity.x = obj1v - obj2v * Object2.elasticity;
			}
			
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * The Y-axis component of the object separation process.
	 * 
	 * @param	Object1 	Any FlxObject.
	 * @param	Object2		Any other FlxObject.
	 * @return	Whether the objects in fact touched and were separated along the Y axis.
	 */
	public static function separateY(Object1:FlxClassicBody, Object2:FlxClassicBody):Bool
	{
		//can't separate two immovable objects
		var obj1immovable:Bool = Object1.kinematic;
		var obj2immovable:Bool = Object2.kinematic;
		if (obj1immovable && obj2immovable)
		{
			return false;
		}
		/*
		//If one of the objects is a tilemap, just pass it off.
		if (Object1.flixelType == TILEMAP)
		{
			return cast(Object1, FlxBaseTilemap<Dynamic>).overlapsWithCallback(Object2, separateY);
		}
		if (Object2.flixelType == TILEMAP)
		{
			return cast(Object2, FlxBaseTilemap<Dynamic>).overlapsWithCallback(Object1, separateY, true);
		}*/

		//First, get the two object deltas
		var overlap:Float = 0;
		var obj1delta:Float = Object1.y - Object1.last.y;
		var obj2delta:Float = Object2.y - Object2.last.y;
		
		if (obj1delta != obj2delta)
		{
			//Check if the Y hulls actually overlap
			var obj1deltaAbs:Float = (obj1delta > 0) ? obj1delta : -obj1delta;
			var obj2deltaAbs:Float = (obj2delta > 0) ? obj2delta : -obj2delta;
			
			var obj1rect:FlxRect = _firstSeparateFlxRect.set(Object1.x, Object1.y - ((obj1delta > 0) ? obj1delta : 0), Object1.width, Object1.height + obj1deltaAbs);
			var obj2rect:FlxRect = _secondSeparateFlxRect.set(Object2.x, Object2.y - ((obj2delta > 0) ? obj2delta : 0), Object2.width, Object2.height + obj2deltaAbs);
			
			if ((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
			{
				var maxOverlap:Float = obj1deltaAbs + obj2deltaAbs + SEPARATE_BIAS;
				
				//If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (obj1delta > obj2delta)
				{
					overlap = Object1.y + Object1.height - Object2.y;
					if ((overlap > maxOverlap) || ((Object1.allowCollisions & DOWN) == 0) || ((Object2.allowCollisions & UP) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= DOWN;
						Object2.touching |= UP;
					}
				}
				else if (obj1delta < obj2delta)
				{
					overlap = Object1.y - Object2.height - Object2.y;
					if ((-overlap > maxOverlap) || ((Object1.allowCollisions & UP) == 0) || ((Object2.allowCollisions & DOWN) == 0))
					{
						overlap = 0;
					}
					else
					{
						Object1.touching |= UP;
						Object2.touching |= DOWN;
					}
				}
			}
		}
		
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			var obj1v:Float = Object1.velocity.y;
			var obj2v:Float = Object2.velocity.y;
			
			if (!obj1immovable && !obj2immovable)
			{
				overlap *= 0.5;
				Object1.y = Object1.y - overlap;
				Object2.y += overlap;
				
				var obj1velocity:Float = Math.sqrt((obj2v * obj2v * Object2.mass)/Object1.mass) * ((obj2v > 0) ? 1 : -1);
				var obj2velocity:Float = Math.sqrt((obj1v * obj1v * Object1.mass)/Object2.mass) * ((obj1v > 0) ? 1 : -1);
				var average:Float = (obj1velocity + obj2velocity) * 0.5;
				obj1velocity -= average;
				obj2velocity -= average;
				Object1.velocity.y = average + obj1velocity * Object1.elasticity;
				Object2.velocity.y = average + obj2velocity * Object2.elasticity;
			}
			else if (!obj1immovable)
			{
				Object1.y = Object1.y - overlap;
				Object1.velocity.y = obj2v - obj1v*Object1.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object1.collisonXDrag && Object2.parent.active && (obj1delta > obj2delta))
				{
					Object1.x += Object2.x - Object2.last.x;
				}
			}
			else if (!obj2immovable)
			{
				Object2.y += overlap;
				Object2.velocity.y = obj1v - obj2v*Object2.elasticity;
				// This is special case code that handles cases like horizontal moving platforms you can ride
				if (Object2.collisonXDrag && Object1.parent.active && (obj1delta < obj2delta))
				{
					Object2.x += Object1.x - Object1.last.x;
				}
			}
			return true;
		}
		else
		{
			return false;
		}
	}
}

class FlxLinkedListNew implements IFlxDestroyable
{
	/**
	 * Pooling mechanism, when FlxLinkedLists are destroyed, they get added
	 * to this collection, and when they get recycled they get removed.
	 */
	public static var  _NUM_CACHED_FLX_LIST:Int = 0;
	private static var _cachedListsHead:FlxLinkedListNew;
	
	/**
	 * Recycle a cached Linked List, or creates a new one if needed.
	 */
	public static function recycle():FlxLinkedListNew
	{
		if (_cachedListsHead != null)
		{
			var cachedList:FlxLinkedListNew = _cachedListsHead;
			_cachedListsHead = _cachedListsHead.next;
			_NUM_CACHED_FLX_LIST--;
			
			cachedList.exists = true;
			cachedList.next = null;
			return cachedList;
		}
		else
			return new FlxLinkedListNew();
	}
	
	/**
	 * Clear cached List nodes. You might want to do this when loading new levels
	 * (probably not though, no need to clear cache unless you run into memory problems).
	 */
	public static function clearCache():Void 
	{
		// null out next pointers to help out garbage collector
		while (_cachedListsHead != null)
		{
			var node = _cachedListsHead;
			_cachedListsHead = _cachedListsHead.next;
			node.object = null;
			node.next = null;
		}
		_NUM_CACHED_FLX_LIST = 0;
	}
	
	/**
	 * Stores a reference to a FlxObject.
	 */
	public var object:FlxClassicBody;
	/**
	 * Stores a reference to the next link in the list.
	 */
	public var next:FlxLinkedListNew;
	
	public var exists:Bool = true;
	
	/**
	 * Private, use recycle instead.
	 */
	private function new() {}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		// ensure we haven't been destroyed already
		if (!exists)
			return;
		
		object = null;
		if (next != null)
		{
			next.destroy();
		}
		exists = false;
		
		// Deposit this list into the linked list for reusal.
		next = _cachedListsHead;
		_cachedListsHead = this;
		_NUM_CACHED_FLX_LIST++;
	}
}