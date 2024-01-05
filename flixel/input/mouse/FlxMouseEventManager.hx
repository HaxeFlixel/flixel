package flixel.input.mouse;

import haxe.ds.ArraySort;
import openfl.errors.Error;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

/**
 * Provides mouse event detection for `FlxObject` and `FlxSprite` (pixel-perfect for those).
 * Normally you would use `FlxMouseEvent` static properties for this.
 * 
 * You can make a new `FlxMouseEventManager` instance for private usage, 
 * but you should know what you are doing.
 * 
 * @see [FlxMouseEvent](https://api.haxeflixel.com/flixel/input/mouse/FlxMouseEvent.html)
 * @see [FlxMouseEvent Demo](https://haxeflixel.com/demos/FlxMouseEvent/)
 * 
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */
class FlxMouseEventManager extends FlxBasic
{
	var _list:Array<FlxMouseEvent<FlxObject>> = [];
	var _overList:Array<FlxMouseEvent<FlxObject>> = [];
	var _downList:Array<FlxMouseEvent<FlxObject>> = [];
	var _clickList:Array<FlxMouseEvent<FlxObject>> = [];

	var mouseClickedTime:Int = -1;

	@:noCompletion
	var _point:FlxPoint = FlxPoint.get();

	/**
	 * The maximum amount of time between two clicks that is considered a double click, in milliseconds.
	 * @since 4.4.0
	 */
	public var maxDoubleClickDelay:Int = 500;
	
	public function new()
	{
		super();

		if (_list != null)
		{
			clearRegistry();
		}
		_list = new Array<FlxMouseEvent<FlxObject>>();
		_overList = new Array<FlxMouseEvent<FlxObject>>();
		_downList = new Array<FlxMouseEvent<FlxObject>>();
		_clickList = new Array<FlxMouseEvent<FlxObject>>();

		FlxG.signals.preStateSwitch.add(removeAll);
	}

