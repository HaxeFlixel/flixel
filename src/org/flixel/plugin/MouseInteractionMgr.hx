package org.flixel.plugin;

import nme.errors.Error;
import org.flixel.FlxBasic;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxU;
import org.flixel.system.input.FlxTouch;

typedef SpriteReg = {
	var sprite:FlxSprite;
	var mouseChildren:Bool;
	var mouseEnabled:Bool;
	var onMouseDown:FlxSprite->Void;
	var onMouseUp:FlxSprite->Void;
	var onMouseOver:FlxSprite->Void;
	var onMouseOut:FlxSprite->Void;
}
/**
* Provides mouse event detection for normal FlxSprites.
* @author TiagoLr (~~~ ProG4mr ~~~)
*/
class MouseInteractionMgr extends FlxBasic
{
	private static var registeredSprites:Array<SpriteReg>;
	private static var mouseOverSprites:Array<SpriteReg>;

	private static var _point:FlxPoint;

	/**
	* Call this using FlxG.addPlugin(new MouseInteractionMgr()).
	*/
	public function new()
	{
		super();

		_point = new FlxPoint();
		//
		if (registeredSprites != null)
		{
			clearRegistry();
		}
		//

		registeredSprites = new Array<SpriteReg>();
		mouseOverSprites = new Array<SpriteReg>();
	}
	/**
	* As alternative you can call MouseInteractionMgr.initTimeManager()).
	*/
	public static function initTimerManager()
	{
		if (FlxG.getPlugin(MouseInteractionMgr) == null)
			FlxG.addPlugin(new MouseInteractionMgr());
	}
	/**
	* Adds a sprite to MouseInteractionMgr registry.
	* Even without any initialization, this is all that is needed to add mouse behaviour
	* to FlxSprites.
	*
	* @param sprite The FlxSprite
	* @param onMouseDown Callback when mouse is pressed down over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param onMouseUp Callback when mouse is released over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param onMouseOver Callback when mouse is this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param onMouseOut Callback when mouse moves out of this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	* @param mouseChildren If mouseChildren is enabled, other sprites overlaped by this will still receive mouse events.
	* @param mouseEnabled If mouseEnabled this sprite will receive mouse events.
	*/
	public static function addSprite(sprite:FlxSprite, onMouseDown:FlxSprite->Void = null, onMouseUp:FlxSprite->Void = null, onMouseOver:FlxSprite->Void = null, onMouseOut:FlxSprite->Void = null, mouseChildren = false, mouseEnabled = true)
	{
		if (FlxG.getPlugin(MouseInteractionMgr) == null)
			FlxG.addPlugin(new MouseInteractionMgr());

		var newReg:SpriteReg = {
			sprite: sprite,
			mouseChildren: mouseChildren,
			mouseEnabled: mouseEnabled,
			onMouseDown: onMouseDown,
			onMouseUp: onMouseUp,
			onMouseOver: onMouseOver,
			onMouseOut: onMouseOut,
		}

		registeredSprites.unshift(newReg);
	}
	/**
	* Removes a sprite from the registry.
	* @param sprite
	*/
	public static function removeSprite(sprite:FlxSprite)
	{
		for (reg in registeredSprites)
		{
			if (reg.sprite == sprite)
			{
				reg.sprite = null;
				reg.onMouseDown = null;
				reg.onMouseUp = null;
				reg.onMouseOver = null;
				reg.onMouseOut = null;
				registeredSprites.remove(reg);
			}
		}
	}
	/**
	*
	*/
	override public function destroy():Void
	{
		clearRegistry();
		_point = null;
		super.destroy();
	}
	/**
	*
	*/
	override public function update():Void
	{
		super.update();

		var currentOverSprites:Array<SpriteReg> = new Array<SpriteReg>();
		for (reg in registeredSprites)
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
			if (getRegister(current.sprite, mouseOverSprites) == null)
			{
				if (current.onMouseOver != null)
					current.onMouseOver(current.sprite);
			}
		}
		// MouseOut - Look for sprites that lost mouse over.
		for (over in mouseOverSprites)
		{
			if (getRegister(over.sprite, currentOverSprites) == null)
			{
				if (over.onMouseOut != null)
					over.onMouseOut(over.sprite);
			}
		}
		// MouseDown - Look for sprites with mouse over when user presses mouse button.
		if (FlxG.mouse.justPressed())
		{
			for (current in currentOverSprites)
			{
				if (current.onMouseDown != null)
					current.onMouseDown(current.sprite);
			}
		}
		// MouseUp - Look for sprites with mouse over when user releases mouse button.
		if (FlxG.mouse.justReleased())
		{
			for (current in currentOverSprites)
			{
				if (current.onMouseUp != null)
					current.onMouseUp(current.sprite);
			}
		}

