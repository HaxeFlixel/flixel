package flixel.effects.fx; 

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;

/**
* BaseFX - Special FX Plugin
* 
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/
class BaseFX 
{
	/**
	 * Set to false to stop this effect being updated by the FlxSpecialFX Plugin. Set to true to enable.
	 */
	public var active:Bool;
	/**
	 * The FlxSprite into which the effect is drawn. Add this to your FlxState / FlxGroup to display the effect.
	 */
	public var sprite:FlxSprite;
	
	#if flash
	/**
	 * A scratch bitmapData used to build-up the effect before passing to sprite.pixels
	 */
	public var canvas:BitmapData;
	
	/**
	 * TODO A snapshot of the sprite background before the effect is applied
	 */
	public var back:BitmapData;
	#end
	
	private var _image:BitmapData;
	private var _sourceRef:FlxSprite;
	private var _updateFromSource:Bool;
	private var _clsRect:Rectangle;
	private var _clsPoint:Point;
	private var _clsColor:Int;

	// For staggered drawing updates
	private var _updateLimit:Int;
	private var _lastUpdate:Int;
	private var _ready:Bool;
	
	private var _copyRect:Rectangle;
	private var _copyPoint:Point;
	
	public function new() 
	{
		_updateLimit = 0;
		_lastUpdate = 0;
		_ready = false;
		active = false;
	}
	
	/**
	 * Starts the effect runnning
	 * 
	 * @param	Delay	How many "game updates" should pass between each update? If your game runs at 30fps a value of 0 means it will do 30 updates per second. A value of 1 means it will do 15 updates per second, etc.
	 */
	public function start(Delay:Int = 0):Void
	{
		_updateLimit = Delay;
		_lastUpdate = 0;
		_ready = true;
	}
	
	/**
	 * Pauses the effect from running. The draw function is still called each loop, but the pixel data is stopped from updating.<br>
	 * To disable the SpecialFX Plugin from calling the FX at all set the "active" parameter to false.
	 */
	public function stop():Void
	{
		_ready = false;
	}
	
	public function draw():Void
	{
		
	}
	
	public function destroy():Void
	{
		if (sprite != null)
		{
			sprite.kill();
		}
		
		#if flash
		if (canvas != null)
		{
			canvas.dispose();
		}
		
		if (back != null)
		{
			back.dispose();
		}
		#end
		
		if (_image != null)
		{
			_image.dispose();
		}
		
		_sourceRef = null;
		active = false;
	}	
}