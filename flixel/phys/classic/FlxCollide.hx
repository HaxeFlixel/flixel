package flixel.phys.classic;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;
import flixel.phys.classic.FlxClassicBody;

/**
 * A fairly generic quad tree structure for rapid overlap checks.
 * FlxQuadTree is also configured for single or dual list operation.
 * You can add items either to its A list or its B list.
 * When you do an overlap check, you can compare the A list to itself,
 * or the A list against the B list.  Handy for different things!
 */
class FlxCollide
{
	public static function collide(array : Array<FlxClassicBody>, iterationNumber : Int)
	{
		FlxNewQuadTree.divisions = 6;
		var root = FlxNewQuadTree.recycle(0, 0, FlxG.worldBounds.width, FlxG.worldBounds.height);
		root.load(array, null, null, separate);
		while(iterationNumber-- > 0)
			root.execute();
		root.destroy();
	}
	
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
		return separatedX || separatedY;
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

class FlxNewQuadTree extends FlxRect
{
	/**
	 * Flag for specifying that you want to add an object to the A list.
	 */
	public static inline var A_LIST:Int = 0;
	/**
	 * Flag for specifying that you want to add an object to the B list.
	 */
	public static inline var B_LIST:Int = 1;
	/**
	 * Controls the granularity of the quad tree.  Default is 6 (decent performance on large and small worlds).
	 */
	public static var divisions:Int;
	
	public var exists:Bool;
	
	/**
	 * Whether this branch of the tree can be subdivided or not.
	 */
	private var _canSubdivide:Bool;
	
	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	private var _headA:FlxLinkedListNew;
	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	private var _tailA:FlxLinkedListNew;
	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	private var _headB:FlxLinkedListNew;
	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	private var _tailB:FlxLinkedListNew;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private static var _min:Int;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _northWestTree:FlxNewQuadTree;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _northEastTree:FlxNewQuadTree;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _southEastTree:FlxNewQuadTree;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _southWestTree:FlxNewQuadTree;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _leftEdge:Float;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _rightEdge:Float;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _topEdge:Float;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _bottomEdge:Float;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _halfWidth:Float;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _halfHeight:Float;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _midpointX:Float;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _midpointY:Float;
	
	/**
	 * Internal, used to reduce recursive method parameters during object placement and tree formation.
	 */
	private static var _object:FlxClassicBody;
	/**
	 * Internal, used to reduce recursive method parameters during object placement and tree formation.
	 */
	private static var _objectLeftEdge:Float;
	/**
	 * Internal, used to reduce recursive method parameters during object placement and tree formation.
	 */
	private static var _objectTopEdge:Float;
	/**
	 * Internal, used to reduce recursive method parameters during object placement and tree formation.
	 */
	private static var _objectRightEdge:Float;
	/**
	 * Internal, used to reduce recursive method parameters during object placement and tree formation.
	 */
	private static var _objectBottomEdge:Float;
	
	/**
	 * Internal, used during tree processing and overlap checks.
	 */
	private static var _list:Int;
	/**
	 * Internal, used during tree processing and overlap checks.
	 */
	private static var _useBothLists:Bool;
	/**
	 * Internal, used during tree processing and overlap checks.
	 */
	private static var _processingCallback:FlxClassicBody->FlxClassicBody->Bool;
	/**
	 * Internal, used during tree processing and overlap checks.
	 */
	private static var _notifyCallback:FlxClassicBody->FlxClassicBody->Void;
	/**
	 * Internal, used during tree processing and overlap checks.
	 */
	private static var _iterator:FlxLinkedListNew;
	
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _objectHullX:Float;
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _objectHullY:Float;
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _objectHullWidth:Float;
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _objectHullHeight:Float;
	
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _checkObjectHullX:Float;
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _checkObjectHullY:Float;
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _checkObjectHullWidth:Float;
	/**
	 * Internal, helpers for comparing actual object-to-object overlap - see overlapNode().
	 */
	private static var _checkObjectHullHeight:Float;
	
