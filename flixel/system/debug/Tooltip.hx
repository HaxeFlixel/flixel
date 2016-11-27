package flixel.system.debug;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.system.debug.FlxDebugger.GraphicCloseButton;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * A generic, Flash-based tooltip class, created for use in FlxDebugger.
 */
class Tooltip extends Sprite
{
	private static var _tooltips:Array<Tooltip> = [];
	private static var _container:Sprite;
	private static var _activeElement:Sprite;
	
	/**
	 * The background color of the window.
	 */
	public static inline var BG_COLOR:FlxColor = 0xFF3A3A3A;
	public static inline var HEADER_ALPHA:Float = 0.8;
	
	public var maxSize:Point;
	
	/**
	 * Width of the window. Using Sprite.width is super unreliable for some reason!
	 */
	private var _width:Int;
	/**
	 * Height of the window. Using Sprite.height is super unreliable for some reason!
	 */
	private var _height:Int;
	
	/**
	 * Main elements
	 */ 
	private var _background:Bitmap;
	private var _shadow:Bitmap;
	private var _text:TextField;
	private var _owner:Sprite;
	
	
	public static function init(container:Sprite):Void
	{
		_container = container;
	}
	
	public static function add(element:Sprite, text:String):Void
	{		
		var tooltip = new Tooltip(element, text);
		
		_container.addChild(tooltip);
		_tooltips.push(tooltip);
	}
	
	public static function remove(element:Sprite):Void
	{
		// TODO: implement this
	}
	
	public function new(owner:Sprite, text:String, width:Float = 0, height:Float = 0)
	{
		super();
		
		_owner = owner;
		
		maxSize = new Point(width, height);
		
		_shadow = new Bitmap(new BitmapData(1, 2, true, FlxColor.BLACK));
		_background = new Bitmap(new BitmapData(1, 1, true, BG_COLOR));
		
		_text = DebuggerUtil.createTextField(2, 1);
		_text.alpha = HEADER_ALPHA;
		_text.text = text;
		_text.wordWrap = true;
		
		addChild(_shadow);
		addChild(_background);
		addChild(_text);
		
		updateSize();
		visible = false;
		
		_owner.addEventListener(MouseEvent.MOUSE_OVER, handleMouseEvents);
		_owner.addEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		maxSize = null;

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
		if (_text != null)
		{
			removeChild(_text);
		}
		_text = null;
	}
	
	/**
	 * Resize the window.  Subject to pre-specified minimums, maximums, and bounding rectangles.
	 *
	 * @param 	Width	How wide to make the window.
	 * @param 	Height	How tall to make the window.
	 */
	public function resize(Width:Float, Height:Float):Void
	{
		maxSize.x = Std.int(Math.abs(Width));
		maxSize.y = Std.int(Math.abs(Height));
		updateSize();
	}
	
	/**
	 * Change the position of the window.  Subject to pre-specified bounding rectangles.
	 * 
	 * @param 	X	Desired X position of top left corner of the window.
	 * @param 	Y	Desired Y position of top left corner of the window.
	 */
	public function reposition(X:Float, Y:Float):Void
	{
		x = X;
		y = Y;
	}
	
	public function setVisible(Value:Bool):Void
	{
		visible = Value;
	
		if (visible) {
			putOnTop();
			
			// Move the tooltip back to the screen if top-left corner
			// is out of the screen.
			x = x < 0 ? 0 : x;
			y = y < 0 ? 0 : y;
			
			// Calculate any adjustments to ensure that part of the
			// tooltip is not outside of the screen.
			var offsetX = x + width >= FlxG.stage.stageWidth ? FlxG.stage.stageWidth - (x + width) : 0;
			var offsetY = y + height >= FlxG.stage.stageHeight ? FlxG.stage.stageHeight - (y + height) : 0;
			x += offsetX;
			y += offsetY;
		}
	}
	
	public function toggleVisible():Void
	{
		setVisible(!visible);
	}
	
	public inline function putOnTop():Void
	{
		parent.addChild(this);
	}
	
	public function update():Void {}
	
	/**
	 * Update the Flash shapes to match the new size, and reposition the header, shadow, and handle accordingly.
	 */
	private function updateSize():Void
	{
		_width = Std.int(maxSize.x == 0 ? _text.textWidth : Math.abs(maxSize.x)) + 8;
		_height = Std.int(maxSize.y == 0 ? _text.textHeight : Math.abs(maxSize.y)) + 8;
		_background.scaleX = _width;
		_background.scaleY = _height;
		_shadow.scaleX = _width;
		_shadow.y = _height;
		_text.width = _width;
	}
	
	private function handleMouseEvents(event:MouseEvent):Void
	{
		if (event.type == MouseEvent.MOUSE_OVER && !visible)
		{
			x = event.stageX + event.target.width + 10;
			y = event.stageY;
			
			setVisible(true);
		}
		else if (event.type == MouseEvent.MOUSE_OUT)
			setVisible(false);
	}
}
