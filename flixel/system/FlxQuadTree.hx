package flixel.system;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxCollisionType;
import flixel.util.FlxRect;

/**
 * A fairly generic quad tree structure for rapid overlap checks.
 * FlxQuadTree is also configured for single or dual list operation.
 * You can add items either to its A list or its B list.
 * When you do an overlap check, you can compare the A list to itself,
 * or the A list against the B list.  Handy for different things!
 */
class FlxQuadTree extends FlxRect
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
	private var _headA:FlxList;
	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	private var _tailA:FlxList;
	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	private var _headB:FlxList;
	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	private var _tailB:FlxList;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private static var _min:Int;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _northWestTree:FlxQuadTree;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _northEastTree:FlxQuadTree;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _southEastTree:FlxQuadTree;
	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	private var _southWestTree:FlxQuadTree;
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
	private static var _object:FlxObject;
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
	private static var _processingCallback:FlxObject->FlxObject->Bool;
	/**
	 * Internal, used during tree processing and overlap checks.
	 */
	private static var _notifyCallback:FlxObject->FlxObject->Void;
	/**
	 * Internal, used during tree processing and overlap checks.
	 */
	private static var _iterator:FlxList;
	
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
	private static var _cachedTreesHead:FlxQuadTree;
	private 	   var next:FlxQuadTree;
	
	/**
	 * Private, use recycle instead.
	 */
	private function new(X:Float, Y:Float, Width:Float, Height:Float, Parent:FlxQuadTree = null)
	{
		super(X, Y, Width, Height);
		reset(X, Y, Width, Height, Parent);
	}
	
	/**
	 * Recycle a cached Quad Tree node, or creates a new one if needed.
	 * @param	X			The X-coordinate of the point in space.
	 * @param	Y			The Y-coordinate of the point in space.
	 * @param	Width		Desired width of this node.
	 * @param	Height		Desired height of this node.
	 * @param	Parent		The parent branch or node.  Pass null to create a root.
	 */
	public static function recycle(X:Float, Y:Float, Width:Float, Height:Float, Parent:FlxQuadTree = null):FlxQuadTree
	{
		if (_cachedTreesHead != null)
		{
			var cachedTree:FlxQuadTree = _cachedTreesHead;
			_cachedTreesHead = _cachedTreesHead.next;
			_NUM_CACHED_QUAD_TREES--;
			
			cachedTree.reset(X, Y, Width, Height, Parent);
			return cachedTree;
		}
		else
			return new FlxQuadTree(X, Y, Width, Height, Parent);
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
	
	public function reset(X:Float, Y:Float, Width:Float, Height:Float, Parent:FlxQuadTree = null):Void
	{
		exists = true;
		
		set(X, Y, Width, Height);
		
		_headA = _tailA = FlxList.recycle();
		_headB = _tailB = FlxList.recycle();
		
		//Copy the parent's children (if there are any)
		if (Parent != null)
		{
			var iterator:FlxList;
			var ot:FlxList;
			if (Parent._headA.object != null)
			{
				iterator = Parent._headA;
				while(iterator != null)
				{
					if (_tailA.object != null)
					{
						ot = _tailA;
						_tailA = FlxList.recycle();
						ot.next = _tailA;
					}
					_tailA.object = iterator.object;
					iterator = iterator.next;
				}
			}
			if (Parent._headB.object != null)
			{
				iterator = Parent._headB;
				while(iterator != null)
				{
					if (_tailB.object != null)
					{
						ot = _tailB;
						_tailB = FlxList.recycle();
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
		if (_headA != null)
		{
			_headA.destroy();
		}
		_headA = null;
		if (_tailA != null)
		{
			_tailA.destroy();
		}
		_tailA = null;
		if (_headB != null)
		{
			_headB.destroy();
		}
		_headB = null;
		if (_tailB != null)
		{
			_tailB.destroy();
		}
		_tailB = null;

		if (_northWestTree != null)
		{
			_northWestTree.destroy();
		}
		_northWestTree = null;
		if (_northEastTree != null)
		{
			_northEastTree.destroy();
		}
		_northEastTree = null;
		if (_southEastTree != null)
		{
			_southEastTree.destroy();
		}
		_southEastTree = null;
		if (_southWestTree != null)
		{
			_southWestTree.destroy();
		}
		_southWestTree = null;

		_object = null;
		_processingCallback = null;
		_notifyCallback = null;
		
		exists = false;
		
		// Deposit this tree into the linked list for reusal.
		next = _cachedTreesHead;
		_cachedTreesHead = this;
		_NUM_CACHED_QUAD_TREES++;
	}

	/**
	 * Load objects and/or groups into the quad tree, and register notify and processing callbacks.
	 * @param ObjectOrGroup1	Any object that is or extends FlxObject or FlxGroup.
	 * @param ObjectOrGroup2	Any object that is or extends FlxObject or FlxGroup.  If null, the first parameter will be checked against itself.
	 * @param NotifyCallback	A function with the form myFunction(Object1:FlxObject,Object2:FlxObject):void that is called whenever two objects are found to overlap in world space, and either no ProcessCallback is specified, or the ProcessCallback returns true. 
	 * @param ProcessCallback	A function with the form myFunction(Object1:FlxObject,Object2:FlxObject):Boolean that is called whenever two objects are found to overlap in world space.  The NotifyCallback is only called if this function returns true.  See FlxObject.separate(). 
	 */
	public function load(ObjectOrGroup1:FlxBasic, ObjectOrGroup2:FlxBasic = null, NotifyCallback:FlxObject->FlxObject->Void = null, ProcessCallback:FlxObject->FlxObject->Bool = null):Void
	{
		add(ObjectOrGroup1, A_LIST);
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
	public function add(ObjectOrGroup:FlxBasic, list:Int):Void
	{
		_list = list;
		
		if (ObjectOrGroup.collisionType == FlxCollisionType.SPRITEGROUP)
		{
			ObjectOrGroup = Reflect.field(ObjectOrGroup, "group");
		}
		
		if (ObjectOrGroup.collisionType == FlxCollisionType.GROUP)
		{
			var i:Int = 0;
			var basic:FlxBasic;
			var collisionType:FlxCollisionType;
			var group:FlxTypedGroup<FlxBasic> = cast ObjectOrGroup;
			var members:Array<FlxBasic> = group.members;
			var l:Int = group.length;
			while (i < l)
			{
				basic = members[i++];
				if ((basic != null) && basic.exists)
				{
					collisionType = basic.collisionType;
					if (collisionType == FlxCollisionType.SPRITEGROUP)
					{
						basic = Reflect.field(ObjectOrGroup, "group");
					}
					
					if (collisionType == FlxCollisionType.GROUP)
					{
						add(basic, list);
					}
					else if (collisionType == FlxCollisionType.OBJECT || collisionType == FlxCollisionType.TILEMAP)
					{
						_object = cast(basic, FlxObject);
						if (_object.exists && _object.allowCollisions != FlxObject.NONE)
						{
							_objectLeftEdge = _object.x;
							_objectTopEdge = _object.y;
							_objectRightEdge = _object.x + _object.width;
							_objectBottomEdge = _object.y + _object.height;
							addObject();
						}
					}
				}
			}
		}
		else
		{
			_object = cast(ObjectOrGroup, FlxObject);
			if (_object.exists && _object.allowCollisions != FlxObject.NONE)
			{
				_objectLeftEdge = _object.x;
				_objectTopEdge = _object.y;
				_objectRightEdge = _object.x + _object.width;
				_objectBottomEdge = _object.y + _object.height;
				addObject();
			}
		}
	}
	
	/**
	 * Internal function for recursively navigating and creating the tree
	 * while adding objects to the appropriate nodes.
	 */
	private function addObject():Void
	{
		//If this quad (not its children) lies entirely inside this object, add it here
		if(!_canSubdivide || ((_leftEdge >= _objectLeftEdge) && (_rightEdge <= _objectRightEdge) && (_topEdge >= _objectTopEdge) && (_bottomEdge <= _objectBottomEdge)))
		{
			addToList();
			return;
		}
		
		//See if the selected object fits completely inside any of the quadrants
		if((_objectLeftEdge > _leftEdge) && (_objectRightEdge < _midpointX))
		{
			if((_objectTopEdge > _topEdge) && (_objectBottomEdge < _midpointY))
			{
				if (_northWestTree == null)
				{
					_northWestTree = FlxQuadTree.recycle(_leftEdge, _topEdge, _halfWidth, _halfHeight, this);
				}
				_northWestTree.addObject();
				return;
			}
			if((_objectTopEdge > _midpointY) && (_objectBottomEdge < _bottomEdge))
			{
				if (_southWestTree == null)
				{
					_southWestTree = FlxQuadTree.recycle(_leftEdge, _midpointY, _halfWidth, _halfHeight, this);
				}
				_southWestTree.addObject();
				return;
			}
		}
		if((_objectLeftEdge > _midpointX) && (_objectRightEdge < _rightEdge))
		{
			if((_objectTopEdge > _topEdge) && (_objectBottomEdge < _midpointY))
			{
				if (_northEastTree == null)
				{
					_northEastTree = FlxQuadTree.recycle(_midpointX, _topEdge, _halfWidth, _halfHeight, this);
				}
				_northEastTree.addObject();
				return;
			}
			if((_objectTopEdge > _midpointY) && (_objectBottomEdge < _bottomEdge))
			{
				if (_southEastTree == null)
				{
					_southEastTree = FlxQuadTree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
				}
				_southEastTree.addObject();
				return;
			}
		}
		
		//If it wasn't completely contained we have to check out the partial overlaps
		if((_objectRightEdge > _leftEdge) && (_objectLeftEdge < _midpointX) && (_objectBottomEdge > _topEdge) && (_objectTopEdge < _midpointY))
		{
			if (_northWestTree == null)
			{
				_northWestTree = FlxQuadTree.recycle(_leftEdge, _topEdge, _halfWidth, _halfHeight, this);
			}
			_northWestTree.addObject();
		}
		if((_objectRightEdge > _midpointX) && (_objectLeftEdge < _rightEdge) && (_objectBottomEdge > _topEdge) && (_objectTopEdge < _midpointY))
		{
			if (_northEastTree == null)
			{
				_northEastTree = FlxQuadTree.recycle(_midpointX, _topEdge, _halfWidth, _halfHeight, this);
			}
			_northEastTree.addObject();
		}
		if((_objectRightEdge > _midpointX) && (_objectLeftEdge < _rightEdge) && (_objectBottomEdge > _midpointY) && (_objectTopEdge < _bottomEdge))
		{
			if (_southEastTree == null)
			{
				_southEastTree = FlxQuadTree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
			}
			_southEastTree.addObject();
		}
		if((_objectRightEdge > _leftEdge) && (_objectLeftEdge < _midpointX) && (_objectBottomEdge > _midpointY) && (_objectTopEdge < _bottomEdge))
		{
			if (_southWestTree == null)
			{
				_southWestTree = FlxQuadTree.recycle(_leftEdge, _midpointY, _halfWidth, _halfHeight, this);
			}
			_southWestTree.addObject();
		}
	}
	
	/**
	 * Internal function for recursively adding objects to leaf lists.
	 */
	private function addToList():Void
	{
		var ot:FlxList;
		if (_list == A_LIST)
		{
			if (_tailA.object != null)
			{
				ot = _tailA;
				_tailA = FlxList.recycle();
				ot.next = _tailA;
			}
			_tailA.object = _object;
		}
		else
		{
			if (_tailB.object != null)
			{
				ot = _tailB;
				_tailB = FlxList.recycle();
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
		var iterator:FlxList;
		
		if (_headA.object != null)
		{
			iterator = _headA;
			while(iterator != null)
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
				if (_object.exists && (_object.allowCollisions > 0) &&
					(_iterator != null) && (_iterator.object != null) &&
					_iterator.object.exists && overlapNode())
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
		//Walk the list and check for overlaps
		var overlapProcessed:Bool = false;
		var checkObject:FlxObject;
		while (_iterator != null)
		{
			if (_object == null || (!_object.exists || (_object.allowCollisions <= 0)))
			{
				break;
			}
			
			checkObject = _iterator.object;
			if((_object == checkObject) || !checkObject.exists || (checkObject.allowCollisions <= 0))
			{
				_iterator = _iterator.next;
				continue;
			}
			
			//calculate bulk hull for _object
			_objectHullX = (_object.x < _object.last.x)?_object.x:_object.last.x;
			_objectHullY = (_object.y < _object.last.y)?_object.y:_object.last.y;
			_objectHullWidth = _object.x - _object.last.x;
			_objectHullWidth = _object.width + ((_objectHullWidth>0)?_objectHullWidth:-_objectHullWidth);
			_objectHullHeight = _object.y - _object.last.y;
			_objectHullHeight = _object.height + ((_objectHullHeight>0)?_objectHullHeight:-_objectHullHeight);
			
			//calculate bulk hull for checkObject
			_checkObjectHullX = (checkObject.x < checkObject.last.x)?checkObject.x:checkObject.last.x;
			_checkObjectHullY = (checkObject.y < checkObject.last.y)?checkObject.y:checkObject.last.y;
			_checkObjectHullWidth = checkObject.x - checkObject.last.x;
			_checkObjectHullWidth = checkObject.width + ((_checkObjectHullWidth>0)?_checkObjectHullWidth:-_checkObjectHullWidth);
			_checkObjectHullHeight = checkObject.y - checkObject.last.y;
			_checkObjectHullHeight = checkObject.height + ((_checkObjectHullHeight>0)?_checkObjectHullHeight:-_checkObjectHullHeight);
			
			//check for intersection of the two hulls
			if ((_objectHullX + _objectHullWidth > _checkObjectHullX) &&
				(_objectHullX < _checkObjectHullX + _checkObjectHullWidth) &&
				(_objectHullY + _objectHullHeight > _checkObjectHullY) &&
				(_objectHullY < _checkObjectHullY + _checkObjectHullHeight))
			{
				// Execute callback functions if they exist
				if ((_processingCallback == null) || _processingCallback(_object, checkObject))
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