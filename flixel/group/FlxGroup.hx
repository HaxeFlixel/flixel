package flixel.group;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;

/**
 * An alias for `FlxTypedGroup<FlxBasic>`, meaning any flixel object or basic can be added to a
 * `FlxGroup`, even another `FlxGroup`.
 */
typedef FlxGroup = FlxTypedGroup<FlxBasic>;

/**
 * This is an organizational class that can update and render a bunch of `FlxBasic`s.
 * NOTE: Although `FlxGroup` extends `FlxBasic`, it will not automatically
 * add itself to the global collisions quad tree, it will only add its members.
 */
class FlxTypedGroup<T:FlxBasic> extends FlxBasic
{
	@:noCompletion
	static function resolveGroup(basic:FlxBasic):FlxTypedGroup<FlxBasic>
	{
		if (basic != null)
		{
			if (basic.flixelType == GROUP)
			{
				return cast basic;
			}
			else if (basic.flixelType == SPRITEGROUP)
			{
				return cast (cast basic:FlxTypedSpriteGroup<Dynamic>).group;
			}
		}
		return null;
	}
	
	@:noCompletion
	@:allow(flixel.system.debug.interaction.Interaction)
	static inline function resolveSelectionGroup(basic:FlxBasic)
	{
		return resolveGroup(basic);
	}
	
	/**
	 * `Array` of all the members in this group.
	 */
	public var members(default, null):Array<T>;

	/**
	 * The maximum capacity of this group. Default is `0`, meaning no max capacity, and the group can just grow.
	 */
	public var maxSize(default, set):Int;

	/**
	 * The number of entries in the members array. For performance and safety you should check this
	 * variable instead of `members.length` unless you really know what you're doing!
	 */
	public var length(default, null):Int = 0;

	/**
	 * A `FlxSignal` that dispatches when a child is added to this group.
	 * @since 4.4.0
	 */
	public var memberAdded(get, never):FlxTypedSignal<T->Void>;

	/**
	 * A `FlxSignal` that dispatches when a child is removed from this group.
	 * @since 4.4.0
	 */
	public var memberRemoved(get, never):FlxTypedSignal<T->Void>;

	/**
	 * Internal variables for lazily creating `memberAdded` and `memberRemoved` signals when needed.
	 */
	@:noCompletion
	var _memberAdded:FlxTypedSignal<T->Void>;

	@:noCompletion
	var _memberRemoved:FlxTypedSignal<T->Void>;

	/**
	 * Internal helper variable for recycling objects a la `FlxEmitter`.
	 */
	@:noCompletion
	var _marker:Int = 0;

	/**
	 * @param   MaxSize   Maximum amount of members allowed.
	 */
	public function new(MaxSize:Int = 0)
	{
		super();

		members = [];
		maxSize = Std.int(Math.abs(MaxSize));
		flixelType = GROUP;
	}

	/**
	 * **WARNING:** A destroyed `FlxBasic` can't be used anymore.
	 * It may even cause crashes if it is still part of a group or state.
	 * You may want to use `kill()` instead if you want to disable the object temporarily only and `revive()` it later.
	 *
	 * This function is usually not called manually (Flixel calls it automatically during state switches for all `add()`ed objects).
	 *
	 * Override this function to `null` out variables manually or call `destroy()` on class members if necessary.
	 * Don't forget to call `super.destroy()`!
	 */
	override public function destroy():Void
	{
		super.destroy();

		FlxDestroyUtil.destroy(_memberAdded);
		FlxDestroyUtil.destroy(_memberRemoved);

		if (members != null)
		{
			var i:Int = 0;
			var basic:FlxBasic = null;

			while (i < length)
			{
				basic = members[i++];

				if (basic != null)
					basic.destroy();
			}

			members = null;
		}
	}

