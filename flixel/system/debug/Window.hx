package flixel.system.debug;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import openfl.Assets;

@:bitmap("assets/images/debugger/windowHandle.png")	private class GraphicWindowHandle extends BitmapData { }

/**
 * A generic, Flash-based window class, created for use in FlxDebugger.
 */
class Window extends Sprite
{
	/**
	 * The background color of the window.
	 */
	public static inline var BG_COLOR:Int = 0xDD5F5F5F;
	/**
	 * The color used for the "handle" at the top of the window.
	 */
	public static inline var TOP_COLOR:Int = 0xBB000000;
	/**
	 * How many windows there are currently in total.
	 */
	private static var WINDOW_AMOUNT:Int = 0;

	/**
	 * Minimum allowed X and Y dimensions for this window.
	 */
	public var minSize:Point;
	/**
	 * Maximum allowed X and Y dimensions for this window.
	 */
	public var maxSize:Point;
	
	/**
	 * Width of the window.  Using Sprite.width is super unreliable for some reason!
	 */
	private var _width:Int;
	/**
	 * Height of the window.  Using Sprite.height is super unreliable for some reason!
	 */
	private var _height:Int;
	/**
	 * Controls where the window is allowed to be positioned.
	 */
	private var _bounds:Rectangle;
	
	/**
	 * Window display element.
	 */
	private var _background:Bitmap;
	/**
	 * Window display element.
	 */
	private var _header:Bitmap;
	/**
	 * Window display element.
	 */
	private var _shadow:Bitmap;
	/**
	 * Window display element.
	 */
	private var _title:TextField;
	/**
	 * Window display element.
	 */
	private var _handle:Bitmap;
	
	/**
	 * Helper for interaction.
	 */
	private var _overHeader:Bool;
	/**
	 * Helper for interaction.
	 */
	private var _overHandle:Bool;
	/**
	 * Helper for interaction.
	 */
	private var _drag:Point;
	/**
	 * Helper for interaction.
	 */
	private var _dragging:Bool;
	/**
	 * Helper for interaction.
	 */
	private var _resizing:Bool;
	/**
	 * Helper for interaction.
	 */
	private var _resizable:Bool;
	/**
	 * The ID of this window.
	 */
	private var _id:Int;
	
	/**
	 * Creates a new window object.  This Flash-based class is mainly (only?) used by FlxDebugger.
	 * 
	 * @param   Title       The name of the window, displayed in the header bar.
	 * @param   Icon	    The icon to use for the window header.
	 * @param   Width       The initial width of the window.
	 * @param   Height      The initial height of the window.
	 * @param   Resizable   Whether you can change the size of the window with a drag handle.
	 * @param   Bounds      A rectangle indicating the valid screen area for the window.
	 */
	public function new(Title:String, ?Icon:BitmapData, Width:Float = 0, Height:Float = 0, Resizable:Bool = true, ?Bounds:Rectangle)
	{
		super();
		
		_width = Std.int(Math.abs(Width));
		_height = Std.int(Math.abs(Height));
		updateBounds(Bounds);
		_drag = new Point();
		
		_resizable = Resizable;
		
		_shadow = new Bitmap(new BitmapData(1, 2, true, FlxColor.BLACK));
		addChild(_shadow);
		_background = new Bitmap(new BitmapData(1, 1, true, BG_COLOR));
		_background.y = 15;
		addChild(_background);
		_header = new Bitmap(new BitmapData(1, 15, true, TOP_COLOR));
		addChild(_header);
		
		_title = new TextField();
		_title.x = 2;
		_title.y = -1;
		_title.alpha = 0.8;
		_title.height = 20;
		_title.selectable = false;
		_title.multiline = false;
		_title.embedFonts = true;
		_title.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xffffff);
		_title.text = Title;
		addChild(_title);
		
		if (Icon != null)
		{
			var _icon = new Bitmap(Icon);
			_icon.x = 5;
			_icon.y = 2;
			_icon.alpha = 0.8;
			_title.x = _icon.x + _icon.width + 2;
			addChild(_icon);
		}
		
		if (_resizable)
		{
			_handle = new Bitmap(new GraphicWindowHandle(0, 0));
			addChild(_handle);
		}
		
		if ((_width != 0) || (_height != 0))
		{
			updateSize();
		}
		bound();
		
		addEventListener(Event.ENTER_FRAME, init);
		
