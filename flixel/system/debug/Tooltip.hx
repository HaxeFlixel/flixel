package flixel.system.debug;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Manages tooltips to be used within the debugger.
 */
class Tooltip
{
	static var _tooltips:Array<TooltipOverlay> = [];
	static var _container:Sprite;

	public static function init(container:Sprite):Void
	{
		_container = container;
	}

	public static function add(element:Sprite, text:String):TooltipOverlay
	{
		var tooltip = new TooltipOverlay(element, text);

		_container.addChild(tooltip);
		_tooltips.push(tooltip);
		return tooltip;
	}

	public static function remove(element:Sprite):Bool
	{
		var removed:Bool = false;

		for (i in 0..._tooltips.length)
		{
			if (_tooltips[i] != null && _tooltips[i].owner == element)
			{
				var tooltip:TooltipOverlay = _tooltips.splice(i, 1)[0];
				tooltip.destroy();
				removed = true;
				break;
			}
		}

		return removed;
	}
}

/**
 * A generic, Flash-based tooltip class, created for use in FlxDebugger.
 */
class TooltipOverlay extends Sprite
{
	/**
	 * The background color of all tooltips.
	 */
	static inline var BG_COLOR:FlxColor = 0xFF3A3A3A;

	/**
	 * Alpha applied to the tooltips text.
	 */
	static inline var TEXT_ALPHA:Float = 0.8;

	/**
	 * How many pixels the tooltip should be away from the target in the x axis.
	 */
	static inline var MARGIN_X:Int = 10;

	/**
	 * How many pixels the tooltip should be away from the target in the y axis.
	 */
	static inline var MARGIN_Y:Float = 10;

	/**
	 * Width of the tooltip. Using Sprite.width is super unreliable for some reason!
	 */
	var _width:Int;

	/**
	 * Height of the tooltip. Using Sprite.height is super unreliable for some reason!
	 */
	var _height:Int;

	/**
	 * Main elements
	 */
	var _background:Bitmap;

	var _shadow:Bitmap;

	/**
	 * Texfield used by the tooltip to display text. If you change anything in the textfield,
	 * be sure to call the proper methods of the tooltip to ensure it keeps a correct size, etc.
	 * If you just want to change the text of the tooltip, use the method `setText()` instead, since
	 * it takes care of properly resizing and positioning the tooltip after the text changes.
	 */
	public var textField(default, null):TextField;

	/**
	 * The element the tooltip is monitoring.
	 */
	public var owner(default, null):Sprite;

	/**
	 * Maximum size allowed for the tooltip. A negative value (or zero) makes
	 * the tooltip auto-adjust its size to properly house its text.
	 */
	public var maxSize:Point;

	/**
	 * Creates a new tooltip.
	 *
	 * @param	target	Element the tooltip will monitor. If the tooltip is being used in "stand alone" fashion, i.e. not monitoring any element, then use `null` as the target.
	 * @param	text	Text displayed with this tooltip.
	 * @param	width	Width of the tooltip.  If a negative value (or zero) is specified, the tooltip will adjust its width to properly accommodate the text.
	 * @param	height	Height of the tooltip.  If a negative value (or zero) is specified, the tooltip will adjust its height to properly accommodate the text.
	 */
	public function new(target:Sprite, text:String, width:Float = 0, height:Float = 0)
	{
		super();

		owner = target;

		maxSize = new Point(width, height);

		_shadow = new Bitmap(new BitmapData(1, 2, true, FlxColor.BLACK));
		_background = new Bitmap(new BitmapData(1, 1, true, BG_COLOR));

		textField = DebuggerUtil.createTextField(2, 1);
		textField.alpha = TEXT_ALPHA;
		textField.text = text;
		textField.wordWrap = true;

		addChild(_shadow);
		addChild(_background);
		addChild(textField);

		updateSize();
		setVisible(false);

		if (owner != null)
		{
			owner.addEventListener(MouseEvent.MOUSE_OVER, handleMouseEvents);
			owner.addEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
		}
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_shadow = FlxDestroyUtil.removeChild(this, _shadow);
		_background = FlxDestroyUtil.removeChild(this, _background);
		textField = FlxDestroyUtil.removeChild(this, textField);
		maxSize = null;

		if (owner != null)
		{
			owner.removeEventListener(MouseEvent.MOUSE_OVER, handleMouseEvents);
			owner.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseEvents);
		}
		owner = null;
	}

	/**
	 * Resize the tooltip. Subject to pre-specified minimums, maximums, and bounding rectangles.
	 *
	 * @param 	Width	How wide to make the tooltip. If zero is specified, the tooltip will adjust its size to properly accommodate the text.
	 * @param 	Height	How tall to make the tooltip. If zero is specified, the tooltip will adjust its size to properly accommodate the text.
	 */
	public function resize(Width:Float, Height:Float):Void
	{
		maxSize.x = Std.int(Math.abs(Width));
		maxSize.y = Std.int(Math.abs(Height));
		updateSize();
	}

	/**
	 * Change the position of the tooltip.
	 *
	 * @param 	X	Desired X position of top left corner of the tooltip.
	 * @param 	Y	Desired Y position of top left corner of the tooltip.
	 */
	public function reposition(X:Float, Y:Float):Void
	{
		x = X;
		y = Y;
		ensureOnScreen();
	}

	public function setVisible(Value:Bool):Void
	{
		visible = Value;

		if (visible)
		{
			putOnTop();
			ensureOnScreen();
		}
	}

	/**
	 * Change the text of the tooltip.
	 *
	 * @param 	Text	Text to be used in the tooltip.
	 */
	public function setText(Text:String):Void
	{
		textField.text = Text;
		updateSize();
		ensureOnScreen();
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
	function updateSize():Void
	{
		_width = Std.int(maxSize.x <= 0 ? textField.textWidth : Math.abs(maxSize.x)) + 8;
		_height = Std.int(maxSize.y <= 0 ? textField.textHeight : Math.abs(maxSize.y)) + 8;
		_background.scaleX = _width;
		_background.scaleY = _height;
		_shadow.scaleX = _width;
		_shadow.y = _height;
		textField.width = _width;
	}

	function ensureOnScreen():Void
	{
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

	function handleMouseEvents(event:MouseEvent):Void
	{
		if (event.type == MouseEvent.MOUSE_OVER && !visible)
		{
			x = event.stageX + MARGIN_X;
			y = event.stageY + MARGIN_Y;

			setVisible(true);
		}
		else if (event.type == MouseEvent.MOUSE_OUT)
			setVisible(false);
	}
}