	/**
	 * Automatically goes through and calls update on everything you added.
	 */
	override public function update(elapsed:Float):Void
	{
		var i:Int = 0;
		var basic:FlxBasic = null;

		while (i < length)
		{
			basic = members[i++];

			if (basic != null && basic.exists && basic.active)
			{
				basic.update(elapsed);
			}
		}
	}

	/**
	 * Automatically goes through and calls render on everything you added.
	 */
	override public function draw():Void
	{
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (cameras != null)
		{
			FlxCamera._defaultCameras = cameras;
		}

		for (basic in members)
		{
			if (basic != null && basic.exists && basic.visible)
				basic.draw();
		}

		FlxCamera._defaultCameras = oldDefaultCameras;
	}

	/**
	 * Adds a new `FlxBasic` subclass (`FlxBasic`, `FlxSprite`, `Enemy`, etc) to the group.
	 * `FlxGroup` will try to replace a `null` member of the array first.
	 * Failing that, `FlxGroup` will add it to the end of the member array.
	 * WARNING: If the group has a `maxSize` that has already been met,
	 * the object will NOT be added to the group!
	 *
	 * @param   basic  The `FlxBasic` you want to add to the group.
	 * @return  The same `FlxBasic` object that was passed in.
	 */
	public function add(basic:T):T
	{
		if (basic == null)
		{
			FlxG.log.warn("Cannot add a `null` object to a FlxGroup.");
			return null;
		}

		// Don't bother adding an object twice.
		if (members.indexOf(basic) >= 0)
			return basic;

		// First, look for a null entry where we can add the object.
		final index:Int = getFirstNull();
		if (index != -1)
		{
			members[index] = basic;

			if (index >= length)
			{
				length = index + 1;
			}

			if (_memberAdded != null)
				_memberAdded.dispatch(basic);

			return basic;
		}

		// If the group is full, return the basic
		if (maxSize > 0 && length >= maxSize)
			return basic;

		// If we made it this far, we need to add the basic to the group.
		members.push(basic);
		length++;

		if (_memberAdded != null)
			_memberAdded.dispatch(basic);

		return basic;
	}

	/**
	 * Inserts a new `FlxBasic` subclass (`FlxBasic`, `FlxSprite`, `Enemy`, etc)
	 * into the group at the specified position.
	 * `FlxGroup` will try to replace a `null` member at the specified position of the array first.
	 * Failing that, `FlxGroup` will insert it at the position of the member array.
	 * WARNING: If the group has a `maxSize` that has already been met,
	 * the object will NOT be inserted to the group!
	 *
	 * @param   position  The position in the group where you want to insert the object.
	 * @param   object    The object you want to insert into the group.
	 * @return  The same `FlxBasic` object that was passed in.
	 */
	public function insert(position:Int, object:T):T
	{
		if (object == null)
		{
			FlxG.log.warn("Cannot insert a `null` object into a FlxGroup.");
			return null;
		}

		// Don't bother inserting an object twice.
		if (members.indexOf(object) >= 0)
			return object;

		// First, look if the member at position is null, so we can directly assign the object at the position.
		if (position < length && members[position] == null)
		{
			members[position] = object;

			if (_memberAdded != null)
				_memberAdded.dispatch(object);

			return object;
		}

		// If the group is full, return the object
		if (maxSize > 0 && length >= maxSize)
			return object;

		// If we made it this far, we need to insert the object into the group at the specified position.
		members.insert(position, object);
		length++;

		if (_memberAdded != null)
			_memberAdded.dispatch(object);

		return object;
	}

