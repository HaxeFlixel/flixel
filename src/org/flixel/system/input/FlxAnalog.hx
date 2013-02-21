package org.flixel.system.input;

import org.flixel.FlxTypedGroup;
import org.flixel.FlxU;
import org.flixel.FlxG;
import org.flixel.FlxAssets;
import org.flixel.FlxSprite;
import org.flixel.FlxPoint;
import flash.geom.Rectangle;
import org.flixel.system.input.FlxTouch;

/**
 * 
 * @author Ka Wing Chin
 */
class FlxAnalog extends FlxTypedGroup<FlxSprite>
{
	// From radians to degrees.
	private static inline var DEGREES:Float = (180 / Math.PI);
	
	// Used with public variable <code>status</code>, means not highlighted or pressed.
	private static inline var NORMAL:Int = 0;
	// Used with public variable <code>status</code>, means highlighted (usually from mouse over).
	private static inline var HIGHLIGHT:Int = 1;
	// Used with public variable <code>status</code>, means pressed (usually from mouse click).
	private static inline var PRESSED:Int = 2;		
	// Shows the current state of the button.
	public var status:Int;
	
	// X position of the upper left corner of this object in world space.
	public var x:Float;
	// Y position of the upper left corner of this object in world space.
	public var y:Float;
	
	// An list of analogs that are currently active.
	private static var _analogs:Array<FlxAnalog>;
	#if !FLX_NO_TOUCH
	// The current pointer that's active on the analog.
	private var _currentTouch:FlxTouch;
	// Helper array for checking touches
	private var _tempTouches:Array<FlxTouch>;
	#end
	// Helper FlxPoint object
	private var _point:FlxPoint;
	
	// This function is called when the button is released.
	public var onUp:Void->Void;
	// This function is called when the button is pressed down.
	public var onDown:Void->Void;
	// This function is called when the mouse goes over the button.
	public var onOver:Void->Void;
	// This function is called when the button is hold down.
	public var onPressed:Void->Void;
	
	// The area which the joystick will react.
	private var _pad:Rectangle;
	// The background of the joystick, also known as the base.
	private var _base:FlxSprite;
	// The thumb 
	public var _stick:FlxSprite;
	
	// The radius where the thumb can move.
	private var _radius:Float;
	private var _direction:Float;
	private var _amount:Float;		
	
	// How fast the speed of this object is changing.
	public var acceleration:FlxPoint;
	// The speed of easing when the thumb is released.
	private var _ease:Float;
	
	/**
	 * Constructor
	 * @param	X		The X-coordinate of the point in space.
 	 * @param	Y		The Y-coordinate of the point in space.
 	 * @param	radius	The radius where the thumb can move. If 0, the background will be use as radius.
 	 * @param	ease	The duration of the easing. The value must be between 0 and 1.
	 */
	public function new(X:Float, Y:Float, Radius:Float = 0, Ease:Float = 0.25)
	{
		super();
		
		x = X;
		y = Y;
		_radius = Radius;
		_ease = Ease;
		
		if (_analogs == null)
		{
			_analogs = new Array<FlxAnalog>();
		}
		_analogs.push(this);
		
		status = NORMAL;
		_direction = 0;
		_amount = 0;
		acceleration = new FlxPoint();
		
		_tempTouches = [];
		_point = new FlxPoint();
		
		createBase();
		createThumb();
		createZone();
	}
	
	/**
	 * Creates the background of the analog stick.
	 * Override this to customize the background.
	 */
	private function createBase():Void
	{
		_base = new FlxSprite(x, y).loadGraphic(FlxAssets.imgBase);
		_base.cameras = [FlxG.camera];
		_base.x += -_base.width * .5;
		_base.y += -_base.height * .5;
		_base.scrollFactor.x = _base.scrollFactor.y = 0;
		_base.solid = false;
		
		#if !FLX_NO_DEBUG
		_base.ignoreDrawDebug = true;
		#end
		
		add(_base);	
	}
	
	/**
	 * Creates the thumb of the analog stick.
	 * Override this to customize the thumb.
	 */
	private function createThumb():Void 
	{
		_stick = new FlxSprite(x, y).loadGraphic(FlxAssets.imgStick);
		_stick.cameras = [FlxG.camera];
		_stick.scrollFactor.x = _stick.scrollFactor.y = 0;
		_stick.solid = false;
		
		#if !FLX_NO_DEBUG
		_stick.ignoreDrawDebug = true;
		#end
		
		add(_stick);
	}
	
	/**
	 * Creates the touch zone. It's based on the size of the background. 
	 * The thumb will react when the mouse is in the zone.
	 * Override this to customize the zone.
	 */
	private function createZone():Void
	{
		if (_radius == 0)			
		{
			_radius = _base.width / 2;
		}
		_pad = new Rectangle(x - _radius, y - _radius, 2 * _radius, 2 * _radius);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_analogs = null;
		onUp = null;
		onDown = null;
		onOver = null;
		onPressed = null;
		acceleration = null;
		_stick = null;
		_base = null;
		_pad = null;
		
		_currentTouch = null;
		_tempTouches = null;
		_point = null;
	}
	
