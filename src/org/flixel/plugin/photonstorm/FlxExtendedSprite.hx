/**
 * FlxExtendedSprite
 * -- Part of the Flixel Power Tools set
 * 
 * v1.4 Added MouseSpring, plugin checks and all the missing documentation
 * v1.3 Added Gravity, Friction and Tolerance support
 * v1.2 Now works fully with FlxMouseControl to be completely clickable and draggable!
 * v1.1 Added "setMouseDrag" and "mouse over" states
 * v1.0 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.4 - July 29th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;

import flash.display.Bitmap;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.baseTypes.MouseSpring;

/**
 * An enhanced FlxSprite that is capable of receiving mouse clicks, being dragged and thrown, mouse springs, gravity and other useful things
 */
class FlxExtendedSprite extends FlxSprite
{
	/**
	 * Used by FlxMouseControl when multiple sprites overlap and register clicks, and you need to determine which sprite has priority
	 */
	#if flash
	public var priorityID:UInt;
	#else
	public var priorityID:Int;
	#end
	
	/**
	 * If the mouse currently pressed down on this sprite?
	 * @default false
	 */
	public var isPressed:Bool;
	
	/**
	 * Is this sprite allowed to be clicked?
	 * @default false
	 */
	public var clickable:Bool;
	private var clickOnRelease:Bool;
	private var clickPixelPerfect:Bool;
	#if flash
	private var clickPixelPerfectAlpha:UInt;
	private var clickCounter:UInt;
	#else
	private var clickPixelPerfectAlpha:Int;
	private var clickCounter:Int;
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Function called when the mouse is pressed down on this sprite. Function is passed these parameters: obj:FlxExtendedSprite, x:int, y:int
	 * @default null
	 */
	public var mousePressedCallback:FlxExtendedSprite->Int->Int->Void;
	
	/**
	 * Function called when the mouse is released from this sprite. Function is passed these parameters: obj:FlxExtendedSprite, x:int, y:int
	 * @default null
	 */
	public var mouseReleasedCallback:FlxExtendedSprite->Int->Int->Void;
	#end
	
	/**
	 * Is this sprite allowed to be thrown?
	 * @default false
	 */
	public var throwable:Bool;
	private var throwXFactor:Int;
	private var throwYFactor:Int;
	
	/**
	 * Does this sprite have gravity applied to it?
	 * @default false
	 */
	public var hasGravity:Bool;
	
	/**
	 * The x axis gravity influence
	 */
	public var gravityX:Int;
	
	/**
	 * The y axis gravity influence
	 */
	public var gravityY:Int;
	
	/**
	 * Determines how quickly the Sprite come to rest on the walls if the sprite has x gravity enabled
	 * @default 500
	 */
	public var frictionX:Float;
	
	/**
	 * Determines how quickly the Sprite come to rest on the ground if the sprite has y gravity enabled
	 * @default 500
	 */
	public var frictionY:Float;
	
	/**
	 * If the velocity.x of this sprite falls between zero and this amount, then the sprite will come to a halt (have velocity.x set to zero)
	 */
	public var toleranceX:Float;
	
	/**
	 * If the velocity.y of this sprite falls between zero and this amount, then the sprite will come to a halt (have velocity.y set to zero)
	 */
	public var toleranceY:Float;
	
	/**
	 * Is this sprite being dragged by the mouse or not?
	 * @default false
	 */
	public var isDragged:Bool;
	
	/**
	 * Is this sprite allowed to be dragged by the mouse? true = yes, false = no
	 * @default false
	 */
	public var draggable:Bool;
	private var dragPixelPerfect:Bool;
	#if flash
	private var dragPixelPerfectAlpha:UInt;
	#else
	private var dragPixelPerfectAlpha:Int;
	#end
	private var dragOffsetX:Int;
	private var dragOffsetY:Int;
	private var dragFromPoint:Bool;
	private var allowHorizontalDrag:Bool;
	private var allowVerticalDrag:Bool;
	
