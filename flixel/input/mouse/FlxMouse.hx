package flixel.input.mouse;

#if !FLX_NO_MOUSE
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.Lib;
import flash.ui.Mouse;
import flixel.util.FlxDestroyUtil;
#if (flash && !FLX_NO_NATIVE_CURSOR)
import flash.ui.MouseCursor;
import flash.ui.MouseCursorData;
#end
import flash.Vector;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.interfaces.IFlxInput;
import flixel.system.FlxAssets;
import flixel.system.replay.MouseRecord;
import flixel.util.FlxPoint;

@:bitmap("assets/images/ui/cursor.png")
private class GraphicCursor extends BitmapData {}

/**
 * This class helps contain and track the mouse pointer in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
@:allow(flixel.system.replay.FlxReplay)
class FlxMouse extends FlxPoint implements IFlxInput
{
	/**
	 * Current "delta" value of mouse wheel. If the wheel was just scrolled up, 
	 * it will have a positive value and vice versa. Otherwise the value will be 0.
	 */
	public var wheel(default, null):Int = 0;
	/**
	 * Current X position of the mouse pointer on the screen.
	 */
	public var screenX(default, null):Int = 0;
	/**
	 * Current Y position of the mouse pointer on the screen.
	 */
	public var screenY(default, null):Int = 0;
	/**
	 * A display container for the mouse cursor. It is a child of FlxGame and 
	 * sits at the right "height". Not used on flash with the native cursor API.
	 */
	public var cursorContainer:Sprite;
	/**
	 * Used to toggle the visiblity of the mouse cursor - works on both 
	 * the flixel and the system cursor, depending on which one is active.
	 */
	public var visible(default, set):Bool = #if mobile false #else true #end;
	/**
	 * Tells flixel to use the default system mouse cursor instead of custom Flixel mouse cursors.
	 */
	public var useSystemCursor(default, set):Bool = false;
	/**
	 * If the left mouse button is currently pressed.
	 */
	public var pressed(get, never):Bool;
	/**
	 * Check to see if the mouse was just pressed.
	 */
	public var justPressed(get, never):Bool;
	/**
	 * Check to see if the mouse was just released.
	 */
	public var justReleased(get, never):Bool;

	#if !FLX_NO_MOUSE_ADVANCED
	/**
	 * Check to see if the right mouse button is pressed.
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
	 * Check to see if the middle mouse button is pressed.
	 */
	public var pressedMiddle(get, never):Bool;
	/**
	 * Check to see if the middle mouse button was just pressed.
	 */
	public var justPressedMiddle(get, never):Bool;
	/**
	 * Check to see if the middle mouse button was just released.
	 */
	public var justReleasedMiddle(get, never):Bool;
	#end

	/**
	 * The left mouse button.
	 */
	private var _leftButton:FlxMouseButton;
	
	#if !FLX_NO_MOUSE_ADVANCED
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
	 * This is just a reference to the current cursor image, if there is one.
	 */
	private var _cursor:Bitmap = null;
	private var _cursorBitmapData:BitmapData;
	private var _wheelUsed:Bool = false;
	private var _visibleWhenFocusLost:Bool = true;
	
	/**
	 * Helper variables for recording purposes.
	 */
	private var _lastX:Int = 0;
	private var _lastY:Int = 0;
	private var _lastWheel:Int = 0;
	private var _point:FlxPoint;
	private var _globalScreenPosition:FlxPoint;
	
	//Helper variable for cleaning up memory
	private var _stage:Stage;
	
	/**
	 * Helper variables for flash native cursors
	 */
	#if (flash && !FLX_NO_NATIVE_CURSOR)
	private var _cursorDefaultName:String = "defaultCursor";
	private var _currentNativeCursor:String;
	private var _previousNativeCursor:String;
	private static var _matrix:Matrix = new Matrix();
	#end
	
	/**
	 * Load a new mouse cursor graphic - if you're using native cursors on flash, 
	 * check registerNativeCursor() for more control.
	 * 
	 * @param   Graphic   The image you want to use for the cursor.
	 * @param   Scale     Change the size of the cursor.
	 * @param   XOffset   The number of pixels between the mouse's screen position and the graphic's top left corner.
	 * @param   YOffset   The number of pixels between the mouse's screen position and the graphic's top left corner.
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
			Graphic = new GraphicCursor(0, 0);
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
			_cursor = new Bitmap(new GraphicCursor(0, 0));
		}
		
		_cursor.x = XOffset;
		_cursor.y = YOffset;
		_cursor.scaleX = Scale;
		_cursor.scaleY = Scale;
		
		#if (flash && !FLX_NO_NATIVE_CURSOR)
		if (XOffset < 0 || YOffset < 0)
		{
			FlxG.log.warn("Negative offsets aren't supported with native cursor. Abs values will be used instead.");
			XOffset = 0;
			YOffset = 0;
		}
		
		if (Scale < 0)
		{
			FlxG.log.warn("Negative scale isn't supported with native cursor. Abs value will be used instead.");
			Scale = 1;
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
				cursorContainer.removeChild(_cursor);
				_cursor = null;
			}
		}
	}

	#if (flash && !FLX_NO_NATIVE_CURSOR)
	/**
	 * Set a Native cursor that has been registered by Name
	 * Warning, you need to use registerNativeCursor() before you use it here
	 * 
	 * @param   Name   The name ID used when registered
	 */
	public function setNativeCursor(Name:String):Void
	{
		_previousNativeCursor = _currentNativeCursor;
		_currentNativeCursor = Name;
		
		Mouse.show();
		
		//Flash requires the use of AUTO before a custom cursor to work
		Mouse.cursor = MouseCursor.AUTO;
		Mouse.cursor = _currentNativeCursor;
	}

	/**
	 * Shortcut to register a native cursor for in flash
	 * 
	 * @param   Name         The ID name used for the cursor
	 * @param   CursorData   MouseCursorData contains the bitmap, hotspot etc
	 * @param   Show         Whether to call setNativeCursor afterwards
	 */
	public inline function registerNativeCursor(Name:String, CursorData:MouseCursorData):Void
	{
		untyped Mouse.registerCursor(Name, CursorData);
	}

	/**
	 * Shortcut to create and set a simple MouseCursorData
	 * 
	 * @param   Name         The ID name used for the cursor
	 * @param   CursorData   MouseCursorData contains the bitmap, hotspot etc
	 */
	public function setSimpleNativeCursorData(Name:String, CursorBitmap:BitmapData):MouseCursorData
	{
		var cursorVector = new Vector<BitmapData>();
		cursorVector[0] = CursorBitmap;
		
		if (CursorBitmap.width > 32 || CursorBitmap.height > 32)
		{
			FlxG.log.warn("Bitmap files used for the cursors should not exceed 32 × 32 pixels, due to an OS limitation.");
		}
		
		var cursorData = new MouseCursorData();
		cursorData.hotSpot = new Point(0, 0);
		cursorData.data = cursorVector;
		
		registerNativeCursor(Name, cursorData);
		setNativeCursor(Name);
		
		Mouse.show();
		
		return cursorData;
	}
	#end
	
	/**
	 * Fetch the world position of the mouse on any given camera. NOTE: FlxG.mouse.x and 
	 * FlxG.mouse.y store the world position of the mouse cursor on the main camera.
	 * 
	 * @param   Camera  If unspecified, FlxG.camera is used instead.
	 * @param   point   An existing point object to store the results (if you don't want a new one created).
	 * @return  The mouse's location in world space.
	 */
	public function getWorldPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = FlxPoint.get();
		}
		getScreenPosition(Camera, _point);
		point.set((_point.x + Camera.scroll.x), (_point.y + Camera.scroll.y));
		return point;
	}

	/**
	 * Fetch the screen position of the mouse on any given camera. NOTE: FlxG.mouse.screenX 
	 * and Mouse.screenY also store the screen position of the mouse cursor on the main camera.
	 * 
	 * @param   Camera  If unspecified, FlxG.camera is used instead.
	 * @param   point   An existing point object to store the results (if you don't want a new one created).
	 * @return  The mouse's location in screen space.
	 */
	public function getScreenPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = FlxPoint.get();
		}
		point.x = (_globalScreenPosition.x - Camera.x) / Camera.zoom;
		point.y = (_globalScreenPosition.y - Camera.y) / Camera.zoom;
		return point;
	}
	
	/**
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion
	override public function destroy():Void
	{
		if (_stage != null)
		{
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, _leftButton.onDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, _leftButton.onUp);
			
			#if !FLX_NO_MOUSE_ADVANCED
			_stage.removeEventListener(untyped MouseEvent.MIDDLE_MOUSE_DOWN, _middleButton.onDown);
			_stage.removeEventListener(untyped MouseEvent.MIDDLE_MOUSE_UP, _middleButton.onUp);
			_stage.removeEventListener(untyped MouseEvent.RIGHT_MOUSE_DOWN, _rightButton.onDown);
			_stage.removeEventListener(untyped MouseEvent.RIGHT_MOUSE_UP, _rightButton.onUp);
			
			_stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			#end
			
			_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		_point = FlxDestroyUtil.put(_point);
		_globalScreenPosition = FlxDestroyUtil.put(_globalScreenPosition);
		
		cursorContainer = null;
		_cursor = null;
		
		#if (flash && !FLX_NO_NATIVE_CURSOR)
		_matrix = null;
		#end
		
		_leftButton   = FlxDestroyUtil.destroy(_leftButton);
		#if !FLX_NO_MOUSE_ADVANCED
		_middleButton = FlxDestroyUtil.destroy(_middleButton);
		_rightButton  = FlxDestroyUtil.destroy(_rightButton);
		#end
		
		_cursorBitmapData = FlxDestroyUtil.dispose(_cursorBitmapData);
		FlxG.signals.gameStarted.remove(onGameStart);

		super.destroy();
	}
	
	/**
	 * Directly set the underyling screen position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse events to the stage.
	 */
	public inline function setGlobalScreenPositionUnsafe(X:Float, Y:Float):Void 
	{
		_globalScreenPosition.set(X, Y);
	}
	
	/**
	 * Resets the just pressed/just released flags and sets mouse to not pressed.
	 */
	public function reset():Void
	{
		_leftButton.reset();
		
		#if !FLX_NO_MOUSE_ADVANCED
		_middleButton.reset();
		_rightButton.reset();
		#end
	}
	
	/**
	 * @param   CursorContainer   The cursor container sprite passed by FlxGame
	 */
	@:allow(flixel.FlxG)
	private function new(CursorContainer:Sprite)
	{
		super();
		
		cursorContainer = CursorContainer;
		cursorContainer.mouseChildren = false;
		cursorContainer.mouseEnabled = false;
		
		_point = FlxPoint.get();
		_globalScreenPosition = FlxPoint.get();
		
		_leftButton = new FlxMouseButton(FlxMouseButton.LEFT);
		
		_stage = Lib.current.stage;
		_stage.addEventListener(MouseEvent.MOUSE_DOWN, _leftButton.onDown);
		_stage.addEventListener(MouseEvent.MOUSE_UP, _leftButton.onUp);
		
		#if !FLX_NO_MOUSE_ADVANCED
		_middleButton = new FlxMouseButton(FlxMouseButton.MIDDLE);
		_rightButton = new FlxMouseButton(FlxMouseButton.RIGHT);
		
		_stage.addEventListener(untyped MouseEvent.MIDDLE_MOUSE_DOWN, _middleButton.onDown);
		_stage.addEventListener(untyped MouseEvent.MIDDLE_MOUSE_UP, _middleButton.onUp);
		_stage.addEventListener(untyped MouseEvent.RIGHT_MOUSE_DOWN, _rightButton.onDown);
		_stage.addEventListener(untyped MouseEvent.RIGHT_MOUSE_UP, _rightButton.onUp);
		
		_stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		#end
		
		_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		FlxG.signals.gameStarted.add(onGameStart);
		Mouse.hide();
	}
	
	/**
	 * Called by the internal game loop to update the mouse pointer's position in the game world.
	 * Also updates the just pressed/just released flags.
	 */
	private function update():Void
	{
		_globalScreenPosition.x = Math.floor(FlxG.game.mouseX);
		_globalScreenPosition.y = Math.floor(FlxG.game.mouseY);
		
		//actually position the flixel mouse cursor graphic
		if (visible)
		{
			cursorContainer.x = _globalScreenPosition.x;
			cursorContainer.y = _globalScreenPosition.y;
		}
		
		#if js
		// need to account for scale as the game sprite is not being scaled on html5
		var scaleMultiplier:Float = FlxG._scaleMode.scale.x;
		_globalScreenPosition.x /= scaleMultiplier;
		_globalScreenPosition.y /= scaleMultiplier;
		#end
		
		updateCursor();
		
		// Update the buttons
		_leftButton.update();
		#if !FLX_NO_MOUSE_ADVANCED
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
	private function onFocus():Void
	{
		reset();
		
		#if (!flash || FLX_NO_NATIVE_CURSOR)
		set_useSystemCursor(useSystemCursor);
		
		visible = _visibleWhenFocusLost;
		#end
	}

	/**
	 * Called from the main Event.DEACTIVATE that is dispatched in FlxGame
	 */
	private function onFocusLost():Void
	{
		#if (!flash || FLX_NO_NATIVE_CURSOR)
		_visibleWhenFocusLost = visible;
		
		if (visible)
		{
			visible = false;
		}
		
		Mouse.show();
		#end
	}
	
	@:allow(flixel.FlxGame)
	private function onGameStart():Void
	{
		// Call set_visible with the value visible has been initialized with
		// (unless set in create() of the initial state)
		set_visible(visible);
	}
	
	/**
	 * Helper function to update the cursor used by update() and playback().
	 * Updates the x, y, screenX, and screenY variables based on the default camera.
	 */
	private function updateCursor():Void
	{
		getScreenPosition(null, _point);
		screenX = Std.int(_point.x);
		screenY = Std.int(_point.y);
		
		getWorldPosition(null, this);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * 
	 * @param   FlashEvent   Flash mouse event.
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
	
	#if !FLX_NO_MOUSE_ADVANCED
	/**
	 * We're detecting the mouse leave event to prevent a bug where `pressed` remains true 
	 * for the middle and right mouse button when pressed and dragged outside the window.
	 * 
	 * @param   E   Flash event.
	 */
	private inline function onMouseLeave(E:Event):Void
	{
		_rightButton.onUp();
		_middleButton.onUp();
	}
	#end
	
	private inline function get_pressed():Bool            { return _leftButton.pressed();        }
	private inline function get_justPressed():Bool        { return _leftButton.justPressed();    }
	private inline function get_justReleased():Bool       { return _leftButton.justReleased();   }

	#if !FLX_NO_MOUSE_ADVANCED
	private inline function get_pressedRight():Bool       { return _rightButton.pressed();       }
	private inline function get_justPressedRight():Bool   { return _rightButton.justPressed();   }
	private inline function get_justReleasedRight():Bool  { return _rightButton.justReleased();  }
	
	private inline function get_pressedMiddle():Bool      { return _middleButton.pressed();      }
	private inline function get_justPressedMiddle():Bool  { return _middleButton.justPressed();  }
	private inline function get_justReleasedMiddle():Bool { return _middleButton.justReleased(); }
	#end
	
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
		if (Mouse.supportsCursor && (_previousNativeCursor != null))
		{
			setNativeCursor(_previousNativeCursor);
		}
		#else
		
		Mouse.hide();
		
		if (visible)
		{
			cursorContainer.visible = true;
		}
		#end
	}
	
	private function set_useSystemCursor(Value:Bool):Bool
	{
		if (Value)
		{
			showSystemCursor();
		} 
		else 
		{
			hideSystemCursor();
		}
		return useSystemCursor = Value;
	}
	
	private function set_visible(Value:Bool):Bool
	{
		if (Value)
		{
			if (useSystemCursor)
			{
				Mouse.show();
			}
			else 
			{
				if (_cursor == null)
				{
					load();
				}
				
				cursorContainer.visible = true;
				Mouse.hide();
			}
			
			#if (flash && !FLX_NO_NATIVE_CURSOR)
			if (Mouse.supportsCursor && (_previousNativeCursor != null))
			{
				setNativeCursor(_previousNativeCursor);
			}
			Mouse.show();
			#end
		}
		else 
		{
			cursorContainer.visible = false;
			Mouse.hide();
			
			#if (flash && !FLX_NO_NATIVE_CURSOR)
			if (Mouse.supportsCursor)
			{
				_previousNativeCursor = _currentNativeCursor;
			}
			#end
		}
		
		return visible = Value;
	}
	
	/** Replay functions **/
	
	private function record():MouseRecord
	{
		if ((_lastX == _globalScreenPosition.x) && (_lastY == _globalScreenPosition.y) 
			&& (_leftButton.current == 0) && (_lastWheel == wheel))
		{
			return null;
		}
		_lastX = Math.floor(_globalScreenPosition.x);
		_lastY = Math.floor(_globalScreenPosition.y);
		_lastWheel = wheel;
		return new MouseRecord(_lastX, _lastY, _leftButton.current, _lastWheel);
	}
	
	private function playback(Record:MouseRecord):Void
	{
		_leftButton.current = Record.button;
		wheel = Record.wheel;
		_globalScreenPosition.copyFrom(Record);
		updateCursor();
	}
}
#end
