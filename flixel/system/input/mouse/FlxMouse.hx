package flixel.system.input.mouse;

import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.Vector;
import flash.ui.MouseCursorData;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.input.IFlxInput;
import flixel.system.replay.MouseRecord;
import flixel.util.FlxPoint;

/**
* This class helps contain and track the mouse pointer in your game.
* Automatically accounts for parallax scrolling, etc.
*/
class FlxMouse extends FlxPoint implements IFlxInput
{
	/**
	 * Current "delta" value of mouse wheel. If the wheel was just scrolled up, it will have a positive value. 
	 * If it was just scrolled down, it will have a negative value. If it wasn't just scroll this frame, it will be 0.
	 */
	public var wheel:Int = 0;
	/**
	 * Current X position of the mouse pointer on the screen.
	 */
	public var screenX:Int = 0;
	/**
	 * Current Y position of the mouse pointer on the screen.
	 */
	public var screenY:Int = 0;
	/**
	 * Property to check if the cursor is visible or not.
	 */
	public var visible(get_visible, null):Bool;

	/**
	 * The left mouse button.
	 */
	private var _leftButton:FlxMouseButton;
	
	#if (FLX_MOUSE_ADVANCED && !js)
	/**
	 * The middle mouse button.
	 */
	private var _middleButton:FlxMouseButton;
	/**
	 * The right mouse button.
	 */
	private var _rightButton:FlxMouseButton;
	#end
	
	/**
	 * A display container for the mouse cursor.
	 * This container is a child of FlxGame and sits at the right "height".
	 */
	public var cursorContainer:Sprite;
	/**
	 * Don't update cursor unless we have to (this is essentially a "visible" bool, 
	 * so we avoid checking the visible property in the Sprite which is slow in cpp).
	 */
	private var _updateCursorContainer:Bool;
	/**
	 * This is just a reference to the current cursor image, if there is one.
	 */
	private var _cursor:Bitmap = null;
	
	private var _cursorBitmapData:BitmapData;

	private var _wheelUsed:Bool = false;
	
	/**
	 * Helper variables for recording purposes.
	 */
	private var _lastX:Int = 0;
	private var _lastY:Int = 0;
	private var _lastWheel:Int = 0;
	private var _point:FlxPoint;
	private var _globalScreenPosition:FlxPoint;
	
	/**
	 * Names for the Native Flash 10.2 Cursors
	 */
	#if (flash && !FLX_NO_NATIVE_CURSOR)
	private var _cursorDefaultName:String = "defaultCursor";
	private var _currentNativeCursor:String;
	private var _previousNativeCursor:String;
	#end

	/**
	 * Constructor.
	 */
	public function new(CursorContainer:Sprite)
	{
		super();
		
		cursorContainer = CursorContainer;
		cursorContainer.mouseChildren = false;
		cursorContainer.mouseEnabled = false;
		_point = new FlxPoint();
		_globalScreenPosition = new FlxPoint();
		
		_leftButton = new FlxMouseButton(true);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, _leftButton.onDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, _leftButton.onUp);
		
