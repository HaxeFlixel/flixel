package flixel.system.debug;

#if !FLX_NO_DEBUG

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.debug.Console;
import flixel.system.debug.Log;
import flixel.system.debug.Stats;
import flixel.system.debug.VCR;
import flixel.system.debug.Watch;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

@:bitmap("assets/images/debugger/flixel.png")	           private class GraphicFlixel     extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/drawDebug.png")   private class GraphicDrawDebug  extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/log.png")         class GraphicLog        extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/stats.png")       class GraphicStats      extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/watch.png")       class GraphicWatch      extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/console.png")     class GraphicConsole    extends BitmapData {}

/**
 * Container for the new debugger overlay. Most of the functionality is in the debug folder widgets,
 * but this class instantiates the widgets and handles their basic formatting and arrangement.
 */
class FlxDebugger extends Sprite
{
	/**
	 * Internal, used to space out windows from the edges.
	 */
	public static inline var GUTTER:Int = 2;
	/**
	 * Internal, used to space out windows from the edges.
	 */
	public static inline var TOP_HEIGHT:Int = 20;
	
	/**
	 * Container for the performance monitor widget.
	 */
	public var stats:Stats;
	/**
	 * Container for the trace output widget.
	 */	 
	public var log:Log;
	/**
	 * Container for the watch window widget.
	 */
	public var watch:Watch;
	/**
	 * Container for the record, stop and play buttons.
	 */
	public var vcr:VCR;
	/**
	 * Container for console.
	 */
	public var console:Console;
	/**
	 * Whether the mouse is currently over one of the debugger windows or not.
	 */
	public var hasMouse:Bool = false;
	
	/**
	 * Internal, tracks what debugger window layout user has currently selected.
	 */
	private var _layout:DebuggerLayout;
	/**
	 * Internal, stores width and height of the Flash Player window.
	 */
	private var _screen:Point;
	/**
	 * Stores the bounds in which the windows can move.
	 */
	private var _screenBounds:Rectangle;
	/**
	 * Internal, used to store the middle debugger buttons for laying them out.
	 */
	private var _middleButtons:Array<FlxSystemButton>;
	/**
	 * Internal, used to store the left debugger buttons for laying them out.
	 */
	private var _leftButtons:Array<FlxSystemButton>;
	/**
	 * Internal, used to store the right debugger buttons for laying them out.
	 */
	private var _rightButtons:Array<FlxSystemButton>;
	/**
	 * The flash Sprite used for the top bar of the debugger ui
	 **/
	private var _topBar:Sprite;
	private var _windows:Array<Window>;

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_screen = null;
		
		for (o in _rightButtons)
		{
			o.destroy();
		}
		_rightButtons = null;
		
		for (o in _leftButtons)
		{
			o.destroy();
		}
		_leftButtons = null;
		
		for (o in _middleButtons)
		{
			o.destroy();
		}
		_middleButtons = null;
		
		removeChild(_topBar);
		_topBar = null;
		
		if (log != null)
		{
			removeChild(log);
			log.destroy();
			log = null;
		}
		if (watch != null)
		{
			removeChild(watch);
			watch.destroy();
			watch = null;
		}
		if (stats != null)
		{
			removeChild(stats);
			stats.destroy();
			stats = null;
		}
		if (console != null) 
		{
			removeChild(console);
			console.destroy();
			console = null;
		}
		
		_windows = null;
		
		removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}
	
	public function update():Void
	{
		for (window in _windows)
		{
			window.update();
		}
	}
	
	/**
	 * Change the way the debugger's windows are laid out.
	 * 
	 * @param   Layout   The layout codes can be found in FlxDebugger, for example FlxDebugger.MICRO
	 */
	public inline function setLayout(Layout:DebuggerLayout):Void
	{
		_layout = Layout;
		resetLayout();
	}
	
	/**
	 * Forces the debugger windows to reset to the last specified layout.
	 * The default layout is STANDARD.
	 */
	public function resetLayout():Void
	{
		switch(_layout)
		{
			case MICRO:
				log.resize(_screen.x / 4, 68);
				log.reposition(0, _screen.y);
				console.resize((_screen.x / 2) - GUTTER * 4, 35);
				console.reposition(log.x + log.width + GUTTER, _screen.y);
				watch.resize(_screen.x / 4, 68);
				watch.reposition(_screen.x,_screen.y);
				stats.reposition(_screen.x, 0);
			case BIG:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 2);
				log.reposition(0, _screen.y - log.height - console.height - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 2);
				watch.reposition(_screen.x, _screen.y - watch.height - console.height - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);
			case TOP:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(0, 0);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0,console.height + GUTTER + 15);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,console.height + GUTTER + 15);
				stats.reposition(_screen.x,_screen.y);
			case LEFT:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2 - GUTTER);
				log.reposition(0,0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2);
				watch.reposition(0,log.y + log.height + GUTTER);
				stats.reposition(_screen.x, 0);
			case RIGHT:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2 - GUTTER);
				log.reposition(_screen.x,0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2);
				watch.reposition(_screen.x,log.y + log.height + GUTTER);
				stats.reposition(0, 0);
			case STANDARD:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0,_screen.y - log.height - console.height - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,_screen.y - watch.height - console.height - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);
		}
	}
	
	public function onResize(Width:Float, Height:Float):Void
	{
		_screen.x = Width;
		_screen.y = Height;
		
		updateBounds();
		_topBar.width = FlxG.stage.stageWidth;
		resetButtonLayout();
		resetLayout();
		scaleX = 1 / FlxG.game.scaleX;
		scaleY = 1 / FlxG.game.scaleY;
		x = -FlxG.game.x * scaleX;
		y = -FlxG.game.y * scaleY;
	}
	
	private function updateBounds():Void
	{
		_screenBounds = new Rectangle(GUTTER, TOP_HEIGHT + GUTTER / 2, _screen.x - GUTTER * 2, _screen.y - GUTTER * 2 - TOP_HEIGHT);
		for (window in _windows)
		{
			window.updateBounds(_screenBounds);
		}
	}
	
	public function onStateSwitch():Void
	{
		for (window in _windows)
		{
			if (Std.is(window, Tracker))
			{
				window.close();
			}
		}
		Tracker.onStateSwitch();
	}

	/**
	 * Align an array of debugger buttons, used for the middle and right layouts
	 */
	public function hAlignButtons(Sprites:Array<FlxSystemButton>, Padding:Float = 0, Set:Bool = true, LeftOffset:Float = 0):Float
	{
		var width:Float = 0;
		var last:Float = LeftOffset;
		
		for (i in 0...Sprites.length)
		{
			var o:Sprite = Sprites[i];
			width += o.width + Padding;
			if (Set) {
				o.x = last;
			}
			last = o.x + o.width + Padding;
		}
		
		return width;
	}

	/**
	 * Position the debugger buttons
	 */
	public function resetButtonLayout():Void
	{
		hAlignButtons(_leftButtons, 10, true, 10);
		
		var offset = FlxG.stage.stageWidth * 0.5 - hAlignButtons(_middleButtons, 10, false) * 0.5;
		hAlignButtons(_middleButtons, 10, true, offset);
		
		var offset = FlxG.stage.stageWidth - hAlignButtons(_rightButtons, 10, false);
		hAlignButtons(_rightButtons, 10, true, offset);
	}
	
	/**
	 * Create and add a new debugger button.
	 * 
	 * @param   Position       Either LEFT, MIDDLE or RIGHT.
	 * @param   Icon           The icon to use for the button
	 * @param   UpHandler      The function to be called when the button is pressed.
	 * @param   ToggleMode     Whether this is a toggle button or not.
	 * @param   UpdateLayout   Whether to update the button layout.
	 * @return  The added button.
	 */
	public function addButton(Position:ButtonAlignment, ?Icon:BitmapData, ?UpHandler:Void->Void, ToggleMode:Bool = false, UpdateLayout:Bool = false):FlxSystemButton
	{
		var button = new FlxSystemButton(Icon, UpHandler, ToggleMode);
		
		var array:Array<FlxSystemButton>; 
		switch (Position)
		{
			case LEFT:
				array = _leftButtons;
			case MIDDLE:
				array = _middleButtons;
			case RIGHT:
				array = _rightButtons;
		}
		
		button.y = (TOP_HEIGHT / 2) - (button.height / 2);
		array.push(button);
		addChild(button);
		
		if (UpdateLayout)
		{
			resetButtonLayout();
		}
		
		return button;
	}
	
	/**
	 * Removes and destroys a button from the debugger.
	 * 
	 * @param   Button         The FlxSystemButton instance to remove.
	 * @param   UpdateLayout   Whether to update the button layout.
	 */
	public function removeButton(Button:FlxSystemButton, UpdateLayout:Bool = true):Void
	{
		removeChild(Button);
		Button.destroy();
		removeButtonFromArray(_leftButtons, Button);
		removeButtonFromArray(_middleButtons, Button);
		removeButtonFromArray(_rightButtons, Button);
		
		if (UpdateLayout)
		{
			resetButtonLayout();
		}
	}
	
	public inline function addWindow(window:Window):Window
	{
		_windows.push(window);
		addChild(window);
		if (_screenBounds != null)
		{
			updateBounds();
			window.bound();
		}
		return window;
	}
	
	public inline function removeWindow(window:Window):Void
	{
		if (contains(window))
		{
			removeChild(window);
		}
		FlxArrayUtil.fastSplice(_windows, window);
	}
	
	/**
	 * Instantiates the debugger overlay.
	 * 
	 * @param   Width    The width of the screen.
	 * @param   Height   The height of the screen.
	 */
	@:allow(flixel.FlxGame)
	private function new(Width:Float, Height:Float)
	{
		super();
		visible = false;
		_layout = STANDARD;
		_screen = new Point();
		_windows = [];
		
		_topBar = new Sprite();
		_topBar.graphics.beginFill(0x000000, 0xAA / 255);
		_topBar.graphics.drawRect(0, 0, FlxG.stage.stageWidth, TOP_HEIGHT);
		_topBar.graphics.endFill();
		addChild(_topBar);
		
		var txt = new TextField();
		txt.height = 20;
		txt.selectable = false;
		txt.y = -9;
		txt.multiline = false;
		txt.embedFonts = true;
		var format = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, FlxColor.WHITE);
		txt.defaultTextFormat = format;
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.text = Std.string(FlxG.VERSION);
		
		_leftButtons = new Array<FlxSystemButton>();
		_rightButtons = new Array<FlxSystemButton>();
		_middleButtons = new Array<FlxSystemButton>();
		
		addWindow(log = new Log());
		addWindow(watch = new Watch());
		addWindow(console = new Console());
		addWindow(stats = new Stats());
		
		stats.visible = true;
		
		vcr = new VCR(this);
		
		addButton(LEFT, new GraphicFlixel(0, 0), openHomepage);
		addButton(LEFT, null, openHomepage).addChild(txt);
		
		addButton(RIGHT, new GraphicLog(0, 0), log.toggleVisibility, true).toggled = !log.visible; 
		addButton(RIGHT, new GraphicWatch(0, 0), watch.toggleVisibility, true).toggled = !watch.visible; 
		addButton(RIGHT, new GraphicConsole(0, 0), console.toggleVisibility, true).toggled = !console.visible; 
		addButton(RIGHT, new GraphicStats(0, 0), stats.toggleVisibility, true).toggled = !stats.visible; 
		addButton(RIGHT, new GraphicDrawDebug(0, 0), toggleVisualDebug, true).toggled = !FlxG.debugger.drawDebug;
		
		#if FLX_RECORD
		addButton(MIDDLE).addChild(vcr.runtimeDisplay);
		#end
		
		onResize(Width, Height);
		
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}
	
	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 * 
	 * @param   E   Flash mouse event.
	 */
	private inline function onMouseOver(?E:MouseEvent):Void
	{
		hasMouse = true;
		#if !FLX_NO_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end
	}
	
	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 * 
	 * @param   E   Flash mouse event.
	 */
	private inline function onMouseOut(?E:MouseEvent):Void
	{
		hasMouse = false;
		
		#if !FLX_NO_MOUSE
		if (!FlxG.vcr.paused)
		{
			FlxG.mouse.useSystemCursor = false;
		}
		#end
	}
	
	private function removeButtonFromArray(Arr:Array<FlxSystemButton>, Button:FlxSystemButton):Void
	{
		var index = FlxArrayUtil.indexOf(Arr, Button);
		if (index != -1)
		{
			Arr.splice(index, 1);
		}
	}

	private inline function toggleVisualDebug ():Void
	{
		FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
	}
	
	private inline function openHomepage():Void
	{
		FlxG.openURL("http://www.haxeflixel.com");
	}
}
#end

enum ButtonAlignment {
	LEFT;
	MIDDLE;
	RIGHT;
}

enum DebuggerLayout {
	STANDARD;
	MICRO;
	BIG;
	TOP;
	LEFT;
	RIGHT;
}
