package flixel.system;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

typedef ProcessCallback = (FlxObject,FlxObject)->Bool;
typedef NotifyCallback = (FlxObject,FlxObject)->Void;

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
	var _canSubdivide:Bool;

	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	var _headA:FlxLinkedList;

	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	var _tailA:FlxLinkedList;

	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	var _headB:FlxLinkedList;

	/**
	 * Refers to the internal A and B linked lists,
	 * which are used to store objects in the leaves.
	 */
	var _tailB:FlxLinkedList;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	static var _min:Int;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _northWestTree:FlxQuadTree;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _northEastTree:FlxQuadTree;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _southEastTree:FlxQuadTree;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _southWestTree:FlxQuadTree;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _leftEdge:Float;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _rightEdge:Float;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _topEdge:Float;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _bottomEdge:Float;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _halfWidth:Float;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _halfHeight:Float;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _midpointX:Float;

	/**
	 * Internal, governs and assists with the formation of the tree.
	 */
	var _midpointY:Float;

	/**
	 * Pooling mechanism, turn FlxQuadTree into a linked list, when FlxQuadTrees are destroyed, they get added to the list, and when they get recycled they get removed.
	 */
	public static var _NUM_CACHED_QUAD_TREES:Int = 0;

	static var _cachedTreesHead:FlxQuadTree;

	var next:FlxQuadTree;

	/**
	 * Private, use recycle instead.
	 */
	function new(x:Float, y:Float, width:Float, height:Float, ?parent:FlxQuadTree)
	{
		super();
		set(x, y, width, height);
		reset(x, y, width, height, parent);
	}

	/**
	 * Recycle a cached Quad Tree node, or creates a new one if needed.
	 * @param   x       The X-coordinate of the point in space.
	 * @param   y       The Y-coordinate of the point in space.
	 * @param   width   Desired width of this node.
	 * @param   height  Desired height of this node.
	 * @param   parent  The parent branch or node.  Pass null to create a root.
	 */
	public static function recycle(x:Float, y:Float, width:Float, height:Float, ?parent:FlxQuadTree):FlxQuadTree
	{
		if (_cachedTreesHead != null)
		{
			var cachedTree:FlxQuadTree = _cachedTreesHead;
			_cachedTreesHead = _cachedTreesHead.next;
			_NUM_CACHED_QUAD_TREES--;

			cachedTree.reset(x, y, width, height, parent);
			return cachedTree;
		}
		else
			return new FlxQuadTree(x, y, width, height, parent);
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

	public function reset(x:Float, y:Float, width:Float, height:Float, ?parent:FlxQuadTree):Void
	{
		exists = true;

		set(x, y, width, height);

		_headA = _tailA = FlxLinkedList.recycle();
		_headB = _tailB = FlxLinkedList.recycle();

		// Copy the parent's children (if there are any)
		if (parent != null)
		{
			var iterator:FlxLinkedList;
			var ot:FlxLinkedList;
			if (parent._headA.object != null)
			{
				iterator = parent._headA;
				while (iterator != null)
				{
					if (_tailA.object != null)
					{
						ot = _tailA;
						_tailA = FlxLinkedList.recycle();
						ot.next = _tailA;
					}
					_tailA.object = iterator.object;
					iterator = iterator.next;
				}
			}
			if (parent._headB.object != null)
			{
				iterator = parent._headB;
				while (iterator != null)
				{
					if (_tailB.object != null)
					{
						ot = _tailB;
						_tailB = FlxLinkedList.recycle();
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

		// Set up comparison/sort helpers
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

		exists = false;

		// Deposit this tree into the linked list for reusal.
		next = _cachedTreesHead;
		_cachedTreesHead = this;
		_NUM_CACHED_QUAD_TREES++;

		super.destroy();
	}

	function load(objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic):Void
	{
		add(objectOrGroup1, A_LIST);
		if (objectOrGroup2 != null)
			add(objectOrGroup2, B_LIST);
	}

	/**
	 * Call this function to add an object to the root of the tree.
	 * This function will recursively add all group members, but
	 * not the groups themselves.
	 * @param	ObjectOrGroup	FlxObjects are just added, FlxGroups are recursed and their applicable members added accordingly.
	 * @param	List			A int flag indicating the list to which you want to add the objects.  Options are A_LIST and B_LIST.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function add(basic:FlxBasic, list:Int):Void
	{
		final group = FlxTypedGroup.resolveGroup(basic);
		if (group != null)
		{
			for (member in group.members)
			{
				if (member != null && member.exists)
					add(member, list);
			}
		}
		else
		{
			final object:FlxObject = cast basic;
			if (object.exists && object.allowCollisions != NONE)
			{
				final rect = FlxRect.get();
				rect.x = object.x;
				rect.y = object.y;
				rect.width = object.x + object.width;
				rect.height = object.y + object.height;
				addObject(object, rect, list);
				rect.put();
			}
		}
	}

	/**
	 * Internal function for recursively navigating and creating the tree
	 * while adding objects to the appropriate nodes.
	 */
	function addObject(object:FlxObject, rect:FlxRect, list:Int):Void
	{
		// If this quad (not its children) lies entirely inside this object, add it here
		if (!_canSubdivide
			|| (_leftEdge >= rect.left && _rightEdge <= rect.right && _topEdge >= rect.top && _bottomEdge <= rect.bottom))
		{
			addToList(object, list);
			return;
		}

		// See if the selected object fits completely inside any of the quadrants
		if ((rect.left > _leftEdge) && (rect.right < _midpointX))
		{
			if ((rect.top > _topEdge) && (rect.bottom < _midpointY))
			{
				if (_northWestTree == null)
				{
					_northWestTree = FlxQuadTree.recycle(_leftEdge, _topEdge, _halfWidth, _halfHeight, this);
				}
				_northWestTree.addObject(object, rect, list);
				return;
			}
			
			if ((rect.top > _midpointY) && (rect.bottom < _bottomEdge))
			{
				if (_southWestTree == null)
				{
					_southWestTree = FlxQuadTree.recycle(_leftEdge, _midpointY, _halfWidth, _halfHeight, this);
				}
				_southWestTree.addObject(object, rect, list);
				return;
			}
		}
		
		if ((rect.left > _midpointX) && (rect.right < _rightEdge))
		{
			if ((rect.top > _topEdge) && (rect.bottom < _midpointY))
			{
				if (_northEastTree == null)
				{
					_northEastTree = FlxQuadTree.recycle(_midpointX, _topEdge, _halfWidth, _halfHeight, this);
				}
				_northEastTree.addObject(object, rect, list);
				return;
			}
			
			if ((rect.top > _midpointY) && (rect.bottom < _bottomEdge))
			{
				if (_southEastTree == null)
				{
					_southEastTree = FlxQuadTree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
				}
				_southEastTree.addObject(object, rect, list);
				return;
			}
		}

		// If it wasn't completely contained we have to check out the partial overlaps
		if ((rect.right > _leftEdge) && (rect.left < _midpointX) && (rect.bottom > _topEdge) && (rect.top < _midpointY))
		{
			if (_northWestTree == null)
			{
				_northWestTree = FlxQuadTree.recycle(_leftEdge, _topEdge, _halfWidth, _halfHeight, this);
			}
			_northWestTree.addObject(object, rect, list);
		}
		
		if ((rect.right > _midpointX) && (rect.left < _rightEdge) && (rect.bottom > _topEdge) && (rect.top < _midpointY))
		{
			if (_northEastTree == null)
			{
				_northEastTree = FlxQuadTree.recycle(_midpointX, _topEdge, _halfWidth, _halfHeight, this);
			}
			_northEastTree.addObject(object, rect, list);
		}
		
		if ((rect.right > _midpointX) && (rect.left < _rightEdge) && (rect.bottom > _midpointY) && (rect.top < _bottomEdge))
		{
			if (_southEastTree == null)
			{
				_southEastTree = FlxQuadTree.recycle(_midpointX, _midpointY, _halfWidth, _halfHeight, this);
			}
			_southEastTree.addObject(object, rect, list);
		}
		
		if ((rect.right > _leftEdge) && (rect.left < _midpointX) && (rect.bottom > _midpointY) && (rect.top < _bottomEdge))
		{
			if (_southWestTree == null)
			{
				_southWestTree = FlxQuadTree.recycle(_leftEdge, _midpointY, _halfWidth, _halfHeight, this);
			}
			_southWestTree.addObject(object, rect, list);
		}
	}

	/**
	 * Internal function for recursively adding objects to leaf lists.
	 */
	function addToList(object:FlxObject, list:Int):Void
	{
		var ot:FlxLinkedList;
		if (list == A_LIST)
		{
			if (_tailA.object != null)
			{
				ot = _tailA;
				_tailA = FlxLinkedList.recycle();
				ot.next = _tailA;
			}
			_tailA.object = object;
		}
		else
		{
			if (_tailB.object != null)
			{
				ot = _tailB;
				_tailB = FlxLinkedList.recycle();
				ot.next = _tailB;
			}
			_tailB.object = object;
		}
		
		if (!_canSubdivide)
			return;
		
		if (_northWestTree != null)
			_northWestTree.addToList(object, list);
		
		if (_northEastTree != null)
			_northEastTree.addToList(object, list);
		
		if (_southEastTree != null)
			_southEastTree.addToList(object, list);
		
		if (_southWestTree != null)
			_southWestTree.addToList(object, list);
	}

	/**
	 * Adds the objects or groups' members to the quadtree, searches for overlaps,
	 * processes them with the `processCallback`, calls the `notifyCallback` and eventually
	 * returns true if there were any overlaps.
	 * 
	 * @param   objectOrGroup1   Any object that is or extends FlxObject or FlxGroup.
	 * @param   objectOrGroup2   Any object that is or extends FlxObject or FlxGroup.
	 *                           If null, the first parameter will be checked against itself.
	 * @param   notifyCallback   A function called whenever two overlapping objects are found,
	 *                           and the processCallback is `null` or returns `true`.
	 * @param   processCallback  A function called whenever two overlapping objects are found.
	 *                           This will return true if the notifyCallback should be called.
	 * @return  Whether or not any overlaps were found.
	 */
	public function loadAndExecute(objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic, ?notifyCallback:NotifyCallback, ?processCallback:ProcessCallback):Bool
	{
		load(objectOrGroup1, objectOrGroup2);
		return execute(objectOrGroup2 != null, notifyCallback, processCallback);
	}

	function execute(useBothLists:Bool, notifyCallback:NotifyCallback, processCallback:ProcessCallback):Bool
	{
		var overlapProcessed:Bool = false;

		if (_headA.object != null)
		{
			var iterator = _headA;
			while (iterator != null)
			{
				final object = iterator.object;
				final next = useBothLists ? _headB : iterator.next;
				
				if (object != null && object.exists && object.allowCollisions > 0
					&& next != null && next.object != null
					&& overlapNode(object, next, notifyCallback, processCallback))
				{
					overlapProcessed = true;
				}
				iterator = iterator.next;
			}
		}

		// Advance through the tree by calling overlap on each child
		if (_northWestTree != null && _northWestTree.execute(useBothLists, notifyCallback, processCallback))
			overlapProcessed = true;
		
		if (_northEastTree != null && _northEastTree.execute(useBothLists, notifyCallback, processCallback))
			overlapProcessed = true;
		
		if (_southEastTree != null && _southEastTree.execute(useBothLists, notifyCallback, processCallback))
			overlapProcessed = true;
		
		if (_southWestTree != null && _southWestTree.execute(useBothLists, notifyCallback, processCallback))
			overlapProcessed = true;
		
		return overlapProcessed;
	}

	/**
	 * An internal function for comparing an object against the contents of a node.
	 * @return	Whether or not any overlaps were found.
	 */
	function overlapNode(object:FlxObject, iterator:FlxLinkedList, notifyCallback:Null<NotifyCallback>, processCallback:Null<ProcessCallback>):Bool
	{
		// Calculate bulk hull for the object
		final objectHullX = (object.x < object.last.x) ? object.x : object.last.x;
		final objectHullY = (object.y < object.last.y) ? object.y : object.last.y;
		final objectHullWidth = object.x - object.last.x;
		final objectHullWidth = object.width + ((objectHullWidth > 0) ? objectHullWidth : -objectHullWidth);
		final objectHullHeight = object.y - object.last.y;
		final objectHullHeight = object.height + ((objectHullHeight > 0) ? objectHullHeight : -objectHullHeight);

		// Walk the list and check for overlaps
		var overlapProcessed:Bool = false;
		var checkObject:FlxObject;

		while (iterator != null)
		{
			checkObject = iterator.object;
			if (object == checkObject || !checkObject.exists || checkObject.allowCollisions <= 0)
			{
				iterator = iterator.next;
				continue;
			}

			// Calculate bulk hull for checkObject
			final checkObjectHullX = (checkObject.x < checkObject.last.x) ? checkObject.x : checkObject.last.x;
			final checkObjectHullY = (checkObject.y < checkObject.last.y) ? checkObject.y : checkObject.last.y;
			final checkObjectHullWidth = checkObject.x - checkObject.last.x;
			final checkObjectHullWidth = checkObject.width + ((checkObjectHullWidth > 0) ? checkObjectHullWidth : -checkObjectHullWidth);
			final checkObjectHullHeight = checkObject.y - checkObject.last.y;
			final checkObjectHullHeight = checkObject.height + ((checkObjectHullHeight > 0) ? checkObjectHullHeight : -checkObjectHullHeight);

			// Check for intersection of the two hulls
			if ((objectHullX + objectHullWidth > checkObjectHullX)
				&& (objectHullX < checkObjectHullX + checkObjectHullWidth)
				&& (objectHullY + objectHullHeight > checkObjectHullY)
				&& (objectHullY < checkObjectHullY + checkObjectHullHeight))
			{
				// Execute callback functions if they exist
				if (processCallback == null || processCallback(object, checkObject))
				{
					overlapProcessed = true;
					if (notifyCallback != null)
					{
						notifyCallback(object, checkObject);
					}
				}
			}
			
			if (iterator != null)
			{
				iterator = iterator.next;
			}
		}

		return overlapProcessed;
	}
}
