package flixel.plugin;

import flash.errors.Error;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.system.input.FlxTouch;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;

/**
* Provides mouse event detection for FlxSprites.
* To use it, initialize the manager and register sprites. 
* 
* 		FlxG.plugins.add(new MouseInteractionMgr());
* 		var spr:FlxSprite = new FlxSprite();
* 		MouseInteractionMgr.addSprite(spr, onMouseDown, onMouseUp, onMouseOver, onMouseOut);
* 
* Also implement the callbacks with FlxSprite return:
* 
* 		function onMouseDown(sprite:FlxSprite) {}
* 		function onMouseUp(sprite:FlxSprite) {}
* 		function onMouseOver(sprite:FlxSprite) {}
* 		function onMouseOut(sprite:FlxSprite) {} 
* 
* @author TiagoLr (~~~ ProG4mr ~~~)
*/
class MouseInteractionMgr extends FlxBasic
{
	static private var _registeredSprites:Array<SpriteReg>;
	static private var _mouseOverSprites:Array<SpriteReg>;

	static private var _point:FlxPoint;

	/**
	* Call this using FlxG.plugins.add(new MouseInteractionMgr()).
	*/
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
	
	/**
	* As alternative you can call MouseInteractionMgr.init().
	*/
	public static inline function init()
	{
		if (FlxG.plugins.get(MouseInteractionMgr) == null)
			FlxG.plugins.add(new MouseInteractionMgr());
	}
	/**
	* Adds a sprite to MouseInteractionMgr registry.
	* Even without any initialization, this is all that is needed to add mouse behaviour
	* to FlxSprites.
	*
	* @param 	Sprite 			The FlxSprite
	* @param 	OnMouseDown 	Callback when mouse is pressed down over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param 	OnMouseUp 		Callback when mouse is released over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param 	OnMouseOver 	Callback when mouse is this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param 	OnMouseOut 		Callback when mouse moves out of this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param 	MouseChildren 	If mouseChildren is enabled, other sprites overlaped by this will still receive mouse events.
	* @param 	MouseEnabled 	If mouseEnabled this sprite will receive mouse events.
	*/
	static public function addSprite(Sprite:FlxSprite, ?OnMouseDown:FlxSprite->Void, ?OnMouseUp:FlxSprite->Void, ?OnMouseOver:FlxSprite->Void, ?OnMouseOut:FlxSprite->Void, MouseChildren = false, MouseEnabled = true)
	{
		if (FlxG.plugins.get(MouseInteractionMgr) == null)
		{
			FlxG.plugins.add(new MouseInteractionMgr());
		}
		
		var newReg:SpriteReg = {
			sprite: Sprite,
			mouseChildren: MouseChildren,
			mouseEnabled: MouseEnabled,
			onMouseDown: OnMouseDown,
			onMouseUp: OnMouseUp,
			onMouseOver: OnMouseOver,
			onMouseOut: OnMouseOut,
		}
		
		_registeredSprites.unshift(newReg);
	}
	
	/**
	* Removes a sprite from the registry.
	* 
	* @param Sprite
	*/
	static public function removeSprite(Sprite:FlxSprite)
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

			if (reg.sprite.alive == false || reg.mouseEnabled == false )
			{
				continue;
			}

