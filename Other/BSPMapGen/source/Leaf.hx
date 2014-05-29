package;

import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.util.FlxRandom;

class Leaf
{
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;

	public var leftChild:Leaf;
	public var rightChild:Leaf;
	public var room:Rectangle;		   // Room inside this Leaf
	public var halls:Array<Rectangle>; // Connects this Leaf to others

	public static inline var MIN_LEAF_SIZE = 6;
	public static inline var MAX_LEAF_SIZE = 24;

	public function new(X:Int, Y:Int, Width:Int, Height:Int)
	{
		// Initialize the leaf
		x = X;
		y = Y;
		width = Width;
		height = Height;
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
		var splitH:Bool = FlxRandom.float() > 0.5;

		if (width > height && height / width >= 0.05)
			splitH = false;
		else if (height > width && width / height >= 0.05)
			splitH = true;

		var max = (splitH ? height : width) - MIN_LEAF_SIZE; // determine the maximum height or width
		if (max <= MIN_LEAF_SIZE)
			return false; // the area is too small to split any more...

		// Where to split
		var split = Std.int(randomNumber(MIN_LEAF_SIZE, max)); // determine where we're going to split

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
			else if (FlxRandom.float() > .5)
				return lRoom;
			else
				return rRoom;
		}
	}

	public function createRooms():Void
	{
		// Generates all rooms and hallways for this leaf and its' children
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
			// This leaf should make a room
			var roomSize:Point;
			var roomPos:Point;
			// Room can be between 3x3 tiles to the leaf size - 2
			roomSize = new Point(randomNumber(3, width - 2), randomNumber(3, height - 2));
			// Place the room within leaf, but not against sides (would merge)
			roomPos = new Point(randomNumber(1, width - roomSize.x - 1), randomNumber(1, height - roomSize.y - 1));
			room = new Rectangle(x + roomPos.x, y + roomPos.y, roomSize.x, roomSize.y);
		}
	}

	public function createHall(L:Rectangle, R:Rectangle):Void
	{
		// Connects 2 rooms together with hallways
		halls = new Array<Rectangle>();

		var point1:Point = new Point(randomNumber(L.left + 1, L.right - 2), randomNumber(L.top + 1, L.bottom - 2));
		var point2:Point = new Point(randomNumber(R.left + 1, R.right - 2), randomNumber(R.top + 1, R.bottom - 2));

		var w = point2.x - point1.x;
		var h = point2.y - point1.y;

		if (w < 0)
		{
			if (h < 0)
			{
				if (FlxRandom.float() > 0.5)
				{
					halls.push(new Rectangle(point2.x, point1.y, Math.abs(w), 1));
					halls.push(new Rectangle(point2.x, point2.y, 1, Math.abs(h)));
				}
				else
				{
					halls.push(new Rectangle(point2.x, point2.y, Math.abs(w), 1));
					halls.push(new Rectangle(point1.x, point2.y, 1, Math.abs(h)));
				}
			}
			else if (h > 0)
			{
				if (FlxRandom.float() > 0.5)
				{
					halls.push(new Rectangle(point2.x, point1.y, Math.abs(w), 1));
					halls.push(new Rectangle(point2.x, point1.y, 1, Math.abs(h)));
				}
				else
				{
					halls.push(new Rectangle(point2.x, point2.y, Math.abs(w), 1));
					halls.push(new Rectangle(point1.x, point1.y, 1, Math.abs(h)));
				}
			}
			else // if (h == 0)
			{
				halls.push(new Rectangle(point2.x, point2.y, Math.abs(w), 1));
			}
		}
		else if (w > 0)
		{
			if (h < 0)
			{
				if (FlxRandom.float() > 0.5)
				{
					halls.push(new Rectangle(point1.x, point2.y, Math.abs(w), 1));
					halls.push(new Rectangle(point1.x, point2.y, 1, Math.abs(h)));
				}
				else
				{
					halls.push(new Rectangle(point1.x, point1.y, Math.abs(w), 1));
					halls.push(new Rectangle(point2.x, point2.y, 1, Math.abs(h)));
				}
			}
			else if (h > 0)
			{
				if (FlxRandom.float() > 0.5)
				{
					halls.push(new Rectangle(point1.x, point1.y, Math.abs(w), 1));
					halls.push(new Rectangle(point2.x, point1.y, 1, Math.abs(h)));
				}
				else
				{
					halls.push(new Rectangle(point1.x, point2.y, Math.abs(w), 1));
					halls.push(new Rectangle(point1.x, point1.y, 1, Math.abs(h)));
				}
			}
			else // if (h == 0)
			{
				halls.push(new Rectangle(point1.x, point1.y, Math.abs(w), 1));
			}
		}
		else // if (w == 0)
		{
			if (h < 0)
			{
				halls.push(new Rectangle(point2.x, point2.y, 1, Math.abs(h)));
			}
			else if (h > 0)
			{
				halls.push(new Rectangle(point1.x, point1.y, 1, Math.abs(h)));
			}
		}
	}

	static public function randomNumber(Min:Float, Max:Float, Absolute = false):Float
	{
		if (!Absolute)
		{
			return Math.floor(FlxRandom.float() * (1 + Max - Min) + Min);
		}
		else
		{
			return Math.abs(Math.floor(FlxRandom.float() * (1 + Max - Min) + Min));
		}
	}
}