	/**
	 * Pooling mechanism, turn FlxQuadTree into a linked list, when FlxQuadTrees are destroyed, they get added to the list, and when they get recycled they get removed.
	 */
	public static  var _NUM_CACHED_QUAD_TREES:Int = 0;
	private static var _cachedTreesHead:FlxNewQuadTree;
	private var next:FlxNewQuadTree;
	
	private static var numberOfQuadTrees = 0;
	
	/**
	 * Private, use recycle instead.
	 */
	private function new(X:Float, Y:Float, Width:Float, Height:Float, ?Parent:FlxNewQuadTree)
	{
		super();
		set(X, Y, Width, Height);
		reset(X, Y, Width, Height, Parent);
		trace(++numberOfQuadTrees);
	}
	
	/**
	 * Recycle a cached Quad Tree node, or creates a new one if needed.
	 * @param	X			The X-coordinate of the point in space.
	 * @param	Y			The Y-coordinate of the point in space.
	 * @param	Width		Desired width of this node.
	 * @param	Height		Desired height of this node.
	 * @param	Parent		The parent branch or node.  Pass null to create a root.
	 */
	public static function recycle(X:Float, Y:Float, Width:Float, Height:Float, ?Parent:FlxNewQuadTree):FlxNewQuadTree
	{
		if (_cachedTreesHead != null)
		{
			var cachedTree:FlxNewQuadTree = _cachedTreesHead;
			_cachedTreesHead = _cachedTreesHead.next;
			_NUM_CACHED_QUAD_TREES--;
			
			cachedTree.reset(X, Y, Width, Height, Parent);
			return cachedTree;
		}
		else
			return new FlxNewQuadTree(X, Y, Width, Height, Parent);
	}
	/**
	 * Clear cached Quad Tree nodes. You might want to do this when loading new levels (probably not though, no need to clear cache unless you run into memory problems).
	 */
	public static function clearCache():Void 
	{
		// null out next pointers to help out garbage collector
		while (_cachedTreesHead != null)
		{
			var node = _cachedTreesHead;
			_cachedTreesHead = _cachedTreesHead.next;
			node.next = null;
		}
		_NUM_CACHED_QUAD_TREES = 0;
	}
	
	public function reset(X:Float, Y:Float, Width:Float, Height:Float, Parent:FlxNewQuadTree = null):Void
	{
		exists = true;
		
		set(X, Y, Width, Height);
		
		_headA = _tailA = FlxLinkedListNew.recycle();
		_headB = _tailB = FlxLinkedListNew.recycle();
		
		//Copy the parent's children (if there are any)
		if (Parent != null)
		{
			var iterator:FlxLinkedListNew;
			var ot:FlxLinkedListNew;
			if (Parent._headA.object != null)
			{
				iterator = Parent._headA;
				while (iterator != null)
				{
					if (_tailA.object != null)
					{
						ot = _tailA;
						_tailA = FlxLinkedListNew.recycle();
						ot.next = _tailA;
					}
					_tailA.object = iterator.object;
					iterator = iterator.next;
				}
			}
			if (Parent._headB.object != null)
			{
				iterator = Parent._headB;
				while (iterator != null)
				{
					if (_tailB.object != null)
					{
						ot = _tailB;
						_tailB = FlxLinkedListNew.recycle();
						ot.next = _tailB;
					}
					_tailB.object = iterator.object;
					iterator = iterator.next;
				}
			}
		}
		else
		{
			_min = Math.floor((width + height) / (2 * divisions));
		}
		_canSubdivide = (width > _min) || (height > _min);
		
		//Set up comparison/sort helpers
		_northWestTree = null;
		_northEastTree = null;
		_southEastTree = null;
		_southWestTree = null;
		_leftEdge = x;
		_rightEdge = x + width;
		_halfWidth = width / 2;
		_midpointX = _leftEdge + _halfWidth;
		_topEdge = y;
		_bottomEdge = y + height;
		_halfHeight = height / 2;
		_midpointY = _topEdge + _halfHeight;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_headA = FlxDestroyUtil.destroy(_headA);
		_headB = FlxDestroyUtil.destroy(_headB);

		_tailA = FlxDestroyUtil.destroy(_tailA);
		_tailB = FlxDestroyUtil.destroy(_tailB);

		_northWestTree = FlxDestroyUtil.destroy(_northWestTree);
		_northEastTree = FlxDestroyUtil.destroy(_northEastTree);
		
		_southWestTree = FlxDestroyUtil.destroy(_southWestTree);
		_southEastTree = FlxDestroyUtil.destroy(_southEastTree);

		_object = null;
		_processingCallback = null;
		_notifyCallback = null;
		
		exists = false;
		
		// Deposit this tree into the linked list for reusal.
		next = _cachedTreesHead;
		_cachedTreesHead = this;
		_NUM_CACHED_QUAD_TREES++;

		super.destroy();
	}