	/**
	 * Recycling is designed to help you reuse game objects without always re-allocating or "newing" them.
	 * It behaves differently depending on whether `maxSize` equals `0` or is bigger than `0`.
	 *
	 * `maxSize > 0` / "rotating-recycling" (used by `FlxEmitter`):
	 *   - at capacity:  returns the next object in line, no matter its properties like `alive`, `exists` etc.
	 *   - otherwise:    returns a new object.
	 *
	 * `maxSize == 0` / "grow-style-recycling"
	 *   - tries to find the first object with `exists == false`
	 *   - otherwise: adds a new object to the `members` array
	 *
	 * WARNING: If this function needs to create a new object, and no object class was provided,
	 * it will return `null` instead of a valid object!
	 *
	 * @param   objectClass    The class type you want to recycle (e.g. `FlxSprite`, `EvilRobot`, etc).
	 * @param   objectFactory  Optional factory function to create a new object
	 *                         if there aren't any dead members to recycle.
	 *                         If `null`, `Type.createInstance()` is used,
	 *                         which requires the class to have no constructor parameters.
	 * @param   force          Force the object to be an `ObjectClass` and not a super class of `ObjectClass`.
	 * @param   revive         Whether recycled members should automatically be revived
	 *                         (by calling `revive()` on them).
	 * @return  A reference to the object that was created.
	 */
	public function recycle(?objectClass:Class<T>, ?objectFactory:Void->T, force = false, revive = true):T
	{
		inline function createObject():T
		{
			if (objectFactory != null)
				return add(objectFactory());
			
			if (objectClass != null)
				return add(Type.createInstance(objectClass, []));
			
			return null;
		}
		
		// rotated recycling
		if (maxSize > 0)
		{
			// create new instance
			if (length < maxSize)
				return createObject();
			
			// get the next member if at capacity
			final basic = members[_marker++];

			if (_marker >= maxSize)
				_marker = 0;

			if (revive)
				basic.revive();

			return cast basic;
		}
		
		// grow-style recycling - grab a basic with exists == false or create a new one
		final basic = getFirstAvailable(objectClass, force);

		if (basic != null)
		{
			if (revive)
				basic.revive();
			return cast basic;
		}

		return createObject();
	}

	/**
	 * Removes an object from the group.
	 *
	 * @param   basic   The `FlxBasic` you want to remove.
	 * @param   splice  Whether the object should be cut from the array entirely or not.
	 * @return  The removed object.
	 */
	public function remove(basic:T, splice = false):T
	{
		if (members == null)
			return null;

		final index = members.indexOf(basic);

		if (index < 0)
			return null;

		if (splice)
		{
			members.splice(index, 1);
			length--;
		}
		else
			members[index] = null;

		if (_memberRemoved != null)
			_memberRemoved.dispatch(basic);

		return basic;
	}

	/**
	 * Replaces an existing `FlxBasic` with a new one.
	 * Does not do anything and returns `null` if the old object is not part of the group.
	 *
	 * @param   oldObject  The object you want to replace.
	 * @param   newObject  The new object you want to use instead.
	 * @return  The new object.
	 */
	public function replace(oldObject:T, newObject:T):T
	{
		final index = members.indexOf(oldObject);

		if (index < 0)
			return null;

		members[index] = newObject;

		if (_memberRemoved != null)
			_memberRemoved.dispatch(oldObject);
		if (_memberAdded != null)
			_memberAdded.dispatch(newObject);

		return newObject;
	}

	/**
	 * Call this function to sort the group according to a particular value and order.
	 * For example, to sort game objects for Zelda-style overlaps you might call
	 * `group.sort(FlxSort.byY, FlxSort.ASCENDING)` at the bottom of your `FlxState#update()` override.
	 *
	 * @param   func   The sorting function to use - you can use one of the premade ones in
	 *                     `FlxSort` or write your own using `FlxSort.byValues()` as a "backend".
	 * @param   order  A constant that defines the sort order.
	 *                     Possible values are `FlxSort.ASCENDING` (default) and `FlxSort.DESCENDING`.
	 */
	public inline function sort(func:(Int,T,T)->Int, order = FlxSort.ASCENDING):Void
	{
		members.sort(func.bind(order));
	}
	
	/**
	 * Searches for, and returns the first member that satisfies the function.
	 * @param   func  The function that tests the members
	 * @since 5.4.0
	 */
	public function getFirst(func:T->Bool):Null<T>
	{
		return getFirstHelper(func);
	}
	
