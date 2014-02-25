package flixel.plugin;

import flash.errors.Error;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;

/**
 * Provides mouse event detection for FlxSprites.
 * To use it, initialize the manager and register sprites. 
 * 
 * 		FlxG.plugins.add(new MouseEventManager());
 * 		var sprite:FlxSprite = new FlxSprite();
 * 		MouseEventManager.addSprite(sprite, onMouseDown, onMouseUp, onMouseOver, onMouseOut);
 * 
 * Or simply add a new sprite the manager will initialize itself: 
 * 
 *      MouseEventManager.addSprite(sprite, onMouseDown, onMouseUp, onMouseOver, onMouseOut);
 * 
 * Also implement the callbacks with FlxSprite parameters:
 * 
 * 		function onMouseDown(sprite:FlxSprite) {}
 * 		function onMouseUp(sprite:FlxSprite) {}
 * 		function onMouseOver(sprite:FlxSprite) {}
 * 		function onMouseOut(sprite:FlxSprite) {} 
 * 
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */
class MouseEventManager extends FlxPlugin
{
	private static var _registeredSprites:Array<SpriteReg>;
	private static var _mouseOverSprites:Array<SpriteReg>;

	private static var _point:FlxPoint;
	
	/**
	 * As alternative you can call MouseEventManager.init().
	 */
	public static inline function init():Void
	{
		if (FlxG.plugins.get(MouseEventManager) == null)
			FlxG.plugins.add(new MouseEventManager());
	}
	
	/**
	 * Adds a sprite to the MouseEventManager registry. Automatically initializes the plugin.
	 *
	 * @param	OnMouseDown		Callback when mouse is pressed down over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	 * @param	OnMouseUp		Callback when mouse is released over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	 * @param	OnMouseOver		Callback when mouse is this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	 * @param	OnMouseOut		Callback when mouse moves out of this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	 * @param	MouseChildren	If mouseChildren is enabled, other sprites overlaped by this will still receive mouse events.
	 * @param	MouseEnabled	If mouseEnabled this sprite will receive mouse events.
	 * @param	PixelPerfect	If enabled the collision check will be pixel-perfect.
	 */
	public static function addSprite(Sprite:FlxSprite, ?OnMouseDown:FlxSprite->Void, ?OnMouseUp:FlxSprite->Void, ?OnMouseOver:FlxSprite->Void, ?OnMouseOut:FlxSprite->Void, MouseChildren = false, MouseEnabled = true, PixelPerfect = true):FlxSprite
	{
		init(); // MEManager is initialized and added to plugins if it was not there already.
		
		var newReg:SpriteReg = {
			sprite: Sprite,
			mouseChildren: MouseChildren,
			mouseEnabled: MouseEnabled,
			onMouseDown: OnMouseDown,
			onMouseUp: OnMouseUp,
			onMouseOver: OnMouseOver,
			onMouseOut: OnMouseOut,
			pixelPerfect: PixelPerfect
		}
		
		_registeredSprites.unshift(newReg);
		return Sprite;
	}
	
	/**
	 * Removes a sprite from the registry.
	 */
	public static function removeSprite(Sprite:FlxSprite):FlxSprite
	{
		for (reg in _registeredSprites)
		{
			if (reg.sprite == Sprite)
			{
				reg.sprite = null;
				reg.onMouseDown = null;
				reg.onMouseUp = null;
				reg.onMouseOver = null;
				reg.onMouseOut = null;
				_registeredSprites.remove(reg);
			}
		}
		return Sprite;
	}

	/**
	* Reorders the registered sprites, using the current sprite drawing order.
	* This should be called if you alter the draw/update order of a registered sprite,
	* That is, if you alter the position of a registered sprite inside its FlxGroup.
	* It may also be called if the sprites are not registered by the same order they are
	* added to FlxGroup.
	*/
	public static function reorderSprites():Void
	{
		var orderedSprites:Array<SpriteReg> = new Array<SpriteReg>();
		var group:Array<FlxBasic> = FlxG.state.members;
		
		traverseFlxGroup(FlxG.state, orderedSprites);
		
		orderedSprites.reverse();
		_registeredSprites = orderedSprites;
	}
	