	/**
	 * Load objects and/or groups into the quad tree, and register notify and processing callbacks.
	 * @param ObjectOrGroup1	Any object that is or extends FlxObject or FlxGroup.
	 * @param ObjectOrGroup2	Any object that is or extends FlxObject or FlxGroup.  If null, the first parameter will be checked against itself.
	 * @param NotifyCallback	A function with the form myFunction(Object1:FlxObject,Object2:FlxObject):void that is called whenever two objects are found to overlap in world space, and either no ProcessCallback is specified, or the ProcessCallback returns true. 
	 * @param ProcessCallback	A function with the form myFunction(Object1:FlxObject,Object2:FlxObject):Boolean that is called whenever two objects are found to overlap in world space.  The NotifyCallback is only called if this function returns true.  See FlxObject.separate(). 
	 */
	public function load(ObjectOrGroup1:Array<FlxClassicBody>, ObjectOrGroup2:FlxClassicBody = null, NotifyCallback:FlxClassicBody->FlxClassicBody->Void = null, ProcessCallback:FlxClassicBody->FlxClassicBody->Bool = null):Void
	{
		for(obj in ObjectOrGroup1)
			add(obj, A_LIST);
		
		if (ObjectOrGroup2 != null)
		{
			add(ObjectOrGroup2, B_LIST);
			_useBothLists = true;
		}
		else
		{
			_useBothLists = false;
		}
		_notifyCallback = NotifyCallback;
		_processingCallback = ProcessCallback;
	}
	
	/**
	 * Call this function to add an object to the root of the tree.
	 * This function will recursively add all group members, but
	 * not the groups themselves.
	 * @param	ObjectOrGroup	FlxObjects are just added, FlxGroups are recursed and their applicable members added accordingly.
	 * @param	List			A int flag indicating the list to which you want to add the objects.  Options are A_LIST and B_LIST.
	 */
	public function add(ObjectOrGroup:FlxClassicBody, list:Int):Void
	{
		_list = list;
		_object = ObjectOrGroup;
		_objectLeftEdge = _object.x;
		_objectTopEdge = _object.y;
		_objectRightEdge = _object.x + _object.width;
		_objectBottomEdge = _object.y + _object.height;
		addObject();
	}
	
