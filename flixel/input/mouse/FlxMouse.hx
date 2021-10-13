package flixel.input.mouse;

#if FLX_MOUSE
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Mouse;
import flixel.FlxG;
import flixel.input.IFlxInputManager;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.system.FlxAssets;
import flixel.system.replay.MouseRecord;
import flixel.util.FlxDestroyUtil;
#if FLX_NATIVE_CURSOR
import flash.Vector;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.ui.MouseCursor;
import flash.ui.MouseCursorData;
#end

@:bitmap("assets/images/ui/cursor.png")
private class GraphicCursor extends BitmapData {}

/**
 * This class helps contain and track the mouse pointer in your game.
 * Automatically accounts for parallax scrolling, etc.
 * Normally accessed via `FlxG.mouse`.
 */
class FlxMouse extends FlxPointer implements IFlxInputManager
{
	/**
	 * Whether or not mouse input is currently enabled.
	 * @since 4.1.0
	 */
	public var enabled:Bool = true;

	/**
	 * Current "delta" value of mouse wheel. If the wheel was just scrolled up,
	 * it will have a positive value and vice versa. Otherwise the value will be 0.
	 */
	public var wheel(default, null):Int = 0;

	/**
	 * A display container for the mouse cursor. It is a child of FlxGame and
	 * sits at the right "height". Not used on flash with the native cursor API.
	 */
	public var cursorContainer(default, null):Sprite;

	/**
	 * Used to toggle the visiblity of the mouse cursor - works on both
	 * the flixel and the system cursor, depending on which one is active.
	 */
	public var visible(default, set):Bool = #if (mobile || switch) false #else true #end;

	/**
	 * Tells flixel to use the default system mouse cursor instead of custom Flixel mouse cursors.
	 */
	public var useSystemCursor(default, set):Bool = false;

	/**
	 * Check to see if the mouse has just been moved.
	 * @since 4.4.0
	 */
	public var justMoved(get, never):Bool;

	/**
	 * Check to see if the left mouse button is currently pressed.
	 */
	public var pressed(get, never):Bool;

	/**
	 * Check to see if the left mouse button has just been pressed.
	 */
	public var justPressed(get, never):Bool;

	/**
	 * Check to see if the left mouse button has just been released.
	 */
	public var justReleased(get, never):Bool;

	/**
	 * Time in ticks of last left mouse button press.
	 * @since 4.3.0
	 */
	public var justPressedTimeInTicks(get, never):Int;

	#if FLX_MOUSE_ADVANCED
	/**
	 * Check to see if the right mouse button is currently pressed.
	 */
	public var pressedRight(get, never):Bool;

	/**
	 * Check to see if the right mouse button has just been pressed.
	 */
	public var justPressedRight(get, never):Bool;

	/**
	 * Check to see if the right mouse button has just been released.
	 */
	public var justReleasedRight(get, never):Bool;

	/**
	 * Time in ticks of last right mouse button press.
	 * @since 4.3.0
	 */
	public var justPressedTimeInTicksRight(get, never):Int;

	/**
	 * Check to see if the middle mouse button is currently pressed.
	 */
	public var pressedMiddle(get, never):Bool;

	/**
	 * Check to see if the middle mouse button has just been pressed.
	 */
	public var justPressedMiddle(get, never):Bool;

	/**
	 * Check to see if the middle mouse button has just been released.
	 */
	public var justReleasedMiddle(get, never):Bool;

	/**
	 * Time in ticks of last middle mouse button press.
	 * @since 4.3.0
	 */
	public var justPressedTimeInTicksMiddle(get, never):Int;
	#end

	/**
	 * The left mouse button.
	 */
	@:allow(flixel.input.mouse.FlxMouseButton)
	var _leftButton:FlxMouseButton;

	#if FLX_MOUSE_ADVANCED
	/**
	 * The middle mouse button.
	 */
	@:allow(flixel.input.mouse.FlxMouseButton)
	var _middleButton:FlxMouseButton;

	/**
	 * The right mouse button.
	 */
	@:allow(flixel.input.mouse.FlxMouseButton)
	var _rightButton:FlxMouseButton;
	#end

	/**
	 * This is just a reference to the current cursor image, if there is one.
	 */
	var _cursor:Bitmap = null;

	var _cursorBitmapData:BitmapData;
	var _wheelUsed:Bool = false;
	var _visibleWhenFocusLost:Bool = true;

	/**
	 * Helper variables for recording purposes.
	 */
	var _lastX:Int = 0;

	var _lastY:Int = 0;
	var _lastWheel:Int = 0;
	var _lastLeftButtonState:FlxInputState;

	/**
	 * Helper variables to see if the mouse has moved since the last update.
	 */
	var _prevX:Int = 0;

	var _prevY:Int = 0;

