package flixel.group;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.system.FlxCollisionType;
import flixel.util.FlxArrayUtil;

/**
 * This is an organizational class that can update and render a bunch of <code>FlxBasic</code>s.
 * NOTE: Although <code>FlxGroup</code> extends <code>FlxBasic</code>, it will not automatically
 * add itself to the global collisions quad tree, it will only add its members.
 */
class FlxTypedGroup<T:FlxBasic> extends FlxBasic
{
	/**
	 * Use with <code>sort()</code> to sort in ascending order.
	 */
	inline static public var ASCENDING:Int = -1;
	/**
	 * Use with <code>sort()</code> to sort in descending order.
	 */
	inline static public var DESCENDING:Int = 1;
	/**
	 * Array of all the members in this group.
	 */
	public var members(get, never):Array<T>;
	/**
	 * The maximum capacity of this group. Default is 0, meaning no max capacity, and the group can just grow.
	 */
	public var maxSize(default, set):Int;
	/**
	 * The number of entries in the members array. For performance and safety you should check this 
	 * variable instead of <code>members.length</code> unless you really know what you're doing!
	 */
	public var length:Int = 0;
	/**
	 * Whether <code>revive()</code> also revives all members of this group. 
	 * False by default.
	 */
	public var autoReviveMembers:Bool = false;
	/**
	 * Internal helper variable for recycling objects a la <code>FlxEmitter</code>.
	 */
	private var _marker:Int = 0;
	/**
	 * Helper for sort.
	 */
	private var _sortIndex:String = null;
	/**
	 * Helper for sort.
	 */
	private var _sortOrder:Int;
	
	/**
	 * Array of all the <code>FlxBasic</code>s that exist in this group.
	 */
	private var _basics:Array<FlxBasic>;
	/**
	 * Array of all the members in this group.
	 */
	private var _members:Array<T>;

	/**
	 * Create a new <code>FlxTypedGroup</code>
	 * 
	 * @param	MaxSize		Maximum amount of members allowed
	 */
	public function new(MaxSize:Int = 0)
	{
		super();
		
		maxSize = Std.int(Math.abs(MaxSize));
		
		_members = new Array<T>();
		_basics = cast _members;
		collisionType = FlxCollisionType.GROUP;
	}
	
