package org.flixel.plugin;

import nme.errors.Error;
import org.flixel.FlxBasic;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.system.input.FlxTouch;

typedef SpriteReg = {
	var sprite:FlxSprite;
	var mouseChildren:Bool;
	var mouseEnabled:Bool;
	var onMouseClick:FlxSprite-> Void;
	var onMouseOver:FlxSprite-> Void;
	var onMouseOut:FlxSprite-> Void;
}
/**
 * Provides mouse event detection for normal FlxSprites.
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */
class MouseInteractionManager extends FlxBasic
{
	private static var registeredSprites:Array<SpriteReg>;
	private static var mouseOverSprites:Array<SpriteReg>;
	
	private var _point:FlxPoint;
	
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
	
	public static function iniTimerManager()
	{
		if (FlxG.getPlugin(MouseInteractionManager) == null)
			FlxG.addPlugin(new MouseInteractionManager());
	}
	
	public static function addSprite(sprite:FlxSprite,
									onMouseClick:FlxSprite-> Void = null,
									onMouseOver:FlxSprite-> Void = null, 
									onMouseOut:FlxSprite-> Void = null, 
									mouseChildren = false, mouseEnabled = true) 
	{
		if (FlxG.getPlugin(MouseInteractionManager) == null)
			FlxG.addPlugin(new MouseInteractionManager());
		
		var newReg:SpriteReg = {
			sprite : sprite,
			mouseChildren : mouseChildren,
			mouseEnabled : mouseEnabled,
			onMouseClick : onMouseClick,
			onMouseOver : onMouseOver,
			onMouseOut : onMouseOut,
		}
		
		registeredSprites.reverse();
		registeredSprites.push(newReg);
		registeredSprites.reverse();
	}
	
	public static function removeSprite(sprite:FlxSprite)
	{
		for (reg in registeredSprites)
		{
			if (reg.sprite == sprite)
			{
				reg.sprite = null;
				reg.onMouseClick = null;
				reg.onMouseOver = null;
				reg.onMouseOut = null;
				registeredSprites.remove(reg);
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
		for (reg in registeredSprites)
		{
			
			// Sprite destroyed check.
			if (reg.sprite.scale == null)
			{
				removeSprite(reg.sprite);
				continue;
			}
			
			if (reg.sprite.alive == false)
			{
				continue;
			}
			
			if (checkOverlap(reg.sprite))
			{
				currentOverSprites.push(reg);
				if (reg.mouseEnabled == false)
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
		
		// MouseClick - Look for sprites with mouse over when user clicks.
		if (FlxG.mouse.justPressed())
		{
			for (current in currentOverSprites)
			{
				if (current.onMouseClick != null)
					current.onMouseClick(current.sprite);
			}
		}
		
		mouseOverSprites = currentOverSprites;
		
	}
	
	public function checkOverlap(sprite:FlxSprite):Bool
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.length;
		var camera:FlxCamera;
		while (i < l)
		{
			camera = FlxG.cameras[i++];
			
			#if !FLX_NO_MOUSE
			FlxG.mouse.getWorldPosition(camera, _point);
			if (sprite.overlapsPoint(_point, true, camera))
			{
				if (sprite.pixelsOverlapPoint(_point, 0x0, camera))
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
	
	// ---------------------------------------------------------------------------
	// ---------------------------------------------------------------------------
	
	function clearRegistry()
	{
		mouseOverSprites = null;
		for (reg in registeredSprites)
		{
			removeSprite(reg.sprite);
		}
		registeredSprites = null;
	}
	
	public static function addMouseClickCallback(sprite:FlxSprite, onMouseClick:FlxSprite-> Void)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.onMouseClick = onMouseClick;
		}
	}
	
	public static function addMouseOverCallback(sprite:FlxSprite, onMouseOver:FlxSprite-> Void)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.onMouseOver = onMouseOver;
		}
	}
	
	public static function addMouseOutCallback(sprite:FlxSprite, onMouseOut:FlxSprite-> Void)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.onMouseOut = onMouseOut;
		}
	}
	
	public static function setSpriteMouseEnabled(sprite:FlxSprite, mouseEnabled:Bool)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.mouseEnabled = mouseEnabled;
		}
	}
	
	public static function isSpriteMouseEnabled(sprite:FlxSprite):Bool
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			return reg.mouseEnabled;
		} 
		else 
		{
			throw new Error("MouseInteractionManager , isSpriteMouseEnabled() : sprite not found");
		}
	}
	
	public static function setSpriteMouseChildren(sprite:FlxSprite, mouseChildren:Bool)
	{
		var reg:SpriteReg = getRegister(sprite);
		if (reg != null)
		{
			reg.mouseChildren = mouseChildren;
		}
	}
	
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
	
	private static function getRegister(sprite:FlxSprite, register:Array<SpriteReg>=null):SpriteReg
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
	
}
