package org.flixel.system.input;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.MouseEvent;
import org.flixel.FlxAssets;

import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxU;
import org.flixel.system.replay.MouseRecord;

/**
 * This class helps contain and track the mouse pointer in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
class Mouse extends FlxPoint
{

	/**
	 * Current "delta" value of mouse wheel.  If the wheel was just scrolled up, it will have a positive value.  If it was just scrolled down, it will have a negative value.  If it wasn't just scroll this frame, it will be 0.
	 */
	public var wheel:Int;
	/**
	 * Current X position of the mouse pointer on the screen.
	 */
	public var screenX:Int;
	/**
	 * Current Y position of the mouse pointer on the screen.
	 */
	public var screenY:Int;
	
	/**
	 * Helper variable for tracking whether the mouse was just pressed or just released.
	 */
	private var _current:Int;
	/**
	 * Helper variable for tracking whether the mouse was just pressed or just released.
	 */
	private var _last:Int;
	/**
	 * A display container for the mouse cursor.
	 * This container is a child of FlxGame and sits at the right "height".
	 */
	private var _cursorContainer:Sprite;
	/**
	 * This is just a reference to the current cursor image, if there is one.
	 */
	private var _cursor:Bitmap;
	/**
	 * Helper variables for recording purposes.
	 */
	private var _lastX:Int;
	private var _lastY:Int;
	private var _lastWheel:Int;
	private var _point:FlxPoint;
	private var _globalScreenPosition:FlxPoint;
	
	/**
	 * Constructor.
	 */
	public function new(CursorContainer:Sprite)
	{
		super();
		_cursorContainer = CursorContainer;
		_lastX = screenX = 0;
		_lastY = screenY = 0;
		_lastWheel = wheel = 0;
		_current = 0;
		_last = 0;
		_cursor = null;
		_point = new FlxPoint();
		_globalScreenPosition = new FlxPoint();
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_cursorContainer = null;
		_cursor = null;
		_point = null;
		_globalScreenPosition = null;
	}
	
	/**
	 * Either show an existing cursor or load a new one.
	 * @param	Graphic		The image you want to use for the cursor.
	 * @param	Scale		Change the size of the cursor.  Default = 1, or native size.  2 = 2x as big, 0.5 = half size, etc.
	 * @param	XOffset		The number of pixels between the mouse's screen position and the graphic's top left corner.
	 * @param	YOffset		The number of pixels between the mouse's screen position and the graphic's top left corner. 
	 */
	public function show(?Graphic:Class<Bitmap> = null, ?Scale:Float = 1, ?XOffset:Int = 0, ?YOffset:Int=0):Void
	{
		_cursorContainer.visible = true;
		if (Graphic != null)
		{
			load(Graphic, Scale, XOffset, YOffset);
		}
		else if (_cursor == null)
		{
			load();
		}
	}
	
	/**
	 * Hides the mouse cursor
	 */
	public function hide():Void
	{
		_cursorContainer.visible = false;
	}
	
	public var visible(getVisible, null):Bool;
	
	/**
	 * Read only, check visibility of mouse cursor.
	 */
	public function getVisible():Bool
	{
		return _cursorContainer.visible;
	}
	
	/**
	 * Load a new mouse cursor graphic
	 * @param	Graphic		The image you want to use for the cursor.
	 * @param	Scale		Change the size of the cursor.
	 * @param	XOffset		The number of pixels between the mouse's screen position and the graphic's top left corner.
	 * @param	YOffset		The number of pixels between the mouse's screen position and the graphic's top left corner. 
	 */
	public function load(?Graphic:Dynamic = null, ?Scale:Float = 1, ?XOffset:Int=0, ?YOffset:Int=0):Void
	{
		if (_cursor != null)
		{
			_cursorContainer.removeChild(_cursor);
		}
		
		if (Graphic == null)
		{
			Graphic = FlxAssets.imgDefaultCursor;
		}
		
		if (Std.is(Graphic, Class))
		{
			_cursor = Type.createInstance(Graphic, []);
		}
		else if (Std.is(Graphic, BitmapData))
		{
			_cursor = new Bitmap(cast(Graphic, BitmapData));
		}
		else if (Std.is(Graphic, String))
		{
			_cursor = new Bitmap(Assets.getBitmapData(Graphic));
		}
		else
		{
			_cursor = new Bitmap(Assets.getBitmapData(FlxAssets.imgDefaultCursor));
		}
		
		_cursor.x = XOffset;
		_cursor.y = YOffset;
		_cursor.scaleX = Scale;
		_cursor.scaleY = Scale;
		
		_cursorContainer.addChild(_cursor);
	}
	
	/**
	 * Unload the current cursor graphic.  If the current cursor is visible,
	 * then the default system cursor is loaded up to replace the old one.
	 */
	public function unload():Void
	{
		if(_cursor != null)
		{
			if (_cursorContainer.visible)
			{
				load();
			}
			else
			{
				_cursorContainer.removeChild(_cursor);
				_cursor = null;
			}
		}
	}

	/**
	 * Called by the internal game loop to update the mouse pointer's position in the game world.
	 * Also updates the just pressed/just released flags.
	 * @param	X			The current X position of the mouse in the window.
	 * @param	Y			The current Y position of the mouse in the window.
	 * @param	XScroll		The amount the game world has scrolled horizontally.
	 * @param	YScroll		The amount the game world has scrolled vertically.
	 */
	public function update(X:Int,Y:Int):Void
	{
		_globalScreenPosition.x = X;
		_globalScreenPosition.y = Y;
		updateCursor();
		if ((_last == -1) && (_current == -1))
		{
			_current = 0;
		}
		else if ((_last == 2) && (_current == 2))
		{
			_current = 1;
		}
		_last = _current;
	}
	
	/**
	 * Internal function for helping to update the mouse cursor and world coordinates.
	 */
	private function updateCursor():Void
	{
		//actually position the flixel mouse cursor graphic
		_cursorContainer.x = _globalScreenPosition.x;
		_cursorContainer.y = _globalScreenPosition.y;
		
		//update the x, y, screenX, and screenY variables based on the default camera.
		//This is basically a combination of getWorldPosition() and getScreenPosition()
		var camera:FlxCamera = FlxG.camera;
		screenX = Math.floor((_globalScreenPosition.x - camera.x)/camera.zoom);
		screenY = Math.floor((_globalScreenPosition.y - camera.y)/camera.zoom);
		x = screenX + camera.scroll.x;
		y = screenY + camera.scroll.y;
	}
	
	/**
	 * Fetch the world position of the mouse on any given camera.
	 * NOTE: Mouse.x and Mouse.y also store the world position of the mouse cursor on the main camera.
	 * @param Camera	If unspecified, first/main global camera is used instead.
	 * @param point		An existing point object to store the results (if you don't want a new one created). 
	 * @return The mouse's location in world space.
	 */
	public function getWorldPosition(?Camera:FlxCamera = null, ?point:FlxPoint = null):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = new FlxPoint();
		}
		getScreenPosition(Camera,_point);
		point.x = _point.x + Camera.scroll.x;
		point.y = _point.y + Camera.scroll.y;
		return point;
	}
	
	/**
	 * Fetch the screen position of the mouse on any given camera.
	 * NOTE: Mouse.screenX and Mouse.screenY also store the screen position of the mouse cursor on the main camera.
	 * @param Camera	If unspecified, first/main global camera is used instead.
	 * @param point		An existing point object to store the results (if you don't want a new one created). 
	 * @return The mouse's location in screen space.
	 */
	public function getScreenPosition(?Camera:FlxCamera = null, ?point:FlxPoint = null):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = (_globalScreenPosition.x - Camera.x)/Camera.zoom;
		point.y = (_globalScreenPosition.y - Camera.y)/Camera.zoom;
		return point;
	}
	
	/**
	 * Resets the just pressed/just released flags and sets mouse to not pressed.
	 */
	public function reset():Void
	{
		_current = 0;
		_last = 0;
	}
	
	/**
	 * Check to see if the mouse is pressed.
	 * @return	Whether the mouse is pressed.
	 */
	public function pressed():Bool { return _current > 0; }
	
	/**
	 * Check to see if the mouse was just pressed.
	 * @return Whether the mouse was just pressed.
	 */
	public function justPressed():Bool { return _current == 2; }
	
	/**
	 * Check to see if the mouse was just released.
	 * @return	Whether the mouse was just released.
	 */
	public function justReleased():Bool { return _current == -1; }
	
	/**
	 * Event handler so FlxGame can update the mouse.
	 * @param	FlashEvent	A <code>MouseEvent</code> object.
	 */
	public function handleMouseDown(FlashEvent:MouseEvent):Void
	{
		if(_current > 0) _current = 1;
		else _current = 2;
	}
	
	/**
	 * Event handler so FlxGame can update the mouse.
	 * @param	FlashEvent	A <code>MouseEvent</code> object.
	 */
	public function handleMouseUp(FlashEvent:MouseEvent):Void
	{
		if(_current > 0) _current = -1;
		else _current = 0;
	}
	
	/**
	 * Event handler so FlxGame can update the mouse.
	 * 
	 * @param	FlashEvent	A <code>MouseEvent</code> object.
	 */
	public function handleMouseWheel(FlashEvent:MouseEvent):Void
	{
		wheel = FlashEvent.delta;
	}
	
	/**
	 * If the mouse changed state or is pressed, return that info now
	 * @return	An array of key state data.  Null if there is no data.
	 */
	public function record():MouseRecord
	{
		if ((_lastX == _globalScreenPosition.x) && (_lastY == _globalScreenPosition.y) && (_current == 0) && (_lastWheel == wheel))
		{
			return null;
		}
		_lastX = Math.floor(_globalScreenPosition.x);
		_lastY = Math.floor(_globalScreenPosition.y);
		_lastWheel = wheel;
		return new MouseRecord(_lastX,_lastY,_current,_lastWheel);
	}
	
	/**
	 * Part of the keystroke recording system.
	 * Takes data about key presses and sets it into array.
	 * @param	KeyStates	Array of data about key states.
	 */
	public function playback(Record:MouseRecord):Void
	{
		_current = Record.button;
		wheel = Record.wheel;
		_globalScreenPosition.x = Record.x;
		_globalScreenPosition.y = Record.y;
		updateCursor();
	}
}