	inline function getFirstHelper(func:T->Bool):Null<T>
	{
		var result:T = null;
		for (basic in members)
		{
			if (basic != null && func(basic))
			{
				result = basic;
				break;
			}
		}
		return result;
	}
	
	/**
	 * Searches for, and returns the last member that satisfies the function.
	 * @param   func  The function that tests the members
	 * @since 5.4.0
	 */
	public function getLast(func:T->Bool):Null<T>
	{
		var result:T = null;
		var i = members.length;
		while (i-- > 0)
		{
			final basic = members[i];
			if (basic != null && func(basic))
			{
				result = basic;
				break;
			}
		}
		return result;
	}
	
	/**
	 * Searches for, and returns the index of the first member that satisfies the function.
	 * @param   func  The function that tests the members
	 * @since 5.4.0
	 */
	public function getFirstIndex(func:T->Bool):Int
	{
		var result = -1;
		for (i=>basic in members)
		{
			if (basic != null && func(basic))
			{
				result = i;
				break;
			}
		}
		return result;
	}
	
	/**
	 * Searches for, and returns the index of the last member that satisfies the function.
	 * @param   func  The function that tests the members
	 * @since 5.4.0
	 */
	public function getLastIndex(func:T->Bool):Int
	{
		var result = -1;
		var i = members.length;
		while (i-- > 0)
		{
			final basic = members[i];
			if (basic != null && func(basic))
			{
				result = i;
				break;
			}
		}
		return result;
	}
	
	/**
	 * Tests whether any member satisfies the function.
	 * @param   func  The function that tests the members
	 * @since 5.4.0
	 */
	public function any(func:T->Bool):Bool
	{
		for (basic in members)
		{
			if (basic != null && func(basic))
				return true;
		}
		return false;
	}
	
	/**
	 * Tests whether every member satisfies the function.
	 * @param   func  The function that tests the members
	 * @since 5.4.0
	 */
	public function every(func:T->Bool):Bool
	{
		for (basic in members)
		{
			if (basic != null && !func(basic))
				return false;
		}
		return true;
	}
	
	/**
	 * Call this function to retrieve the first object with `exists == false` in the group.
	 * This is handy for recycling in general, e.g. respawning enemies.
	 *
	 * @param   objectClass  An optional parameter that lets you narrow the
	 *                       results to instances of this particular class.
	 * @param   force        Force the object to be an `ObjectClass` and not a super class of `ObjectClass`.
	 * @return  A `FlxBasic` currently flagged as not existing.
	 */
	public function getFirstAvailable(?objectClass:Class<T>, force = false):Null<T>
	{
		for (basic in members)
		{
			if (basic != null && !basic.exists && (objectClass == null || Std.isOfType(basic, objectClass)))
			{
				if (force && Type.getClassName(Type.getClass(basic)) != Type.getClassName(objectClass))
				{
					continue;
				}
				return basic;
			}
		}

		return null;
	}

	/**
	 * Call this function to retrieve the first index set to `null`.
	 * Returns `-1` if no index stores a `null` object.
	 *
	 * @return  An `Int` indicating the first `null` slot in the group.
	 */
	public function getFirstNull():Int
	{
		return members.indexOf(null);
	}

	/**
	 * Call this function to retrieve the first object with `exists == true` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `FlxBasic` currently flagged as existing.
	 */
	public function getFirstExisting():Null<T>
	{
		return getFirstHelper((basic)->basic.exists);
	}

	/**
	 * Call this function to retrieve the first object with `dead == false` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `FlxBasic` currently flagged as not dead.
	 */
	public function getFirstAlive():Null<T>
	{
		return getFirstHelper((basic)->basic.exists && basic.alive);
	}

	/**
	 * Call this function to retrieve the first object with `dead == true` in the group.
	 * This is handy for checking if everything's wiped out, or choosing a squad leader, etc.
	 *
	 * @return  A `FlxBasic` currently flagged as dead.
	 */
	public function getFirstDead():Null<T>
	{
		return getFirstHelper((basic)->!basic.alive);
	}
	
