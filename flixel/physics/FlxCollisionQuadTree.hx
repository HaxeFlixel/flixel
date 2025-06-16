package flixel.physics;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.physics.FlxCollider;
import flixel.system.FlxLinkedList;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPool;
import flixel.util.FlxSpriteUtil;
import haxe.iterators.ArrayIterator;
import openfl.display.Graphics;

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
	
	public var maxItems:Int = 10;
	
	public final rect = FlxRect.get();
	
	var data:QuadTreeData = LEAF([]);
	
	static function executeOnceHelper(x, y, width, height, divisions, maxItems, objectA, objectB, ?notifier, ?processer)
	{
		final quad = get(x, y, width, height, divisions, maxItems);
		final result = quad.loadAndExecute(objectA, objectB, notifier, processer);
		quad.put();
		return result;
	}
	
	overload public static inline extern function executeOnce(x:Float, y:Float, width:Float, height:Float, divisions, maxItems, objectA, objectB, ?notifier, ?processer)
	{
		return executeOnceHelper(x, y, width, height, divisions, maxItems, objectA, objectB, notifier, processer);
	}
	
	overload public static inline extern function executeOnce(rect:FlxRect, divisions, maxItems, objectA, objectB, ?notifier, ?processer)
	{
		return executeOnce(rect.x, rect.y, rect.width, rect.height, divisions, maxItems, objectA, objectB, notifier, processer);
	}
	
	overload public static inline extern function get(x, y, width, height, divisions, maxItems)
	{
		return pool.get().reset(x, y, width, height, divisions, maxItems);
	}
	
	overload public static inline extern function get(rect:FlxRect, divisions:Int, maxItems:Int)
	{
		return get(rect.x, rect.y, rect.width, rect.height, divisions, maxItems);
	}
	
	
	overload public static inline extern function get()
	{
		return get(0, 0, 0, 0, 0, 0);
	}
	
	function new() {}
	
	public function reset(x:Float, y:Float, width:Float, height:Float, divisions:Int, maxItems:Int)
	{
		this.divisions = divisions;
		this.maxItems = maxItems;
		
		rect.set(x, y, width, height);
		
		destroy();
		
		return this;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		switch data
		{
			case LEAF(items):
				items.resize(0);
			case BRANCH(children):
				children.destroy();
				data = LEAF([]);
		}
	}
	
	public function put()
	{
		pool.put(this);
	}
	
	public function getCount():Int
	{
		return switch data
		{
			case LEAF(items): items.length;
			case BRANCH(children):
				var count = 0;
				
				for (child in children)
					count += child.getCount();
				
				return count;
		}
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
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function loadAndExecute(objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic, ?notifier:NotifyCallback, ?processer:ProcessCallback):Bool
	{
		add(objectOrGroup1);
		if (objectOrGroup2 != null && objectOrGroup2 == objectOrGroup1)
		{
			add(objectOrGroup2);
			return execute(objectOrGroup1, notifier, processer);
		}
		return execute(objectOrGroup1, notifier, processer);
	}
	
	
	
	/**
	 * Call this function to add an object to the root of the tree.
	 * This function will recursively add all group members, but not the groups themselves.
	 * 
	 * @param   basic  FlxObjects are just added, FlxGroups are recursed and their applicable members added accordingly.
	 * @param   list   A int flag indicating the list to which you want to add the objects.  Options are A_LIST and B_LIST.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function add(basic:FlxBasic):Void
	{
		final group = FlxTypedGroup.resolveGroup(basic);
		if (group != null)
		{
			for (member in group.members)
			{
				if (member != null && member.exists)
					add(member);
			}
		}
		else if (basic is IFlxCollider)
		{
			final collider = (cast basic : IFlxCollider).getCollider();
			if (basic.exists && collider.allowCollisions != NONE)
			{
				addCollider(cast basic);
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
	function addCollider(object:IFlxCollider):Void
	{
		final bounds = object.getCollider().bounds;
		if (!rect.overlaps(bounds))
			return;
		
		switch data
		{
			case LEAF(items):
				items.push(object);
				
				if (items.length > maxItems && divisions > 0)
				{
					final children = new ChildTrees(this);
					for (item in items)
					{
						for (child in children.iterator())
							child.addCollider(item);
					}
					data = BRANCH(children);
				}
				
			case BRANCH(children):
				
				for (child in children)
					child.addCollider(object);
		}
	}
	
	static var noNotify = (a, b)->{} ;
	static var noProcess = (a, b)->true;
	
	public function execute(objectOrGroup:FlxBasic, ?notifier:NotifyCallback, ?processer:ProcessCallback):Bool
	{
		final noCallback = notifier == null && execute == null;
		
		if (notifier == null)
			notifier = noNotify;
		
		if (processer == null)
			processer = noProcess;
		
		return executeHelper(objectOrGroup, [], notifier, processer, noCallback);
	}
	
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	function executeHelper(basic:FlxBasic, exclude:Array<IFlxCollider>, notifier:NotifyCallback, processer:ProcessCallback, stopAtFirst:Bool):Bool
	{
		final group = FlxTypedGroup.resolveGroup(basic);
		if (group != null)
		{
			var found = false;
			for (member in group.members)
			{
				if (member != null && member.exists && executeHelper(member, exclude, notifier, processer, stopAtFirst))
				{
					if (stopAtFirst)
						return true;
					
					found = true;
				}
			}
			return found;
		}
		
		if (basic is IFlxCollider)
		{
			// add collider to excludes, otherwise each impact will dispatch twice
			exclude.push(cast basic);
			return executeColliderHelper(cast basic, exclude.copy(), notifier, processer, stopAtFirst);
		}
		
		return false;
	}
	
	public function executeCollider(object:IFlxCollider, notifier:NotifyCallback, processer:ProcessCallback, stopAtFirst:Bool):Bool
	{
		return executeColliderHelper(object, [], notifier, processer, stopAtFirst);
	}
	
	function executeColliderHelper(object:IFlxCollider, checked:Array<IFlxCollider>, notifier:NotifyCallback, processer:ProcessCallback, stopAtFirst:Bool):Bool
	{
		switch data
		{
			case LEAF(items):
				final b = object.getCollider().bounds;
				
				if (!b.overlaps(rect))
					return false;
				
				var found = false;
				for (item in items)
				{
					if (checked.contains(item) || item == object)
						continue;
					
					checked.push(item);
					final a = item.getCollider().bounds;
					final overlaps = a.overlaps(b);
					if (a.overlaps(b) && processer(object, item))
					{
						notifier(object, item);
						if (stopAtFirst)
							return true;
						
						found = true;
					}
				}
				return found;
				
			case BRANCH(children):
				
				var found = false;
				for (child in children.iterator())
				{
					if (child.executeColliderHelper(object, checked, notifier, processer, stopAtFirst))
					{
						if (stopAtFirst)
							return true;
						
						found = true;
					}
				}
				
				return found;
		}
	}
	
	function getQuadrant(up:Bool, left:Bool, result:FlxRect)
	{
		final halfX = rect.width / 2;
		final halfY = rect.height / 2;
		
		if (up && left)
			result.set(rect.x, rect.y, halfX, halfY);
		else if (up && !left)
			result.set(rect.x + halfX, rect.y, halfX, halfY);
		else if (!up && left)
			result.set(rect.x, rect.y + halfY, halfX, halfY);
		else if (!up && !left)
			result.set(rect.x + halfX, rect.y + halfY, halfX, halfY);
	}
	
	public function drawDebugOnCamera(camera:FlxCamera)
	{
		if (!camera.visible || !camera.exists)
			return;

		final gfx = beginDrawDebug(camera);
		drawDebugHelper(gfx, -camera.viewLeft, -camera.viewTop);
		endDrawDebug(camera);
	}
	
	function drawDebugHelper(gfx:Graphics, offsetX:Float, offsetY:Float)
	{
		// fill static graphics object with square shape
		// gfx.lineStyle(0.1, 0xFF00ff00, 1);
		final color:FlxColor = switch divisions
		{
			case 0: 0xFFff00ff;
			case 1: 0xFFff0000;
			case 2: 0xFFff8000;
			case 3: 0xFFffff00;
			case 4: 0xFF00ff00;
			case 5: 0xFF0000ff;
			case _: 0xFF800080;
		}
		
		switch data
		{
			case BRANCH(children):
				
				if (color.alpha > 0)
				{
					gfx.beginFill(color, 1);
					gfx.drawRect(rect.x + offsetX, rect.y + (rect.height * 0.5) + offsetY, rect.width, 1.0);
					gfx.drawRect(rect.x + (rect.width * 0.5) + offsetX, rect.y + offsetY, 1, rect.height);
					gfx.endFill();
				}
				
				for (child in children)
					child.drawDebugHelper(gfx, offsetX, offsetY);
				
			case LEAF(items):
		}
	}
	
	inline function beginDrawDebug(camera:FlxCamera):Graphics
	{
		if (FlxG.renderBlit)
		{
			FlxSpriteUtil.flashGfx.clear();
			return FlxSpriteUtil.flashGfx;
		}
		else
		{
			return camera.debugLayer.graphics;
		}
	}

	inline function endDrawDebug(camera:FlxCamera)
	{
		if (FlxG.renderBlit)
			camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
}

enum abstract Quadrant(Int)
{
	static public function iterator():Iterator<Quadrant>
	{
		return cast 0...4;
	}
	
	var NW = 0;
	var NE = 1;
	var SE = 2;
	var SW = 3;
}

enum QuadTreeData
{
	LEAF(items:Array<IFlxCollider>);
	BRANCH(children:ChildTrees);
}

abstract ChildTrees(Array<FlxCollisionQuadTree>)
{
	public var nw(get, never):FlxCollisionQuadTree;
	public var ne(get, never):FlxCollisionQuadTree;
	public var se(get, never):FlxCollisionQuadTree;
	public var sw(get, never):FlxCollisionQuadTree;
	inline function get_nw() return this[(cast NW:Int)];
	inline function get_ne() return this[(cast NE:Int)];
	inline function get_se() return this[(cast SE:Int)];
	inline function get_sw() return this[(cast SW:Int)];
	
	public function new (parent:FlxCollisionQuadTree)
	{
		this = [];
		for (i in Quadrant.iterator())
			this.push(createQuadrant(parent, i));
	}
	
	public function destroy()
	{
		for (i in this)
			i.destroy();
		
		this.resize(0);
	}
	
	function createQuadrant(parent:FlxCollisionQuadTree, quadrant:Quadrant)
	{
		final rect = parent.rect;
		final halfX = rect.width * 0.5;
		final halfY = rect.height * 0.5;
		
		return switch quadrant
		{
			case NW:
				FlxCollisionQuadTree.get(rect.x, rect.y, halfX, halfY, parent.divisions - 1, parent.maxItems);
			case NE:
				FlxCollisionQuadTree.get(rect.x + halfX, rect.y, halfX, halfY, parent.divisions - 1, parent.maxItems);
			case SE:
				FlxCollisionQuadTree.get(rect.x + halfX, rect.y + halfY, halfX, halfY, parent.divisions - 1, parent.maxItems);
			case SW:
				FlxCollisionQuadTree.get(rect.x, rect.y + halfY, halfX, halfY, parent.divisions - 1, parent.maxItems);
		}
	}
	
	public function iterator()
	{
		return this.iterator();
	}
}