		#if (FLX_MOUSE_ADVANCED && !js)
		_middleButton = new FlxMouseButton();
		_rightButton = new FlxMouseButton();
		Lib.current.stage.addEventListener(untyped MouseEvent.MIDDLE_MOUSE_DOWN, _middleButton.onDown);
		Lib.current.stage.addEventListener(untyped MouseEvent.MIDDLE_MOUSE_UP, _middleButton.onUp);
		Lib.current.stage.addEventListener(untyped MouseEvent.RIGHT_MOUSE_DOWN, _rightButton.onDown);
		Lib.current.stage.addEventListener(untyped MouseEvent.RIGHT_MOUSE_UP, _rightButton.onUp);
		#end
		
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
	}

	/**
	 * Internal event handler for input and focus.
	 * @param FlashEvent Flash mouse event.
	 */
	private function onMouseWheel(FlashEvent:MouseEvent):Void
	{
		#if !FLX_NO_DEBUG
		if ((FlxG.debugger.visible && FlxG.game.debugger.hasMouse) 
			#if (FLX_RECORD) || FlxG.game.replaying #end)
		{
			return;
		}
		#end
		
		_wheelUsed = true;
		wheel = FlashEvent.delta;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		cursorContainer = null;
		_cursor = null;
		_point = null;
		_globalScreenPosition = null;
		
		if (_cursorBitmapData != null)
		{
			_cursorBitmapData.dispose();
			_cursorBitmapData = null;
		}
	}

	/**
	 * Either show an existing cursor or load a new one.
	 * @param 	Graphic 	The image you want to use for the cursor.
	 * @param 	Scale 		Change the size of the cursor. Default = 1, or native size. 2 = 2x as big, 0.5 = half size, etc.
	 * @param 	XOffset 	The number of pixels between the mouse's screen position and the graphic's top left corner.
	 * @param 	YOffset 	The number of pixels between the mouse's screen position and the graphic's top left corner.
	 */
	public function show(?Graphic:Dynamic, Scale:Float = 1, XOffset:Int = 0, YOffset:Int = 0):Void
	{
		_updateCursorContainer = true;
		cursorContainer.visible = true;
		
		if (Graphic != null)
		{
			load(Graphic, Scale, XOffset, YOffset);
		}
		else if (_cursor == null)
		{
			load();
		}
		if (useSystemCursor)
		{
			Mouse.show();
		}
	}

	/**
	 * Hides the mouse cursor
	 */
	inline public function hide():Void
	{
		_updateCursorContainer = false;
		cursorContainer.visible = false;
	}

	/**
	 * Read only, check visibility of mouse cursor.
	 */
	inline private function get_visible():Bool
	{
		return _updateCursorContainer;
	}

	/**
	 * Load a new mouse cursor graphic
	 * @param 	Graphic 	The image you want to use for the cursor.
	 * @param 	Scale 		Change the size of the cursor.
	 * @param 	XOffset 	The number of pixels between the mouse's screen position and the graphic's top left corner.
	 * @param 	YOffset 	The number of pixels between the mouse's screen position and the graphic's top left corner.
	 */
	public function load(?Graphic:Dynamic, Scale:Float = 1, XOffset:Int = 0, YOffset:Int = 0):Void
	{
		#if (!flash || FLX_NO_NATIVE_CURSOR)
		if (_cursor != null)
		{
			cursorContainer.removeChild(_cursor);
		}
		#end
		
		if (Graphic == null)
		{
			Graphic = FlxAssets.IMG_CURSOR;
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
			_cursor = new Bitmap(FlxAssets.getBitmapData(Graphic));
		}
		else
		{
			_cursor = new Bitmap(FlxAssets.getBitmapData(FlxAssets.IMG_CURSOR));
		}
		
		_cursor.x = XOffset;
		_cursor.y = YOffset;
		_cursor.scaleX = Scale;
		_cursor.scaleY = Scale;
		
		#if (flash && !FLX_NO_NATIVE_CURSOR)
		setSimpleNativeCursorData(_cursorDefaultName, _cursor.bitmapData);
		#else
		cursorContainer.addChild(_cursor);
		#end
	}

	/**
	 * Unload the current cursor graphic. If the current cursor is visible,
	 * then the default system cursor is loaded up to replace the old one.
	 */
	public function unload():Void
	{
		if (_cursor != null)
		{
			if (cursorContainer.visible)
			{
				load();
			}
			else
			{
				cursorContainer.removeChild(_cursor);
				_cursor = null;
			}
		}
	}

	#if (flash && !FLX_NO_NATIVE_CURSOR)
	/**
	 * Set a Native cursor that has been registered by Name
	 * Warning, you need to use registerNativeCursor before you use it here
	 * @param 	Name 	The name ID used when registered
	 */
	public function setNativeCursor(Name:String):Void
	{
		if(_currentNativeCursor != Name)
		{
			_previousNativeCursor = _currentNativeCursor;
			_currentNativeCursor = Name;
			Mouse.cursor = _currentNativeCursor;
		}
	}

	/**
	 * Shortcut to register a Native cursor for > Flash 10.2
	 * @param  Name       The ID name used for the cursor
	 * @param  CursorData MouseCursorData contains the bitmap, hotspot etc
	 */
	inline public function registerNativeCursor(Name:String, CursorData:MouseCursorData):Void
	{
		untyped Mouse.registerCursor(Name, CursorData);
	}

	/**
	 * Shortcut to create and set a simple MouseCursorData
	 * @param  Name       The ID name used for the cursor
	 * @param  CursorData MouseCursorData contains the bitmap, hotspot etc
	 */
	public function setSimpleNativeCursorData(Name:String, CursorBitmap:BitmapData):MouseCursorData
	{
		var cursorVector = new Vector<BitmapData>();
		cursorVector[0] = CursorBitmap;
		
		if(_cursor.bitmapData.width > 32 ||_cursor.bitmapData.height > 32)
		{
			FlxG.log.warn ("Bitmap files used for the cursors should not exceed 32 × 32 pixels, due to an OS limitation.");
		}
		
		var cursorData = new MouseCursorData();
		cursorData.hotSpot = new Point(0, 0);
		cursorData.data = cursorVector;
		
		registerNativeCursor( Name, cursorData );
		setNativeCursor( Name );
		
		Mouse.show();
		
		return cursorData;
	}
	#end

	/**
	 * Called by the internal game loop to update the mouse pointer's position in the game world.
	 * Also updates the just pressed/just released flags.
	 * @param 	X 	The current X position of the mouse in the window.
	 * @param 	Y 	The current Y position of the mouse in the window.
	 */
	public function update():Void
	{
		var X = Math.floor(FlxG.game.mouseX);
		var Y = Math.floor(FlxG.game.mouseY);
		
		_globalScreenPosition.x = X;
		_globalScreenPosition.y = Y;
		updateCursor();
		
		// Update the button states
		_leftButton.update();
		
		#if (FLX_MOUSE_ADVANCED && !js)
		_middleButton.update();
		_rightButton.update();
		#end
		
		if (!_wheelUsed)
		{
			wheel = 0;
		}
		_wheelUsed = false;
	}

	/**
	 * Internal function for helping to update the mouse cursor and world coordinates.
	 */
	private function updateCursor():Void
	{
		//actually position the flixel mouse cursor graphic
		if (_updateCursorContainer)
		{
			cursorContainer.x = _globalScreenPosition.x;
			cursorContainer.y = _globalScreenPosition.y;
		}
		
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
	 * @param 	Camera 	If unspecified, first/main global camera is used instead.
	 * @param 	point 	An existing point object to store the results (if you don't want a new one created).
	 * @return 	The mouse's location in world space.
	 */
	public function getWorldPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
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
	 * @param 	Camera 	If unspecified, first/main global camera is used instead.
	 * @param 	point 	An existing point object to store the results (if you don't want a new one created).
	 * @return 	The mouse's location in screen space.
	 */
	public function getScreenPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = (_globalScreenPosition.x - Camera.x) / Camera.zoom;
		point.y = (_globalScreenPosition.y - Camera.y) / Camera.zoom;
		return point;
	}

	/**
	 * Resets the just pressed/just released flags and sets mouse to not pressed.
	 */
	public function reset():Void
	{
		_leftButton.reset();
		
		#if (FLX_MOUSE_ADVANCED && !js)
		_middleButton.reset();
		_rightButton.reset();
		#end
	}

	/**
	 * Check to see if the mouse is pressed.
	 * @return 	Whether the mouse is pressed.
	 */
	inline public function pressed():Bool { return _leftButton.pressed(); }

	/**
	 * Check to see if the mouse was just pressed.
	 * @return 	Whether the mouse was just pressed.
	 */
	inline public function justPressed():Bool { return _leftButton.justPressed(); }

	/**
	 * Check to see if the mouse was just released.
	 * @return 	Whether the mouse was just released.
	 */
	inline public function justReleased():Bool { return _leftButton.justReleased(); }

	#if (FLX_MOUSE_ADVANCED && !js)
	/**
	 * Check to see if the right mouse button is pressed.
	 * Requires the <code>FLX_MOUSE_ADVANCED</code> flag in the .nmml to be set.
	 * @return 	Whether the right mouse button is pressed.
	 */
	inline public function pressedRight():Bool { return _rightButton.pressed(); }

	/**
	 * Check to see if the right mouse button was just pressed.
	 * Requires the <code>FLX_MOUSE_ADVANCED</code> flag in the .nmml to be set.
	 * @return 	Whether the right mouse button was just pressed.
	 */
	inline public function justPressedRight():Bool { return _rightButton.justPressed(); }

	/**
	 * Check to see if the right mouse button was just released.
	 * Requires the <code>FLX_MOUSE_ADVANCED</code> flag in the .nmml to be set.
	 * @return 	Whether the right mouse button was just released.
	 */
	inline public function justReleasedRight():Bool { return _rightButton.justReleased(); }

	/**
	 * Check to see if the middle mouse button is pressed.
	 * Requires the <code>FLX_MOUSE_ADVANCED</code> flag in the .nmml to be set.
	 * @return 	Whether the middle mouse button is pressed.
	 */
	inline public function pressedMiddle():Bool { return _middleButton.pressed(); }

	/**
	 * Check to see if the middle mouse button was just pressed.
	 * Requires the <code>FLX_MOUSE_ADVANCED</code> flag in the .nmml to be set.
	 * @return 	Whether the middle mouse button was just pressed.
	 */
	inline public function justPressedMiddle():Bool { return _middleButton.justPressed();  }

	/**
	 * Check to see if the middle mouse button was just released.
	 * Requires the <code>FLX_MOUSE_ADVANCED</code> flag in the .nmml to be set.
	 * @return 	Whether the middle mouse button was just released.
	 */
	inline public function justReleasedMiddle():Bool { return _middleButton.justReleased(); }
	#end

	/**
	 * If the mouse changed state or is pressed, return that info now
	 * @return An array of key state data. Null if there is no data.
	 */
	public function record():MouseRecord
	{
		if ((_lastX == _globalScreenPosition.x) && (_lastY == _globalScreenPosition.y) && (_leftButton.current == 0) && (_lastWheel == wheel))
		{
			return null;
		}
		_lastX = Math.floor(_globalScreenPosition.x);
		_lastY = Math.floor(_globalScreenPosition.y);
		_lastWheel = wheel;
		return new MouseRecord(_lastX, _lastY, _leftButton.current, _lastWheel);
	}

	/**
	 * Part of the keystroke recording system.
	 * Takes data about key presses and sets it into array.
	 * @param KeyStates Array of data about key states.
	 */
	public function playback(Record:MouseRecord):Void
	{
		_leftButton.current = Record.button;
		wheel = Record.wheel;
		_globalScreenPosition.x = Record.x;
		_globalScreenPosition.y = Record.y;
		updateCursor();
	}

	/**
	 * Called from the main Event.ACTIVATE is dispatched in FlxGame
	 */
	inline public function onFocus():Void
	{
		reset();
		useSystemCursor = useSystemCursor;
	}

	/**
	 * Called from the main Event.DEACTIVATE is dispatched in FlxGame
	 */
	inline public function onFocusLost():Void
	{
		Mouse.show();
	}

	/**
	 * Show the default system cursor, if Flash 10.2 return to AUTO
	 */
	private function showSystemCursor():Void
	{
		#if (flash && !FLX_NO_NATIVE_CURSOR)
		setNativeCursor(MouseCursor.AUTO);
		#else
		Mouse.show();
		cursorContainer.visible = false;
		#end
	}

	/**
	 * Hide the system cursor, if Flash 10.2 return to default
	 */
	private function hideSystemCursor():Void
	{
		#if (flash && !FLX_NO_NATIVE_CURSOR)
		if(Mouse.supportsCursor && _previousNativeCursor != null)
		{
			setNativeCursor(_previousNativeCursor);
		}
		#else
		Mouse.hide();
		cursorContainer.visible = true;
		#end
	}
	
	/**
	 * Tells flixel to use the default system mouse cursor instead of custom Flixel mouse cursors.
	 * @default false
	 */
	public var useSystemCursor(default, set):Bool = false;
	
	private function set_useSystemCursor(value:Bool):Bool
	{
		useSystemCursor = value;
		if (!useSystemCursor)
		{
			hideSystemCursor();
		} 
		else 
		{
			showSystemCursor();
		}
		return value;
	}
}