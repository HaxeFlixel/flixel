package flixel.system.debug;

import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.display.DisplayObject;
import flixel.FlxG;
import flixel.system.debug.console.Console;
import flixel.system.debug.log.Log;
import flixel.system.debug.stats.Stats;
import flixel.system.debug.watch.Watch;
import flixel.system.debug.watch.Tracker;
import flixel.system.debug.completion.CompletionList;
import flixel.system.debug.log.BitmapLog;
import flixel.system.debug.interaction.Interaction;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxHorizontalAlign;

using flixel.util.FlxArrayUtil;

@:bitmap("assets/images/debugger/flixel.png")
private class GraphicFlixel extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/drawDebug.png")
private class GraphicDrawDebug extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/log.png")
@:noCompletion class GraphicLog extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/stats.png")
@:noCompletion class GraphicStats extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/watch.png")
@:noCompletion class GraphicWatch extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/bitmapLog.png")
@:noCompletion class GraphicBitmapLog extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/console.png")
@:noCompletion class GraphicConsole extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/arrowLeft.png")
@:noCompletion class GraphicArrowLeft extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/arrowRight.png")
@:noCompletion class GraphicArrowRight extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/close.png")
@:noCompletion class GraphicCloseButton extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/interactive.png")
@:noCompletion class GraphicInteractive extends BitmapData {}

/**
 * Container for the new debugger overlay. Most of the functionality is in the debug folder widgets,
 * but this class instantiates the widgets and handles their basic formatting and arrangement.
 */
class FlxDebugger extends Sprite
{
	#if FLX_DEBUG
	/**
	 * Internal, used to space out windows from the edges.
	 */
	public static inline var GUTTER:Int = 2;

	/**
	 * Internal, used to space out windows from the edges.
	 */
	public static inline var TOP_HEIGHT:Int = 20;

	public var stats:Stats;
	public var log:Log;
	public var watch:Watch;
	public var bitmapLog:BitmapLog;
	public var vcr:VCR;
	public var console:Console;
	public var interaction:Interaction;

	var completionList:CompletionList;

	/**
	 * Internal, tracks what debugger window layout user has currently selected.
	 */
	var _layout:FlxDebuggerLayout = FlxDebuggerLayout.STANDARD;

	/**
	 * Internal, stores width and height of the game.
	 */
	var _screen:Point = new Point();

	/**
	 * Stores the bounds in which the windows can move.
	 */
	var _screenBounds:Rectangle;

	var _buttons:Map<FlxHorizontalAlign, Array<FlxSystemButton>> = [LEFT => [], CENTER => [], RIGHT => []];

	/**
	 * The flash Sprite used for the top bar of the debugger ui
	**/
	var _topBar:Sprite;

	var _windows:Array<Window> = [];

	var _usingSystemCursor = false;
	var _wasMouseVisible:Bool = true;
	var _wasUsingSystemCursor:Bool = false;

	/**
	 * Instantiates the debugger overlay.
	 *
	 * @param   Width    The width of the screen.
	 * @param   Height   The height of the screen.
	 */
	@:allow(flixel.FlxGame)
	function new(Width:Float, Height:Float)
	{
		super();

		visible = false;
		tabChildren = false;

		Tooltip.init(this);

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
		var format = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xffffff);
		txt.defaultTextFormat = format;
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.text = Std.string(FlxG.VERSION);

		addWindow(log = new Log());
		addWindow(bitmapLog = new BitmapLog());
		addWindow(watch = new Watch());
		completionList = new CompletionList(5);
		addWindow(console = new Console(completionList));
		addWindow(stats = new Stats());
		addWindow(interaction = new Interaction(this));

		vcr = new VCR(this);

		addButton(LEFT, new GraphicFlixel(0, 0), openHomepage);
		addButton(LEFT, null, openGitHub).addChild(txt);

		addWindowToggleButton(interaction, GraphicInteractive);
		addWindowToggleButton(bitmapLog, GraphicBitmapLog);
		addWindowToggleButton(log, GraphicLog);

		addWindowToggleButton(watch, GraphicWatch);
		addWindowToggleButton(console, GraphicConsole);
		addWindowToggleButton(stats, GraphicStats);

