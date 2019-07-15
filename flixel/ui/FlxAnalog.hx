package flixel.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;

/**
 * A virtual thumbstick - useful for input on mobile devices.
 *
 * @author Ka Wing Chin
 */
class FlxAnalog extends FlxSpriteGroup
{
	/**
	 * Shows the current state of the button.
	 */
	public var status:Int = NORMAL;

	public var thumb:FlxSprite;

	/**
	 * The background of the joystick, also known as the base.
	 */
	public var base:FlxSprite;

	/**
	 * This function is called when the button is released.
	 */
	public var onUp:Void->Void;

	/**
	 * This function is called when the button is pressed down.
	 */
	public var onDown:Void->Void;

	/**
	 * This function is called when the mouse goes over the button.
	 */
	public var onOver:Void->Void;

	/**
	 * This function is called when the button is hold down.
	 */
	public var onPressed:Void->Void;

	/**
	 * Used with public variable status, means not highlighted or pressed.
	 */
	static inline var NORMAL:Int = 0;

	/**
	 * Used with public variable status, means highlighted (usually from mouse over).
	 */
	static inline var HIGHLIGHT:Int = 1;

	/**
	 * Used with public variable status, means pressed (usually from mouse click).
	 */
	static inline var PRESSED:Int = 2;

	/**
	 * A list of analogs that are currently active.
	 */
	static var _analogs:Array<FlxAnalog> = [];

	#if FLX_TOUCH
	/**
	 * The current pointer that's active on the analog.
	 */
	var _currentTouch:FlxTouch;

	/**
	 * Helper array for checking touches
	 */
	var _tempTouches:Array<FlxTouch> = [];
	#end

	/**
	 * The area which the joystick will react.
	 */
	var _zone:FlxRect = FlxRect.get();

	/**
	 * The radius in which the stick can move.
	 */
	var _radius:Float = 0;

	var _direction:Float = 0;
	var _amount:Float = 0;

	/**
	 * The speed of easing when the thumb is released.
	 */
	var _ease:Float;

	/**
	 * Create a virtual thumbstick - useful for input on mobile devices.
	 *
	 * @param   X            The X-coordinate of the point in space.
	 * @param   Y            The Y-coordinate of the point in space.
	 * @param   Radius       The radius where the thumb can move. If 0, half the base's width will be used.
	 * @param   Ease         Used to smoothly back thumb to center. Must be between 0 and (FlxG.updateFrameRate / 60).
	 * @param   BaseGraphic  The graphic you want to display as base of the joystick.
	 * @param   ThumbGraphic The graphic you want to display as thumb of the joystick.
	 */
	public function new(X:Float = 0, Y:Float = 0, Radius:Float = 0, Ease:Float = 0.25, ?BaseGraphic:FlxGraphicAsset, ?ThumbGraphic:FlxGraphicAsset)
	{
		super();

		_radius = Radius;
		_ease = FlxMath.bound(Ease, 0, 60 / FlxG.updateFramerate);

		_analogs.push(this);

		_point = FlxPoint.get();

		createBase(BaseGraphic);
		createThumb(ThumbGraphic);

		x = X;
		y = Y;

		scrollFactor.set();
		moves = false;
	}

	/**
	 * Creates the background of the analog stick.
	 */
	function createBase(?Graphic:FlxGraphicAsset):Void
	{
		base = new FlxSprite(0, 0, Graphic);
		if (Graphic == null)
		{
			base.frames = FlxAssets.getVirtualInputFrames();
			base.animation.frameName = "base";
			base.resetSizeFromFrame();
		}
		base.x += -base.width * 0.5;
		base.y += -base.height * 0.5;
		base.scrollFactor.set();
		base.solid = false;

		#if FLX_DEBUG
		base.ignoreDrawDebug = true;
		#end

		add(base);
	}

	/**
	 * Creates the thumb of the analog stick.
	 */
	function createThumb(?Graphic:FlxGraphicAsset):Void
	{
		thumb = new FlxSprite(0, 0, Graphic);
		if (Graphic == null)
		{
			thumb.frames = FlxAssets.getVirtualInputFrames();
			thumb.animation.frameName = "thumb";
			thumb.resetSizeFromFrame();
		}
		thumb.scrollFactor.set();
		thumb.solid = false;

		#if FLX_DEBUG
		thumb.ignoreDrawDebug = true;
		#end

		add(thumb);
	}

	/**
	 * Creates the touch zone. It's based on the size of the background.
	 * The thumb will react when the mouse is in the zone.
	 */
	function createZone():Void
	{
		if (base != null && _radius == 0)
			_radius = base.width * 0.5;

		_zone.set(x - _radius, y - _radius, 2 * _radius, 2 * _radius);
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();

		_zone = FlxDestroyUtil.put(_zone);

		_analogs.remove(this);
		onUp = null;
		onDown = null;
		onOver = null;
		onPressed = null;
		thumb = null;
		base = null;

		#if FLX_TOUCH
		_currentTouch = null;
		_tempTouches = null;
		#end
	}

