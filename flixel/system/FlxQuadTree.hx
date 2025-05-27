package flixel.system;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxCollision;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPool;

typedef ProcessCallback = (FlxObject, FlxObject) -> Bool;
typedef NotifyCallback = (FlxObject, FlxObject) -> Void;

/**
 * A fairly generic quad tree structure for rapid overlap checks.
 * FlxQuadTree is also configured for single or dual list operation.
 * You can add items either to its A list or its B list.
 * When you do an overlap check, you can compare the A list to itself,
 * or the A list against the B list.  Handy for different things!
 */
class FlxQuadTree implements IFlxDestroyable implements IFlxPooled
{
	public static var pool:FlxPool<FlxQuadTree> = new FlxPool(() -> new FlxQuadTree());
	
	/**
	 * Controls the granularity of the quad tree.  Default is 6 (decent performance on large and small worlds).
	 */
	public var divisions:Int;
	
	public var rect:FlxRect;
	
	final listA:Array<FlxObject> = [];
	final listB:Array<FlxObject> = [];
	
	var nw:Null<FlxQuadTree>;
	var ne:Null<FlxQuadTree>;
	var se:Null<FlxQuadTree>;
	var sw:Null<FlxQuadTree>;
	
	// var minSize:Float;
	
	overload public static inline extern function executeOnce(x, y, width, height, divisions, objectA, objectB, notifier, processer)
	{
		final quad = get(x, y, width, height, divisions);
		final result = quad.loadAndExecute(objectA, objectB, notifier, processer);
		quad.put();
		return result;
	}
	
	overload public static inline extern function executeOnce(rect, divisions, objectA, objectB, notifier, processer)
	{
		return executeOnce(rect.x, rect.y, rect.width, rect.height, divisions, objectA, objectB, notifier, processer);
	}
	
	/**
	 * Recycle a cached Quad Tree node, or creates a new one if needed.
	 * @param   x          The X-coordinate of the point in space.
	 * @param   y          The Y-coordinate of the point in space.
	 * @param   width      Desired width of this node.
	 * @param   height     Desired height of this node.
	 * @param   divisions  Desired height of this node.
	 */
	public static function get(x, y, width, height, divisions)
	{
		return pool.get().reset(x, y, width, height, divisions);
	}
	
	static function getSub(x, y, width, height, parent)
	{
		return pool.get().resetSub(x, y, width, height, parent);
	}
	
	function new() {}
	
	public function reset(x:Float, y:Float, width:Float, height:Float, divisions:Int)
	{
		this.divisions = divisions;
		
		rect = FlxRect.get(x, y, width, height);
		
		listA.resize(0);
		listB.resize(0);
		
		return this;
	}
	
	public function resetSub(x:Float, y:Float, width:Float, height:Float, parent:FlxQuadTree)
	{
		return reset(x, y, width, height, parent.divisions - 1);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		rect = FlxDestroyUtil.put(rect);
		listA.resize(0);
		listB.resize(0);
		
		nw = FlxDestroyUtil.put(nw);
		ne = FlxDestroyUtil.put(ne);
		sw = FlxDestroyUtil.put(sw);
		se = FlxDestroyUtil.put(se);
	}
	
	public function put()
	{
		pool.put(this);
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
	public function loadAndExecute(objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic, ?notifier:NotifyCallback, ?processer:ProcessCallback):Bool
	{
		load(objectOrGroup1, objectOrGroup2);
		return execute(objectOrGroup2 != null, notifier, processer);
	}
	
	public function load(objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic):Void
	{
		add(objectOrGroup1, true);
		if (objectOrGroup2 != null && objectOrGroup2 != objectOrGroup1)
			add(objectOrGroup2, false);
	}
	
	/**
	 * Call this function to add an object to the root of the tree.
	 * This function will recursively add all group members, but not the groups themselves.
	 * 
	 * @param   basic  FlxObjects are just added, FlxGroups are recursed and their applicable members added accordingly.
	 * @param   list   A int flag indicating the list to which you want to add the objects.  Options are A_LIST and B_LIST.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	function add(basic:FlxBasic, listA:Bool):Void
	{
		final group = FlxTypedGroup.resolveGroup(basic);
		if (group != null)
		{
			for (member in group.members)
			{
				if (member != null && member.exists)
					add(member, listA);
			}
		}
		else if (basic is FlxObject)
		{
			final object:FlxObject = cast basic;
			if (object.exists && object.allowCollisions != NONE)
				addObject(object, listA);
		}
		else
		{
			throw 'Can only add FlxGroups, FlxSpriteGroups and FlxObjects to quad trees';
		}
	}
	
	/**
	 * Internal function for recursively navigating and creating the tree
	 * while adding objects to the appropriate nodes.
	 */
	function addObject(object:FlxObject, isA:Bool):Void
	{
		final bounds = object.getHitbox();
		// If this quad lies entirely inside this object, add it here
		if (divisions > 0 || bounds.contains(rect))
		{
			(isA ? listA : listB).push(object);
			bounds.put();
			return;
		}
		
		final quadrant = FlxRect.get();
		
		getQuadrant(false, false, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (nw == null)
				nw = getSub(quadrant.x, quadrant.y, quadrant.width, quadrant.height, this);
				
			nw.addObject(object, isA);
		}
		
		getQuadrant(true, false, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (ne == null)
				ne = getSub(quadrant.x, quadrant.y, quadrant.width, quadrant.height, this);
				
			ne.addObject(object, isA);
		}
		
		getQuadrant(false, true, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (sw == null)
				sw = getSub(quadrant.x, quadrant.y, quadrant.width, quadrant.height, this);
				
			sw.addObject(object, isA);
		}
		
		getQuadrant(true, true, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (se == null)
				se = getSub(quadrant.x, quadrant.y, quadrant.width, quadrant.height, this);
				
			se.addObject(object, isA);
		}
		
		quadrant.put();
		bounds.put();
	}
	
	public function execute(useBothLists:Bool, notifier:NotifyCallback, processer:ProcessCallback):Bool
	{
		var processed = false;
		
		final listB = useBothLists ? this.listB : this.listA;
		for (a in 0...listA.length)
		{
			final objectA = listA[a];
			final rectA = FlxCollision.getDeltaRect(objectA);
			for (b in 0...listB.length)
			{
				final objectB = listB[b];
				final rectB = FlxCollision.getDeltaRect(objectB);
				if (processOverlap(objectA, objectB, rectA, rectB, notifier, processer))
					processed = true;
			}
		}
	
		
		// Advance through the tree by calling overlap on each child
		if (nw != null && nw.execute(useBothLists, notifier, processer))
			processed = true;
			
		if (ne != null && ne.execute(useBothLists, notifier, processer))
			processed = true;
			
		if (se != null && se.execute(useBothLists, notifier, processer))
			processed = true;
			
		if (sw != null && sw.execute(useBothLists, notifier, processer))
			processed = true;
			
		return processed;
	}
	
	function processOverlap(a:FlxObject, b:FlxObject, rectA:FlxRect, rectB:FlxRect, notifier:Null<NotifyCallback>, processer:Null<ProcessCallback>):Bool
	{
		if (rectA.overlaps(rectB) && (processer == null || processer(a, b)))
		{
			if (notifier != null)
				notifier(a, b);
				
			return true;
		}
		
		return false;
	}
	
	function getQuadrant(up:Bool, left:Bool, result:FlxRect)
	{
		result.set(rect.x, rect.y, rect.width / 2, rect.height / 2);
		
		if (!left) result.x += result.width;
		if (!up  ) result.y += result.height;
	}
}