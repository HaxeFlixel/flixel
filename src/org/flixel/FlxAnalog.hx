package org.flixel;
import flash.geom.Rectangle;

/**
 * 
 * @author Ka Wing Chin
 */
class FlxAnalog extends FlxGroup
{
	// How fast the speed of this object is changing.	
	private static inline var ACCELERATION:Float = 10;
	
	public var x:Float;
	public var y:Float;
	private var _centerX:Float;
	private var _centerY:Float;

	private var _pad:Rectangle;
	private var _base:FlxSprite;
	public var _stick:FlxSprite;
	
	public var accel:FlxPoint;
	public var pressed:Bool;
	private var yMin:Float;
	private var yMax:Float;
	private var xMin:Float;
	private var xMax:Float;
		
	/**
	 * Constructor
	 * @param X		The x-position of the analog stick
	 * @param Y		The y-position of the analog stick.
	 */
	public function new(X:Float, Y:Float)
	{
		super();
		
		accel = new FlxPoint();
		x = X;
		y = Y;		
		
		yMin = 0 - 24 + y;
		yMax = 100 - 24 + y;
		xMin = 0 - 24 + x;
		xMax = 100 - 24 + x;
		
		_pad = new Rectangle(x, y, 100, 100);
		_centerX = X + _pad.width * 0.25;
		_centerY = Y + _pad.width * 0.25;
		
		_base = new FlxSprite(X, Y, FlxAssets.imgBase);
		_base.cameras = [FlxG.camera];
		_base.scrollFactor.x = _base.scrollFactor.y = 0;
		_base.solid = false;
		_base.ignoreDrawDebug = true;
		add(_base);
		
		_stick = new FlxSprite(_centerX, _centerY, FlxAssets.imgStick);
		_stick.cameras = [FlxG.camera];
		_stick.scrollFactor.x = _stick.scrollFactor.y = 0;
		_stick.width = _stick.height = 48;
		_stick.offset.x = 20; 
		_stick.offset.y = 3;
		_stick.solid = false;
		_stick.ignoreDrawDebug = true;
		add(_stick);
	}
	
	override public function update():Void 
	{
		if (FlxG.mouse.pressed())
		{
			if (_pad.contains(FlxG.mouse.screenX, FlxG.mouse.screenY) || pressed)
			{
				pressed = true;
				_stick.x = FlxG.mouse.screenX - _stick.width * 0.5;
				_stick.y = FlxG.mouse.screenY - _stick.height * 0.5;
				
				if (_stick.y <= yMin)
				{
					_stick.y = yMin;
				}
				if (_stick.y >= yMax)
				{
					_stick.y = yMax;
				}
				if (_stick.x <= xMin)
				{
					_stick.x = xMin;
				}
				if (_stick.x >= xMax)
				{
					_stick.x = xMax;
				}
				
				accel.x = ((74 - (100 - _stick.x)) - x) / ACCELERATION;
				accel.y = ((74 - (100 - _stick.y)) - y) / ACCELERATION;
			}
		}
		else
		{
			pressed = false;			
			_stick.x = _centerX - ((_centerX - _stick.x) / 1.5);
			_stick.y = _centerY - ((_centerY - _stick.y) / 1.5);
			// TODO: add motion to accel when released.
			accel.x = 0;//FlxU.round(((74 - (100 - (_stick.x)))-x) / ACCELERATION);
			accel.y = 0;//FlxU.round(((74 - (100 - (_stick.y)))-y) / ACCELERATION);			
		}
		super.update();
	}
}