	/**
	 * Internal function for recursively navigating and creating the tree
	 * while adding objects to the appropriate nodes.
	 */
	private function addObject():Void
	{
		//If this quad (not its children) lies entirely inside this object, add it here
		if (!_canSubdivide || (_leftEdge >= _objectLeftEdge && _rightEdge <= _objectRightEdge && _topEdge >= _objectTopEdge && _bottomEdge <= _objectBottomEdge))
		{
			addToList();
			return;
		}
		
		//See if the selected object fits completely inside any of the quadrants
		if ((_objectLeftEdge > _leftEdge) && (_objectRightEdge < _midpointX))
		{
			if ((_objectTopEdge > _topEdge) && (_objectBottomEdge < _midpointY))
			{
				if (_northWestTree == null)
				{
					_northWestTree = FlxNewQuadTree.recycle(_leftEdge, _topEdge, _halfWidth, _halfHeight, this);
				}
				_northWestTree.addObject();
				return;
			}
			if ((_objectTopEdge > _midpointY) && (_objectBottomEdge < _bottomEdge))
			{
				if (_southWestTree == null)
				{
					_southWestTree = FlxNewQuadTree.recycle(_leftEdge, _midpointY, _halfWidth, _halfHeight, this);
				}
				_southWestTree.addObject();
				return;
			}
		}
		if ((_objectLeftEdge > _midpointX) && (_objectRightEdge < _rightEdge))
		{
			if ((_objectTopEdge > _topEdge) && (_objectBottomEdge < _midpointY))
			{
				if (_northEastTree == null)
				{
					_northEastTree = FlxNewQuadTree.recycle(_midpointX, _topEdge, _halfWidth, _halfHeight, this);
				}
				_northEastTree.addObject();
				return;
			}
			if ((_objectTopEdge > _midpointY) && (_objectBottomEdge < _bottomEdge))
			{
				if (_southEastTree == null)
				{
					_southEastTree = FlxNewQuadTree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
				}
				_southEastTree.addObject();
				return;
			}
		}
		
		//If it wasn't completely contained we have to check out the partial overlaps
		if ((_objectRightEdge > _leftEdge) && (_objectLeftEdge < _midpointX) && (_objectBottomEdge > _topEdge) && (_objectTopEdge < _midpointY))
		{
			if (_northWestTree == null)
			{
				_northWestTree = FlxNewQuadTree.recycle(_leftEdge, _topEdge, _halfWidth, _halfHeight, this);
			}
			_northWestTree.addObject();
		}
		if ((_objectRightEdge > _midpointX) && (_objectLeftEdge < _rightEdge) && (_objectBottomEdge > _topEdge) && (_objectTopEdge < _midpointY))
		{
			if (_northEastTree == null)
			{
				_northEastTree = FlxNewQuadTree.recycle(_midpointX, _topEdge, _halfWidth, _halfHeight, this);
			}
			_northEastTree.addObject();
		}
		if ((_objectRightEdge > _midpointX) && (_objectLeftEdge < _rightEdge) && (_objectBottomEdge > _midpointY) && (_objectTopEdge < _bottomEdge))
		{
			if (_southEastTree == null)
			{
				_southEastTree = FlxNewQuadTree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
			}
			_southEastTree.addObject();
		}
		if ((_objectRightEdge > _leftEdge) && (_objectLeftEdge < _midpointX) && (_objectBottomEdge > _midpointY) && (_objectTopEdge < _bottomEdge))
		{
			if (_southWestTree == null)
			{
				_southWestTree = FlxNewQuadTree.recycle(_leftEdge, _midpointY, _halfWidth, _halfHeight, this);
			}
			_southWestTree.addObject();
		}
	}
	
	/**
	 * Internal function for recursively adding objects to leaf lists.
	 */
	private function addToList():Void
	{
		var ot:FlxLinkedListNew;
		if (_list == A_LIST)
		{
			if (_tailA.object != null)
			{
				ot = _tailA;
				_tailA = FlxLinkedListNew.recycle();
				ot.next = _tailA;
			}
			_tailA.object = _object;
		}
		else
		{
			if (_tailB.object != null)
			{
				ot = _tailB;
				_tailB = FlxLinkedListNew.recycle();
				ot.next = _tailB;
			}
			_tailB.object = _object;
		}
		if (!_canSubdivide)
		{
			return;
		}
		if (_northWestTree != null)
		{
			_northWestTree.addToList();
		}
		if (_northEastTree != null)
		{
			_northEastTree.addToList();
		}
		if (_southEastTree != null)
		{
			_southEastTree.addToList();
		}
		if (_southWestTree != null)
		{
			_southWestTree.addToList();
		}
	}
	
