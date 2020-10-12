package flixel.input.mouse;

import haxe.ds.ArraySort;
import flash.errors.Error;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

/**
 * Provides mouse event detection for `FlxObject` and `FlxSprite` (pixel-perfect for those).
 * To use it, initialize the manager and register objects / sprites.
 *
 * ```haxe
 * FlxG.plugins.add(new FlxMouseEventManager());
 * var object = new FlxObject();
 * FlxMouseEventManager.add(
 *	 object, onMouseDown, onMouseUp, onMouseOver, onMouseOut);
 * ```
 *
 * Or simply add a new object and this plugin will initialize itself:
 *
 * ```haxe
 * FlxMouseEventManager.add(
 *	 object, onMouseDown, onMouseUp, onMouseOver, onMouseOut);
 * ```
 *
 * Also implement the callbacks with the object's type as parameters:
 *
 * ```haxe
 * function onMouseDown(object:FlxObject) {}
 * function onMouseUp(object:FlxObject) {}
 * function onMouseOver(object:FlxObject) {}
 * function onMouseOut(object:FlxObject) {}
 * ```
 *
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */
class FlxMouseEventManager extends FlxBasic
{
	static var _registeredObjects:Array<ObjectMouseData<FlxObject>> = [];
	static var _mouseOverObjects:Array<ObjectMouseData<FlxObject>> = [];
	static var _mouseDownObjects:Array<ObjectMouseData<FlxObject>> = [];
	static var _mouseClickedObjects:Array<ObjectMouseData<FlxObject>> = [];

	static var _mouseClickedTime:Int = -1;

	static var _point:FlxPoint = FlxPoint.get();

	/**
	 * The maximum amount of time between two clicks that is considered a double click, in milliseconds.
	 * @since 4.4.0
	 */
	public static var maxDoubleClickDelay:Int = 500;

	/**
	 * As alternative you can call FlxMouseEventManager.init().
	 */
	public static inline function init():Void
	{
		if (FlxG.plugins.get(FlxMouseEventManager) == null)
			FlxG.plugins.add(new FlxMouseEventManager());
	}

	/**
	 * Adds an object to the FlxMouseEventManager registry. Automatically initializes the plugin.
	 *
	 * @param   OnMouseDown     Callback when mouse is pressed down over this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   OnMouseUp       Callback when mouse is released over this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   OnMouseOver     Callback when mouse is this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   OnMouseOut      Callback when mouse moves out of this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 * @param   MouseChildren   If true, other objects overlapped by this will still receive mouse events.
	 * @param   MouseEnabled    If true, this object will receive mouse events.
	 * @param   PixelPerfect    If true, the collision check will be pixel-perfect. Only works for FlxSprites.
	 * @param   MouseButtons    The mouse buttons that can trigger callbacks. Left only by default.
	 */
	public static function add<T:FlxObject>(Object:T, ?OnMouseDown:T->Void, ?OnMouseUp:T->Void, ?OnMouseOver:T->Void, ?OnMouseOut:T->Void,
			MouseChildren = false, MouseEnabled = true, PixelPerfect = true, ?MouseButtons:Array<FlxMouseButtonID>):T
	{
		init(); // MEManager is initialized and added to plugins if it was not there already.

		var newReg = new ObjectMouseData<T>(Object, OnMouseDown, OnMouseUp, OnMouseOver, OnMouseOut, MouseChildren, MouseEnabled, PixelPerfect, MouseButtons);

		if ((Object is FlxSprite))
		{
			newReg.sprite = cast Object;
		}

		if (!MouseChildren)
		{
			_registeredObjects.unshift(cast newReg);
		}
		else
		{
			// place mouseChildren=true objects immediately after =false ones
			var index = 0;

			while (index < _registeredObjects.length && !_registeredObjects[index].mouseChildren)
				index++;

			_registeredObjects.insert(index, cast newReg);
		}

		return Object;
	}

	/**
	 * Removes a registered object from the registry.
	 */
	public static function remove<T:FlxObject>(Object:T):T
	{
		for (reg in _registeredObjects)
		{
			if (reg.object == Object)
			{
				reg.destroy();
				_registeredObjects.remove(reg);
			}
		}
		return Object;
	}

