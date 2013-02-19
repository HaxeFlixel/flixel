package org.flixel;

import org.flixel.system.layer.Atlas;

/**
 * This is an organizational class that can update and render a bunch of <code>FlxBasic</code>s.
 * NOTE: Although <code>FlxGroup</code> extends <code>FlxBasic</code>, it will not automatically
 * add itself to the global collisions quad tree, it will only add its members.
 */
class FlxTypedGroup<T:FlxBasic> extends FlxBasic
{
	/**
	 * The maximum capacity of this group.  Default is 0, meaning no max capacity, and the group can just grow.
	 */
	public var maxSize(default, set_maxSize):Int;
	
	/**
	 * Use with <code>sort()</code> to sort in ascending order.
	 */
	static public inline var ASCENDING:Int = -1;
	/**
	 * Use with <code>sort()</code> to sort in descending order.
	 */
	static public inline var DESCENDING:Int = 1;
	
	/**
	 * Array of all the <code>FlxBasic</code>s that exist in this group.
	 */
	public var members:Array<T>;
	/**
	 * The number of entries in the members array.
	 * For performance and safety you should check this variable
	 * instead of members.length unless you really know what you're doing!
	 */
	public var length:Int;

	/**
	 * Internal helper variable for recycling objects a la <code>FlxEmitter</code>.
	 */
	private var _marker:Int;
	
	/**
	 * Helper for sort.
	 */
	private var _sortIndex:String;
	/**
	 * Helper for sort.
	 */
	private var _sortOrder:Int;

	/**
	 * Constructor
	 */
	public function new(MaxSize:Int = 0)
	{
		super();
		members = new Array<T>();
		length = 0;
		maxSize = Std.int(Math.abs(MaxSize));
		_marker = 0;
		_sortIndex = null;
	}
	
	/**
	 * Override this function to handle any deleting or "shutdown" type operations you might need,
	 * such as removing traditional Flash children like Sprite objects.
	 */
	override public function destroy():Void
	{
		if (members != null)
		{
			var basic:T;
			var i:Int = 0;
			while(i < length)
			{
				basic = members[i++];
				if (basic != null)
				{
					basic.destroy();
				}
			}
			members = null;
		}
		_sortIndex = null;
		super.destroy();
	}
	
	/**
	 * Just making sure we don't increment the active objects count.
	 */
	override public function preUpdate():Void { }
	
	/**
	 * Automatically goes through and calls update on everything you added.
	 */
	override public function update():Void
	{
		var basic:T;
		var i:Int = 0;
		while(i < length)
		{
			basic = members[i++];
			if ((basic != null) && basic.exists && basic.active)
			{
				basic.preUpdate();
				basic.update();
				
				if (basic.hasTween) 
				{
					basic.updateTweens();
				}
				
				basic.postUpdate();
			}
		}
		
		if (hasTween)
		{
			updateTweens();
		}
	}
	
