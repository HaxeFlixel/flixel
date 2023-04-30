package flixel.system.debug.completion;

import flixel.math.FlxMath;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

using flixel.util.FlxStringUtil;
using StringTools;

class CompletionList extends Sprite
{
	public var completed:String->Void;
	public var selectionChanged:String->Void;
	public var closed:Void->Void;

	public var filter(default, set):String;

	public var items(default, null):Array<String>;

	var entries:Array<CompletionListEntry> = [];
	var originalItems:Array<String>;
	var selectedIndex:Int = 0;
	var lowerVisibleIndex:Int = 0;
	var upperVisibleIndex:Int = 0;
	var scrollBar:CompletionListScrollBar;
	var actualHeight:Int;

	public function new(capacity:Int)
	{
		super();

		visible = false;
		upperVisibleIndex = capacity - 1;
		actualHeight = capacity * CompletionListEntry.HEIGHT;

		createPopupEntries(capacity);
		createScrollBar();
		updateSelectedItem();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public function show(x:Float, items:Array<String>)
	{
		visible = true;
		this.x = x;
		this.originalItems = items;
		filter = "";

		updateEntries();
	}

	public function setY(y:Float)
	{
		this.y = y - actualHeight;
	}

	public function close()
	{
		visible = false;
		filter = null;

		if (closed != null)
			closed();
	}

	function createPopupEntries(amount:Int)
	{
		for (i in 0...amount)
		{
			var entry = new CompletionListEntry();
			entries.push(entry);
			addChild(entry);
			entry.y = CompletionListEntry.HEIGHT * i;
		}
	}

	function createScrollBar()
	{
		scrollBar = new CompletionListScrollBar(CompletionListEntry.WIDTH, 0, 5, actualHeight);
		addChild(scrollBar);
	}

	function onKeyDown(e:KeyboardEvent)
	{
		if (!visible)
			return;

		switch (e.keyCode)
		{
			case Keyboard.DOWN:
				updateIndices(1);

			case Keyboard.UP:
				updateIndices(-1);

			case Keyboard.ENTER:
				if (completed != null)
					completed(items[selectedIndex]);
				close();
				return;

			case Keyboard.ESCAPE:
				close();
				return;
		}

		updateEntries();
	}

	function updateIndices(modifier:Int)
	{
		selectedIndex = bound(selectedIndex + modifier);
		if (FlxMath.inBounds(selectedIndex, lowerVisibleIndex, upperVisibleIndex))
			return;

		// scroll visible area
		lowerVisibleIndex = bound(lowerVisibleIndex + modifier);
		upperVisibleIndex = bound(upperVisibleIndex + modifier);
		var range = upperVisibleIndex - lowerVisibleIndex;

		if (range == items.length)
			return;

		// hit lower or upper end
		if (lowerVisibleIndex == 0)
			upperVisibleIndex = entries.length - 1;
		else if (upperVisibleIndex == items.length - 1)
			lowerVisibleIndex = items.length - entries.length;
	}

	function bound(index:Int)
	{
		return Std.int(FlxMath.bound(index, 0, items.length - 1));
	}

	function updateEntries()
	{
		updateLabels();
		updateSelectedItem();
		scrollBar.updateHandle(lowerVisibleIndex, items.length, entries.length);
	}

	function updateLabels()
	{
		for (i in 0...entries.length)
		{
			var selectedItem = items[lowerVisibleIndex + i];
			if (selectedItem == null)
				selectedItem = "";
			entries[i].setItem(selectedItem);
		}
	}

	function updateSelectedItem()
	{
		for (entry in entries)
			entry.selected = false;
		entries[selectedIndex - lowerVisibleIndex].selected = true;

		if (selectionChanged != null)
			selectionChanged(items[selectedIndex]);
	}

	function setItems(items:Array<String>)
	{
		if (items == null)
			return;
		if (items.length == 0)
			close();

		this.items = items;

		selectedIndex = 0;
		lowerVisibleIndex = 0;
		upperVisibleIndex = entries.length - 1;
		updateEntries();
	}

	function filterItems(filter:String):Array<String>
	{
		if (filter == null)
			filter = "";

		return sortItems(filter, originalItems.filter(function(item)
		{
			return item.toLowerCase().contains(filter.toLowerCase());
		}));
	}

	/**
	 * sort items so that:
	 *   - strings starting with the filter have a higher priority than those only containing it
	 *   - of those, shorter items (-> closer to the filter) have a higher priority
	 */
	function sortItems(filter:String, items:Array<String>):Array<String>
	{
		if (filter == "")
			return items;

		items.sort(function(a, b)
		{
			var valueA = startsWithExt(a, filter);
			var valueB = startsWithExt(b, filter);
			if (valueA > valueB)
				return -valueA;
			if (valueB > valueA)
				return valueB;

			if (valueA == valueB)
				return Std.int(a.length - b.length);
			return 0;
		});
		return items;
	}

	/**
	 * Custom startsWith() that ignores leading underscores.
	 */
	function startsWithExt(s:String, start:String):Int
	{
		if (s.startsWith(start))
			return 2;
		if (~/^[_]+/.replace(s, "").startsWith(start))
			return 1;
		return 0;
	}

	function set_filter(filter:String):String
	{
		if (filter == this.filter)
			return filter;

		setItems(filterItems(filter));
		return this.filter = filter;
	}
}