		var drawDebugButton = addButton(RIGHT, new GraphicDrawDebug(0, 0), toggleDrawDebug, true);
		drawDebugButton.toggled = !FlxG.debugger.drawDebug;
		FlxG.debugger.drawDebugChanged.add(function()
		{
			drawDebugButton.toggled = !FlxG.debugger.drawDebug;
		});

		#if FLX_RECORD
		addButton(CENTER).addChild(vcr.runtimeDisplay);
		#end

		addChild(completionList);

		onResize(Width, Height);

		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

		FlxG.signals.preStateSwitch.add(Tracker.onStateSwitch);
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_screen = null;
		_buttons = null;

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
		if (bitmapLog != null)
		{
			removeChild(bitmapLog);
			bitmapLog.destroy();
			bitmapLog = null;
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
			window.update();
	}

	/**
	 * Change the way the debugger's windows are laid out.
	 *
	 * @param   Layout   The layout codes can be found in FlxDebugger, for example FlxDebugger.MICRO
	 */
	public inline function setLayout(Layout:FlxDebuggerLayout):Void
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
		switch (_layout)
		{
			case MICRO:
				log.resize(_screen.x / 4, 68);
				log.reposition(0, _screen.y);
				console.resize((_screen.x / 2) - GUTTER * 4, 35);
				console.reposition(log.x + log.width + GUTTER, _screen.y);
				watch.resize(_screen.x / 4, 68);
				watch.reposition(_screen.x, _screen.y);
				stats.reposition(_screen.x, 0);
				bitmapLog.resize(_screen.x / 4, 68);
				bitmapLog.reposition(0, _screen.y - (68 * 2) - (GUTTER * 2));
			case BIG:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 2);
				log.reposition(0, _screen.y - log.height - console.height - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 2);
				watch.reposition(_screen.x, _screen.y - watch.height - console.height - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);
				bitmapLog.resize((_screen.x - GUTTER * 3) / 2, _screen.y - (GUTTER * 2) - (_screen.y / 2) - (35 * 2));
				bitmapLog.reposition(0, GUTTER * 1.5);
			case TOP:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(0, 0);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0, console.height + GUTTER + 15);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x, console.height + GUTTER + 15);
				stats.reposition(_screen.x, _screen.y);
				bitmapLog.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				bitmapLog.reposition(0, console.height + (GUTTER * 2) + 15 + (_screen.y / 4) + GUTTER);
			case LEFT:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2 - GUTTER);
				log.reposition(0, 0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2);
				watch.reposition(0, log.y + log.height + GUTTER);
				stats.reposition(_screen.x, 0);
				bitmapLog.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2 - GUTTER);
				bitmapLog.reposition((_screen.x / 3) + GUTTER * 2, 0);
			case RIGHT:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2 - GUTTER);
				log.reposition(_screen.x, 0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2);
				watch.reposition(_screen.x, log.y + log.height + GUTTER);
				stats.reposition(0, 0);
				bitmapLog.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2 - GUTTER);
				bitmapLog.reposition(_screen.x - (GUTTER * 2) - ((_screen.x / 3) * 2), 0);
			case STANDARD:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0, _screen.y - log.height - console.height - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x, _screen.y - watch.height - console.height - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);
				bitmapLog.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				bitmapLog.reposition(0, log.y - GUTTER - bitmapLog.height);
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
		scaleX = scaleY = 1;
		x = -FlxG.scaleMode.offset.x;
		y = -FlxG.scaleMode.offset.y;
	}

	function updateBounds():Void
	{
		_screenBounds = new Rectangle(GUTTER, TOP_HEIGHT + GUTTER / 2, _screen.x - GUTTER * 2, _screen.y - GUTTER * 2 - TOP_HEIGHT);
		for (window in _windows)
		{
			window.updateBounds(_screenBounds);
		}
	}

	/**
	 * Align an array of debugger buttons, used for the middle and right layouts
	 */
	function hAlignButtons(Sprites:Array<FlxSystemButton>, Padding:Float = 0, Set:Bool = true, LeftOffset:Float = 0):Float
	{
		var width:Float = 0;
		var last:Float = LeftOffset;

		for (i in 0...Sprites.length)
		{
			var o:Sprite = Sprites[i];
			width += o.width + Padding;
			if (Set)
				o.x = last;
			last = o.x + o.width + Padding;
		}

		return width;
	}

	/**
	 * Position the debugger buttons
	 */
	function resetButtonLayout():Void
	{
		hAlignButtons(_buttons[FlxHorizontalAlign.LEFT], 10, true, 10);

		var offset = FlxG.stage.stageWidth * 0.5 - hAlignButtons(_buttons[FlxHorizontalAlign.CENTER], 10, false) * 0.5;
		hAlignButtons(_buttons[FlxHorizontalAlign.CENTER], 10, true, offset);

		var offset = FlxG.stage.stageWidth - hAlignButtons(_buttons[FlxHorizontalAlign.RIGHT], 10, false);
		hAlignButtons(_buttons[FlxHorizontalAlign.RIGHT], 10, true, offset);
	}

	/**
	 * Create and add a new debugger button.
	 *
	 * @param   Position       Either LEFT, CENTER or RIGHT.
	 * @param   Icon           The icon to use for the button
	 * @param   UpHandler      The function to be called when the button is pressed.
	 * @param   ToggleMode     Whether this is a toggle button or not.
	 * @param   UpdateLayout   Whether to update the button layout.
	 * @return  The added button.
	 */
	public function addButton(Position:FlxHorizontalAlign, ?Icon:BitmapData, ?UpHandler:Void->Void, ToggleMode:Bool = false,
			UpdateLayout:Bool = false):FlxSystemButton
	{
		var button = new FlxSystemButton(Icon, UpHandler, ToggleMode);
		button.y = (TOP_HEIGHT / 2) - (button.height / 2);
		_buttons[Position].push(button);
		addChild(button);

		if (UpdateLayout)
			resetButtonLayout();

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

		_buttons[FlxHorizontalAlign.LEFT].remove(Button);
		_buttons[FlxHorizontalAlign.CENTER].remove(Button);
		_buttons[FlxHorizontalAlign.RIGHT].remove(Button);

		if (UpdateLayout)
			resetButtonLayout();
	}

	public function addWindowToggleButton(window:Window, icon:Class<BitmapData>):Void
	{
		var button = addButton(RIGHT, Type.createInstance(icon, [0, 0]), window.toggleVisible, true, true);
		window.toggleButton = button;
		button.toggled = !window.visible;
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
			removeChild(window);
		_windows.fastSplice(window);
	}

	override public function addChild(child:DisplayObject):DisplayObject
	{
		var result = super.addChild(child);
		// hack to make sure the completion list always stays on top
		if (completionList != null)
			super.addChild(completionList);
		return result;
	}

	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 */
	function onMouseOver(_):Void
	{
		onMouseFocus();
	}

	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 */
	function onMouseOut(_):Void
	{
		onMouseFocusLost();
	}

	function onMouseFocus():Void
	{
		#if FLX_MOUSE
		FlxG.mouse.enabled = false;
		_wasMouseVisible = FlxG.mouse.visible;
		_wasUsingSystemCursor = FlxG.mouse.useSystemCursor;
		FlxG.mouse.useSystemCursor = true;
		_usingSystemCursor = true;
		#end
	}

	@:allow(flixel.system.debug)
	function onMouseFocusLost():Void
	{
		#if FLX_MOUSE
		// Disable mouse input if the interaction tool is in use,
		// so users can select interactable elements, e.g. buttons.
		FlxG.mouse.enabled = !interaction.isInUse();

		if (_usingSystemCursor)
		{
			FlxG.mouse.useSystemCursor = _wasUsingSystemCursor;
			FlxG.mouse.visible = _wasMouseVisible;
		}
		#end
	}

	inline function toggleDrawDebug():Void
	{
		FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
	}

	inline function openHomepage():Void
	{
		FlxG.openURL("http://www.haxeflixel.com");
	}

	inline function openGitHub():Void
	{
		var url = "https://github.com/HaxeFlixel/flixel";
		if (FlxVersion.sha != "")
		{
			url += '/commit/${FlxVersion.sha}';
		}
		FlxG.openURL(url);
	}
	#end
}

enum FlxDebuggerLayout
{
	STANDARD;
	MICRO;
	BIG;
	TOP;
	LEFT;
	RIGHT;
}