	/**
	 * Automatically goes through and calls render on everything you added.
	 */
	override public function draw():Void
	{
		var basic:T;
		var i:Int = 0;
		while (i < length)
		{
			basic = members[i++];
			if ((basic != null) && basic.exists && basic.visible)
			{
				basic.draw();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function set_maxSize(Size:Int):Int
	{
		maxSize = Std.int(Math.abs(Size));
		if (_marker >= maxSize)
		{
			_marker = 0;
		}
		if ((maxSize == 0) || (members == null) || (maxSize >= members.length))
		{
			return maxSize;
		}
		
		//If the max size has shrunk, we need to get rid of some objects
		var basic:T;
		var i:Int = maxSize;
		var l:Int = members.length;
		while (i < l)
		{
			basic = members[i++];
			if (basic != null)
			{
				basic.destroy();
			}
		}
		length = maxSize;
		FlxU.SetArrayLength(members, maxSize);
		return maxSize;
	}
	
	/**
	 * Adds a new <code>FlxBasic</code> subclass (FlxBasic, FlxSprite, Enemy, etc) to the group.
	 * FlxGroup will try to replace a null member of the array first.
	 * Failing that, FlxGroup will add it to the end of the member array,
	 * assuming there is room for it, and doubling the size of the array if necessary.
	 * <p>WARNING: If the group has a maxSize that has already been met,
	 * the object will NOT be added to the group!</p>
	 * @param	Object		The object you want to add to the group.
	 * @return	The same <code>FlxBasic</code> object that was passed in.
	 */
	public function add(Object:T):T
	{
		if (Object == null)
		{
			FlxG.log("WARNING: Cannot add a `null` object to a FlxGroup.");
			return null;
		}
		
		//Don't bother adding an object twice.
		if (FlxU.ArrayIndexOf(members, Object) >= 0)
		{
			return Object;
		}
		
		//First, look for a null entry where we can add the object.
		var i:Int = 0;
		var l:Int = members.length;
		while(i < l)
		{
			if(members[i] == null)
			{
				members[i] = Object;
				if (i >= length)
				{
					length = i + 1;
				}
				#if !flash
				setGroupAtlas(Object);
				#end
				return Object;
			}
			i++;
		}
		
		//Failing that, expand the array (if we can) and add the object.
		if (maxSize > 0)
		{
			if (members.length >= maxSize)
			{
				return Object;
			}
			else if (members.length * 2 <= maxSize)
			{
				FlxU.SetArrayLength(members, members.length * 2);
			}
			else
			{
				FlxU.SetArrayLength(members, maxSize);
			}
		}
		else
		{
			FlxU.SetArrayLength(members, members.length * 2);
		}
		
		//If we made it this far, then we successfully grew the group,
		//and we can go ahead and add the object at the first open slot.
		#if !flash
		setGroupAtlas(Object);
		#end
		members[i] = Object;
		length = i + 1;
		return Object;
	}
	
	#if !flash
	private function setGroupAtlas(Object:T):Void
	{
		if (_atlas != null)
		{
			Object.atlas = _atlas;
		}
	}
	
	override private function set_atlas(value:Atlas):Atlas 
	{
		if (_atlas != value)
		{
			if (value == null)
			{
				_node = null;
				_framesData = null;
			}
			
			_atlas = value;
		}
		
		if (_atlas != null)
		{
			for (basic in members)
			{
				if (basic != null)
				{
					setGroupAtlas(basic);
				}
			}
		}
		
		return value;
	}
	#end
	
	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * <p>If you specified a maximum size for this group (like in FlxEmitter),
	 * then recycle will employ what we're calling "rotating" recycling.
	 * Recycle() will first check to see if the group is at capacity yet.
	 * If group is not yet at capacity, recycle() returns a new object.
	 * If the group IS at capacity, then recycle() just returns the next object in line.</p>
	 * <p>If you did NOT specify a maximum size for this group,
	 * then recycle() will employ what we're calling "grow-style" recycling.
	 * Recycle() will return either the first object with exists == false,
	 * or, finding none, add a new object to the array,
	 * doubling the size of the array if necessary.</p>
	 * <p>WARNING: If this function needs to create a new object,
	 * and no object class was provided, it will return null
	 * instead of a valid object!</p>
	 * @param	ObjectClass		The class type you want to recycle (e.g. FlxSprite, EvilRobot, etc). Do NOT "new" the class in the parameter!
	 * @return	A reference to the object that was created.  Don't forget to cast it back to the Class you want (e.g. myObject = myGroup.recycle(myObjectClass) as myObjectClass;).
	 */
	public function recycle(ObjectClass:Class<T> = null):T
	{
		var basic:T;
		if (maxSize > 0)
		{
			if (length < maxSize)
			{
				if (ObjectClass == null)
				{
					return null;
				}
				return add(Type.createInstance(ObjectClass, []));
			}
			else
			{
				basic = members[_marker++];
				if (_marker >= maxSize)
				{
					_marker = 0;
				}
				return basic;
			}
		}
		else
		{
			basic = getFirstAvailable(ObjectClass);
			if (basic != null)
			{
				return basic;
			}
			if (ObjectClass == null)
			{
				return null;
			}
			return add(Type.createInstance(ObjectClass, []));
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
		if (members == null)
		{
			return null;
		}
		
		var index:Int = FlxU.ArrayIndexOf(members, Object);
		if ((index < 0) || (index >= members.length))
		{
			return null;
		}
		if (Splice)
		{
			members.splice(index, 1);
		}
		else
		{
			members[index] = null;
		}
		return Object;
	}
	
	/**
	 * Replaces an existing <code>FlxBasic</code> with a new one.
	 * @param	OldObject	The object you want to replace.
	 * @param	NewObject	The new object you want to use instead.
	 * @return	The new object.
	 */
	public function replace(OldObject:T, NewObject:T):T
	{
		var index:Int = FlxU.ArrayIndexOf(members, OldObject);
		if ((index < 0) || (index >= members.length))
		{
			return null;
		}
		members[index] = NewObject;
		return NewObject;
	}
	
	/**
	 * Call this function to sort the group according to a particular value and order.
	 * For example, to sort game objects for Zelda-style overlaps you might call
	 * <code>myGroup.sort("y",ASCENDING)</code> at the bottom of your
	 * <code>FlxState.update()</code> override.  To sort all existing objects after
	 * a big explosion or bomb attack, you might call <code>myGroup.sort("exists",DESCENDING)</code>.
	 * @param	Index	The <code>String</code> name of the member variable you want to sort on.  Default value is "y".
	 * @param	Order	A <code>FlxGroup</code> constant that defines the sort order.  Possible values are <code>ASCENDING</code> and <code>DESCENDING</code>.  Default value is <code>ASCENDING</code>.  
	 */
	public function sort(Index:String = "y", Order:Int = -1):Void
	{
		_sortIndex = Index;
		_sortOrder = Order;
		members.sort(sortHandler);
	}

	/**
	 * Go through and set the specified variable to the specified value on all members of the group.
	 * @param	VariableName	The string representation of the variable name you want to modify, for example "visible" or "scrollFactor".
	 * @param	Value			The value you want to assign to that variable.
	 * @param	Recurse			Default value is true, meaning if <code>setAll()</code> encounters a member that is a group, it will call <code>setAll()</code> on that group rather than modifying its variable.
	 */
	public function setAll(VariableName:String, Value:Dynamic, Recurse:Bool = true):Void
	{
		var basic:T;
		var i:Int = 0;
		while(i < length)
		{
			basic = members[i++];
			if(basic != null)
			{
				if (Recurse && Std.is(basic, FlxTypedGroup))
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
	 * @param	FunctionName	The string representation of the function you want to call on each object, for example "kill()" or "init()".
	 * @param	Recurse			Default value is true, meaning if <code>callAll()</code> encounters a member that is a group, it will call <code>callAll()</code> on that group rather than calling the group's function.
	 */ 
	public function callAll(FunctionName:String, Recurse:Bool = true):Void
	{
		var basic:T;
		var i:Int = 0;
		while(i < length)
		{
			basic = members[i++];
			if(basic != null)
			{
				if (Recurse && Std.is(basic, FlxTypedGroup))
				{
					(cast basic).callAll(FunctionName, Recurse);
				}
				else
				{
					Reflect.callMethod(basic, Reflect.getProperty(basic, FunctionName), []);
				}
			}
		}
	}
	
	/**
	 * Call this function to retrieve the first object with exists == false in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 * @param	ObjectClass		An optional parameter that lets you narrow the results to instances of this particular class.
	 * @return	A <code>FlxBasic</code> currently flagged as not existing.
	 */
	public function getFirstAvailable(ObjectClass:Class<T> = null):T
	{
		var basic:T;
		var i:Int = 0;
		while(i < length)
		{
			basic = members[i++];
			if ((basic != null) && !basic.exists && ((ObjectClass == null) || Std.is(basic, ObjectClass)))
			{
				return basic;
			}
		}
		return null;
	}
	
	/**
	 * Call this function to retrieve the first index set to 'null'.
	 * Returns -1 if no index stores a null object.
	 * @return	An <code>int</code> indicating the first null slot in the group.
	 */
	public function getFirstNull():Int
	{
		var basic:T;
		var i:Int = 0;
		var l:Int = members.length;
		while(i < l)
		{
			if (members[i] == null)
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
	 * @return	A <code>FlxBasic</code> currently flagged as existing.
	 */
	public function getFirstExtant():T
	{
		var basic:T;
		var i:Int = 0;
		while(i < length)
		{
			basic = members[i++];
			if ((basic != null) && basic.exists)
			{
				return basic;
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
		var basic:T;
		var i:Int = 0;
		while(i < length)
		{
			basic = members[i++];
			if ((basic != null) && basic.exists && basic.alive)
			{
				return basic;
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
		var basic:T;
		var i:Int = 0;
		while (i < length)
		{
			basic = members[i++];
			if ((basic != null) && !basic.alive)
			{
				return basic;
			}
		}
		return null;
	}
	
	/**
	 * Call this function to find out how many members of the group are not dead.
	 * @return	The number of <code>FlxBasic</code>s flagged as not dead.  Returns -1 if group is empty.
	 */
	public function countLiving():Int
	{
		var count:Int = -1;
		var basic:T;
		var i:Int = 0;
		while (i < length)
		{
			basic = members[i++];
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
	 * @return	The number of <code>FlxBasic</code>s flagged as dead.  Returns -1 if group is empty.
	 */
	public function countDead():Int	
	{
		var count:Int = -1;
		var basic:T;
		var i:Int = 0;
		while(i < length)
		{
			basic = members[i++];
			if(basic != null)
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
	 * 
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
		return FlxG.getRandom(members, StartIndex, Length);
	}
	
	/**
	 * Remove all instances of <code>FlxBasic</code> subclass (FlxSprite, FlxBlock, etc) from the list.
	 * WARNING: does not destroy() or kill() any of these objects!
	 */
	public function clear():Void
	{
		length = 0;
		members.splice(0, members.length);
	}
	
	/**
	 * Calls kill on the group's members and then on the group itself.
	 */
	override public function kill():Void
	{
		var basic:T;
		var i:Int = 0;
		while (i < length)
		{
			basic = members[i++];
			if ((basic != null) && basic.exists)
			{
				basic.kill();
			}
		}
		super.kill();
	}
	
	/**
	 * Revives the group itself and all of it's members.
	 */
	public function reviveWithMembers():Void
	{
		revive();
		var basic:T;
		var i:Int = 0;
		while (i < length)
		{
			basic = members[i++];
			if ((basic != null) && !basic.exists)
			{
				if (Std.is(basic, FlxTypedGroup))
				{
					(cast basic).reviveWithMembers();
				}
				else
				{
					basic.revive();
				}
			}
		}
	}
	
	/**
	 * Helper function for the sort process.
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
}