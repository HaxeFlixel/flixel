package flixel.plugin.photonstorm;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.plugin.photonstorm.baseTypes.FlxMouseSpring;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxMath;

/**
 * An enhanced FlxSprite that is capable of receiving mouse clicks, being dragged and thrown, mouse springs, gravity and other useful things
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/
class FlxExtendedSprite extends FlxSprite
{
	/**
	 * Used by FlxMouseControl when multiple sprites overlap and register clicks, and you need to determine which sprite has priority
	 */
	public var priorityID:Int;
	/**
	 * If the mouse currently pressed down on this sprite?
	 * @default false
	 */
	public var isPressed:Bool = false;
	/**
	 * Is this sprite allowed to be clicked?
	 * @default false
	 */
	public var clickable:Bool = false;
	/**
	 * Is this sprite allowed to be thrown?
	 * @default false
	 */
	public var throwable:Bool = false;
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
	/**
	 * Does this sprite have gravity applied to it?
	 * @default false
	 */
	public var hasGravity:Bool = false;
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
	public var isDragged:Bool = false;
	/**
	 * Is this sprite allowed to be dragged by the mouse? true = yes, false = no
	 * @default false
	 */
	public var draggable:Bool= false;
	/**
	 * Will the Mouse Spring be active always (false) or only when pressed (true)
	 * @default true
	 */
	public var springOnPressed:Bool = true;
	/**
	 * By default the spring attaches to the top left of the sprite. To change this location provide an x offset (in pixels)
	 */
	public var springOffsetX:Int;
	/**
	 * By default the spring attaches to the top left of the sprite. To change this location provide a y offset (in pixels)
	 */
	public var springOffsetY:Int;
	
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
	/**
	 * The MouseSpring object which is used to tie this sprite to the mouse
	 */
	public var mouseSpring:FlxMouseSpring;
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
	/**
	 * Is this sprite using a mouse spring?
	 * @default false
	 */
	public var hasMouseSpring:Bool = false;
	#end
	
	private var _snapOnDrag:Bool = false;
	private var _snapOnRelease:Bool = false;
	private var _snapX:Int;
	private var _snapY:Int;
	
	private var _clickOnRelease:Bool = false;
	private var _clickPixelPerfect:Bool = false;
	private var _clickPixelPerfectAlpha:Int;
	private var _clickCounter:Int = 0;
	
	private var _rect:FlxRect; 
	private var _throwXFactor:Int;
	private var _throwYFactor:Int;
	
	private var _dragPixelPerfect:Bool;
	private var _dragPixelPerfectAlpha:Int;
	private var _dragOffsetX:Int;
	private var _dragOffsetY:Int;
	private var _dragFromPoint:Bool;
	private var _allowHorizontalDrag:Bool = true;
	private var _allowVerticalDrag:Bool = true;
	
	/**
	 * Creates a white 8x8 square <code>FlxExtendedSprite</code> at the specified position.
	 * Optionally can load a simple, one-frame graphic instead.
	 * 
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic)
	{
		_rect = new FlxRect();
		
		super(X, Y, SimpleGraphic);
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Allow this Sprite to receive mouse clicks, the total number of times this sprite is clicked is stored in this.clicks<br>
	 * You can add callbacks via mousePressedCallback and mouseReleasedCallback
	 * 
	 * @param	OnRelease			Register the click when the mouse is pressed down (false) or when it's released (true). Note that callbacks still fire regardless of this setting.
	 * @param	PixelPerfect		If true it will use a pixel perfect test to see if you clicked the Sprite. False uses the bounding box.
	 * @param	AlphaThreshold		If using pixel perfect collision this specifies the alpha level from 0 to 255 above which a collision is processed (default 255)
	 */
	public function enableMouseClicks(OnRelease:Bool, PixelPerfect:Bool = false, AlphaThreshold:Int = 255):Void
	{
		if (FlxG.plugins.get(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseClicks called but FlxMouseControl plugin not activated";
		}
		
		clickable = true;
		
		_clickOnRelease = OnRelease;
		_clickPixelPerfect = PixelPerfect;
		_clickPixelPerfectAlpha = AlphaThreshold;
		_clickCounter = 0;
	}

	/**
	 * Stops this sprite from checking for mouse clicks and clears any set callbacks
	 */
	public function disableMouseClicks():Void
	{
		clickable = false;
		mousePressedCallback = null;
		mouseReleasedCallback = null;
	}
	
	/**
	 * The number of clicks this item has received. Usually you'd only set it to zero.
	 */
	public var clicks(get, set):Int;
	
	private function get_clicks():Int
	{
		return _clickCounter;
	}
	
	private function set_clicks(NewValue:Int):Int
	{
		return _clickCounter = NewValue;
	}
	
	/**
	 * Make this Sprite draggable by the mouse. You can also optionally set mouseStartDragCallback and mouseStopDragCallback
	 * 
	 * @param	LockCenter			If false the Sprite will drag from where you click it. If true it will center itself to the tip of the mouse pointer.
	 * @param	PixelPerfect		If true it will use a pixel perfect test to see if you clicked the Sprite. False uses the bounding box.
	 * @param	AlphaThreshold		If using pixel perfect collision this specifies the alpha level from 0 to 255 above which a collision is processed (default 255)
	 * @param	BoundsRect			If you want to restrict the drag of this sprite to a specific FlxRect, pass the FlxRect here, otherwise it's free to drag anywhere
	 * @param	BoundsSprite		If you want to restrict the drag of this sprite to within the bounding box of another sprite, pass it here
	 */
	public function enableMouseDrag(LockCenter:Bool = false, PixelPerfect:Bool = false, AlphaThreshold:Int = 255, ?BoundsRect:FlxRect, ?BoundsSprite:FlxSprite):Void
	{
		if (FlxG.plugins.get(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseDrag called but FlxMouseControl plugin not activated";
		}
		
		draggable = true;
		
		_dragFromPoint = LockCenter;
		_dragPixelPerfect = PixelPerfect;
		_dragPixelPerfectAlpha = AlphaThreshold;
		
		if (BoundsRect != null)
		{
			boundsRect = BoundsRect;
		}
		
		if (BoundsSprite != null)
		{
			boundsSprite = BoundsSprite;
		}
	}
	
	/**
	 * Stops this sprite from being able to be dragged. If it is currently the target of 
	 * an active drag it will be stopped immediately. Also disables any set callbacks.
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
	
	/**
	 * Make this Sprite throwable by the mouse. The sprite is thrown only when the mouse button is released.
	 * 
	 * @param	FactorX		The sprites velocity is set to FlxMouseControl.speedX * xFactor. Try a value around 50+
	 * @param	FactorY		The sprites velocity is set to FlxMouseControl.speedY * yFactor. Try a value around 50+
	 */
	public function enableMouseThrow(FactorX:Int, FactorY:Int):Void
	{
		if (FlxG.plugins.get(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseThrow called but FlxMouseControl plugin not activated";
		}
		
		throwable = true;
		_throwXFactor = FactorX;
		_throwYFactor = FactorY;
		
		if (clickable == false && draggable == false)
		{
			clickable = true;
		}
	}

	/**
	 * Stops this sprite from being able to be thrown. If it currently has velocity this is NOT removed from it.
	 */
	public function disableMouseThrow():Void
	{
		throwable = false;
	}

	/**
	 * Make this Sprite snap to the given grid either during drag or when it's released.
	 * For example 16x16 as the snapX and snapY would make the sprite snap to every 16 pixels.
	 * 
	 * @param	SnapX		The width of the grid cell in pixels
	 * @param	SnapY		The height of the grid cell in pixels
	 * @param	OnDrag		If true the sprite will snap to the grid while being dragged
	 * @param	OnRelease	If true the sprite will snap to the grid when released
	 */
	public function enableMouseSnap(SnapX:Int, SnapY:Int, OnDrag:Bool = true, OnRelease:Bool = false):Void
	{
		_snapOnDrag = OnDrag;
		_snapOnRelease = OnRelease;
		_snapX = SnapX;
		_snapY = SnapY;
	}

	/**
	 * Stops the sprite from snapping to a grid during drag or release.
	 */
	public function disableMouseSnap():Void
	{
		_snapOnDrag = false;
		_snapOnRelease = false;
	}

	/**
	 * Adds a simple spring between the mouse and this Sprite. The spring can be activated either when the mouse is pressed (default), or enabled all the time.
	 * Note that nearly always the Spring will over-ride any other motion setting the sprite has (like velocity or gravity)
	 * 
	 * @param	OnPressed			True if the spring should only be active when the mouse is pressed down on this sprite
	 * @param	RetainVelocity		True to retain the velocity of the spring when the mouse is released, or false to clear it
	 * @param	Tension				The tension of the spring, smaller numbers create springs closer to the mouse pointer
	 * @param	Friction			The friction applied to the spring as it moves
	 * @param	Gravity				The gravity controls how far "down" the spring hangs (use a negative value for it to hang up!)
	 * @return	The <code>FlxMouseSpring</code> object if you wish to perform further chaining on it. Also available via FlxExtendedSprite.mouseSpring
	 */ 
	public function enableMouseSpring(OnPressed:Bool = true, RetainVelocity:Bool = false, Tension:Float = 0.1, Friction:Float = 0.95, Gravity:Float = 0):FlxMouseSpring
	{
		if (FlxG.plugins.get(FlxMouseControl) == null)
		{
			throw "FlxExtendedSprite.enableMouseSpring called but FlxMouseControl plugin not activated";
		}
		
		hasMouseSpring = true;
		springOnPressed = OnPressed;
		
		if (mouseSpring == null)
		{
			mouseSpring = new FlxMouseSpring(this, RetainVelocity, Tension, Friction, Gravity);
		}
		else
		{
			mouseSpring.tension = Tension;
			mouseSpring.friction = Friction;
			mouseSpring.gravity = Gravity;
		}
		
		if (clickable == false && draggable == false)
		{
			clickable = true;
		}
		
		return mouseSpring;
	}
	
	/**
	 * Stops the sprite to mouse spring from being active
	 */
	public function disableMouseSpring():Void
	{
		hasMouseSpring = false;
		mouseSpring = null;
	}
	#end
	
	/**
	* Restricts this sprite to drag movement only on the given axis. Note: If both are set to false the sprite will never move!
	 * 
	 * @param	AllowHorizontalDrag		To enable the sprite to be dragged horizontally set to true, otherwise false
	 * @param	AllowVerticalDrag		To enable the sprite to be dragged vertically set to true, otherwise false
	 */
	public function setDragLock(AllowHorizontalDrag:Bool = true, AllowVerticalDrag:Bool = true):Void
	{
		_allowHorizontalDrag = AllowHorizontalDrag;
		_allowVerticalDrag = AllowVerticalDrag;
	}
	
	/**
	 * The spring x coordinate in game world space. Consists of <code>sprite.x + springOffsetX</code>
	 */
	public var springX(get, never):Int;
	
	private function get_springX():Int
	{
		return Math.floor(x + springOffsetX);
	}
	
	/**
	 * The spring y coordinate in game world space. Consists of <code>sprite.y + springOffsetY</code>
	 */
	public var springY(get, never):Int;
	
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
		// TODO: touch drag
		if (_allowHorizontalDrag == true)
		{
			#if !FLX_NO_MOUSE
			x = Math.floor(FlxG.mouse.x) - _dragOffsetX;
			#end
		}
		
		if (_allowVerticalDrag == true)
		{
			#if !FLX_NO_MOUSE
			y = Math.floor(FlxG.mouse.y) - _dragOffsetY;
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
		
		if (_snapOnDrag)
		{
			x = (Math.floor(x / _snapX) * _snapX);
			y = (Math.floor(y / _snapY) * _snapY);
		}
	}
	
	/**
	 * Checks if the mouse is over this sprite and pressed, then does a pixel 
	 * perfect check if needed and adds it to the FlxMouseControl check stack.
	 */
	private function checkForClick():Void
	{
		#if !FLX_NO_MOUSE
		if (mouseOver && FlxG.mouse.justPressed())
		{
			//	If we don't need a pixel perfect check, then don't bother running one! By this point we know the mouse is over the sprite already
			if (_clickPixelPerfect == false && _dragPixelPerfect == false)
			{
				FlxMouseControl.addToStack(this);
				return;
			}
			
			if (_clickPixelPerfect && FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), this, _clickPixelPerfectAlpha))
			{
				FlxMouseControl.addToStack(this);
				return;
			}
			
			if (_dragPixelPerfect && FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), this, _dragPixelPerfectAlpha))
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
		
		if (clickable == true && _clickOnRelease == false)
		{
			_clickCounter++;
		}
		
		if (mousePressedCallback != null)
		{
			mousePressedCallback(this, mouseX, mouseY);
		}
	}
	
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
		
		if (clickable == true && _clickOnRelease == true)
		{
			_clickCounter++;
		}
		
		if (throwable == true)
		{
			velocity.x = FlxMouseControl.speedX * _throwXFactor;
			velocity.y = FlxMouseControl.speedY * _throwYFactor;
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
		if (_dragFromPoint == false)
		{
			_dragOffsetX = Math.floor(Math.floor(FlxG.mouse.x) - x);
			_dragOffsetY = Math.floor(Math.floor(FlxG.mouse.y) - y);
		}
		else
		{
			// Move the sprite to the middle of the mouse
			_dragOffsetX = Std.int(frameWidth / 2);
			_dragOffsetY = Std.int(frameHeight / 2);
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
		
		if (_snapOnRelease)
		{
			x = (Math.floor(x / _snapX) * _snapX);
			y = (Math.floor(y / _snapY) * _snapY);
		}
	}
	
	/**
	 * Gravity can be applied to the sprite, pulling it in any direction. Gravity is given in pixels per second and is applied as acceleration.
	 * If you don't want gravity for a specific direction pass a value of zero. To cancel it entirely pass both values as zero.
	 * 
	 * @param	GravityX	A positive value applies gravity dragging the sprite to the right. A negative value drags the sprite to the left. Zero disables horizontal gravity.
	 * @param	GravityY	A positive value applies gravity dragging the sprite down. A negative value drags the sprite up. Zero disables vertical gravity.
	 * @param	FrictionX	The amount of friction applied to the sprite if it hits a wall. Allows it to come to a stop without constantly jittering.
	 * @param	FrictionY	The amount of friction applied to the sprite if it hits the floor/roof. Allows it to come to a stop without constantly jittering.
	 * @param	ToleranceX	If the velocity.x of the sprite falls between 0 and +- this value, it is set to stop (velocity.x = 0)
	 * @param	ToleranceY	If the velocity.y of the sprite falls between 0 and +- this value, it is set to stop (velocity.y = 0)
	 */
	public function setGravity(GravityX:Int, GravityY:Int, FrictionX:Float = 500, FrictionY:Float = 500, ToleranceX:Float = 10, ToleranceY:Float = 10):Void
	{
		hasGravity = true;
		
		gravityX = GravityX;
		gravityY = GravityY;
		
		frictionX = FrictionX;
		frictionY = FrictionY;
		
		toleranceX = ToleranceX;
		toleranceY = ToleranceY;
		
		if (GravityX == 0 && GravityY == 0)
		{
			hasGravity = false;
		}
		
		acceleration.x = GravityX;
		acceleration.y = GravityY;
	}
	
	/**
	 * Switches the gravity applied to the sprite. If gravity was +400 Y (pulling them down) this will swap it to -400 Y (pulling them up)
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
	
	/**
	 * A <code>FlxPoint</code> consisting of this sprites world x/y coordinates
	 */
	public var point(get, set):FlxPoint;
	
	private function get_point():FlxPoint
	{
		return _point;
	}
	
	private function set_point(NewPoint:FlxPoint):FlxPoint
	{
		return _point = NewPoint;
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Return true if the mouse is over this Sprite, otherwise false. Only takes the Sprites bounding box into consideration and does not check if there 
	 * are other sprites potentially on-top of this one. Check the value of this.isPressed if you need to know if the mouse is currently clicked on this sprite.
	 */
	public var mouseOver(get, never):Bool;
	
	private function get_mouseOver():Bool
	{
		return FlxMath.pointInCoordinates(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), Math.floor(x), Math.floor(y), Math.floor(width), Math.floor(height));
	}
	
	/**
	 * Returns how many horizontal pixels the mouse pointer is inside this sprite from the top left corner. Returns -1 if outside.
	 */
	public var mouseX(get, never):Int;
	
	private function get_mouseX():Int
	{
		if (mouseOver)
		{
			return Math.floor(FlxG.mouse.x - x);
		}
		
		return -1;
	}
	
	/**
	 * Returns how many vertical pixels the mouse pointer is inside this sprite from the top left corner. Returns -1 if outside.
	 */
	public var mouseY(get, never):Int;
	
	private function get_mouseY():Int
	{
		if (mouseOver)
		{
			return Math.floor(FlxG.mouse.y - y);
		}
		
		return -1;
	}
	#end
	
	/**
	 * Returns a <code>FlxRect</code> consisting of the bounds of this Sprite.
	 */
	public var rect(get, never):FlxRect;
	
	private function get_rect():FlxRect
	{
		_rect.x = x;
		_rect.y = y;
		_rect.width = width;
		_rect.height = height;
		
		return _rect;
	}
}