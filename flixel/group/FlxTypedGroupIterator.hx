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
	private var _filter : T -> Bool;
	private var _cursor : Int;
	private var _length : Int;

	public function new(GroupMembers : Array<T>, filter : T -> Bool = null)
	{
		_groupMembers = GroupMembers;
		_filter = filter;
		_cursor = 0;
		_length = _groupMembers.length;
	}

	public function next()
	{
		return hasNext() ? _groupMembers[_cursor++] : null;
	}

	public function hasNext() : Bool
	{
		while (_cursor < _length && (_groupMembers[_cursor] == null || _filter != null && !_filter(_groupMembers[_cursor])))
		{
			_cursor++;
		}
		return _cursor < _length;
	}
	
}