	#if !FLX_NO_MOUSE
	/**
	 * Function called when the mouse starts to drag this sprite. Function is passed these parameters: obj:FlxExtendedSprite, x:int, y:int
	 * @default null
	 */
	public var mouseStartDragCallback:Dynamic;
	
	/**
	 * Function called when the mouse stops dragging this sprite. Function is passed these parameters: obj:FlxExtendedSprite, x:int, y:int
	 * @default null
	 */
	public var mouseStopDragCallback:Dynamic;
	#end
	
	/**
	 * An FlxRect region of the game world within which the sprite is restricted during mouse drag
	 * @default null
	 */
	public var boundsRect:FlxRect;
	
	/**
	 * An FlxSprite the bounds of which this sprite is restricted during mouse drag
	 * @default null
	 */
	public var boundsSprite:FlxSprite;
	
	private var snapOnDrag:Bool;
	private var snapOnRelease:Bool;
	private var snapX:Int;
	private var snapY:Int;
	
	#if !FLX_NO_MOUSE
	/**
	 * Is this sprite using a mouse spring?
	 * @default false
	 */
	public var hasMouseSpring:Bool;
	#end
	
	/**
	 * Will the Mouse Spring be active always (false) or only when pressed (true)
	 * @default true
	 */
	public var springOnPressed:Bool;
	
	#if !FLX_NO_MOUSE
	/**
	 * The MouseSpring object which is used to tie this sprite to the mouse
	 */
	public var mouseSpring:MouseSpring;
	#end
	
	/**
	 * By default the spring attaches to the top left of the sprite. To change this location provide an x offset (in pixels)
	 */
	public var springOffsetX:Int;
	
	/**
	 * By default the spring attaches to the top left of the sprite. To change this location provide a y offset (in pixels)
	 */
	public var springOffsetY:Int;
	