	/**
	 * WARNING: This will remove this group entirely. Use <code>kill()</code> if you want to disable it
	 * temporarily only and be able to <code>revive()</code> it later.
	 * Override this function to handle any deleting or "shutdown" type operations you might need,
	 * such as removing traditional Flash children like Sprite objects.
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		if (_basics != null)
		{
			var i:Int = 0;
			var basic:FlxBasic = null;
			
			while (i < length)
			{
				basic = _basics[i++];
				
				if (basic != null)
				{
					basic.destroy();
				}
			}
			
			_basics = null;
			_members = null;
		}
		
		_sortIndex = null;
	}
	
	/**
	 * Automatically goes through and calls update on everything you added.
	 */
	override public function update():Void
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if ((basic != null) && basic.exists && basic.active)
			{
				basic.update();
			}
		}
	}
	
	/**
	 * Automatically goes through and calls render on everything you added.
	 */
	override public function draw():Void
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if ((basic != null) && basic.exists && basic.visible)
			{
				basic.draw();
			}
		}
	}
	
	#if !FLX_NO_DEBUG
	override public function drawDebug():Void 
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if ((basic != null) && basic.exists && basic.visible)
			{
				basic.drawDebug();
			}
		}
	}
	#end
	
	/**
	 * Adds a new <code>FlxBasic</code> subclass (FlxBasic, FlxSprite, Enemy, etc) to the group.
	 * FlxGroup will try to replace a null member of the array first.
	 * Failing that, FlxGroup will add it to the end of the member array,
	 * assuming there is room for it, and doubling the size of the array if necessary.
	 * WARNING: If the group has a maxSize that has already been met,
	 * the object will NOT be added to the group!
	 * 
	 * @param	Object		The object you want to add to the group.
	 * @return	The same <code>FlxBasic</code> object that was passed in.
	 */
	public function add(Object:T):T
	{
		if (Object == null)
		{
			FlxG.log.warn("Cannot add a `null` object to a FlxGroup.");
			return null;
		}
		
		// Don't bother adding an object twice.
		if (FlxArrayUtil.indexOf(_members, Object) >= 0)
		{
			return Object;
		}
		
		// First, look for a null entry where we can add the object.
		var i:Int = 0;
		var l:Int = _members.length;
		
		while (i < l)
		{
			if (_members[i] == null)
			{
				_members[i] = Object;
				
				if (i >= length)
				{
					length = i + 1;
				}
				
				return Object;
			}
			i++;
		}
		
		// Failing that, expand the array (if we can) and add the object.
		if (maxSize > 0)
		{
			if (_members.length >= maxSize)
			{
				return Object;
			}
			else if (_members.length * 2 <= maxSize)
			{
				FlxArrayUtil.setLength(_members, _members.length * 2);
			}
			else
			{
				FlxArrayUtil.setLength(_members, maxSize);
			}
		}
		else
		{
			FlxArrayUtil.setLength(_members, _members.length * 2);
		}
		
		// If we made it this far, then we successfully grew the group,
		// and we can go ahead and add the object at the first open slot.
		_members[i] = Object;
		length = i + 1;
		
		return Object;
	}
	
	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * If you specified a maximum size for this group (like in </code>FlxEmitter</code> ),
	 * then recycle will employ what we're calling "rotating" recycling.
	 * <code>recycle()</code> will first check to see if the group is at capacity yet.
	 * If group is not yet at capacity, recycle() returns a new object.
	 * If the group IS at capacity, then recycle() just returns the next object in line.
	 * If you did NOT specify a maximum size for this group,
	 * then </code>recycle()</code> will employ what we're calling "grow-style" recycling.
	 * </code>recycle()</code> will return either the first object with </code>exists == false()</code>,
	 * or, finding none, add a new object to the array,
	 * doubling the size of the array if necessary.
	 * WARNING: If this function needs to create a new object,
	 * and no object class was provided, it will return null
	 * instead of a valid object!
	 * 
	 * @param	ObjectClass		The class type you want to recycle (e.g. FlxSprite, EvilRobot, etc). Do NOT "new" the class in the parameter!
	 * @param 	ContructorArgs  An array of arguments passed into a newly object if there aren't any dead members to recycle. 
	 * @param 	Force           Force the object to be an ObjectClass and not a super class of ObjectClass. 
	 * @return	A reference to the object that was created.  Don't forget to cast it back to the Class you want (e.g. myObject = myGroup.recycle(myObjectClass) as myObjectClass;).
	 */
	public function recycle(ObjectClass:Class<T> = null, ContructorArgs:Array<Dynamic> = null, Force:Bool = false):T
	{
		if (ContructorArgs == null)
		{
			ContructorArgs = [];
		}
		
		var basic:T = null;
		
		if (maxSize > 0)
		{
			if (length < maxSize)
			{
				if (ObjectClass == null)
				{
					return null;
				}
				
				return add(Type.createInstance(ObjectClass, ContructorArgs));
			}
			else
			{
				basic = _members[_marker++];
				
				if (_marker >= maxSize)
				{
					_marker = 0;
				}
				
				return basic;
			}
		}
		else
		{
			basic = getFirstAvailable(ObjectClass, Force);
			
			if (basic != null)
			{
				return basic;
			}
			if (ObjectClass == null)
			{
				return null;
			}
			
			return add(Type.createInstance(ObjectClass, ContructorArgs));
		}
	}
	
	/**
	 * Removes an object from the group.
	 * @param	Object	The <code>FlxBasic</code> you want to remove.
	 * @param	Splice	Whether the object should be cut from the array entirely or not.
	 * @return	The removed object.
	 */
	public function remove(Object:T, Splice:Bool = false):T
	{
		if (_members == null)
		{
			return null;
		}
		
		var index:Int = FlxArrayUtil.indexOf(_members, Object);
		
		if ((index < 0) || (index >= _members.length))
		{
			return null;
		}
		if (Splice)
		{
			_members.splice(index, 1);
		}
		else
		{
			_members[index] = null;
		}
		
		return Object;
	}
	
	/**
	 * Replaces an existing <code>FlxBasic</code> with a new one.
	 * 
	 * @param	OldObject	The object you want to replace.
	 * @param	NewObject	The new object you want to use instead.
	 * @return	The new object.
	 */
	public function replace(OldObject:T, NewObject:T):T
	{
		var index:Int = FlxArrayUtil.indexOf(_members, OldObject);
		
		if ((index < 0) || (index >= _members.length))
		{
			return null;
		}
		
		_members[index] = NewObject;
		
		return NewObject;
	}
	
	/**
	 * Call this function to sort the group according to a particular value and order.
	 * For example, to sort game objects for Zelda-style overlaps you might call
	 * <code>myGroup.sort("y",ASCENDING)</code> at the bottom of your
	 * <code>FlxState.update()</code> override.  To sort all existing objects after
	 * a big explosion or bomb attack, you might call <code>myGroup.sort("exists",DESCENDING)</code>.
	 * 
	 * @param	Index	The <code>String</code> name of the member variable you want to sort on.  Default value is "y".
	 * @param	Order	A <code>FlxGroup</code> constant that defines the sort order.  Possible values are <code>ASCENDING</code> and <code>DESCENDING</code>.  Default value is <code>ASCENDING</code>.  
	 */
	public function sort(Index:String = "y", Order:Int = -1):Void
	{
		_sortIndex = Index;
		_sortOrder = Order;
		_members.sort(sortHandler);
	}

	/**
	 * Go through and set the specified variable to the specified value on all members of the group.
	 * 
	 * @param	VariableName	The string representation of the variable name you want to modify, for example "visible" or "scrollFactor".
	 * @param	Value			The value you want to assign to that variable.
	 * @param	Recurse			Default value is true, meaning if <code>setAll()</code> encounters a member that is a group, it will call <code>setAll()</code> on that group rather than modifying its variable.
	 */
	public function setAll(VariableName:String, Value:Dynamic, Recurse:Bool = true):Void
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if (basic != null)
			{
				if (Recurse && basic.collisionType == FlxCollisionType.GROUP)
				{
					(cast basic).setAll(VariableName, Value, Recurse);
				}
				else
				{
					Reflect.setProperty(basic, VariableName, Value);
				}
			}
		}
	}
	
	/**
	 * Go through and call the specified function on all members of the group.
	 * Currently only works on functions that have no required parameters.
	 * 
	 * @param	FunctionName	The string representation of the function you want to call on each object, for example "kill()" or "init()".
	 * @param	Recurse			Default value is true, meaning if <code>callAll()</code> encounters a member that is a group, it will call <code>callAll()</code> on that group rather than calling the group's function.
	 */ 
	public function callAll(FunctionName:String, Args:Array<Dynamic> = null, Recurse:Bool = true):Void
	{
		if (Args == null) 	
			Args = [];
		
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if (basic != null)
			{
				if (Recurse && basic.collisionType == FlxCollisionType.GROUP)
				{
					(cast(basic, FlxTypedGroup<Dynamic>)).callAll(FunctionName, Recurse);
				}
				else
				{
					Reflect.callMethod(basic, Reflect.getProperty(basic, FunctionName), Args);
				}
			}
		}
	}
	
	/**
	 * Call this function to retrieve the first object with exists == false in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 * 
	 * @param	ObjectClass		An optional parameter that lets you narrow the results to instances of this particular class.
	 * @param 	Force           Force the object to be an ObjectClass and not a super class of ObjectClass. 
	 * @return	A <code>FlxBasic</code> currently flagged as not existing.
	 */
	public function getFirstAvailable(ObjectClass:Class<T> = null, Force:Bool = false):T
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++]; // we use basic as FlxBasic for performance reasons
			
			if ((basic != null) && !basic.exists && ((ObjectClass == null) || Std.is(basic, ObjectClass)))
			{
				if (Force && Type.getClassName(Type.getClass(basic)) != Type.getClassName(ObjectClass)) 
				{
					continue;
				}
				return _members[i - 1];
			}
		}
		
		return null;
	}
	
	/**
	 * Call this function to retrieve the first index set to 'null'.
	 * Returns -1 if no index stores a null object.
	 * 
	 * @return	An <code>Int</code> indicating the first null slot in the group.
	 */
	public function getFirstNull():Int
	{
		var i:Int = 0;
		var l:Int = _members.length;
		
		while (i < l)
		{
			if (_members[i] == null)
			{
				return i;
			}
			else
			{
				i++;
			}
		}
		
		return -1;
	}
	
	/**
	 * Call this function to retrieve the first object with exists == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>FlxBasic</code> currently flagged as existing.
	 */
	public function getFirstExisting():T
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++]; // we use basic as FlxBasic for performance reasons
			
			if ((basic != null) && basic.exists)
			{
				return _members[i - 1];
			}
		}
		
		return null;
	}
	
	/**
	 * Call this function to retrieve the first object with dead == false in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>FlxBasic</code> currently flagged as not dead.
	 */
	public function getFirstAlive():T
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++]; // we use basic as FlxBasic for performance reasons
			
			if ((basic != null) && basic.exists && basic.alive)
			{
				return _members[i - 1];
			}
		}
		
		return null;
	}
	
	/**
	 * Call this function to retrieve the first object with dead == true in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 * 
	 * @return	A <code>FlxBasic</code> currently flagged as dead.
	 */
	public function getFirstDead():T
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++]; // we use basic as FlxBasic for performance reasons
			
			if ((basic != null) && !basic.alive)
			{
				return _members[i - 1];
			}
		}
		
		return null;
	}
	
	/**
	 * Call this function to find out how many members of the group are not dead.
	 * 
	 * @return	The number of <code>FlxBasic</code>s flagged as not dead.  Returns -1 if group is empty.
	 */
	public function countLiving():Int
	{
		var i:Int = 0;
		var count:Int = -1;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if (basic != null)
			{
				if (count < 0)
				{
					count = 0;
				}
				if (basic.exists && basic.alive)
				{
					count++;
				}
			}
		}
		
		return count;
	}
	
	/**
	 * Call this function to find out how many members of the group are dead.
	 * 
	 * @return	The number of <code>FlxBasic</code>s flagged as dead.  Returns -1 if group is empty.
	 */
	public function countDead():Int	
	{
		var i:Int = 0;
		var count:Int = -1;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if (basic != null)
			{
				if (count < 0)
				{
					count = 0;
				}
				if (!basic.alive)
				{
					count++;
				}
			}
		}
		
		return count;
	}
	
	/**
	 * Returns a member at random from the group.
	 * 
	 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
	 * @param	Length		Optional restriction on the number of values you want to randomly select from.
	 * @return	A <code>FlxBasic</code> from the members list.
	 */
	public function getRandom(StartIndex:Int = 0, Length:Int = 0):T
	{
		if (StartIndex < 0)
		{
			StartIndex = 0;
		}
		if (Length <= 0)
		{
			Length = length;
		}
		
		return FlxArrayUtil.getRandom(_members, StartIndex, Length);
	}
	
	/**
	 * Remove all instances of <code>FlxBasic</code> subclass (FlxSprite, FlxBlock, etc) from the list.
	 * WARNING: does not destroy() or kill() any of these objects!
	 */
	public function clear():Void
	{
		length = 0;
		_members.splice(0, _members.length);
	}
	
	/**
	 * Calls kill on the group's members and then on the group itself. 
	 * You can revive this group later via <code>revive()</code> after this.
	 */
	override public function kill():Void
	{
		var i:Int = 0;
		var basic:FlxBasic = null;
		
		while (i < length)
		{
			basic = _basics[i++];
			
			if ((basic != null) && basic.exists)
			{
				basic.kill();
			}
		}
		
		super.kill();
	}
	
	/**
	 * Revives the group itself (and all of it's members if 
	 * <code>autoReviveMembers</code> has been set to true.
	 */
	override public function revive():Void
	{
		super.revive();
		
		if (autoReviveMembers)
		{
			var i:Int = 0;
			var basic:FlxBasic = null;
			
			while (i < length)
			{
				basic = _basics[i++];
				
				if ((basic != null) && !basic.exists)
				{
					basic.revive();
				}
			}
		}
	}
	
	/**
	 * Iterate through every members
	 * @return An iterator
	 */
	public function iterator():FlxGroupIterator<T>
	{
		return new FlxGroupIterator(_members);
	}
	
	/**
	 * Iterate through every dead members
	 * @return An iterator
	 */
	public function iteratorAlive()
	{
		return new FlxGroupIterator(_members, function(m : T) { return m.exists && m.alive; } );
	}
	
	/**
	 * Iterate through every dead members
	 * @return An iterator
	 */
	public function iteratorDead()
	{
		return new FlxGroupIterator(_members, function(m : T) { return !m.alive; } );
	}
	
	/**
	 * Iterate through every dead members
	 * @return An iterator
	 */
	public function iteratorExists()
	{
		return new FlxGroupIterator(_members, function(m : T) { return m.exists; } );
	}
	
	/**
	 * Helper function for the sort process.
	 * 
	 * @param 	Obj1	The first object being sorted.
	 * @param	Obj2	The second object being sorted.
	 * @return	An integer value: -1 (Obj1 before Obj2), 0 (same), or 1 (Obj1 after Obj2).
	 */
	private function sortHandler(Obj1:T, Obj2:T):Int
	{
		var prop1 = Reflect.getProperty(Obj1, _sortIndex);
		var prop2 = Reflect.getProperty(Obj2, _sortIndex);
		
		if (prop1 < prop2)
		{
			return _sortOrder;
		}
		else if (prop1 > prop2)
		{
			return -_sortOrder;
		}
		
		return 0;
	}
	
	private function set_maxSize(Size:Int):Int
	{
		maxSize = Std.int(Math.abs(Size));
		
		if (_marker >= maxSize)
		{
			_marker = 0;
		}
		if ((maxSize == 0) || (_members == null) || (maxSize >= _members.length))
		{
			return maxSize;
		}
		
		// If the max size has shrunk, we need to get rid of some objects
		var i:Int = maxSize;
		var l:Int = _members.length;
		var basic:FlxBasic = null;
		
		while (i < l)
		{
			basic = _basics[i++];
			
			if (basic != null)
			{
				basic.destroy();
			}
		}
		
		length = maxSize;
		FlxArrayUtil.setLength(_members, maxSize);
		
		return maxSize;
	}
	
	private function get_members():Array<T>
	{
		return _members;
	}
}
