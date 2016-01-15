package flixel.input.mouse;

import flash.errors.Error;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.input.mouse.FlxMouseButton;
import flixel.group.FlxSpriteGroup;

/**
 * Provides mouse event detection for FlxObjects and FlxSprites (pixel-perfect for those).
 * To use it, initialize the manager and register objects / sprites. 
 * 
 *    FlxG.plugins.add(new FlxMouseEventManager());
 *    var object = new FlxObject();
 *    FlxMouseEventManager.add(object, onMouseDown, onMouseUp, onMouseOver, onMouseOut);
 * 
 * Or simply add a new object and this plugin will initialize itself: 
 * 
 *    FlxMouseEventManager.add(object, onMouseDown, onMouseUp, onMouseOver, onMouseOut);
 * 
 * Also implement the callbacks with the object's type as parameters:
 * 
 *    function onMouseDown(object:FlxObject) {}
 *    function onMouseUp(object:FlxObject) {}
 *    function onMouseOver(object:FlxObject) {}
 *    function onMouseOut(object:FlxObject) {} 
 * 
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */
class FlxMouseEventManager extends FlxBasic
{
	private static var _registeredObjects:Array<ObjectMouseData<FlxObject>> = [];
	private static var _mouseOverObjects:Array<ObjectMouseData<FlxObject>> = [];

	private static var _point:FlxPoint = FlxPoint.get();
	
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
	 *                          Must have Object as argument - e.g. onMouseDown(object:FlxObject).
	 * @param   OnMouseUp       Callback when mouse is released over this object.
	 *                          Must have Object as argument - e.g. onMouseDown(object:FlxObject).
	 * @param   OnMouseOver     Callback when mouse is this object.
	 *                          Must have Object as argument - e.g. onMouseDown(object:FlxObject).
	 * @param   OnMouseOut      Callback when mouse moves out of this object.
	 *                          Must have Object as argument - e.g. onMouseDown(object:FlxObject).
	 * @param   MouseChildren   If true, other objects overlaped by this will still receive mouse events.
	 * @param   MouseEnabled    If true, this object will receive mouse events.
	 * @param   PixelPerfect    If true, the collision check will be pixel-perfect. Only works for FlxSprites.
	 * @param   MouseButtons    The mouse buttons that can trigger callbacks. Left only by default.
	 */
	public static function add<T:FlxObject>(Object:T, ?OnMouseDown:T->Void, ?OnMouseUp:T->Void, ?OnMouseOver:T->Void,
		?OnMouseOut:T->Void, MouseChildren = false, MouseEnabled = true, PixelPerfect = true, ?MouseButtons:Array<FlxMouseButtonID>):T
	{
		init(); // MEManager is initialized and added to plugins if it was not there already.
		
		var newReg = new ObjectMouseData<T>(Object, OnMouseDown, OnMouseUp, OnMouseOver,
			OnMouseOut, MouseChildren, MouseEnabled, PixelPerfect, MouseButtons);
		
		if (Std.is(Object, FlxSprite))
		{
			newReg.sprite = cast Object;
		}
		
		_registeredObjects.unshift(cast newReg);
		return Object;
	}
	
	/**
	 * Removes a registerd object from the registry.
	 */
	public static function remove<T:FlxObject>(Object:T):T
	{
		for (reg in _registeredObjects)
		{
			if (reg.object == Object)
			{
				reg.object = null;
				reg.sprite = null;
				reg.onMouseDown = null;
				reg.onMouseUp = null;
				reg.onMouseOver = null;
				reg.onMouseOut = null;
				_registeredObjects.remove(reg);
			}
		}
		return Object;
	}

	/**
	 * Removes all registerd objects from the registry.
	 */
	public static function removeAll():Void
	{
		if (_registeredObjects != null)
		{
			for (reg in _registeredObjects)
			{
				remove(reg.object);
			}
		}
		_registeredObjects = [];
		_mouseOverObjects = [];
	}

	/**
	 * Reorders the registered objects, using the current object drawing order.
	 * This should be called if you alter the draw/update order of a registered object,
	 * That is, if you alter the position of a registered object inside its FlxGroup.
	 * It may also be called if the objects are not registered by the same order they are
	 * added to FlxGroup.
	 */
	public static function reorder():Void
	{
		var orderedObjects = new Array<ObjectMouseData<FlxObject>>();
		var group:Array<FlxBasic> = FlxG.state.members;
		
		traverseFlxGroup(FlxG.state, orderedObjects);
		
		orderedObjects.reverse();
		_registeredObjects = orderedObjects;
	}
	