	// Helper variable for cleaning up memory
	var _stage:Stage;

	/**
	 * Helper variables for flash native cursors
	 */
	#if FLX_NATIVE_CURSOR
	var _cursorDefaultName:String = "defaultCursor";
	var _currentNativeCursor:String;
	var _matrix = new Matrix();
	#end

	/**
	 * Load a new mouse cursor graphic - if you're using native cursors on flash,
	 * check registerNativeCursor() for more control.
	 *
	 * @param   Graphic   The image you want to use for the cursor.
	 * @param   Scale     Change the size of the cursor.
	 * @param   XOffset   The number of pixels between the mouse's screen position and the graphic's top left corner.
	 *                    Has to be positive when using native cursors.
	 * @param   YOffset   The number of pixels between the mouse's screen position and the graphic's top left corner.
	 *                    Has to be positive when using native cursors.
	 */
	public function load(?Graphic:Dynamic, Scale:Float = 1, XOffset:Int = 0, YOffset:Int = 0):Void
	{
		#if !FLX_NATIVE_CURSOR
		if (_cursor != null)
		{
			FlxDestroyUtil.removeChild(cursorContainer, _cursor);
		}
		#end

		if (Graphic == null)
		{
			Graphic = new GraphicCursor(0, 0);
		}

		if ((Graphic is Class))
		{
			_cursor = Type.createInstance(Graphic, []);
		}
		else if ((Graphic is BitmapData))
		{
			_cursor = new Bitmap(cast Graphic);
		}
		else if ((Graphic is String))
		{
			_cursor = new Bitmap(FlxAssets.getBitmapData(Graphic));
		}
		else
		{
			_cursor = new Bitmap(new GraphicCursor(0, 0));
		}

		_cursor.x = XOffset;
		_cursor.y = YOffset;
		_cursor.scaleX = Scale;
		_cursor.scaleY = Scale;

		#if FLX_NATIVE_CURSOR
		if (XOffset < 0 || YOffset < 0)
		{
			throw "Negative offsets aren't supported for native cursors.";
		}

		if (Scale < 0)
		{
			throw "Negative scale isn't supported for native cursors.";
		}

		var scaledWidth:Int = Std.int(Scale * _cursor.bitmapData.width);
		var scaledHeight:Int = Std.int(Scale * _cursor.bitmapData.height);

		var bitmapWidth:Int = scaledWidth + XOffset;
		var bitmapHeight:Int = scaledHeight + YOffset;

		var cursorBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0x0);
		if (_matrix != null)
		{
			_matrix.identity();
			_matrix.scale(Scale, Scale);
			_matrix.translate(XOffset, YOffset);
		}
		cursorBitmap.draw(_cursor.bitmapData, _matrix);
		setSimpleNativeCursorData(_cursorDefaultName, cursorBitmap);
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
				_cursor = FlxDestroyUtil.removeChild(cursorContainer, _cursor);
			}
		}
	}

	#if FLX_NATIVE_CURSOR
	/**
	 * Set a Native cursor that has been registered by name
	 * Warning, you need to use registerNativeCursor() before you use it here
	 *
	 * @param   name   The name ID used when registered
	 */
	public function setNativeCursor(name:String):Void
	{
		_currentNativeCursor = name;

		Mouse.show();

		// Flash requires the use of AUTO before a custom cursor to work
		Mouse.cursor = MouseCursor.AUTO;
		Mouse.cursor = _currentNativeCursor;
	}

	/**
	 * Shortcut to register a native cursor in flash
	 *
	 * @param   name         The ID name used for the cursor
	 * @param   cursorData   MouseCursorData contains the bitmap, hotspot etc
	 */
	public inline function registerNativeCursor(name:String, cursorData:MouseCursorData):Void
	{
		untyped Mouse.registerCursor(name, cursorData);
	}

	/**
	 * Shortcut to register a simple MouseCursorData
	 *
	 * @param   name         The ID name used for the cursor
	 * @param   cursorData   MouseCursorData contains the bitmap, hotspot etc
	 * @since   4.2.0
	 */
	public function registerSimpleNativeCursorData(name:String, cursorBitmap:BitmapData):MouseCursorData
	{
		var cursorVector = new Vector<BitmapData>();
		cursorVector[0] = cursorBitmap;

		if (cursorBitmap.width > 32 || cursorBitmap.height > 32)
			throw "BitmapData files used for native cursors cannot exceed 32x32 pixels due to an OS limitation.";

		var cursorData = new MouseCursorData();
		cursorData.hotSpot = new Point(0, 0);
		cursorData.data = cursorVector;

		registerNativeCursor(name, cursorData);

		return cursorData;
	}

	/**
	 * Shortcut to create and set a simple MouseCursorData
	 *
	 * @param   name         The ID name used for the cursor
	 * @param   cursorData   MouseCursorData contains the bitmap, hotspot etc
	 */
	public function setSimpleNativeCursorData(name:String, cursorBitmap:BitmapData):MouseCursorData
	{
		var data = registerSimpleNativeCursorData(name, cursorBitmap);
		setNativeCursor(name);
		Mouse.show();
		return data;
	}
	#end

	/**
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion
	public function destroy():Void
	{
		if (_stage != null)
		{
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, _leftButton.onDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, _leftButton.onUp);

			#if FLX_MOUSE_ADVANCED
			_stage.removeEventListener(untyped MouseEvent.MIDDLE_MOUSE_DOWN, _middleButton.onDown);
			_stage.removeEventListener(untyped MouseEvent.MIDDLE_MOUSE_UP, _middleButton.onUp);
			_stage.removeEventListener(untyped MouseEvent.RIGHT_MOUSE_DOWN, _rightButton.onDown);
			_stage.removeEventListener(untyped MouseEvent.RIGHT_MOUSE_UP, _rightButton.onUp);

			_stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			#end

			_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		cursorContainer = null;
		_cursor = null;

		#if FLX_NATIVE_CURSOR
		_matrix = null;
		#end

		_leftButton = FlxDestroyUtil.destroy(_leftButton);
		#if FLX_MOUSE_ADVANCED
		_middleButton = FlxDestroyUtil.destroy(_middleButton);
		_rightButton = FlxDestroyUtil.destroy(_rightButton);
		#end

		_cursorBitmapData = FlxDestroyUtil.dispose(_cursorBitmapData);
		FlxG.signals.postGameStart.remove(onGameStart);
	}

	/**
	 * Resets the just pressed/just released flags and sets mouse to not pressed.
	 */
	public function reset():Void
	{
		_leftButton.reset();

		#if FLX_MOUSE_ADVANCED
		_middleButton.reset();
		_rightButton.reset();
		#end
	}

	/**
	 * @param   cursorContainer   The cursor container sprite passed by FlxGame
	 */
	@:allow(flixel.FlxG)
	function new(cursorContainer:Sprite)
	{
		super();
		this.cursorContainer = cursorContainer;
		this.cursorContainer.mouseChildren = false;
		this.cursorContainer.mouseEnabled = false;

		_leftButton = new FlxMouseButton(FlxMouseButtonID.LEFT);

		_stage = Lib.current.stage;
		_stage.addEventListener(MouseEvent.MOUSE_DOWN, _leftButton.onDown);
		_stage.addEventListener(MouseEvent.MOUSE_UP, _leftButton.onUp);

		#if FLX_MOUSE_ADVANCED
		_middleButton = new FlxMouseButton(FlxMouseButtonID.MIDDLE);
		_rightButton = new FlxMouseButton(FlxMouseButtonID.RIGHT);

		_stage.addEventListener(untyped MouseEvent.MIDDLE_MOUSE_DOWN, _middleButton.onDown);
		_stage.addEventListener(untyped MouseEvent.MIDDLE_MOUSE_UP, _middleButton.onUp);
		_stage.addEventListener(untyped MouseEvent.RIGHT_MOUSE_DOWN, _rightButton.onDown);
		_stage.addEventListener(untyped MouseEvent.RIGHT_MOUSE_UP, _rightButton.onUp);

		_stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		#end

		_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

		FlxG.signals.postGameStart.add(onGameStart);
		Mouse.hide();
	}

	/**
	 * Called by the internal game loop to update the mouse pointer's position in the game world.
	 * Also updates the just pressed/just released flags.
	 */
	function update():Void
	{
		_prevX = x;
		_prevY = y;

		#if !FLX_UNIT_TEST // Travis segfaults when game.mouseX / Y is accessed
		setGlobalScreenPositionUnsafe(FlxG.game.mouseX, FlxG.game.mouseY);

		// actually position the flixel mouse cursor graphic
		if (visible)
		{
			cursorContainer.x = FlxG.game.mouseX;
			cursorContainer.y = FlxG.game.mouseY;
		}
		#end

		// Update the buttons
		_leftButton.update();
		#if FLX_MOUSE_ADVANCED
		_middleButton.update();
		_rightButton.update();
		#end

		// Update the wheel
		if (!_wheelUsed)
		{
			wheel = 0;
		}
		_wheelUsed = false;
	}

	/**
	 * Called from the main Event.ACTIVATE that is dispatched in FlxGame
	 */
	function onFocus():Void
	{
		reset();

		#if !FLX_NATIVE_CURSOR
		set_useSystemCursor(useSystemCursor);

		visible = _visibleWhenFocusLost;
		#end
	}

	/**
	 * Called from the main Event.DEACTIVATE that is dispatched in FlxGame
	 */
	function onFocusLost():Void
	{
		#if !FLX_NATIVE_CURSOR
		_visibleWhenFocusLost = visible;

		if (visible)
		{
			visible = false;
		}

		Mouse.show();
		#end
	}

	function onGameStart():Void
	{
		// Call set_visible with the value visible has been initialized with
		// (unless set in create() of the initial state)
		set_visible(visible);
	}

	/**
	 * Internal event handler for input and focus.
	 */
	function onMouseWheel(flashEvent:MouseEvent):Void
	{
		if (enabled)
		{
			_wheelUsed = true;
			wheel = flashEvent.delta;
		}
	}

	#if FLX_MOUSE_ADVANCED
	/**
	 * We're detecting the mouse leave event to prevent a bug where `pressed` remains true
	 * for the middle and right mouse button when pressed and dragged outside the window.
	 */
	inline function onMouseLeave(_):Void
	{
		_rightButton.onUp();
		_middleButton.onUp();
	}
	#end

	inline function get_justMoved():Bool
		return _prevX != x || _prevY != y;

	inline function get_pressed():Bool
		return _leftButton.pressed;

	inline function get_justPressed():Bool
		return _leftButton.justPressed;

	inline function get_justReleased():Bool
		return _leftButton.justReleased;

	inline function get_justPressedTimeInTicks():Int
		return _leftButton.justPressedTimeInTicks;

	#if FLX_MOUSE_ADVANCED
	inline function get_pressedRight():Bool
		return _rightButton.pressed;

	inline function get_justPressedRight():Bool
		return _rightButton.justPressed;

	inline function get_justReleasedRight():Bool
		return _rightButton.justReleased;

	inline function get_justPressedTimeInTicksRight():Int
		return _rightButton.justPressedTimeInTicks;

	inline function get_pressedMiddle():Bool
		return _middleButton.pressed;

	inline function get_justPressedMiddle():Bool
		return _middleButton.justPressed;

	inline function get_justReleasedMiddle():Bool
		return _middleButton.justReleased;

	inline function get_justPressedTimeInTicksMiddle():Int
		return _middleButton.justPressedTimeInTicks;
	#end

	function showSystemCursor():Void
	{
		#if FLX_NATIVE_CURSOR
		Mouse.cursor = MouseCursor.AUTO;
		#else
		cursorContainer.visible = false;
		#end

		Mouse.show();
	}

	function hideSystemCursor():Void
	{
		#if FLX_NATIVE_CURSOR
		if (_currentNativeCursor != null)
		{
			setNativeCursor(_currentNativeCursor);
		}
		#else
		Mouse.hide();

		if (visible)
		{
			cursorContainer.visible = true;
		}
		#end
	}

	function set_useSystemCursor(value:Bool):Bool
	{
		if (value)
		{
			showSystemCursor();
		}
		else
		{
			hideSystemCursor();
		}
		return useSystemCursor = value;
	}

	function showCursor():Void
	{
		if (useSystemCursor)
		{
			Mouse.show();
		}
		else
		{
			if (_cursor == null)
				load();

			#if FLX_NATIVE_CURSOR
			Mouse.show();
			#else
			cursorContainer.visible = true;
			Mouse.hide();
			#end
		}
	}

	function hideCursor():Void
	{
		cursorContainer.visible = false;
		Mouse.hide();
	}

	function set_visible(value:Bool):Bool
	{
		if (value)
			showCursor();
		else
			hideCursor();

		return visible = value;
	}

	@:allow(flixel.system.replay.FlxReplay)
	function record():MouseRecord
	{
		if ((_lastX == _globalScreenX)
			&& (_lastY == _globalScreenY)
			&& (_lastLeftButtonState == _leftButton.current)
			&& (_lastWheel == wheel))
		{
			return null;
		}

		_lastX = _globalScreenX;
		_lastY = _globalScreenY;
		_lastLeftButtonState = _leftButton.current;
		_lastWheel = wheel;
		return new MouseRecord(_lastX, _lastY, _leftButton.current, _lastWheel);
	}

	@:allow(flixel.system.replay.FlxReplay)
	function playback(record:MouseRecord):Void
	{
		// Manually dispatch a MOUSE_UP event so that, e.g., FlxButtons click correctly on playback.
		// Note: some clicks are fast enough to not pass through a frame where they are PRESSED
		// and JUST_RELEASED is swallowed by FlxButton and others, but not third-party code
		if ((_lastLeftButtonState == PRESSED || _lastLeftButtonState == JUST_PRESSED)
			&& (record.button == RELEASED || record.button == JUST_RELEASED))
		{
			_stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, record.x, record.y));
		}
		_lastLeftButtonState = _leftButton.current = record.button;
		wheel = record.wheel;
		_globalScreenX = record.x;
		_globalScreenY = record.y;
		updatePositions();
	}
}
#end