			if (checkOverlap(reg.sprite))
			{
				currentOverSprites.push(reg);
				
				if (reg.mouseChildren == false)
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
				if (current.onMouseOver != null)
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
				if (over.onMouseOut != null)
				{
					over.onMouseOut(over.sprite);
				}
			}
		}
		// MouseDown - Look for sprites with mouse over when user presses mouse button.
		if (FlxG.mouse.justPressed())
		{
			for (current in currentOverSprites)
			{
				if (current.onMouseDown != null)
				{
					current.onMouseDown(current.sprite);
				}
			}
		}
		// MouseUp - Look for sprites with mouse over when user releases mouse button.
		if (FlxG.mouse.justReleased())
		{
			for (current in currentOverSprites)
			{
				if (current.onMouseUp != null)
				{
					current.onMouseUp(current.sprite);
				}
			}
		}

		_mouseOverSprites = currentOverSprites;
	}

	private function checkOverlap(Sprite:FlxSprite):Bool
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.list.length;
		var camera:FlxCamera;
		
		while (i < l)
		{
			camera = FlxG.cameras.list[i++];

			#if !FLX_NO_MOUSE
			FlxG.mouse.getWorldPosition(camera, _point);
			
			if (Sprite.angle != 0)
			{
				FlxAngle.rotatePoint(_point.x, _point.y, Sprite.x + Sprite.origin.x, Sprite.y + Sprite.origin.y, -180 + Sprite.angle, _point);	
			}
			
			if (Sprite.overlapsPoint(_point, true, camera))
			{
				#if flash
				if (Sprite.pixelsOverlapPoint(_point, 0x0, camera))
				#else
				if (Sprite.pixelsOverlapPoint(_point, 0x01, camera))
				#end
				{
					return true;
				}
			}
			#end

			#if !FLX_NO_TOUCH
			for (j in 0...FlxG.touchManager.touches.length)
			{
				var touch:FlxTouch = FlxG.touchManager.touches[j];
				touch.getWorldPosition(camera, _point);
				
				if (Sprite.angle != 0)
				{
					FlxAngle.rotatePoint(_point.x, _point.y, Sprite.x + Sprite.origin.x, Sprite.y + Sprite.origin.y, -180 + Sprite.angle, _point);	
				}
				
				if (Sprite.overlapsPoint(_point, true, camera))
				{
					if (Sprite.pixelsOverlapPoint(_point, 0x0, camera))
					{
						return true;
					}
				}
			}
			#end
		}

		return false;
	}

	/**
	* Reorders the registered sprites, using the current sprite drawing order.
	* This should be called if you alter the draw/update order of a registered sprite,
	* That is, if you alter the position of a registered sprite inside its FlxGroup.
	* It may also be called if the sprites are not registered by the same order they are
	* added to FlxGroup.
	*/
	static public function reorderSprites()
	{
		var orderedSprites:Array<SpriteReg> = new Array<SpriteReg>();
		var group:Array<FlxBasic> = FlxG.state.members;

		traverseFlxGroup(FlxG.state, orderedSprites);

		orderedSprites.reverse();
		_registeredSprites = orderedSprites;
	}

	static private function traverseFlxGroup(Group:FlxGroup, OrderedSprites:Array<SpriteReg>)
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
	
	/**
	* Sets the mouseDown callback associated with a sprite.
	*
	* @param 	Sprite 			The sprite to set the callback.
	* @param 	OnMouseDown 	Callback when mouse is pressed down over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	static public function setMouseDownCallback(Sprite:FlxSprite, OnMouseDown:FlxSprite->Void)
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
	* @param 	Sprite 		The sprite to set the callback.
	* @param 	OnMouseUp 	Callback when mouse is released over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	static public function setMouseUpCallback(Sprite:FlxSprite, OnMouseUp:FlxSprite->Void)
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
	* @param 	Sprite 			The sprite to set the callback.
	* @param 	OnMouseOver 	Callback when mouse is over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	static public function setMouseOverCallback(Sprite:FlxSprite, OnMouseOver:FlxSprite->Void)
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
	* @param 	Sprite 			The FlxSprite to set the callback.
	* @param 	OnMouseOver 	Callback when mouse is moves out of this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	static public function setMouseOutCallback(Sprite:FlxSprite, OnMouseOut:FlxSprite->Void)
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
	* @param 	Sprite 			The FlxSprite.
	* @param 	MouseEnabled 	Whether this sprite will be tested for mouse events.
	*/
	static public function setSpriteMouseEnabled(Sprite:FlxSprite, MouseEnabled:Bool)
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.mouseEnabled = MouseEnabled;
		}
	}
	
	/**
	* Checks if an FlxSprite is mouseEnabled.
	*
	* @param 	Sprite 	The FlxSprite.
	*/
	static public function isSpriteMouseEnabled(Sprite:FlxSprite):Bool
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
	* @param 	Sprite 			The FlxSprite.
	* @param 	MouseChildren 	Whether this sprite will allow other overlapped sprites to receive mouseEvents.
	*/
	static public function setSpriteMouseChildren(Sprite:FlxSprite, MouseChildren:Bool):Void
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			reg.mouseChildren = MouseChildren;
		}
	}
	
	/**
	* Checks if an FlxSprite allows mouseChildren.
	* 
	* @param 	Sprite 	The FlxSprite.
	*/
	static public function isSpriteMouseChildren(Sprite:FlxSprite):Bool
	{
		var reg:SpriteReg = getRegister(Sprite);
		
		if (reg != null)
		{
			return reg.mouseChildren;
		}
		else
		{
			throw new Error("MouseInteractionManager , isSpriteMouseChildren() : sprite not found");
		}
	}

	static private function getRegister(Sprite:FlxSprite, ?Register:Array<SpriteReg>):SpriteReg
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

	private function clearRegistry():Void
	{
		_mouseOverSprites = null;
		
		for (reg in _registeredSprites)
		{
			removeSprite(reg.sprite);
		}
		
		_registeredSprites = null;
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
}