	/**
	 * Sets the mouseDown callback associated with an object.
	 *
	 * @param 	OnMouseDown 	Callback when mouse is pressed down over this object. Must have Object as argument - e.g. onMouseDown(object:FlxObject).
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
	 *                      Must have Object as argument - e.g. onMouseDown(object:FlxObject).
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
	 * Sets the mouseOver callback associated with an object.
	 *
	 * @param   OnMouseOver   Callback when mouse is over this object.
	 *                        Must have Object as argument - e.g. onMouseDown(object:FlxObject).
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
	 * @param   OnMouseOver   Callback when mouse is moves out of this object.
	 *                        Must have Object as argument - e.g. onMouseDown(object:FlxObject).
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
	
	private static function traverseFlxGroup(Group:FlxTypedGroup<Dynamic>, OrderedObjects:Array<ObjectMouseData<Dynamic>>):Void
	{
		for (basic in Group.members)
		{
			var group = FlxTypedGroup.resolveGroup(basic);
			if (group != null)
			{
				traverseFlxGroup(group, OrderedObjects);
			}
			if (Std.is(basic, FlxObject))
			{
				var reg = getRegister(cast basic);
				
				if (reg != null)
				{
					OrderedObjects.push(reg);
				}
			}
		}
	}

	private static function getRegister<T:FlxObject>(Object:T, ?Register:Array<ObjectMouseData<FlxObject>>):ObjectMouseData<T>
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
	
	public function new()
	{
		super();
		
		if (_registeredObjects != null)
		{
			clearRegistry();
		}
		_registeredObjects = new Array<ObjectMouseData<FlxObject>>();
		_mouseOverObjects = new Array<ObjectMouseData<FlxObject>>();
	}
	
	override public function destroy():Void
	{
		clearRegistry();
		_point = FlxDestroyUtil.put(_point);
		super.destroy();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		var currentOverObjects = new Array<ObjectMouseData<FlxObject>>();
		
		for (reg in _registeredObjects)
		{
			// Sprite destroyed check.
			if (reg.object.acceleration == null)
			{
				remove(reg.object);
				continue;
			}
			
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
		
	#if !FLX_NO_MOUSE
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
	#end
		
		_mouseOverObjects = currentOverObjects;
	}
	
	private function clearRegistry():Void
	{
		_mouseOverObjects = null;
		
		for (reg in _registeredObjects)
		{
			remove(reg.object);
		}
		
		_registeredObjects = null;
	}

	private function checkOverlap<T:FlxObject>(Register:ObjectMouseData<T>):Bool
	{
		for (camera in Register.object.cameras)
		{
			#if !FLX_NO_MOUSE
			_point = FlxG.mouse.getWorldPosition(camera, _point);
			
			if (checkOverlapWithPoint(Register, _point, camera))
			{
				return true;
			}
			#end
			
			#if !FLX_NO_TOUCH
			for (touch in FlxG.touches.list)
			{
				_point = touch.getWorldPosition(camera, _point);
				
				if (checkOverlapWithPoint(Register, _point, camera))
				{
					return true;
				}
			}
			#end
		}
		
		return false;
	}
	
	private inline function checkOverlapWithPoint<T:FlxObject>(Register:ObjectMouseData<T>, Point:FlxPoint, Camera:FlxCamera):Bool
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
	
	private inline function checkPixelPerfectOverlap(Point:FlxPoint, Sprite:FlxSprite, Camera:FlxCamera):Bool
	{
		if (Sprite.angle != 0)
		{
			var pivot = FlxPoint.weak(Sprite.x + Sprite.origin.x, Sprite.y + Sprite.origin.y);
			Point.rotate(pivot, -Sprite.angle);
		}
		return Sprite.pixelsOverlapPoint(Point, 0x01, Camera);
	}
}

private class ObjectMouseData<T:FlxObject>
{
	public var object:FlxObject;
	public var onMouseDown:T->Void;
	public var onMouseUp:T->Void;
	public var onMouseOver:T->Void;
	public var onMouseOut:T->Void;
	public var mouseChildren:Bool;
	public var mouseEnabled:Bool;
	public var pixelPerfect:Bool;
	public var sprite:FlxSprite;
	public var mouseButtons:Array<FlxMouseButtonID>;
	public var currentMouseButton:Null<FlxMouseButtonID>;
	
	public function new(object:T, onMouseDown:T->Void, onMouseUp:T->Void, onMouseOver:T->Void, onMouseOut:T->Void, 
		mouseChildren:Bool, mouseEnabled:Bool, pixelPerfect:Bool, mouseButtons:Array<FlxMouseButtonID>)
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
}