		mouseOverSprites = currentOverSprites;
	}

	private function checkOverlap(sprite:FlxSprite):Bool
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.length;
		var camera:FlxCamera;
		while (i < l)
		{
			camera = FlxG.cameras[i++];

			#if !FLX_NO_MOUSE
			FlxG.mouse.getWorldPosition(camera, _point);
			if (sprite.angle != 0)
			{
				FlxU.rotatePoint(_point.x, _point.y, sprite.x + sprite.origin.x, sprite.y + sprite.origin.y, -180 + sprite.angle, _point);	
			}
			if (sprite.overlapsPoint(_point, true, camera))
			{
				#if flash
				if (sprite.pixelsOverlapPoint(_point, 0x0, camera))
				#else
				if (sprite.pixelsOverlapPoint(_point, 0x01, camera))
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
				if (sprite.angle != 0)
				{
					FlxU.rotatePoint(_point.x, _point.y, sprite.x + sprite.origin.x, sprite.y + sprite.origin.y, -180 + sprite.angle, _point);	
				}
				if (sprite.overlapsPoint(_point, true, camera))
				{
					if (sprite.pixelsOverlapPoint(_point, 0x0, camera))
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
	public static function reorderSprites()
	{
		var orderedSprites:Array<SpriteReg> = new Array<SpriteReg>();
		var group:Array<FlxBasic> = FlxG.state.members;

		traverseFlxGroup(FlxG.state, orderedSprites);

		orderedSprites.reverse();
		registeredSprites = orderedSprites;
	}

	private static function traverseFlxGroup(group:FlxGroup, orderedSprites:Array<SpriteReg>)
	{
		for (basic in group.members)
		{
			if (Std.is(basic, FlxGroup))
			{
				traverseFlxGroup(cast(basic, FlxGroup), orderedSprites);
			}

			if (Std.is(basic, FlxSprite))
			{
				var reg = getRegister(cast(basic, FlxSprite));
				if (reg != null)
				{
					orderedSprites.push(reg);
				}
			}
		}
	}

	// ---------------------------------------------------------------------------
	// ---------------------------------------------------------------------------

	/**
	* Sets the mouseDown callback associated with a sprite.
	*
	* @param sprite The sprite to set the callback.
	* @param onMouseDown Callback when mouse is pressed down over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	public static function setMouseDownCallback(sprite:FlxSprite, onMouseDown:FlxSprite-> Void)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.onMouseDown = onMouseDown;
		}
	}
	/**
	* Sets the mouseUp callback associated with a sprite.
	*
	* @param sprite The sprite to set the callback.
	* @param onMouseUp Callback when mouse is released over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	public static function setMouseUpCallback(sprite:FlxSprite, onMouseUp:FlxSprite-> Void)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.onMouseUp = onMouseUp;
		}
	}
	/**
	* Sets the mouseOver callback associated with a sprite.
	*
	* @param sprite The sprite to set the callback.
	* @param onMouseOver Callback when mouse is over this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	public static function setMouseOverCallback(sprite:FlxSprite, onMouseOver:FlxSprite-> Void)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.onMouseOver = onMouseOver;
		}
	}
	/**
	* Sets the mouseOut callback associated with a sprite.
	*
	* @param sprite The FlxSprite to set the callback.
	* @param onMouseOver Callback when mouse is moves out of this sprite. Must have Sprite as argument - e.g. onMouseDown(sprite:FlxSprite).
	*/
	public static function setMouseOutCallback(sprite:FlxSprite, onMouseOut:FlxSprite-> Void)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.onMouseOut = onMouseOut;
		}
	}
	/**
	* Enables/disables mouse behavior for an FlxSprite.
	*
	* @param sprite The FlxSprite.
	* @param mouseEnabled Whether this sprite will be tested for mouse events.
	*/
	public static function setSpriteMouseEnabled(sprite:FlxSprite, mouseEnabled:Bool)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.mouseEnabled = mouseEnabled;
		}
	}
	/**
	* Checks if an FlxSprite is mouseEnabled.
	*
	* @param sprite The FlxSprite.
	* @return
	*/
	public static function isSpriteMouseEnabled(sprite:FlxSprite):Bool
	{
		var reg:SpriteReg = getRegister(sprite);
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
	* @param sprite The FlxSprite.
	* @param mouseChildren Whether this sprite will allow other overlapped sprites to receive mouseEvents.
	*/
	public static function setSpriteMouseChildren(sprite:FlxSprite, mouseChildren:Bool):Void
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.mouseChildren = mouseChildren;
		}
	}
	/**
	* Checks if an FlxSprite allows mouseChildren.
	* @param sprite The FlxSprite.
	* @return
	*/
	public static function isSpriteMouseChildren(sprite:FlxSprite):Bool
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			return reg.mouseChildren;
		}
		else
		{
			throw new Error("MouseInteractionManager , isSpriteMouseChildren() : sprite not found");
		}
	}

	// ---------------------------------------------------------------------------

	private static function getRegister(sprite:FlxSprite, register:Array<SpriteReg> = null):SpriteReg
	{
		if (register == null)
			register = registeredSprites;

		for (reg in register)
		{
			if (reg.sprite == sprite)
			{
				return reg;
			}
		}
		return null;
	}

	private function clearRegistry():Void
	{
		mouseOverSprites = null;
		for (reg in registeredSprites)
		{
			removeSprite(reg.sprite);
		}
		registeredSprites = null;
	}
}