		_id = WINDOW_AMOUNT++;
		if (FlxG.save.data.windowSettings != null)
		{
			visible = FlxG.save.data.windowSettings[_id];
		}
		else
		{
			FlxG.save.data.windowSettings = new Array<Bool>();
		}
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		minSize = null;
		maxSize = null;
		_bounds = null;
		if (_shadow != null)
		{
			removeChild(_shadow);
		}
		_shadow = null;
		if (_background != null)
		{
			removeChild(_background);
		}
		_background = null;
		if (_header != null)
		{
			removeChild(_header);
		}
		_header = null;
		if (_title != null)
		{
			removeChild(_title);
		}
		_title = null;
		if(_handle != null)
		{
			removeChild(_handle);
		}
		_handle = null;
		_drag = null;
	}
	
	/**
	 * Resize the window.  Subject to pre-specified minimums, maximums, and bounding rectangles.
	 * @param 	Width	How wide to make the window.
	 * @param 	Height	How tall to make the window.
	 */
	public function resize(Width:Float, Height:Float):Void
	{
		_width = Std.int(Math.abs(Width));
		_height = Std.int(Math.abs(Height));
		updateSize();
	}
	
	/**
	 * Change the position of the window.  Subject to pre-specified bounding rectangles.
	 * @param 	X	Desired X position of top left corner of the window.
	 * @param 	Y	Desired Y position of top left corner of the window.
	 */
	public function reposition(X:Float, Y:Float):Void
	{
		x = X;
		y = Y;
		bound();
	}
	
	//***EVENT HANDLERS***//
	
	/**
	 * Used to set up basic mouse listeners.
	 * @param E		Flash event.
	 */
	private function init(E:Event = null):Void
	{
		#if flash
		if (root == null)
		#else
		if (stage == null)
		#end
		{
			return;
		}
		removeEventListener(Event.ENTER_FRAME, init);
		
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	/**
	 * Mouse movement handler.  Figures out if mouse is over handle or header bar or what.
	 * @param E		Flash mouse event.
	 */
	private function onMouseMove(E:MouseEvent = null):Void
	{
		if (!parent.visible)
		{
			_overHandle = _overHeader = false;
			return;
		}
		
		if (_dragging) //user is moving the window around
		{
			_overHeader = true;
			reposition(parent.mouseX - _drag.x, parent.mouseY - _drag.y);
		}
		else if (_resizing)
		{
			_overHandle = true;
			resize(mouseX - _drag.x, mouseY - _drag.y);
		}
		else if ((mouseX >= 0) && (mouseX <= _width) && (mouseY >= 0) && (mouseY <= _height))
		{	//not dragging, mouse is over the window
			_overHeader = (mouseX <= _header.width) && (mouseY <= _header.height);
			if (_resizable)
			{
				_overHandle = (mouseX >= _width - _handle.width) && (mouseY >= _height - _handle.height);
			}
		}
		else
		{	//not dragging, mouse is NOT over window
			_overHandle = _overHeader = false;
		}
	}
	
	/**
	 * Figure out if window is being repositioned (clicked on header) or resized (clicked on handle).
	 * @param E		Flash mouse event.
	 */
	private function onMouseDown(E:MouseEvent = null):Void
	{
		if (_overHeader)
		{
			parent.addChild(this);
			_dragging = true;
			_drag.x = mouseX;
			_drag.y = mouseY;
		}
		else if (_overHandle)
		{
			_resizing = true;
			_drag.x = _width - mouseX;
			_drag.y = _height - mouseY;
		}
	}
	
	/**
	 * User let go of header bar or handler (or nothing), so turn off drag and resize behaviors.
	 * @param E		Flash mouse event.
	 */
	private function onMouseUp(E:MouseEvent = null):Void
	{
		_dragging = false;
		_resizing = false;
	}
	
	//***MISC GUI MGMT STUFF***//
	
	/**
	 * Keep the window within the pre-specified bounding rectangle. 
	 */
	private function bound():Void
	{
		if(_bounds != null)
		{
			x = FlxMath.bound(x, _bounds.left, _bounds.right - _width);
			y = FlxMath.bound(y, _bounds.top, _bounds.bottom - _height);
		}
	}
	
	/**
	 * Update the Flash shapes to match the new size, and reposition the header, shadow, and handle accordingly.
	 */
	private function updateSize():Void
	{
		_width = Std.int(FlxMath.bound(_width, minSize.x, maxSize.x));
		_height = Std.int(FlxMath.bound(_height, minSize.y, maxSize.y));
		
		_header.scaleX = _width;
		_background.scaleX = _width;
		_background.scaleY = _height-15;
		_shadow.scaleX = _width;
		_shadow.y = _height;
		_title.width = _width-4;
		if(_resizable)
		{
			_handle.x = _width-_handle.width;
			_handle.y = _height-_handle.height;
		}
	}
	
	public function updateBounds(Bounds:Rectangle):Void
	{
		_bounds = Bounds;
		minSize = new Point(50, 30);
		if (_bounds != null)
		{
			maxSize = new Point(_bounds.width,_bounds.height);
		}
		else
		{
			maxSize = new Point(FlxMath.MAX_VALUE, FlxMath.MAX_VALUE);
		}
	}
	
	public function toggleVisibility():Void
	{
		visible = !visible;
		FlxG.save.data.windowSettings[_id] = visible;
	}
}