	/**
	 * Update the behavior.
	 */
	override public function update(elapsed:Float):Void
	{
		var offAll:Bool = true;

		#if FLX_MOUSE
		_point.set(FlxG.mouse.screenX, FlxG.mouse.screenY);

		if (!updateAnalog(_point, FlxG.mouse.pressed, FlxG.mouse.justPressed, FlxG.mouse.justReleased))
		{
			offAll = false;
		}
		#end

		// There is no reason to get into the loop if their is already a pointer on the analog
		#if FLX_TOUCH
		if (_currentTouch != null)
		{
			_tempTouches.push(_currentTouch);
		}
		else
		{
			for (touch in FlxG.touches.list)
			{
				var touchInserted:Bool = false;

				for (analog in _analogs)
				{
					// Check whether the pointer is already taken by another analog.
					// TODO: check this place. This line was 'if (analog != this && analog._currentTouch != touch && touchInserted == false)'
					if (analog == this && analog._currentTouch != touch && !touchInserted)
					{
						_tempTouches.push(touch);
						touchInserted = true;
					}
				}
			}
		}

		for (touch in _tempTouches)
		{
			_point = touch.getWorldPosition(FlxG.camera, _point);

			if (!updateAnalog(_point, touch.pressed, touch.justPressed, touch.justReleased, touch))
			{
				offAll = false;
				break;
			}
		}
		#end

		if ((status == HIGHLIGHT || status == NORMAL) && _amount != 0)
		{
			_amount -= _amount * _ease * FlxG.updateFramerate / 60;

			if (Math.abs(_amount) < 0.1)
			{
				_amount = 0;
				_direction = 0;
			}
		}

		thumb.x = x + Math.cos(_direction) * _amount * _radius - (thumb.width * 0.5);
		thumb.y = y + Math.sin(_direction) * _amount * _radius - (thumb.height * 0.5);

		if (offAll)
		{
			status = NORMAL;
		}

		#if FLX_TOUCH
		_tempTouches.splice(0, _tempTouches.length);
		#end

		super.update(elapsed);
	}

	function updateAnalog(TouchPoint:FlxPoint, Pressed:Bool, JustPressed:Bool, JustReleased:Bool, ?Touch:FlxTouch):Bool
	{
		var offAll:Bool = true;

		#if FLX_TOUCH
		// Use the touch to figure out the world position if it's passed in, as
		// the screen coordinates passed in touchPoint are wrong
		// if the control is used in a group, for example.
		if (Touch != null)
		{
			TouchPoint.set(Touch.screenX, Touch.screenY);
		}
		#end

		if (_zone.containsPoint(TouchPoint) || (status == PRESSED))
		{
			offAll = false;

			if (Pressed)
			{
				#if FLX_TOUCH
				if (Touch != null)
				{
					_currentTouch = Touch;
				}
				#end
				status = PRESSED;

				if (JustPressed)
				{
					if (onDown != null)
					{
						onDown();
					}
				}

				if (status == PRESSED)
				{
					if (onPressed != null)
					{
						onPressed();
					}

					var dx:Float = TouchPoint.x - x;
					var dy:Float = TouchPoint.y - y;

					var dist:Float = Math.sqrt(dx * dx + dy * dy);

					if (dist < 1)
					{
						dist = 0;
					}

					_direction = Math.atan2(dy, dx);
					_amount = Math.min(_radius, dist) / _radius;

					acceleration.x = Math.cos(_direction) * _amount;
					acceleration.y = Math.sin(_direction) * _amount;
				}
			}
			else if (JustReleased && status == PRESSED)
			{
				#if FLX_TOUCH
				_currentTouch = null;
				#end

				status = HIGHLIGHT;

				if (onUp != null)
				{
					onUp();
				}

				acceleration.set();
			}

			if (status == NORMAL)
			{
				status = HIGHLIGHT;

				if (onOver != null)
				{
					onOver();
				}
			}
		}

		return offAll;
	}

	/**
	 * Returns the angle in degrees.
	 */
	public function getAngle():Float
	{
		return _direction * FlxAngle.TO_DEG;
	}

	/**
	 * Whether the thumb is pressed or not.
	 */
	public var pressed(get, never):Bool;

	inline function get_pressed():Bool
	{
		return status == PRESSED;
	}

	/**
	 * Whether the thumb is just pressed or not.
	 */
	public var justPressed(get, never):Bool;

	function get_justPressed():Bool
	{
		#if FLX_MOUSE
		return FlxG.mouse.justPressed && status == PRESSED;
		#end

		#if FLX_TOUCH
		if (_currentTouch != null)
		{
			return _currentTouch.justPressed && status == PRESSED;
		}
		#end

		return false;
	}

	/**
	 * Whether the thumb is just released or not.
	 */
	public var justReleased(get, never):Bool;

	function get_justReleased():Bool
	{
		#if FLX_MOUSE
		return FlxG.mouse.justReleased && status == HIGHLIGHT;
		#end

		#if FLX_TOUCH
		if (_currentTouch != null)
		{
			return _currentTouch.justReleased && status == HIGHLIGHT;
		}
		#end

		return false;
	}

	override function set_x(X:Float):Float
	{
		super.set_x(X);
		createZone();

		return X;
	}

	override function set_y(Y:Float):Float
	{
		super.set_y(Y);
		createZone();

		return Y;
	}
}