	/**
	* Sets the mouseDown callback associated with a sprite.
	*
	* @param 	OnMouseDown 	Callback when mouse is pressed down over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	public static function setMouseDownCallback(Sprite:FlxSprite, OnMouseDown:FlxSprite->Void):Void
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.onMouseDown = OnMouseDown;
		}
	}
	
	/**
	* Sets the mouseUp callback associated with a sprite.
	*
	* @param 	OnMouseUp 	Callback when mouse is released over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	public static function setMouseUpCallback(Sprite:FlxSprite, OnMouseUp:FlxSprite->Void):Void
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.onMouseUp = OnMouseUp;
		}
	}
	
	/**
	* Sets the mouseOver callback associated with a sprite.
	*
	* @param 	OnMouseOver 	Callback when mouse is over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	public static function setMouseOverCallback(Sprite:FlxSprite, OnMouseOver:FlxSprite->Void):Void
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.onMouseOver = OnMouseOver;
		}
	}
	
	/**
	 * Sets the mouseOut callback associated with a sprite.
	 *
	 * @param 	OnMouseOver 	Callback when mouse is moves out of this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	 */
	public static function setMouseOutCallback(Sprite:FlxSprite, OnMouseOut:FlxSprite->Void):Void
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.onMouseOut = OnMouseOut;
		}
	}
	
	/**
	 * Enables/disables mouse behavior for an FlxSprite.
	 * 
	 * @param 	MouseEnabled 	Whether this sprite will be tested for mouse events.
	 */
	public static function setSpriteMouseEnabled(Sprite:FlxSprite, MouseEnabled:Bool):Void
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.mouseEnabled = MouseEnabled;
		}
	}
	
	/**
	 * Checks if an FlxSprite is mouseEnabled.
	 */
	public static function isSpriteMouseEnabled(Sprite:FlxSprite):Bool
	{
		var reg:SpriteReg = getRegister(Sprite);
		
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
	 * Enables/disables mouseChildren for an FlxSprite.
	 *
	 * @param 	MouseChildren 	Whether this sprite will allow other overlapped sprites to receive mouseEvents.
	 */
	public static function setSpriteMouseChildren(Sprite:FlxSprite, MouseChildren:Bool):Void
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.mouseChildren = MouseChildren;
		}
	}
	
	/**
	 * Checks if an FlxSprite allows mouseChildren.
	 */
	public static function isSpriteMouseChildren(Sprite:FlxSprite):Bool
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			return reg.mouseChildren;
		}
		else
		{
			throw new Error("MouseEventManager , isSpriteMouseChildren() : sprite not found");
		}
	}
	
	private static function traverseFlxGroup(Group:FlxGroup, OrderedSprites:Array<SpriteReg>):Void
	{
		for (basic in Group.members)
		{
			if (Std.is(basic, FlxGroup))
			{
				traverseFlxGroup(cast(basic, FlxGroup), OrderedSprites);
			}
			
			if (Std.is(basic, FlxSprite))
			{
				var reg = getRegister(cast(basic, FlxSprite));
				
				if (reg != null)
				{
					OrderedSprites.push(reg);
				}
			}
		}
	}

	private static function getRegister(Sprite:FlxSprite, ?Register:Array<SpriteReg>):SpriteReg
	{
		if (Register == null)
		{
			Register = _registeredSprites;
		}
		
		for (reg in Register)
		{
			if (reg.sprite == Sprite)
			{
				return reg;
			}
		}
		
		return null;
	}
	
	public function new()
	{
		super();
		
		_point = new FlxPoint();
		
		if (_registeredSprites != null)
		{
			clearRegistry();
		}
		
		_registeredSprites = new Array<SpriteReg>();
		_mouseOverSprites = new Array<SpriteReg>();
	}
	
	override public function destroy():Void
	{
		clearRegistry();
		_point = null;
		
		super.destroy();
	}
	
	override public function update():Void
	{
		super.update();
		
		var currentOverSprites:Array<SpriteReg> = new Array<SpriteReg>();
		
		for (reg in _registeredSprites)
		{
			// Sprite destroyed check.
			if (reg.sprite.scale == null)
			{
				removeSprite(reg.sprite);
				continue;
			}
			
			if (!reg.sprite.alive || !reg.mouseEnabled)
			{
				continue;
			}
			
			if (checkOverlap(reg.sprite, reg.pixelPerfect))
			{
				currentOverSprites.push(reg);
				
				if (!reg.mouseChildren)
				{
					break;
				}
			}
		}
		
		// MouseOver - Look for new sprites with mouse over.
		for (current in currentOverSprites)
		{
			if (getRegister(current.sprite, _mouseOverSprites) == null)
			{
				if ((current.onMouseOver != null) && current.sprite.exists  && current.sprite.visible)
				{
					current.onMouseOver(current.sprite);
				}
			}
		}
		
		// MouseOut - Look for sprites that lost mouse over.
		for (over in _mouseOverSprites)
		{
			if (getRegister(over.sprite, currentOverSprites) == null)
			{
				if ((over.onMouseOut != null) && over.sprite.exists  && over.sprite.visible)
				{
					over.onMouseOut(over.sprite);
				}
			}
		}
		
		// MouseDown - Look for sprites with mouse over when user presses mouse button.
		#if !FLX_NO_MOUSE
		if (FlxG.mouse.justPressed)
		{
			for (current in currentOverSprites)
			{
				if ((current.onMouseDown != null) && current.sprite.exists  && current.sprite.visible)
				{
					current.onMouseDown(current.sprite);
				}
			}
		}
		
		// MouseUp - Look for sprites with mouse over when user releases mouse button.
		if (FlxG.mouse.justReleased)
		{
			for (current in currentOverSprites)
			{
				if ((current.onMouseUp != null) && current.sprite.exists  && current.sprite.visible)
				{
					current.onMouseUp(current.sprite);
				}
			}
		}
		#end
		
		_mouseOverSprites = currentOverSprites;
	}
	
	private function clearRegistry():Void
	{
		_mouseOverSprites = null;
		
		for (reg in _registeredSprites)
		{
			removeSprite(reg.sprite);
		}
		
		_registeredSprites = null;
	}

	private function checkOverlap(Sprite:FlxSprite, PixelPerfect:Bool):Bool
	{
		for (camera in Sprite.cameras)
		{
			#if !FLX_NO_MOUSE
			FlxG.mouse.getWorldPosition(camera, _point);
			
			if (Sprite.angle != 0)
			{
				FlxAngle.rotatePoint(_point.x, _point.y, (Sprite.x + Sprite.origin.x), (Sprite.y + Sprite.origin.y), Sprite.angle - 180, _point);	
			}
			
			if (Sprite.overlapsPoint(_point, true, camera))
			{
				if (!PixelPerfect || Sprite.pixelsOverlapPoint(_point, 0x01, camera))				
				{
					return true;
				}
			}
			#end
			
			#if !FLX_NO_TOUCH
			for (touch in FlxG.touches.list)
			{
				touch.getWorldPosition(camera, _point);
				
				if (Sprite.angle != 0)
				{
					FlxAngle.rotatePoint(_point.x, _point.y, (Sprite.x + Sprite.origin.x), (Sprite.y + Sprite.origin.y), Sprite.angle - 180, _point);	
				}
				
				if (Sprite.overlapsPoint(_point, true, camera))
				{
					if (!PixelPerfect || Sprite.pixelsOverlapPoint(_point, 0x01, camera))
					{
						return true;
					}
				}
			}
			#end
		}
		
		return false;
	}
}

typedef SpriteReg = {
	var sprite:FlxSprite;
	var mouseChildren:Bool;
	var mouseEnabled:Bool;
	var onMouseDown:FlxSprite->Void;
	var onMouseUp:FlxSprite->Void;
	var onMouseOver:FlxSprite->Void;
	var onMouseOut:FlxSprite->Void;
	var pixelPerfect:Bool;
}