	/**
	 * Creates a white 8x8 square <code>FlxExtendedSprite</code> at the specified position.
	 * Optionally can load a simple, one-frame graphic instead.
	 * 
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(X:Float = 0, Y:Float = 0, SimpleGraphic:Dynamic = null)
	{
		isPressed = false;
		clickable = false;
		clickOnRelease = false;
		clickPixelPerfect = false;
		throwable = false;
		hasGravity = false;
		isDragged = false;
		draggable = false;
		dragPixelPerfect = false;
		allowHorizontalDrag = true;
		allowVerticalDrag = true;
		boundsRect = null;
		boundsSprite = null;
		snapOnDrag = false;
		snapOnRelease = false;
		#if !FLX_NO_MOUSE
		hasMouseSpring = false;
		#end
		springOnPressed = true;
		
		clickCounter = 0;
		
		super(X, Y, SimpleGraphic);
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Allow this Sprite to receive mouse clicks, the total number of times this sprite is clicked is stored in this.clicks<br>
	 * You can add callbacks via mousePressedCallback and mouseReleasedCallback
	 * 
	 * @param	onRelease			Register the click when the mouse is pressed down (false) or when it's released (true). Note that callbacks still fire regardless of this setting.
	 * @param	pixelPerfect		If true it will use a pixel perfect test to see if you clicked the Sprite. False uses the bounding box.
	 * @param	alphaThreshold		If using pixel perfect collision this specifies the alpha level from 0 to 255 above which a collision is processed (default 255)
	 */
	#if flash
	public function enableMouseClicks(onRelease:Bool, pixelPerfect:Bool = false, alphaThreshold:UInt = 255):Void
	#else
	public function enableMouseClicks(onRelease:Bool, pixelPerfect:Bool = false, alphaThreshold:Int = 255):Void
	#end
	{
		if (FlxG.getPlugin(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseClicks called but FlxMouseControl plugin not activated";
		}
		
		clickable = true;
		
		clickOnRelease = onRelease;
		clickPixelPerfect = pixelPerfect;
		clickPixelPerfectAlpha = alphaThreshold;
		clickCounter = 0;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Stops this sprite from checking for mouse clicks and clears any set callbacks
	 */
	public function disableMouseClicks():Void
	{
		clickable = false;
		mousePressedCallback = null;
		mouseReleasedCallback = null;
	}
	#end
	
	#if !FLX_NO_MOUSE
	
	#if flash
	public var clicks(get_clicks, set_clicks):UInt;
	/**
	 * Returns the number of times this sprite has been clicked (can be reset by setting clicks to zero)
	 */
	private function get_clicks():UInt
	{
		return clickCounter;
	}
	/**
	 * Sets the number of clicks this item has received. Usually you'd only set it to zero.
	 */
	private function set_clicks(i:UInt):UInt
	{
		clickCounter = i;
		return i;
	}
	#else
	public var clicks(get_clicks, set_clicks):Int;
	/**
	 * Returns the number of times this sprite has been clicked (can be reset by setting clicks to zero)
	 */
	private function get_clicks():Int
	{
		return clickCounter;
	}
	
	/**
	 * Sets the number of clicks this item has received. Usually you'd only set it to zero.
	 */
	private function set_clicks(i:Int):Int
	{
		clickCounter = i;
		return i;
	}
	#end
	
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Make this Sprite draggable by the mouse. You can also optionally set mouseStartDragCallback and mouseStopDragCallback
	 * 
	 * @param	lockCenter			If false the Sprite will drag from where you click it. If true it will center itself to the tip of the mouse pointer.
	 * @param	pixelPerfect		If true it will use a pixel perfect test to see if you clicked the Sprite. False uses the bounding box.
	 * @param	alphaThreshold		If using pixel perfect collision this specifies the alpha level from 0 to 255 above which a collision is processed (default 255)
	 * @param	boundsRect			If you want to restrict the drag of this sprite to a specific FlxRect, pass the FlxRect here, otherwise it's free to drag anywhere
	 * @param	boundsSprite		If you want to restrict the drag of this sprite to within the bounding box of another sprite, pass it here
	 */
	#if flash
	public function enableMouseDrag(lockCenter:Bool = false, pixelPerfect:Bool = false, alphaThreshold:UInt = 255, boundsRect:FlxRect = null, boundsSprite:FlxSprite = null):Void
	#else
	public function enableMouseDrag(lockCenter:Bool = false, pixelPerfect:Bool = false, alphaThreshold:Int = 255, boundsRect:FlxRect = null, boundsSprite:FlxSprite = null):Void
	#end
	{
		if (FlxG.getPlugin(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseDrag called but FlxMouseControl plugin not activated";
		}
		
		draggable = true;
		
		dragFromPoint = lockCenter;
		dragPixelPerfect = pixelPerfect;
		dragPixelPerfectAlpha = alphaThreshold;
		
		if (boundsRect != null)
		{
			this.boundsRect = boundsRect;
		}
		
		if (boundsSprite != null)
		{
			this.boundsSprite = boundsSprite;
		}
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Stops this sprite from being able to be dragged. If it is currently the target of an active drag it will be stopped immediately. Also disables any set callbacks.
	 */
	public function disableMouseDrag():Void
	{
		if (isDragged)
		{
			FlxMouseControl.dragTarget = null;
			FlxMouseControl.isDragging = false;
		}
		
		isDragged = false;
		draggable = false;
		
		mouseStartDragCallback = null;
		mouseStopDragCallback = null;
	}
	#end
	
	/**
	* Restricts this sprite to drag movement only on the given axis. Note: If both are set to false the sprite will never move!
	 * 
	 * @param	allowHorizontal		To enable the sprite to be dragged horizontally set to true, otherwise false
	 * @param	allowVertical		To enable the sprite to be dragged vertically set to true, otherwise false
	 */
	public function setDragLock(allowHorizontal:Bool = true, allowVertical:Bool = true):Void
	{
		allowHorizontalDrag = allowHorizontal;
		allowVerticalDrag = allowVertical;
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Make this Sprite throwable by the mouse. The sprite is thrown only when the mouse button is released.
	 * 
	 * @param	xFactor		The sprites velocity is set to FlxMouseControl.speedX * xFactor. Try a value around 50+
	 * @param	yFactor		The sprites velocity is set to FlxMouseControl.speedY * yFactor. Try a value around 50+
	 */
	public function enableMouseThrow(xFactor:Int, yFactor:Int):Void
	{
		if (FlxG.getPlugin(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseThrow called but FlxMouseControl plugin not activated";
		}
		
		throwable = true;
		throwXFactor = xFactor;
		throwYFactor = yFactor;
		
		if (clickable == false && draggable == false)
		{
			clickable = true;
		}
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Stops this sprite from being able to be thrown. If it currently has velocity this is NOT removed from it.
	 */
	public function disableMouseThrow():Void
	{
		throwable = false;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Make this Sprite snap to the given grid either during drag or when it's released.
	 * For example 16x16 as the snapX and snapY would make the sprite snap to every 16 pixels.
	 * 
	 * @param	snapX		The width of the grid cell in pixels
	 * @param	snapY		The height of the grid cell in pixels
	 * @param	onDrag		If true the sprite will snap to the grid while being dragged
	 * @param	onRelease	If true the sprite will snap to the grid when released
	 */
	public function enableMouseSnap(snapX:Int, snapY:Int, onDrag:Bool = true, onRelease:Bool = false):Void
	{
		snapOnDrag = onDrag;
		snapOnRelease = onRelease;
		this.snapX = snapX;
		this.snapY = snapY;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Stops the sprite from snapping to a grid during drag or release.
	 */
	public function disableMouseSnap():Void
	{
		snapOnDrag = false;
		snapOnRelease = false;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Adds a simple spring between the mouse and this Sprite. The spring can be activated either when the mouse is pressed (default), or enabled all the time.
	 * Note that nearly always the Spring will over-ride any other motion setting the sprite has (like velocity or gravity)
	 * 
	 * @param	onPressed			true if the spring should only be active when the mouse is pressed down on this sprite
	 * @param	retainVelocity		true to retain the velocity of the spring when the mouse is released, or false to clear it
	 * @param	tension				The tension of the spring, smaller numbers create springs closer to the mouse pointer
	 * @param	friction			The friction applied to the spring as it moves
	 * @param	gravity				The gravity controls how far "down" the spring hangs (use a negative value for it to hang up!)
	 * 
	 * @return	The MouseSpring object if you wish to perform further chaining on it. Also available via FlxExtendedSprite.mouseSpring
	 */ 
	public function enableMouseSpring(onPressed:Bool = true, retainVelocity:Bool = false, tension:Float = 0.1, friction:Float = 0.95, gravity:Float = 0):MouseSpring
	{
		if (FlxG.getPlugin(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseSpring called but FlxMouseControl plugin not activated";
		}
		
		hasMouseSpring = true;
		springOnPressed = onPressed;
		
		if (mouseSpring == null)
		{
			mouseSpring = new MouseSpring(this, retainVelocity, tension, friction, gravity);
		}
		else
		{
			mouseSpring.tension = tension;
			mouseSpring.friction = friction;
			mouseSpring.gravity = gravity;
		}
		
		if (clickable == false && draggable == false)
		{
			clickable = true;
		}
		
		return mouseSpring;
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Stops the sprite to mouse spring from being active
	 */
	public function disableMouseSpring():Void
	{
		hasMouseSpring = false;
		
		mouseSpring = null;
	}
	#end
	
	public var springX(get_springX, null):Int;
	
	/**
	 * The spring x coordinate in game world space. Consists of sprite.x + springOffsetX
	 */
	private function get_springX():Int
	{
		return Math.floor(x + springOffsetX);
	}
	
	public var springY(get_springY, null):Int;
	
	/**
	 * The spring y coordinate in game world space. Consists of sprite.y + springOffsetY
	 */
	private function get_springY():Int
	{
		return Math.floor(y + springOffsetY);
	}
	
	/**
	 * Core update loop
	 */
	override public function update():Void
	{
		#if !FLX_NO_MOUSE
		if (draggable == true && isDragged == true)
		{
			updateDrag();
		}
		
		if (isPressed == false && FlxG.mouse.justPressed())
		{
			checkForClick();
		}
		
		if (hasGravity == true)
		{
			updateGravity();
		}
		
		if (hasMouseSpring == true)
		{
			if (springOnPressed == false)
			{
				mouseSpring.update();
			}
			else
			{
				if (isPressed == true)
				{
					mouseSpring.update();
				}
				else
				{
					mouseSpring.reset();
				}
			}
		}
		#end
		super.update();
	}
	
	/**
	 * Called by update, applies friction if the sprite has gravity to stop jittery motion when slowing down
	 */
	private function updateGravity():Void
	{
		//	A sprite can have horizontal and/or vertical gravity in each direction (positiive / negative)
		
		//	First let's check the x movement
		
		if (velocity.x != 0)
		{
			if (acceleration.x < 0)
			{
				//	Gravity is pulling them left
				if ((touching & FlxObject.WALL) != 0)
				{
					drag.y = frictionY;
					
					if ((wasTouching & FlxObject.WALL) == 0)
					{
						if (velocity.x < toleranceX)
						{
							//trace("(left) velocity.x", velocity.x, "stopped via tolerance break", toleranceX);
							velocity.x = 0;
						}
					}
				}
				else
				{
					drag.y = 0;
				}
			}
			else if (acceleration.x > 0)
			{
				//	Gravity is pulling them right
				if ((touching & FlxObject.WALL) != 0)
				{
					//	Stop them sliding like on ice
					drag.y = frictionY;
					
					if ((wasTouching & FlxObject.WALL) == 0)
					{
						if (velocity.x > -toleranceX)
						{
							//trace("(right) velocity.x", velocity.x, "stopped via tolerance break", toleranceX);
							velocity.x = 0;
						}
					}
				}
				else
				{
					drag.y = 0;
				}
			}
		}
		
		//	Now check the y movement
		
		if (velocity.y != 0)
		{
			if (acceleration.y < 0)
			{
				//	Gravity is pulling them up (velocity is negative)
				if ((touching & FlxObject.CEILING) != 0)
				{
					drag.x = frictionX;
					
					if ((wasTouching & FlxObject.CEILING) == 0)
					{
						if (velocity.y < toleranceY)
						{
							//trace("(down) velocity.y", velocity.y, "stopped via tolerance break", toleranceY);
							velocity.y = 0;
						}
					}
				}
				else
				{
					drag.x = 0;
				}
			}
			else if (acceleration.y > 0)
			{
				//	Gravity is pulling them down (velocity is positive)
				if ((touching & FlxObject.FLOOR) != 0)
				{
					//	Stop them sliding like on ice
					drag.x = frictionX;
					
					if ((wasTouching & FlxObject.FLOOR) == 0)
					{
						if (velocity.y > -toleranceY)
						{
							//trace("(down) velocity.y", velocity.y, "stopped via tolerance break", toleranceY);
							velocity.y = 0;
						}
					}
				}
				else
				{
					drag.x = 0;
				}
			}
		}
	}
	
	/**
	 * Updates the Mouse Drag on this Sprite.
	 */
	private function updateDrag():Void
	{
		//FlxG.mouse.getWorldPosition(null, tempPoint);
		//todo touch drag
		if (allowHorizontalDrag == true)
		{
			#if !FLX_NO_MOUSE
			x = Math.floor(FlxG.mouse.x) - dragOffsetX;
			#end
		}
		
		if (allowVerticalDrag == true)
		{
			#if !FLX_NO_MOUSE
			y = Math.floor(FlxG.mouse.y) - dragOffsetY;
			#end
		}
		
		if (boundsRect != null)
		{
			checkBoundsRect();
		}

		if (boundsSprite != null)
		{
			checkBoundsSprite();
		}
		
		if (snapOnDrag)
		{
			x = (Math.floor(x / snapX) * snapX);
			y = (Math.floor(y / snapY) * snapY);
		}
	}
	
	/**
	 * Checks if the mouse is over this sprite and pressed, then does a pixel perfect check if needed and adds it to the FlxMouseControl check stack
	 */
	private function checkForClick():Void
	{
		#if !FLX_NO_MOUSE
		if (mouseOver && FlxG.mouse.justPressed())
		{
			//	If we don't need a pixel perfect check, then don't bother running one! By this point we know the mouse is over the sprite already
			if (clickPixelPerfect == false && dragPixelPerfect == false)
			{
				FlxMouseControl.addToStack(this);
				return;
			}
			
			if (clickPixelPerfect && FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), this, clickPixelPerfectAlpha))
			{
				FlxMouseControl.addToStack(this);
				return;
			}
			
			if (dragPixelPerfect && FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), this, dragPixelPerfectAlpha))
			{
				FlxMouseControl.addToStack(this);
				return;
			}
		}
		#end
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Called by FlxMouseControl when this sprite is clicked. Should not usually be called directly.
	 */
	public function mousePressedHandler():Void
	{
		isPressed = true;
		
		if (clickable == true && clickOnRelease == false)
		{
			clickCounter++;
		}
		
		if (mousePressedCallback != null)
		{
			mousePressedCallback(this, mouseX, mouseY);
		}
	}
	#end
	
	#if !FLX_NO_MOUSE
	/**
	 * Called by FlxMouseControl when this sprite is released from a click. Should not usually be called directly.
	 */
	public function mouseReleasedHandler():Void
	{
		isPressed = false;
		
		if (isDragged == true)
		{
			stopDrag();
		}
		
		if (clickable == true && clickOnRelease == true)
		{
			clickCounter++;
		}
		
		if (throwable == true)
		{
			velocity.x = FlxMouseControl.speedX * throwXFactor;
			velocity.y = FlxMouseControl.speedY * throwYFactor;
		}
		
		if (mouseReleasedCallback != null)
		{
			mouseReleasedCallback(this, mouseX, mouseY);
		}
	}
	#end
	
	/**
	 * Called by FlxMouseControl when Mouse Drag starts on this Sprite. Should not usually be called directly.
	 */
	public function startDrag():Void
	{
		isDragged = true;
		#if !FLX_NO_MOUSE
		if (dragFromPoint == false)
		{
			dragOffsetX = Math.floor(Math.floor(FlxG.mouse.x) - x);
			dragOffsetY = Math.floor(Math.floor(FlxG.mouse.y) - y);
		}
		else
		{
			//	Move the sprite to the middle of the mouse
			dragOffsetX = Std.int(frameWidth / 2);
			dragOffsetY = Std.int(frameHeight / 2);
		}
		#end
	}
	
	/**
	 * Bounds Rect check for the sprite drag
	 */
	private function checkBoundsRect():Void
	{
		if (x < boundsRect.left)
		{
			x = boundsRect.x;
		}
		else if ((x + width) > boundsRect.right)
		{
			x = boundsRect.right - width;
		}
		
		if (y < boundsRect.top)
		{
			y = boundsRect.top;
		}
		else if ((y + height) > boundsRect.bottom)
		{
			y = boundsRect.bottom - height;
		}
	}
	
	/**
	 * Parent Sprite Bounds check for the sprite drag
	 */
	private function checkBoundsSprite():Void
	{
		if (x < boundsSprite.x)
		{
			x = boundsSprite.x;
		}
		else if ((x + width) > (boundsSprite.x + boundsSprite.width))
		{
			x = (boundsSprite.x + boundsSprite.width) - width;
		}
		
		if (y < boundsSprite.y)
		{
			y = boundsSprite.y;
		}
		else if ((y + height) > (boundsSprite.y + boundsSprite.height))
		{
			y = (boundsSprite.y + boundsSprite.height) - height;
		}
	}
	
	/**
	 * Called by FlxMouseControl when Mouse Drag is stopped on this Sprite. Should not usually be called directly.
	 */
	public function stopDrag():Void
	{
		isDragged = false;
		
		if (snapOnRelease)
		{
			x = (Math.floor(x / snapX) * snapX);
			y = (Math.floor(y / snapY) * snapY);
		}
	}
	
	/**
	 * Gravity can be applied to the sprite, pulling it in any direction. Gravity is given in pixels per second and is applied as acceleration.
	 * If you don't want gravity for a specific direction pass a value of zero. To cancel it entirely pass both values as zero.
	 * 
	 * @param	gravityX	A positive value applies gravity dragging the sprite to the right. A negative value drags the sprite to the left. Zero disables horizontal gravity.
	 * @param	gravityY	A positive value applies gravity dragging the sprite down. A negative value drags the sprite up. Zero disables vertical gravity.
	 * @param	frictionX	The amount of friction applied to the sprite if it hits a wall. Allows it to come to a stop without constantly jittering.
	 * @param	frictionY	The amount of friction applied to the sprite if it hits the floor/roof. Allows it to come to a stop without constantly jittering.
	 * @param	toleranceX	If the velocity.x of the sprite falls between 0 and +- this value, it is set to stop (velocity.x = 0)
	 * @param	toleranceY	If the velocity.y of the sprite falls between 0 and +- this value, it is set to stop (velocity.y = 0)
	 */
	public function setGravity(gravityX:Int, gravityY:Int, frictionX:Float = 500, frictionY:Float = 500, toleranceX:Float = 10, toleranceY:Float = 10):Void
	{
		hasGravity = true;
		
		this.gravityX = gravityX;
		this.gravityY = gravityY;
		
		this.frictionX = frictionX;
		this.frictionY = frictionY;
		
		this.toleranceX = toleranceX;
		this.toleranceY = toleranceY;
		
		if (gravityX == 0 && gravityY == 0)
		{
			hasGravity = false;
		}
		
		acceleration.x = gravityX;
		acceleration.y = gravityY;
	}
	
	/**
	 * Switches the gravity applied to the sprite. If gravity was +400 Y (pulling them down) this will swap it to -400 Y (pulling them up)<br>
	 * To reset call flipGravity again
	 */
	public function flipGravity():Void
	{
		if (!Math.isNaN(gravityX) && gravityX != 0)
		{
			gravityX = -gravityX;
			acceleration.x = gravityX;
		}
		
		if (!Math.isNaN(gravityY) && gravityY != 0)
		{
			gravityY = -gravityY;
			acceleration.y = gravityY;
		}
	}
	
	public var point(get_point, set_point):FlxPoint;
	
	/**
	 * Returns an FlxPoint consisting of this sprites world x/y coordinates
	 */
	private function get_point():FlxPoint
	{
		return _point;
	}
	
	private function set_point(p:FlxPoint):FlxPoint
	{
		_point = p;
		return p;
	}
	
	#if !FLX_NO_MOUSE
	public var mouseOver(get_mouseOver, null):Bool;
	
	/**
	 * Return true if the mouse is over this Sprite, otherwise false. Only takes the Sprites bounding box into consideration and does not check if there 
	 * are other sprites potentially on-top of this one. Check the value of this.isPressed if you need to know if the mouse is currently clicked on this sprite.
	 */
	private function get_mouseOver():Bool
	{
		return FlxMath.pointInCoordinates(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), Math.floor(x), Math.floor(y), Math.floor(width), Math.floor(height));
	}
	
	public var mouseX(get_mouseX, null):Int;
	
	/**
	 * Returns how many horizontal pixels the mouse pointer is inside this sprite from the top left corner. Returns -1 if outside.
	 */
	private function get_mouseX():Int
	{
		if (mouseOver)
		{
			return Math.floor(FlxG.mouse.x - x);
		}
		
		return -1;
	}
	
	public var mouseY(get_mouseY, null):Int;
	
	/**
	 * Returns how many vertical pixels the mouse pointer is inside this sprite from the top left corner. Returns -1 if outside.
	 */
	private function get_mouseY():Int
	{
		if (mouseOver)
		{
			return Math.floor(FlxG.mouse.y - y);
		}
		
		return -1;
	}
	#end
	
	public var rect(get_rect, null):FlxRect;
	
	/**
	 * Returns an FlxRect consisting of the bounds of this Sprite.
	 */
	private function get_rect():FlxRect
	{
		_rect.x = x;
		_rect.y = y;
		_rect.width = width;
		_rect.height = height;
		
		return _rect;
	}
}