	override public function destroy():Void
	{
		clearRegistry();
		_point = FlxDestroyUtil.put(_point);
		FlxG.signals.preStateSwitch.remove(removeAll);
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var currentOverObjects = new Array<FlxMouseEvent<FlxObject>>();

		for (event in _list)
		{
			if (!event.object.alive || !event.object.exists || !event.object.visible || !event.mouseEnabled)
			{
				continue;
			}

			if (checkOverlap(event))
			{
				currentOverObjects.push(event);

				if (!event.mouseChildren)
				{
					break;
				}
			}
		}

		// MouseOut - Look for objects that lost mouse over.
		for (over in _overList)
		{
			if (over.onMouseOut != null)
			{
				// slightly different logic here - objects whose exists or visible
				// property has been set to false should also receive a mouse out!
				if (!over.object.exists || !over.object.visible || get(over.object, currentOverObjects) == null)
				{
					over.onMouseOut(over.object);
				}
			}
		}

		// MouseOver - Look for new objects with mouse over.
		for (current in currentOverObjects)
		{
			if (current.onMouseOver != null)
			{
				if (current.object.exists && current.object.visible && get(current.object, _overList) == null)
				{
					current.onMouseOver(current.object);
				}
			}
		}

		#if FLX_MOUSE
		// If mouse input is not enabled globally, prevent all tracked objects from responding to
		// down/click/doubleclick/up events until mouse input is re-enabled.
		if (!FlxG.mouse.enabled)
			return;

		// MouseMove - Look for objects with mouse over that have mouseMove callbacks
		if (FlxG.mouse.justMoved)
		{
			for (current in currentOverObjects)
			{
				if (current.onMouseMove != null && current.object.exists && current.object.visible)
				{
					current.onMouseMove(current.object);
				}
			}
		}

		// MouseDown - Look for objects with mouse over when user presses mouse button.
		for (current in currentOverObjects)
		{
			if (current.onMouseDown != null && current.object.exists && current.object.visible)
			{
				for (buttonID in current.mouseButtons)
				{
					if (FlxMouseButton.getByID(buttonID).justPressed)
					{
						current.onMouseDown(current.object);
					}
				}
			}
		}

		// MouseClick/MouseDoubleClick - Look for objects with mouse down first.
		if (FlxG.mouse.justPressed)
		{
			for (current in currentOverObjects)
			{
				if ((current.onMouseClick != null || current.onMouseDoubleClick != null)
					&& current.object.exists
					&& current.object.visible)
				{
					_downList.push(current);
				}
			}
		}

		// MouseUp - Look for objects with mouse over when user releases mouse button.
		for (current in currentOverObjects)
		{
			if (current.onMouseUp != null && current.object.exists && current.object.visible)
			{
				for (buttonID in current.mouseButtons)
				{
					if (FlxMouseButton.getByID(buttonID).justReleased)
					{
						current.onMouseUp(current.object);
					}
				}
			}
		}

		// MouseClick - Look for objects that had mouse down and now have mouse over when the user releases the mouse button.
		// DoubleClick - Look for objects that were recently clicked and have just been clicked again.
		if (_clickList.length > 0 && FlxG.game.ticks - mouseClickedTime > maxDoubleClickDelay)
		{
			_clickList = [];
		}

		if (FlxG.mouse.justReleased)
		{
			mouseClickedTime = FlxG.game.ticks;

			var previousClickedObjects = _clickList;

			if (_clickList.length > 0)
			{
				_clickList = [];
			}

			for (down in _downList)
			{
				if (down.object != null
					&& down.object.exists
					&& down.object.visible
					&& get(down.object, currentOverObjects) != null)
				{
					if (down.onMouseClick != null)
					{
						down.onMouseClick(down.object);
					}

					if (down.onMouseDoubleClick != null)
					{
						if (get(down.object, previousClickedObjects) != null)
						{
							down.onMouseDoubleClick(down.object);
						}
						else
						{
							_clickList.push(down);
						}
					}
				}
			}
		}

		if (_downList.length > 0 && !FlxG.mouse.pressed)
		{
			// if the user just released the mouse OR if the user released the mouse while the window was tabbed out
			_downList = [];
		}

		// MouseWheel - Look for objects with mouse over when user spins the mouse wheel.
		if (FlxG.mouse.wheel != 0)
		{
			for (current in currentOverObjects)
			{
				if (current.onMouseWheel != null && current.object.exists && current.object.visible)
				{
					current.onMouseWheel(current.object);
				}
			}
		}
		#end

		_overList = currentOverObjects;
	}

	function addEvent<T:FlxObject>(event:FlxMouseEvent<T>):FlxMouseEvent<T>
	{
		if (!event.mouseChildren)
		{
			_list.unshift(cast event);
		}
		else
		{
			// place mouseChildren=true objects immediately after =false ones
			var index = 0;

			while (index < _list.length && !_list[index].mouseChildren)
				index++;

			_list.insert(index, cast event);
		}
		
		return event;
	}

	/**
	 * Adds an object to the FlxMouseEventManager registry. Automatically initializes the plugin.
	 *
	 * @param   onMouseDown     Callback when mouse is pressed down over this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   onMouseUp       Callback when mouse is released over this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   onMouseOver     Callback when mouse is this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   onMouseOut      Callback when mouse moves out of this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   mouseChildren   If true, other objects overlapped by this will still receive mouse events.
	 * @param   mouseEnabled    If true, this object will receive mouse events.
	 * @param   pixelPerfect    If true, the collision check will be pixel-perfect. Only works for FlxSprites.
	 * @param   mouseButtons    The mouse buttons that can trigger callbacks. Left only by default.
	 */
	public function add<T:FlxObject>(object:T, ?onMouseDown:T->Void, ?onMouseUp:T->Void, ?onMouseOver:T->Void, ?onMouseOut:T->Void,
			mouseChildren = false, mouseEnabled = true, pixelPerfect = true, ?mouseButtons:Array<FlxMouseButtonID>):T
	{
		var event = new FlxMouseEvent<T>(object, onMouseDown, onMouseUp, onMouseOver, onMouseOut, mouseChildren, mouseEnabled, pixelPerfect, mouseButtons);
		addEvent(event);

		return object;
	}

	/**
	 * Removes a registered object from the registry.
	 */
	public function remove<T:FlxObject>(object:T):T
	{
		for (event in _list)
		{
			if (event.object == object)
			{
				event.destroy();
				_list.remove(event);
			}
		}
		return object;
	}