	/**
	 * Removes all registered objects from the registry.
	 */
	public static function removeAll():Void
	{
		if (_registeredObjects != null)
		{
			for (reg in _registeredObjects)
			{
				reg.destroy();
			}
		}

		_registeredObjects.splice(0, _registeredObjects.length);
		_mouseOverObjects = [];
		_mouseDownObjects = [];
		_mouseClickedObjects = [];
	}

	/**
	 * Reorders the registered objects, using the current object drawing order.
	 * This should be called if you alter the draw/update order of a registered object,
	 * That is, if you alter the position of a registered object inside its `FlxGroup`.
	 * It may also be called if the objects are not registered by the same order they are
	 * added to `FlxGroup`.
	 */
	public static function reorder():Void
	{
		var orderedObjects = new Array<ObjectMouseData<FlxObject>>();

		traverseFlxGroup(FlxG.state, orderedObjects);

		orderedObjects.reverse();
		_registeredObjects = orderedObjects;

		ArraySort.sort(_registeredObjects, sortByMouseChildren); // stable sort preserves the order of registers with the same mouseChildren status
	}

	/**
	 * Sets the mouseDown callback associated with an object.
	 *
	 * @param 	OnMouseDown 	Callback when mouse is pressed down over this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static function setMouseDownCallback<T:FlxObject>(Object:T, OnMouseDown:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseDown = OnMouseDown;
		}
	}

	/**
	 * Sets the mouseUp callback associated with an object.
	 *
	 * @param   OnMouseUp   Callback when mouse is released over this object.
	 *                      Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static function setMouseUpCallback<T:FlxObject>(Object:T, OnMouseUp:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseUp = OnMouseUp;
		}
	}

	/**
	 * Sets the mouseClick callback associated with an object.
	 *
	 * @param   OnMouseClick    Callback when mouse is pressed and released over this object.
	 *                      	Must have Object as argument - e.g. `onMouseClick(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static function setMouseClickCallback<T:FlxObject>(Object:T, OnMouseClick:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseClick = OnMouseClick;
		}
	}

	/**
	 * Sets the mouseDoubleClick callback associated with an object.
	 *
	 * @param   OnMouseDoubleClick    	Callback when mouse is pressed and released over this object twice.
	 *                      			Must have Object as argument - e.g. `onMouseDoubleClick(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static function setMouseDoubleClickCallback<T:FlxObject>(Object:T, OnMouseDoubleClick:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseDoubleClick = OnMouseDoubleClick;
		}
	}

	/**
	 * Sets the mouseOver callback associated with an object.
	 *
	 * @param   OnMouseOver   Callback when mouse is over this object.
	 *                        Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static function setMouseOverCallback<T:FlxObject>(Object:T, OnMouseOver:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseOver = OnMouseOver;
		}
	}

	/**
	 * Sets the mouseOut callback associated with an object.
	 *
	 * @param   OnMouseOver   Callback when mouse is moved out of this object.
	 *                        Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static function setMouseOutCallback<T:FlxObject>(Object:T, OnMouseOut:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseOut = OnMouseOut;
		}
	}

	/**
	 * Sets the mouseMove callback associated with an object.
	 *
	 * @param   OnMouseMove   Callback when the mouse is moved while over this object.
	 *                        Must have Object as argument - e.g. `onMouseMove(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static function setMouseMoveCallback<T:FlxObject>(Object:T, OnMouseMove:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseMove = OnMouseMove;
		}
	}

	/**
	 * Sets the mouseWheel callback associated with an object.
	 *
	 * @param   OnMouseWheel  Callback when the mouse wheel is moved while over this object.
	 *                        Must have Object as argument - e.g. `onMouseWheel(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static function setMouseWheelCallback<T:FlxObject>(Object:T, OnMouseWheel:T->Void):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.onMouseWheel = OnMouseWheel;
		}
	}

	/**
	 * Enables/disables mouse behavior for an object.
	 *
	 * @param   MouseEnabled   Whether this object will be tested for mouse events.
	 */
	public static function setObjectMouseEnabled<T:FlxObject>(Object:T, MouseEnabled:Bool):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.mouseEnabled = MouseEnabled;
		}
	}

	/**
	 * Checks if a registered object is mouseEnabled.
	 */
	public static function isObjectMouseEnabled<T:FlxObject>(Object:T):Bool
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			return reg.mouseEnabled;
		}
		else
		{
			return false;
		}
	}

	/**
	 * Enables/disables mouseChildren for an object.
	 *
	 * @param   MouseChildren   Whether this object will allow other overlapping object to receive mouse events.
	 */
	public static function setObjectMouseChildren<T:FlxObject>(Object:T, MouseChildren:Bool):Void
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			reg.mouseChildren = MouseChildren;
			_registeredObjects.remove(cast reg);

			if (!MouseChildren)
			{
				_registeredObjects.unshift(cast reg);
			}
			else
			{
				var index = 0;

				while (index < _registeredObjects.length && !_registeredObjects[index].mouseChildren)
					index++;

				_registeredObjects.insert(index, cast reg);
			}
		}
	}

	/**
	 * Checks if an object allows mouseChildren.
	 */
	public static function isObjectMouseChildren<T:FlxObject>(Object:T):Bool
	{
		var reg = getRegister(Object);

		if (reg != null)
		{
			return reg.mouseChildren;
		}
		else
		{
			throw new Error("FlxMouseEventManager , isObjectMouseChildren() : object not found");
		}
	}

	/**
	 * @param   MouseButtons    The mouse buttons that can trigger callbacks. Left only by default.
	 */
	public static function setObjectMouseButtons<T:FlxObject>(object:T, mouseButtons:Array<FlxMouseButtonID>):Void
	{
		var reg = getRegister(object);

		if (reg != null)
		{
			reg.mouseButtons = mouseButtons;
		}
	}

	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	static function traverseFlxGroup(Group:FlxTypedGroup<Dynamic>, OrderedObjects:Array<ObjectMouseData<Dynamic>>):Void
	{
		for (basic in Group.members)
		{
			var group = FlxTypedGroup.resolveGroup(basic);
			if (group != null)
			{
				traverseFlxGroup(group, OrderedObjects);
			}
			if ((basic is FlxObject))
			{
				var reg = getRegister(cast basic);

				if (reg != null)
				{
					OrderedObjects.push(reg);
				}
			}
		}
	}

	static function getRegister<T:FlxObject>(Object:T, ?Register:Array<ObjectMouseData<FlxObject>>):ObjectMouseData<T>
	{
		if (Register == null)
		{
			Register = _registeredObjects;
		}

		for (reg in Register)
		{
			if (reg.object == Object)
			{
				return cast reg;
			}
		}

		return null;
	}

	static function sortByMouseChildren(reg1:ObjectMouseData<FlxObject>, reg2:ObjectMouseData<FlxObject>):Int
	{
		if (reg1.mouseChildren == reg2.mouseChildren)
		{
			return 0;
		}

		if (!reg1.mouseChildren)
		{
			return -1;
		}

		return 1;
	}

	public function new()
	{
		super();

		if (_registeredObjects != null)
		{
			clearRegistry();
		}
		_registeredObjects = new Array<ObjectMouseData<FlxObject>>();
		_mouseOverObjects = new Array<ObjectMouseData<FlxObject>>();
		_mouseDownObjects = new Array<ObjectMouseData<FlxObject>>();
		_mouseClickedObjects = new Array<ObjectMouseData<FlxObject>>();

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

		var currentOverObjects = new Array<ObjectMouseData<FlxObject>>();

		for (reg in _registeredObjects)
		{
			if (!reg.object.alive || !reg.object.exists || !reg.object.visible || !reg.mouseEnabled)
			{
				continue;
			}

			if (checkOverlap(reg))
			{
				currentOverObjects.push(reg);

				if (!reg.mouseChildren)
				{
					break;
				}
			}
		}

		// MouseOut - Look for objects that lost mouse over.
		for (over in _mouseOverObjects)
		{
			if (over.onMouseOut != null)
			{
				// slightly different logic here - objects whose exists or visible
				// property has been set to false should also receive a mouse out!
				if (!over.object.exists || !over.object.visible || getRegister(over.object, currentOverObjects) == null)
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
				if (current.object.exists && current.object.visible && getRegister(current.object, _mouseOverObjects) == null)
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
					_mouseDownObjects.push(current);
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
		if (_mouseClickedObjects.length > 0 && FlxG.game.ticks - _mouseClickedTime > maxDoubleClickDelay)
		{
			_mouseClickedObjects = [];
		}

		if (FlxG.mouse.justReleased)
		{
			_mouseClickedTime = FlxG.game.ticks;

			var previousClickedObjects = _mouseClickedObjects;

			if (_mouseClickedObjects.length > 0)
			{
				_mouseClickedObjects = [];
			}

			for (down in _mouseDownObjects)
			{
				if (down.object != null
					&& down.object.exists
					&& down.object.visible
					&& getRegister(down.object, currentOverObjects) != null)
				{
					if (down.onMouseClick != null)
					{
						down.onMouseClick(down.object);
					}

					if (down.onMouseDoubleClick != null)
					{
						if (getRegister(down.object, previousClickedObjects) != null)
						{
							down.onMouseDoubleClick(down.object);
						}
						else
						{
							_mouseClickedObjects.push(down);
						}
					}
				}
			}
		}

		if (_mouseDownObjects.length > 0 && !FlxG.mouse.pressed)
		{
			// if the user just released the mouse OR if the user released the mouse while the window was tabbed out
			_mouseDownObjects = [];
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

		_mouseOverObjects = currentOverObjects;
	}

	function clearRegistry():Void
	{
		_mouseOverObjects = null;
		_mouseDownObjects = null;
		_mouseClickedObjects = null;
		_registeredObjects = FlxDestroyUtil.destroyArray(_registeredObjects);
	}

	function checkOverlap<T:FlxObject>(Register:ObjectMouseData<T>):Bool
	{
		for (camera in Register.object.cameras)
		{
			#if FLX_MOUSE
			_point = FlxG.mouse.getPositionInCameraView(camera, _point);
			if (camera.containsPoint(_point))
			{
				_point = FlxG.mouse.getWorldPosition(camera, _point);

				if (checkOverlapWithPoint(Register, _point, camera))
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

					if (checkOverlapWithPoint(Register, _point, camera))
					{
						return true;
					}
				}
			}
			#end
		}

		return false;
	}

	inline function checkOverlapWithPoint<T:FlxObject>(Register:ObjectMouseData<T>, Point:FlxPoint, Camera:FlxCamera):Bool
	{
		if (Register.pixelPerfect && (Register.sprite != null))
		{
			return checkPixelPerfectOverlap(Point, Register.sprite, Camera);
		}
		else
		{
			return Register.object.overlapsPoint(Point, true, Camera);
		}
	}

	inline function checkPixelPerfectOverlap(Point:FlxPoint, Sprite:FlxSprite, Camera:FlxCamera):Bool
	{
		if (Sprite.angle != 0)
		{
			var pivot = FlxPoint.weak(Sprite.x + Sprite.origin.x - Sprite.offset.x, Sprite.y + Sprite.origin.y - Sprite.offset.y);
			Point.rotate(pivot, -Sprite.angle);
		}
		return Sprite.pixelsOverlapPoint(Point, 0x01, Camera);
	}
}

private class ObjectMouseData<T:FlxObject> implements IFlxDestroyable
{
	public var object:FlxObject;
	public var onMouseDown:T->Void;
	public var onMouseUp:T->Void;
	public var onMouseClick:T->Void;
	public var onMouseDoubleClick:T->Void;
	public var onMouseOver:T->Void;
	public var onMouseOut:T->Void;
	public var onMouseMove:T->Void;
	public var onMouseWheel:T->Void;
	public var mouseChildren:Bool;
	public var mouseEnabled:Bool;
	public var pixelPerfect:Bool;
	public var sprite:FlxSprite;
	public var mouseButtons:Array<FlxMouseButtonID>;
	public var currentMouseButton:Null<FlxMouseButtonID>;

	public function new(object:T, onMouseDown:T->Void, onMouseUp:T->Void, onMouseOver:T->Void, onMouseOut:T->Void, mouseChildren:Bool, mouseEnabled:Bool,
			pixelPerfect:Bool, mouseButtons:Array<FlxMouseButtonID>)
	{
		this.object = object;
		this.onMouseDown = onMouseDown;
		this.onMouseUp = onMouseUp;
		this.onMouseOver = onMouseOver;
		this.onMouseOut = onMouseOut;
		this.mouseChildren = mouseChildren;
		this.mouseEnabled = mouseEnabled;
		this.pixelPerfect = pixelPerfect;
		this.mouseButtons = (mouseButtons == null) ? [FlxMouseButtonID.LEFT] : mouseButtons;
	}

	public function destroy():Void
	{
		object = null;
		sprite = null;
		onMouseDown = null;
		onMouseUp = null;
		onMouseClick = null;
		onMouseDoubleClick = null;
		onMouseOver = null;
		onMouseOut = null;
		onMouseMove = null;
		onMouseWheel = null;
		mouseButtons = null;
	}
}