	/**
	 * FlxQuadTree's other main function.  Call this after adding objects
	 * using FlxQuadTree.load() to compare the objects that you loaded.
	 * @return	Whether or not any overlaps were found.
	 */
	public function execute():Bool
	{
		var overlapProcessed:Bool = false;
		var iterator:FlxLinkedListNew;
		
		if (_headA.object != null)
		{
			iterator = _headA;
			while (iterator != null)
			{
				_object = iterator.object;
				if (_useBothLists)
				{
					_iterator = _headB;
				}
				else
				{
					_iterator = iterator.next;
				}
				if (_object != null &&
					_iterator != null && _iterator.object != null && overlapNode())
				{
					overlapProcessed = true;
				}
				iterator = iterator.next;
			}
		}
		
		//Advance through the tree by calling overlap on each child
		if ((_northWestTree != null) && _northWestTree.execute())
		{
			overlapProcessed = true;
		}
		if ((_northEastTree != null) && _northEastTree.execute())
		{
			overlapProcessed = true;
		}
		if ((_southEastTree != null) && _southEastTree.execute())
		{
			overlapProcessed = true;
		}
		if ((_southWestTree != null) && _southWestTree.execute())
		{
			overlapProcessed = true;
		}
		
		return overlapProcessed;
	}
	
	/**
	 * An internal function for comparing an object against the contents of a node.
	 * @return	Whether or not any overlaps were found.
	 */
	private function overlapNode():Bool
	{
		//Calculate bulk hull for _object
		_objectHullX = (_object.x < _object.last.x) ? _object.x : _object.last.x;
		_objectHullY = (_object.y < _object.last.y) ? _object.y : _object.last.y;
		_objectHullWidth = _object.x - _object.last.x;
		_objectHullWidth = _object.width + ((_objectHullWidth > 0) ? _objectHullWidth : -_objectHullWidth);
		_objectHullHeight = _object.y - _object.last.y;
		_objectHullHeight = _object.height + ((_objectHullHeight > 0) ? _objectHullHeight : -_objectHullHeight);
		
		//Walk the list and check for overlaps
		var overlapProcessed:Bool = false;
		var checkObject:FlxClassicBody;
		
		while (_iterator != null)
		{
			checkObject = _iterator.object;
			if (_object == checkObject)
			{
				_iterator = _iterator.next;
				continue;
			}
			
			//Calculate bulk hull for checkObject
			_checkObjectHullX = (checkObject.x < checkObject.last.x) ? checkObject.x : checkObject.last.x;
			_checkObjectHullY = (checkObject.y < checkObject.last.y) ? checkObject.y : checkObject.last.y;
			_checkObjectHullWidth = checkObject.x - checkObject.last.x;
			_checkObjectHullWidth = checkObject.width + ((_checkObjectHullWidth > 0) ? _checkObjectHullWidth : -_checkObjectHullWidth);
			_checkObjectHullHeight = checkObject.y - checkObject.last.y;
			_checkObjectHullHeight = checkObject.height + ((_checkObjectHullHeight > 0) ? _checkObjectHullHeight : -_checkObjectHullHeight);
			
			//Check for intersection of the two hulls
			if ((_objectHullX + _objectHullWidth > _checkObjectHullX) &&
				(_objectHullX < _checkObjectHullX + _checkObjectHullWidth) &&
				(_objectHullY + _objectHullHeight > _checkObjectHullY) &&
				(_objectHullY < _checkObjectHullY + _checkObjectHullHeight))
			{
				//Execute callback functions if they exist
				if (_processingCallback == null || _processingCallback(_object, checkObject))
				{
					overlapProcessed = true;
					if (_notifyCallback != null)
					{
						_notifyCallback(_object, checkObject);
					}
				}
			}
			if (_iterator != null)
			{
				_iterator = _iterator.next;
			}
		}
		
		return overlapProcessed;
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