	/**
	 * Removes all registered objects from the registry.
	 */
	public function removeAll():Void
	{
		if (_list != null)
		{
			for (event in _list)
			{
				event.destroy();
			}
		}

		_list.splice(0, _list.length);
		_overList = [];
		_downList = [];
		_clickList = [];
	}

	/**
	 * Reorders the registered objects, using the current object drawing order.
	 * This should be called if you alter the draw/update order of a registered object,
	 * That is, if you alter the position of a registered object inside its `FlxGroup`.
	 * It may also be called if the objects are not registered by the same order they are
	 * added to `FlxGroup`.
	 */
	public function reorder():Void
	{
		var orderedObjects = new Array<FlxMouseEvent<FlxObject>>();

		traverseFlxGroup(FlxG.state, orderedObjects);

		orderedObjects.reverse();
		_list = orderedObjects;

		ArraySort.sort(_list, sortByMouseChildren); // stable sort preserves the order of registers with the same mouseChildren status
	}

	/**
	 * Sets the mouseDown callback associated with an object.
	 *
	 * @param   onMouseDown   Callback when mouse is pressed down over this object.
	 *                        Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public function setMouseDownCallback<T:FlxObject>(object:T, onMouseDown:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseDown = onMouseDown;
		}
	}

	/**
	 * Sets the mouseUp callback associated with an object.
	 *
	 * @param   onMouseUp   Callback when mouse is released over this object.
	 *                      Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public function setMouseUpCallback<T:FlxObject>(object:T, onMouseUp:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseUp = onMouseUp;
		}
	}

	/**
	 * Sets the mouseClick callback associated with an object.
	 *
	 * @param   onMouseClick    Callback when mouse is pressed and released over this object.
	 *                      	Must have Object as argument - e.g. `onMouseClick(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public function setMouseClickCallback<T:FlxObject>(object:T, onMouseClick:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseClick = onMouseClick;
		}
	}

	/**
	 * Sets the mouseDoubleClick callback associated with an object.
	 *
	 * @param   onMouseDoubleClick    	Callback when mouse is pressed and released over this object twice.
	 *                      			Must have Object as argument - e.g. `onMouseDoubleClick(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public function setMouseDoubleClickCallback<T:FlxObject>(object:T, onMouseDoubleClick:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseDoubleClick = onMouseDoubleClick;
		}
	}

	/**
	 * Sets the mouseOver callback associated with an object.
	 *
	 * @param   onMouseOver   Callback when mouse is over this object.
	 *                        Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public function setMouseOverCallback<T:FlxObject>(object:T, onMouseOver:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseOver = onMouseOver;
		}
	}

	/**
	 * Sets the mouseOut callback associated with an object.
	 *
	 * @param   onMouseOver   Callback when mouse is moved out of this object.
	 *                        Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public function setMouseOutCallback<T:FlxObject>(object:T, onMouseOut:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseOut = onMouseOut;
		}
	}

	/**
	 * Sets the mouseMove callback associated with an object.
	 *
	 * @param   onMouseMove   Callback when the mouse is moved while over this object.
	 *                        Must have Object as argument - e.g. `onMouseMove(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public function setMouseMoveCallback<T:FlxObject>(object:T, onMouseMove:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseMove = onMouseMove;
		}
	}

	/**
	 * Sets the mouseWheel callback associated with an object.
	 *
	 * @param   onMouseWheel  Callback when the mouse wheel is moved while over this object.
	 *                        Must have Object as argument - e.g. `onMouseWheel(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public function setMouseWheelCallback<T:FlxObject>(object:T, onMouseWheel:T->Void):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.onMouseWheel = onMouseWheel;
		}
	}

	/**
	 * Enables/disables mouse behavior for an object.
	 *
	 * @param   MouseEnabled   Whether this object will be tested for mouse events.
	 */
	public function setObjectMouseEnabled<T:FlxObject>(object:T, MouseEnabled:Bool):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.mouseEnabled = MouseEnabled;
		}
	}

	/**
	 * Checks if a registered object is mouseEnabled.
	 */
	public function isObjectMouseEnabled<T:FlxObject>(object:T):Bool
	{
		var event = get(object);

		if (event != null)
		{
			return event.mouseEnabled;
		}
		else
		{
			return false;
		}
	}

	/**
	 * Enables/disables mouseChildren for an object.
	 *
	 * @param   mouseChildren   Whether this object will allow other overlapping object to receive mouse events.
	 */
	public function setObjectMouseChildren<T:FlxObject>(object:T, mouseChildren:Bool):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.mouseChildren = mouseChildren;
			_list.remove(cast event);

			if (!mouseChildren)
			{
				_list.unshift(cast event);
			}
			else
			{
				var index = 0;

				while (index < _list.length && !_list[index].mouseChildren)
					index++;

				_list.insert(index, cast event);
			}
		}
	}

	/**
	 * Checks if an object allows mouseChildren.
	 */
	public function isObjectMouseChildren<T:FlxObject>(object:T):Bool
	{
		var event = get(object);

		if (event != null)
		{
			return event.mouseChildren;
		}
		else
		{
			throw new Error("FlxMouseEventManager , isObjectMouseChildren() : object not found");
		}
	}

	/**
	 * @param   MouseButtons    The mouse buttons that can trigger callbacks. Left only by default.
	 */
	public function setObjectMouseButtons<T:FlxObject>(object:T, mouseButtons:Array<FlxMouseButtonID>):Void
	{
		var event = get(object);

		if (event != null)
		{
			event.mouseButtons = mouseButtons;
		}
	}

	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	function traverseFlxGroup(group:FlxTypedGroup<Dynamic>, orderedObjects:Array<FlxMouseEvent<Dynamic>>):Void
	{
		for (basic in group.members)
		{
			var group = FlxTypedGroup.resolveGroup(basic);
			if (group != null)
			{
				traverseFlxGroup(group, orderedObjects);
			}
			if ((basic is FlxObject))
			{
				var event = get(cast basic);

				if (event != null)
				{
					orderedObjects.push(event);
				}
			}
		}
	}

	function get<T:FlxObject>(object:T, ?list:Array<FlxMouseEvent<FlxObject>>):FlxMouseEvent<T>
	{
		if (list == null)
		{
			list = _list;
		}

		for (event in list)
		{
			if (event.object == object)
			{
				return cast event;
			}
		}

		return null;
	}

	function sortByMouseChildren(event1:FlxMouseEvent<FlxObject>, event2:FlxMouseEvent<FlxObject>):Int
	{
		if (event1.mouseChildren == event2.mouseChildren)
		{
			return 0;
		}

		if (!event1.mouseChildren)
		{
			return -1;
		}

		return 1;
	}

	function clearRegistry():Void
	{
		_overList = null;
		_downList = null;
		_clickList = null;
		_list = FlxDestroyUtil.destroyArray(_list);
	}

	function checkOverlap<T:FlxObject>(event:FlxMouseEvent<T>):Bool
	{
		for (camera in event.object.cameras)
		{
			#if FLX_MOUSE
			_point = FlxG.mouse.getPositionInCameraView(camera, _point);
			if (camera.containsPoint(_point))
			{
				_point = FlxG.mouse.getWorldPosition(camera, _point);

				if (checkOverlapWithPoint(event, _point, camera))
				{
					return true;
				}
			}
			#end

			#if FLX_TOUCH
			for (touch in FlxG.touches.list)
			{
				_point = touch.getPositionInCameraView(camera, _point);
				if (camera.containsPoint(_point))
				{
					_point = touch.getWorldPosition(camera, _point);

					if (checkOverlapWithPoint(event, _point, camera))
					{
						return true;
					}
				}
			}
			#end
		}

		return false;
	}

	inline function checkOverlapWithPoint<T:FlxObject>(event:FlxMouseEvent<T>, point:FlxPoint, camera:FlxCamera):Bool
	{
		if (event.pixelPerfect && (event.sprite != null))
		{
			return event.sprite.pixelsOverlapPoint(point, 0x01, camera);
		}
		else
		{
			return event.object.overlapsPoint(point, true, camera);
		}
	}
}