	/**
	 * Update the behavior. 
	 */
	override public function update():Void 
	{
		#if !FLX_NO_TOUCH
		var touch:FlxTouch = null;
		#end
		var offAll:Bool = true;
		
		// There is no reason to get into the loop if their is already a pointer on the analog
		#if !FLX_NO_TOUCH
			if (_currentTouch != null)
			{
				_tempTouches.push(_currentTouch);
			}
			else
			{
				for (touch in FlxG.touchManager.touches)
				{		
					var touchInserted:Bool = false;
					for (analog in _analogs)
					{
						// check whether the pointer is already taken by another analog.
						// TODO: check this place. This line was 'if (analog != this && analog._currentTouch != touch && touchInserted == false)'
						if (analog == this && analog._currentTouch != touch && touchInserted == false) 
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
				if (updateAnalog(_point, touch.pressed(), touch.justPressed(), touch.justReleased(), touch) == false)
				{
					offAll = false;
					break;
				}
			}
		#end
		
		#if !FLX_NO_MOUSE
			_point.x = FlxG.mouse.screenX;
			_point.y = FlxG.mouse.screenY;
			
			if (updateAnalog(_point, FlxG.mouse.pressed(), FlxG.mouse.justPressed(), FlxG.mouse.justReleased()) == false)
			{
				offAll = false;
			}
		#end
		
		if ((status == HIGHLIGHT || status == NORMAL) && _amount != 0)
		{
			_amount *= _ease;
			if (Math.abs(_amount) < 0.1) 
			{
				_amount = 0;
			}
		}
		
		_stick.x = x + Math.cos(_direction) * _amount * _radius - (_stick.width * 0.5);
		_stick.y = y + Math.sin(_direction) * _amount * _radius - (_stick.height * 0.5);
		
		if (offAll)
		{
			status = NORMAL;
		}
		#if !FLX_NO_TOUCH
		_tempTouches.splice(0, _tempTouches.length);
		#end
		super.update();
	}
	
	private function updateAnalog(touchPoint:FlxPoint, pressed:Bool, justPressed:Bool, justReleased:Bool, touch:FlxTouch = null):Bool
	{
		var offAll:Bool = true;
		#if !FLX_NO_TOUCH
		// Use the touch to figure out the world position if it's passed in, as 
		// the screen coordinates passed in touchPoint are wrong
		// if the control is used in a group, for example.
		if (touch != null)
		{
			touchPoint.x = touch.screenX;
			touchPoint.y = touch.screenY;
		}
		#end
		if (_pad.contains(touchPoint.x, touchPoint.y) || (status == PRESSED))
		{
			offAll = false;
			
			if (pressed)
			{
				#if !FLX_NO_TOUCH
				if (touch != null)
				{
					_currentTouch = touch;
				}
				#end
				status = PRESSED;			
				if (justPressed)
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
					
					var dx:Float = touchPoint.x - x;
					var dy:Float = touchPoint.y - y;
					
					var dist:Float = Math.sqrt(dx * dx + dy * dy);
					if (dist < 1) 
					{
						dist = 0;
					}
					_direction = Math.atan2(dy, dx);
					_amount = FlxU.min(_radius, dist) / _radius;
					
					acceleration.x = Math.cos(_direction) * _amount * _radius;
					acceleration.y = Math.sin(_direction) * _amount * _radius;			
				}					
			}
			else if (justReleased && status == PRESSED)
			{				
				#if !FLX_NO_TOUCH
				_currentTouch = null;
				#end
				status = HIGHLIGHT;
				if (onUp != null)
				{
					onUp();
				}
				acceleration.x = 0;
				acceleration.y = 0;
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
	 * @return	The angle.
	 */
	public function getAngle():Float
	{
		return Math.atan2(acceleration.y, acceleration.x) * DEGREES;
	}
	
	/**
	 * Whether the thumb is pressed or not.
	 */
	public function pressed():Bool
	{
		return status == PRESSED;
	}
	
	/**
	 * Whether the thumb is just pressed or not.
	 */
	public function justPressed():Bool
	{
		#if !FLX_NO_TOUCH
		return _currentTouch.justPressed() && status == PRESSED;
		#end
		#if !FLX_NO_MOUSE
		return FlxG.mouse.justPressed() && status == PRESSED;
		#end
	}
	
	/**
	 * Whether the thumb is just released or not.
	 */
	public function justReleased():Bool
	{
		#if !FLX_NO_TOUCH
		return _currentTouch.justReleased() && status == HIGHLIGHT;
		#end
		#if !FLX_NO_MOUSE
		return FlxG.mouse.justReleased() && status == HIGHLIGHT;
		#end
	}

	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the analog.
	 * @param Alpha
	 */
	public function set_alpha(Alpha:Float):Void
	{
		_base.alpha = Alpha;
		_stick.alpha = Alpha;
	}
	
}
