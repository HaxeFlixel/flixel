package flixel.physics;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.physics.FlxCollider;
import flixel.system.FlxLinkedList;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPool;

typedef NotifyCallback = (IFlxCollider, IFlxCollider) -> Void;

/**
 * A fairly generic quad tree structure for rapid overlap checks.
 * FlxCollisionQuadTree is also configured for single or dual list operation.
 * You can add items either to its A list or its B list.
 * When you do an overlap check, you can compare the A list to itself,
 * or the A list against the B list.  Handy for different things!
 */
class FlxCollisionQuadTree implements IFlxDestroyable implements IFlxPooled
{
	public static var pool:FlxPool<FlxCollisionQuadTree> = new FlxPool(() -> new FlxCollisionQuadTree());
	
	/**
	 * Controls the granularity of the quad tree.  Default is 6 (decent performance on large and small worlds).
	 */
	public var divisions:Int = 0;
	
	public var rect:FlxRect;
	
	final listA:Array<IFlxCollider> = [];
	final listB:Array<IFlxCollider> = [];
	
	var nw:Null<FlxCollisionQuadTree>;
	var ne:Null<FlxCollisionQuadTree>;
	var se:Null<FlxCollisionQuadTree>;
	var sw:Null<FlxCollisionQuadTree>;
	
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
	
	overload public static inline extern function get(x, y, width, height, divisions)
	{
		return pool.get().reset(x, y, width, height, divisions);
	}
	
	overload public static inline extern function get(rect:FlxRect, divisions:Int)
	{
		return get(rect.x, rect.y, rect.width, rect.height, divisions);
	}
	
	overload static inline extern function getSub(x, y, width, height, parent)
	{
		return pool.get().resetSub(x, y, width, height, parent);
	}
	
	overload static inline extern function getSub(rect:FlxRect, parent)
	{
		return getSub(rect.x, rect.y, rect.width, rect.height, parent);
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
	
	public function resetSub(x:Float, y:Float, width:Float, height:Float, parent:FlxCollisionQuadTree)
	{
		return reset(x, y, width, height, parent.divisions - 1);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		listA.resize(0);
		listB.resize(0);
		
		nw = FlxDestroyUtil.destroy(nw);
		ne = FlxDestroyUtil.destroy(ne);
		sw = FlxDestroyUtil.destroy(sw);
		se = FlxDestroyUtil.destroy(se);
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
	
	function load(objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic):Void
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
		else if (basic is IFlxCollider)
		{
			final collider = (cast basic : IFlxCollider).getCollider();
			if (basic.exists && collider.allowCollisions != NONE)
			{
				addCollider(cast basic, collider, listA);
			}
		}
		else
		{
			throw 'Can only add FlxGroups and IFlxColliders to quad trees';
		}
	}
	
	/**
	 * Internal function for recursively navigating and creating the tree
	 * while adding objects to the appropriate nodes.
	 */
	function addCollider(object:IFlxCollider, collider:FlxCollider, isA:Bool):Void
	{
		final bounds = collider.bounds;
		// If this quad (not its children) lies entirely inside this object, add it here
		if (divisions > 0 || bounds.contains(rect))
		{
			(isA ? listA : listB).push(object);
			return;
		}
		
		final quadrant = FlxRect.get();
		
		getQuadrant(false, false, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (nw == null)
				nw = getSub(quadrant, this);
				
			nw.addCollider(object, collider, isA);
		}
		
		getQuadrant(true, false, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (ne == null)
				ne = getSub(quadrant, this);
				
			ne.addCollider(object, collider, isA);
		}
		
		getQuadrant(false, true, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (sw == null)
				sw = getSub(quadrant, this);
				
			sw.addCollider(object, collider, isA);
		}
		
		getQuadrant(true, true, quadrant);
		if (quadrant.overlaps(bounds))
		{
			if (se == null)
				se = getSub(quadrant, this);
				
			se.addCollider(object, collider, isA);
		}
		
		quadrant.put();
	}
	
	function execute(useBothLists:Bool, notifier:NotifyCallback, processer:ProcessCallback):Bool
	{
		var processed = false;
		
		if (useBothLists)
		{
			for (a in 0...listA.length)
			{
				for (b in 0...listB.length)
				{
					if (process(listA[a], listB[b], notifier, processer))
						processed = true;
				}
			}
		}
		else
		{
			for (a in 0...listA.length)
			{
				for (b in a...listA.length)
				{
					if (process(listA[a], listA[b], notifier, processer))
						processed = true;
				}
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
	
	function process(a:IFlxCollider, b:IFlxCollider, notifier:Null<NotifyCallback>, processer:Null<ProcessCallback>):Bool
	{
		if (a.getCollider().bounds.overlaps(b.getCollider().bounds) && (processer == null || processer(a, b)))
		{
			if (notifier != null)
				notifier(a, b);
				
			return true;
		}
		
		return false;
	}
	
	function getQuadrant(up:Bool, left:Bool, result:FlxRect)
	{
		final halfX = rect.width / 2;
		final halfY = rect.height / 2;
		
		if (up && left)
			result.set(rect.x, rect.y, halfX, halfY);
		else if (up && !left)
			result.set(rect.x + halfX, rect.y, halfX, rect.height);
		else if (!up && left)
			result.set(rect.x, rect.y + halfY, rect.width, halfY);
		else if (!up && !left)
			result.set(rect.x + halfX, rect.y + halfY, halfX, halfY);
	}
}
