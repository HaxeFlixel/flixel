package flixel.ui;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;

@:bitmap("assets/images/ui/analog/base.png")  private class GraphicBase  extends BitmapData {}
@:bitmap("assets/images/ui/analog/thumb.png") private class GraphicThumb extends BitmapData {}

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
	private static inline var NORMAL:Int = 0;
	/**
	 * Used with public variable status, means highlighted (usually from mouse over).
	 */ 
	private static inline var HIGHLIGHT:Int = 1;
	/**
	 * Used with public variable status, means pressed (usually from mouse click).
	 */ 
	private static inline var PRESSED:Int = 2;
	
	/**
	 * A list of analogs that are currently active.
	 */ 
	private static var _analogs:Array<FlxAnalog>;
	
	#if !FLX_NO_TOUCH
	/**
	 * The current pointer that's active on the analog.
	 */ 
	private var _currentTouch:FlxTouch;
	/**
	 * Helper array for checking touches
	 */ 
	private var _tempTouches:Array<FlxTouch>;
	#end
	
	/**
	 * The area which the joystick will react.
	 */
	private var _zone:FlxRect;
	
	/**
	 * The radius in which the stick can move.
	 */ 
	private var _radius:Float;
	private var _direction:Float = 0;
	private var _amount:Float = 0;		
	/**
	 * The speed of easing when the thumb is released.
	 */ 
	private var _ease:Float;
	
	/**
	 * Create a virtual thumbstick - useful for input on mobile devices.
	 *  
	 * @param	X		The X-coordinate of the point in space.
 	 * @param	Y		The Y-coordinate of the point in space.
 	 * @param	radius	The radius where the thumb can move. If 0, the background will be use as radius.
 	 * @param	ease	The duration of the easing. The value must be between 0 and 1.
	 */
	public function new(X:Float, Y:Float, Radius:Float = 0, Ease:Float = 0.25)
	{
		_zone = new FlxRect();
		
		super();
		
		_radius = Radius;
		_ease = Ease;
		
		if (_analogs == null)
		{
			_analogs = new Array<FlxAnalog>();
		}
		_analogs.push(this);
		
		acceleration = new FlxPoint();
		#if !FLX_NO_TOUCH
		_tempTouches = [];
		#end
		_point = new FlxPoint();
		
		createBase();
		createThumb();
		
		x = X;
		y = Y;
	}
	
	/**
	 * Creates the background of the analog stick.
	 * Override this to customize the background.
	 */
	private function createBase():Void
	{
		base = new FlxSprite(x, y);
		base.loadGraphic(GraphicBase);
		base.x += -base.width * 0.5;
		base.y += -base.height * 0.5;
		base.scrollFactor.set();
		base.solid = false;
		
		#if !FLX_NO_DEBUG
		base.ignoreDrawDebug = true;
		#end
		
		add(base);	
	}
	
	/**
	 * Creates the thumb of the analog stick.
	 * Override this to customize the thumb.
	 */
	private function createThumb():Void 
	{
		thumb = new FlxSprite(x, y);
		thumb.loadGraphic(GraphicThumb);
		thumb.scrollFactor.set();
		thumb.solid = false;
		
		#if !FLX_NO_DEBUG
		thumb.ignoreDrawDebug = true;
		#end
		
		add(thumb);
	}
	
	/**
	 * Creates the touch zone. It's based on the size of the background. 
	 * The thumb will react when the mouse is in the zone.
	 * Override this to customize the zone.
	 */
	private function createZone():Void
	{
		if (base != null)			
		{
			_radius = base.width / 2;
		}
		
		_zone.set(x - _radius, y - _radius, 2 * _radius, 2 * _radius);
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
		thumb = null;
		base = null;
		_zone = null;
		_point = null;
		
		#if !FLX_NO_TOUCH
		_currentTouch = null;
		_tempTouches = null;
		#end
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
				for (touch in FlxG.touches.list)
				{		
					var touchInserted:Bool = false;
					
					for (analog in _analogs)
					{
						// Check whether the pointer is already taken by another analog.
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
				
				if (updateAnalog(_point, touch.pressed, touch.justPressed, touch.justReleased, touch) == false)
				{
					offAll = false;
					break;
				}
			}
		#end
		
		#if !FLX_NO_MOUSE
			_point.set(FlxG.mouse.screenX, FlxG.mouse.screenY);
			
			if (updateAnalog(_point, FlxG.mouse.pressed, FlxG.mouse.justPressed, FlxG.mouse.justReleased) == false)
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
		
		thumb.x = x + Math.cos(_direction) * _amount * _radius - (thumb.width * 0.5);
		thumb.y = y + Math.sin(_direction) * _amount * _radius - (thumb.height * 0.5);
		
		if (offAll)
		{
			status = NORMAL;
		}
		
		#if !FLX_NO_TOUCH
		_tempTouches.splice(0, _tempTouches.length);
		#end
		
		super.update();
	}
	
	private function updateAnalog(TouchPoint:FlxPoint, Pressed:Bool, JustPressed:Bool, JustReleased:Bool, ?Touch:FlxTouch):Bool
	{
		var offAll:Bool = true;
		
		#if !FLX_NO_TOUCH
		// Use the touch to figure out the world position if it's passed in, as 
		// the screen coordinates passed in touchPoint are wrong
		// if the control is used in a group, for example.
		if (Touch != null)
		{
			TouchPoint.set(Touch.screenX, Touch.screenY);
		}
		#end
		
		if (_zone.containsFlxPoint(TouchPoint) || (status == PRESSED))
		{
			offAll = false;
			
			if (Pressed)
			{
				#if !FLX_NO_TOUCH
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
					
					acceleration.x = Math.cos(_direction) * _amount * _radius;
					acceleration.y = Math.sin(_direction) * _amount * _radius;			
				}					
			}
			else if (JustReleased && status == PRESSED)
			{				
				#if !FLX_NO_TOUCH
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
	 * 
	 * @return	The angle.
	 */
	public function getAngle():Float
	{
		return Math.atan2(acceleration.y, acceleration.x) * FlxAngle.TO_DEG;
	}
	
	/**
	 * Whether the thumb is pressed or not.
	 */
	public var pressed(get, never):Bool;
	
	private inline function get_pressed():Bool
	{
		return status == PRESSED;
	}
	
	/**
	 * Whether the thumb is just pressed or not.
	 */
	public var justPressed(get, never):Bool;
	
	private function get_justPressed():Bool
	{
		#if !FLX_NO_TOUCH
		if (_currentTouch != null)
		{
			return _currentTouch.justPressed && status == PRESSED;
		}
		#end
		
		#if !FLX_NO_MOUSE
		return FlxG.mouse.justPressed && status == PRESSED;
		#end
		
		return false;
	}
	
	/**
	 * Whether the thumb is just released or not.
	 */
	public var justReleased(get, never):Bool;
	
	private function get_justReleased():Bool
	{
		#if !FLX_NO_TOUCH
		if (_currentTouch != null)
		{
			return _currentTouch.justReleased && status == HIGHLIGHT;
		}
		#end
		
		#if !FLX_NO_MOUSE
		return FlxG.mouse.justReleased && status == HIGHLIGHT;
		#end
		
		return false;
	}
	
	override public function set_x(X:Float):Float
	{
		super.set_x(X);
		createZone();
		
		return X;
	}
	
	override public function set_y(Y:Float):Float
	{
		super.set_y(Y);
		createZone();
		
		return Y;
	}
}