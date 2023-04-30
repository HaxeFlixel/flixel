package flixel.input.mouse;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.util.FlxDestroyUtil;

class FlxMouseEvent<T:FlxObject> implements IFlxDestroyable
{
	public static var globalManager:FlxMouseEventManager;

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
	public static inline function add<T:FlxObject>(object:T, ?onMouseDown:T->Void, ?onMouseUp:T->Void, ?onMouseOver:T->Void, ?onMouseOut:T->Void,
			mouseChildren = false, mouseEnabled = true, pixelPerfect = true, ?mouseButtons:Array<FlxMouseButtonID>):T
	{
		return globalManager.add(object, onMouseDown, onMouseUp, onMouseOver, onMouseOut,
			mouseChildren, mouseEnabled, pixelPerfect, mouseButtons);
	}

	/**
	 * Removes a registered object from the registry.
	 */
	public static inline function remove<T:FlxObject>(object:T):T
	{
		return globalManager.remove(object);
	}

	/**
	 * Removes all registered objects from the registry.
	 */
	public static inline function removeAll():Void
	{
		globalManager.removeAll();
	}

	/**
	 * Reorders the registered objects, using the current object drawing order.
	 * This should be called if you alter the draw/update order of a registered object,
	 * That is, if you alter the position of a registered object inside its `FlxGroup`.
	 * It may also be called if the objects are not registered by the same order they are
	 * added to `FlxGroup`.
	 */
	public static inline function reorder():Void
	{
		globalManager.reorder();
	}

	/**
	 * Sets the mouseDown callback associated with an object.
	 *
	 * @param   onMouseDown   Callback when mouse is pressed down over this object.
	 *                          Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static inline function setMouseDownCallback<T:FlxObject>(object:T, onMouseDown:T->Void):Void
	{
		globalManager.setMouseDownCallback(object, onMouseDown);
	}

	/**
	 * Sets the mouseUp callback associated with an object.
	 *
	 * @param   onMouseUp   Callback when mouse is released over this object.
	 *                      Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static inline function setMouseUpCallback<T:FlxObject>(object:T, onMouseUp:T->Void):Void
	{
		globalManager.setMouseUpCallback(object, onMouseUp);
	}

	/**
	 * Sets the mouseClick callback associated with an object.
	 *
	 * @param   onMouseClick    Callback when mouse is pressed and released over this object.
	 *                          Must have Object as argument - e.g. `onMouseClick(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static inline function setMouseClickCallback<T:FlxObject>(object:T, onMouseClick:T->Void):Void
	{
		globalManager.setMouseClickCallback(object, onMouseClick);
	}

	/**
	 * Sets the mouseDoubleClick callback associated with an object.
	 *
	 * @param   onMouseDoubleClick   Callback when mouse is pressed and released over this object twice.
	 *                               Must have Object as argument - e.g. `onMouseDoubleClick(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static inline function setMouseDoubleClickCallback<T:FlxObject>(object:T, onMouseDoubleClick:T->Void):Void
	{
		globalManager.setMouseDoubleClickCallback(object, onMouseDoubleClick);
	}

	/**
	 * Sets the mouseOver callback associated with an object.
	 *
	 * @param   onMouseOver   Callback when mouse is over this object.
	 *                        Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static inline function setMouseOverCallback<T:FlxObject>(object:T, onMouseOver:T->Void):Void
	{
		globalManager.setMouseOverCallback(object, onMouseOver);
	}

	/**
	 * Sets the mouseOut callback associated with an object.
	 *
	 * @param   OnMouseOver   Callback when mouse is moved out of this object.
	 *                        Must have Object as argument - e.g. `onMouseDown(object:FlxObject)`.
	 */
	public static inline function setMouseOutCallback<T:FlxObject>(object:T, onMouseOut:T->Void):Void
	{
		globalManager.setMouseOutCallback(object, onMouseOut);
	}

	/**
	 * Sets the mouseMove callback associated with an object.
	 *
	 * @param   onMouseMove   Callback when the mouse is moved while over this object.
	 *                        Must have Object as argument - e.g. `onMouseMove(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static inline function setMouseMoveCallback<T:FlxObject>(object:T, onMouseMove:T->Void):Void
	{
		globalManager.setMouseMoveCallback(object, onMouseMove);
	}

	/**
	 * Sets the mouseWheel callback associated with an object.
	 *
	 * @param   onMouseWheel  Callback when the mouse wheel is moved while over this object.
	 *                        Must have Object as argument - e.g. `onMouseWheel(object:FlxObject)`.
	 * @since 4.4.0
	 */
	public static inline function setMouseWheelCallback<T:FlxObject>(object:T, onMouseWheel:T->Void):Void
	{
		globalManager.setMouseWheelCallback(object, onMouseWheel);
	}

	/**
	 * Enables/disables mouse behavior for an object.
	 *
	 * @param   mouseEnabled   Whether this object will be tested for mouse events.
	 */
	public static inline function setObjectMouseEnabled<T:FlxObject>(object:T, mouseEnabled:Bool):Void
	{
		globalManager.setObjectMouseEnabled(object, mouseEnabled);
	}

	/**
	 * Checks if a registered object is mouseEnabled.
	 */
	public static inline function isObjectMouseEnabled<T:FlxObject>(object:T):Bool
	{
		return globalManager.isObjectMouseEnabled(object);
	}

	/**
	 * Enables/disables mouseChildren for an object.
	 *
	 * @param   mouseChildren   Whether this object will allow other overlapping object to receive mouse events.
	 */
	public static inline function setObjectMouseChildren<T:FlxObject>(object:T, mouseChildren:Bool):Void
	{
		globalManager.setObjectMouseChildren(object, mouseChildren);
	}

	/**
	 * Checks if an object allows mouseChildren.
	 */
	public static inline function isObjectMouseChildren<T:FlxObject>(object:T):Bool
	{
		return globalManager.isObjectMouseChildren(object);
	}

	/**
	 * @param   mouseButtons    The mouse buttons that can trigger callbacks. Left only by default.
	 */
	public static inline function setObjectMouseButtons<T:FlxObject>(object:T, mouseButtons:Array<FlxMouseButtonID>):Void
	{
		globalManager.setObjectMouseButtons(object, mouseButtons);
	}

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

	@:allow(flixel.input.mouse.FlxMouseEventManager)
	function new(object:T, onMouseDown:T->Void, onMouseUp:T->Void, onMouseOver:T->Void, onMouseOut:T->Void,
		mouseChildren:Bool, mouseEnabled:Bool, pixelPerfect:Bool, mouseButtons:Null<Array<FlxMouseButtonID>>)
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

		if ((object is FlxSprite))
		{
			sprite = cast object;
		}
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
