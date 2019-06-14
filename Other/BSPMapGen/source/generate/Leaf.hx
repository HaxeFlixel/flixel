package generate;

import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.math.FlxPoint;

class Leaf
{
	public static inline var MIN_SIZE = 6;
	public static inline var MAX_SIZE = 24;

	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;

	public var leftChild:Leaf;
	public var rightChild:Leaf;
	public var room:Rectangle;
	public var hallways:Array<Rectangle>;

	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function split():Bool
	{
		// Split leaf into 2 children
		if (leftChild != null || rightChild != null)
			return false; // Already split

		// Determine split direction
		// If width >25% larger than height, split vertically
		// Else if height >25% larger than width, split horizontally
		// Else split randomly
		var splitH:Bool = FlxG.random.float() > 0.5;

		if (width > height && height / width >= 0.05)
			splitH = false;
		else if (height > width && width / height >= 0.05)
			splitH = true;

		var max = (splitH ? height : width) - MIN_SIZE; // determine the maximum height or width
		if (max <= MIN_SIZE)
			return false; // the area is too small to split any more...

		// Where to split
		var split = Std.int(FlxG.random.float(MIN_SIZE, max)); // determine where we're going to split

		// Create children based on split direction
		if (splitH)
		{
			leftChild = new Leaf(x, y, width, split);
			rightChild = new Leaf(x, y + split, width, height - split);
		}
		else
		{
			leftChild = new Leaf(x, y, split, height);
			rightChild = new Leaf(x + split, y, width - split, height);
		}

		return true;
	}

	public function getRoom():Rectangle
	{
		if (room != null)
			return room;
		else
		{
			var lRoom:Rectangle = null;
			var rRoom:Rectangle = null;
			if (leftChild != null)
			{
				lRoom = leftChild.getRoom();
			}
			if (rightChild != null)
			{
				rRoom = rightChild.getRoom();
			}
			if (lRoom == null && rRoom == null)
				return null;
			else if (rRoom == null)
				return lRoom;
			else if (lRoom == null)
				return rRoom;
			else if (FlxG.random.float() > .5)
				return lRoom;
			else
				return rRoom;
		}
	}

	public function createRooms():Void
	{
		// Generates all rooms and hallways for this leaf and its children
		if (leftChild != null || rightChild != null)
		{
			// This leaf has been split, go to children leafs
			if (leftChild != null)
			{
				leftChild.createRooms();
			}
			if (rightChild != null)
			{
				rightChild.createRooms();
			}

			// If both left/right children in leaf, make hallway between them
			if (leftChild != null && rightChild != null)
			{
				createHall(leftChild.getRoom(), rightChild.getRoom());
			}
		}
		else
		{
			// Room can be between 3x3 tiles to the leaf size - 2
			var roomSize = new FlxPoint(FlxG.random.float(3, width - 2), FlxG.random.float(3, height - 2));
			// Place the room within leaf, but not against sides (would merge)
			var roomPos = new FlxPoint(FlxG.random.float(1, width - roomSize.x - 1), FlxG.random.float(1, height - roomSize.y - 1));

			room = new Rectangle(x + roomPos.x, y + roomPos.y, roomSize.x, roomSize.y);
		}
	}

	public function createHall(left:Rectangle, right:Rectangle):Void
	{
		// Connects 2 rooms together with hallways
		hallways = [];

		var point1 = FlxPoint.get(FlxG.random.float(left.left + 1, left.right - 2), FlxG.random.float(left.top + 1, left.bottom - 2));
		var point2 = FlxPoint.get(FlxG.random.float(right.left + 1, right.right - 2), FlxG.random.float(right.top + 1, right.bottom - 2));

		var w = point2.x - point1.x;
		var h = point2.y - point1.y;

		if (w < 0)
		{
			if (h < 0)
			{
				if (FlxG.random.float() > 0.5)
				{
					hallways.push(new Rectangle(point2.x, point1.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point2.x, point2.y, 1, Math.abs(h)));
				}
				else
				{
					hallways.push(new Rectangle(point2.x, point2.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point1.x, point2.y, 1, Math.abs(h)));
				}
			}
			else if (h > 0)
			{
				if (FlxG.random.float() > 0.5)
				{
					hallways.push(new Rectangle(point2.x, point1.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point2.x, point1.y, 1, Math.abs(h)));
				}
				else
				{
					hallways.push(new Rectangle(point2.x, point2.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point1.x, point1.y, 1, Math.abs(h)));
				}
			}
			else
			{
				hallways.push(new Rectangle(point2.x, point2.y, Math.abs(w), 1));
			}
		}
		else if (w > 0)
		{
			if (h < 0)
			{
				if (FlxG.random.float() > 0.5)
				{
					hallways.push(new Rectangle(point1.x, point2.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point1.x, point2.y, 1, Math.abs(h)));
				}
				else
				{
					hallways.push(new Rectangle(point1.x, point1.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point2.x, point2.y, 1, Math.abs(h)));
				}
			}
			else if (h > 0)
			{
				if (FlxG.random.float() > 0.5)
				{
					hallways.push(new Rectangle(point1.x, point1.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point2.x, point1.y, 1, Math.abs(h)));
				}
				else
				{
					hallways.push(new Rectangle(point1.x, point2.y, Math.abs(w), 1));
					hallways.push(new Rectangle(point1.x, point1.y, 1, Math.abs(h)));
				}
			}
			else
			{
				hallways.push(new Rectangle(point1.x, point1.y, Math.abs(w), 1));
			}
		}
		else
		{
			if (h < 0)
			{
				hallways.push(new Rectangle(point2.x, point2.y, 1, Math.abs(h)));
			}
			else if (h > 0)
			{
				hallways.push(new Rectangle(point1.x, point1.y, 1, Math.abs(h)));
			}
		}
	}
}
