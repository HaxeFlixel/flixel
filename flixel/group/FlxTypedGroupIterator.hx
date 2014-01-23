package flixel.group;

import flixel.FlxBasic;

/**
 * Iterator implementation for groups
 * Support a filter method (used for iteratorAlive, iteratorDead and iteratorExists)
 * @author Masadow
 */
class FlxTypedGroupIterator<T>
{
	private var _groupMembers : Array<T>;
	private var _cursor : Int;
	private var _filter : T -> Bool;

	public function new(GroupMembers : Array<T>, filter : T -> Bool = null)
	{
		_groupMembers = GroupMembers;
		_cursor = 0;
		_filter = filter;
	}

	public function next()
	{
		return hasNext() ? _groupMembers[_cursor++] : null;
	}

	public function hasNext() : Bool
	{
		while (_cursor < _groupMembers.length && (_groupMembers[_cursor] == null || _filter != null && !_filter(_groupMembers[_cursor])))
		{
			_cursor++;
		}
		return _cursor < _groupMembers.length;
	}
	
}