	/**
	 * Call this function to find out how many members of the group are not dead.
	 *
	 * @return  The number of `FlxBasic`s flagged as not dead. Returns `-1` if group is empty.
	 */
	public function countLiving():Int
	{
		var count:Int = -1;

		for (basic in members)
		{
			if (basic != null)
			{
				if (count < 0)
					count = 0;
				if (basic.exists && basic.alive)
					count++;
			}
		}

		return count;
	}

	/**
	 * Call this function to find out how many members of the group are dead.
	 *
	 * @return  The number of `FlxBasic`s flagged as dead. Returns `-1` if group is empty.
	 */
	public function countDead():Int
	{
		var count:Int = -1;
		
		for (basic in members)
		{
			if (basic != null)
			{
				if (count < 0)
					count = 0;
				if (!basic.alive)
					count++;
			}
		}

		return count;
	}
	
	/**
	 * Returns a member at random from the group.
	 *
	 * @param   startIndex  Optional offset off the front of the array.
	 *                      Default value is `0`, or the beginning of the array.
	 * @param   length      Optional restriction on the number of values you want to randomly select from.
	 * @return  A `FlxBasic` from the `members` list.
	 */
	public function getRandom(startIndex:Int = 0, length:Int = 0)
	{
		if (startIndex < 0)
			startIndex = 0;
		if (length <= 0)
			length = this.length;

		return FlxG.random.getObject(members, startIndex, length);
	}

	/**
	 * Remove all instances of `FlxBasic` subclasses (`FlxSprite`, `FlxTileblock`, etc) from the list.
	 * WARNING: does not `destroy()` or `kill()` any of these objects!
	 */
	public function clear():Void
	{
		length = 0;

		if (_memberRemoved != null)
		{
			for (member in members)
			{
				if (member != null)
					_memberRemoved.dispatch(member);
			}
		}

		FlxArrayUtil.clearArray(members);
	}

	/**
	 * Calls `kill()` on the group's unkilled `members`. Revive them via `reviveMembers()`.
	 * @since 5.4.0
	 */
	public function killMembers():Void
	{
		for (basic in members)
		{
			if (basic != null && basic.exists)
				basic.kill();
		}
	}

	/**
	 * Calls `killMembers()` and then kills the group itself.
	 * Revive this group via `revive()`.
	 */
	override public function kill():Void
	{
		killMembers();

		super.kill();
	}

	/**
	 * Calls `revive()` on the group's killed members and then on the group itself.
	 * @since 5.4.0
	 */
	public function reviveMembers():Void
	{
		for (basic in members)
		{
			if (basic != null && !basic.exists)
				basic.revive();
		}
	}

	/**
	 * Calls `reviveMembers()` and then revives the group itself.
	 */
	override public function revive():Void
	{
		reviveMembers();

		super.revive();
	}

	/**
	 * Iterates through every member.
	 */
	public inline function iterator(?filter:T->Bool):FlxTypedGroupIterator<T>
	{
		return new FlxTypedGroupIterator<T>(members, filter);
	}

	/**
	 * Iterates through every member and index.
	 */
	public inline function keyValueIterator()
	{
		return members.keyValueIterator();
	}

	/**
	 * Applies a function to all members.
	 *
	 * @param   func     A function that modifies one element at a time.
	 * @param   recurse  Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEach(func:T->Void, recurse = false)
	{
		for (basic in members)
		{
			if (basic != null)
			{
				if (recurse)
				{
					final group = resolveGroup(basic);
					if (group != null)
						group.forEach(cast func, recurse);
				}

				func(basic);
			}
		}
	}

	/**
	 * Applies a function to all `alive` members.
	 *
	 * @param   func     A function that modifies one element at a time.
	 * @param   recurse  Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEachAlive(func:T->Void, recurse = false)
	{
		for (basic in members)
		{
			if (basic != null && basic.exists && basic.alive)
			{
				if (recurse)
				{
					final group = resolveGroup(basic);
					if (group != null)
						group.forEachAlive(cast func, recurse);
				}

				func(basic);
			}
		}
	}

	/**
	 * Applies a function to all dead members.
	 *
	 * @param   func     A function that modifies one element at a time.
	 * @param   recurse  Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEachDead(func:T->Void, recurse = false)
	{
		for (basic in members)
		{
			if (basic != null && !basic.alive)
			{
				if (recurse)
				{
					final group = resolveGroup(basic);
					if (group != null)
						group.forEachDead(cast func, recurse);
				}

				func(basic);
			}
		}
	}

	/**
	 * Applies a function to all existing members.
	 *
	 * @param   func     A function that modifies one element at a time.
	 * @param   recurse  Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEachExists(func:T->Void, recurse:Bool = false)
	{
		for (basic in members)
		{
			if (basic != null && basic.exists)
			{
				if (recurse)
				{
					final group = resolveGroup(basic);
					if (group != null)
						group.forEachExists(cast func, recurse);
				}

				func(cast basic);
			}
		}
	}

	/**
	 * Applies a function to all members of type `Class<K>`.
	 *
	 * @param   objectClass  A class that objects will be checked against before Function is applied, ex: `FlxSprite`.
	 * @param   func         A function that modifies one element at a time.
	 * @param   recurse      Whether or not to apply the function to members of subgroups as well.
	 */
	public function forEachOfType<K>(objectClass:Class<K>, func:K->Void, recurse:Bool = false)
	{
		for (basic in members)
		{
			if (basic != null)
			{
				if (recurse)
				{
					var group = resolveGroup(basic);
					if (group != null)
						group.forEachOfType(objectClass, cast func, recurse);
				}

				if (Std.isOfType(basic, objectClass))
					func(cast basic);
			}
		}
	}

	@:noCompletion
	function set_maxSize(size:Int):Int
	{
		maxSize = Std.int(Math.abs(size));

		if (_marker >= maxSize)
			_marker = 0;

		if (maxSize == 0 || members == null || maxSize >= length)
			return maxSize;

		// If the max size has shrunk, we need to get rid of some objects
		while (length > maxSize)
		{
			final basic = members.splice(maxSize - 1, 1)[0];

			if (basic != null)
			{
				if (_memberRemoved != null)
					_memberRemoved.dispatch(cast basic);

				basic.destroy();
			}
			length--;
		}

		return maxSize;
	}

	@:noCompletion
	function get_memberAdded():FlxTypedSignal<T->Void>
	{
		if (_memberAdded == null)
			_memberAdded = new FlxTypedSignal<T->Void>();

		return _memberAdded;
	}

	@:noCompletion
	function get_memberRemoved():FlxTypedSignal<T->Void>
	{
		if (_memberRemoved == null)
			_memberRemoved = new FlxTypedSignal<T->Void>();

		return _memberRemoved;
	}
}

/**
 * Iterator implementation for groups
 * Support a filter method (used for iteratorAlive, iteratorDead and iteratorExists)
 * @author Masadow
 */
class FlxTypedGroupIterator<T>
{
	var _groupMembers:Array<T>;
	var _filter:T->Bool;
	var _cursor:Int;
	var _length:Int;

	public function new(groupMembers:Array<T>, ?filter:T->Bool)
	{
		_groupMembers = groupMembers;
		_filter = filter;
		_cursor = 0;
		_length = _groupMembers.length;
	}

	public function next()
	{
		return hasNext() ? _groupMembers[_cursor++] : null;
	}

	public function hasNext():Bool
	{
		while (_cursor < _length && (_groupMembers[_cursor] == null || _filter != null && !_filter(_groupMembers[_cursor])))
		{
			_cursor++;
		}
		return _cursor < _length;
	}
}
