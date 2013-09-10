package flixel.system.debug;

#if !FLX_NO_DEBUG

import flash.text.TextFieldAutoSize;
import flash.Lib;
import flash.text.TextFormatAlign;
import flixel.util.FlxColor;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.debug.Console;
import flixel.system.debug.Log;
import flixel.system.debug.Stats;
import flixel.system.debug.VCR;
import flixel.system.debug.Watch;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;

/**
 * Container for the new debugger overlay.
 * Most of the functionality is in the debug folder widgets,
 * but this class instantiates the widgets and handles their basic formatting and arrangement.
 */
class FlxDebugger extends Sprite
{
	/**
	 * Debugger overlay layout preset: Wide but low windows at the bottom of the screen.
	 */
	inline static public var STANDARD:Int = 0;
	
	/**
	 * Debugger overlay layout preset: Tiny windows in the screen corners.
	 */
	inline static public var MICRO:Int = 1;
	
	/**
	 * Debugger overlay layout preset: Large windows taking up bottom half of screen.
	 */
	inline static public var BIG:Int = 2;
	
	/**
	 * Debugger overlay layout preset: Wide but low windows at the top of the screen.
	 */
	inline static public var TOP:Int = 3;
	
	/**
	 * Debugger overlay layout preset: Large windows taking up left third of screen.
	 */
	inline static public var LEFT:Int = 4;
	
	/**
	 * Debugger overlay layout preset: Large windows taking up right third of screen.
	 */
	inline static public var RIGHT:Int = 5;

	/**
	 * Internal, used to space out windows from the edges.
	 */
	inline static public var GUTTER:Int = 2;
	/**
	 * Internal, used to space out windows from the edges.
	 */
	inline static public var TOP_HEIGHT:Int = 20;
	
	/**
	 * Container for the performance monitor widget.
	 */
	public var stats:Stats;
	/**
	 * Container for the bitmap output widget
	 */
	public var bmpLog:BmpLog;	
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
	public var hasMouse:Bool;
	
	/**
	 * Internal, tracks what debugger window layout user has currently selected.
	 */
	private var _layout:Int;
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
	
	/**
	 * Instantiates the debugger overlay.
	 * 
	 * @param 	Width	The width of the screen.
	 * @param 	Height	The height of the screen.
	 */
	public function new(Width:Float, Height:Float)
	{
		super();
		visible = false;
		hasMouse = false;
		_screen = new Point();

		_topBar = new Sprite();
		_topBar.graphics.beginFill(0x000000, 0x7f / 255);
		_topBar.graphics.drawRect(0, 0, FlxG.stage.stageWidth, TOP_HEIGHT);
		_topBar.graphics.endFill();
		addChild(_topBar);

		var txt = new TextField();
		txt.height = 20;
		txt.selectable = false;
		txt.multiline = false;
		txt.embedFonts = true;
		var format = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, FlxColor.WHITE);
		txt.defaultTextFormat = format;
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.text = FlxG.libraryName;

		log = new Log("log", 0, 0, true);
		addChild(log);
		
		watch = new Watch("watch", 0, 0, true);
		addChild(watch);
		
		console = new Console("console", 0, 0, false);
		addChild(console);
		
		stats = new Stats("stats", 0, 0, false);
		addChild(stats);

		#if FLX_BMP_DEBUG
		bmpLog = new BmpLog("bmplog", 0, 0, true);
		addChild(bmpLog);
		#end
		
		vcr = new VCR();

		_leftButtons = new Array<FlxSystemButton>();
		_middleButtons = new Array<FlxSystemButton>();
		_rightButtons = new Array<FlxSystemButton>();

		addCreateLeftButton(FlxAssets.IMG_FLIXEL, null, false);

		var display = new FlxSystemButton(null, null);
		display.addChild(txt);
		addLeftButton(display);

		addCreateRightButton(FlxAssets.IMG_LOG_DEBUG, toggleLogWindow, false);
		addCreateRightButton(FlxAssets.IMG_WATCH_DEBUG, toggleWatchWindow, false);
		addCreateRightButton(FlxAssets.IMG_CONSOLE, toggleConsoleWindow, false);
		addCreateRightButton(FlxAssets.IMG_STATS_DEBUG, toggleStatsWindow, false);
		addCreateRightButton(FlxAssets.IMG_VISUAL_DEBUG, toggleVisualDebug, false);

		addMiddleButton(vcr.restartBtn, false);
		#if FLX_RECORD
		addMiddleButton(vcr.openBtn, false);
		addMiddleButton(vcr.recordBtn, false);
		#end
		addMiddleButton(vcr.playbackToggleBtn, false);
		addMiddleButton(vcr.stepBtn, false);

		#if FLX_RECORD
		var runtimeDisplay = new FlxSystemButton(null, null);
		runtimeDisplay.addChild(vcr.runtimeDisplay);
		addMiddleButton(runtimeDisplay, false);
		#end

		onResize(Width, Height);

		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}

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

		if (bmpLog != null) 
		{
			removeChild(bmpLog);
			bmpLog.destroy();
			bmpLog = null;
		}		
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
		
		removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}
	
	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseOver(?E:MouseEvent):Void
	{
		hasMouse = true;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end
	}
	
	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseOut(?E:MouseEvent):Void
	{
		hasMouse = false;
		
		#if !FLX_NO_MOUSE
		if(!FlxG.vcr.paused)
			FlxG.mouse.useSystemCursor = false;
		#end
	}
	
	/**
	 * Change the way the debugger's windows are laid out.
	 * 
	 * @param	Layout	The layout codes can be found in <code>FlxDebugger</code>, for example <code>FlxDebugger.MICRO</code>
	 */
	public function setLayout(Layout:Int):Void
	{
		_layout = Layout;
		resetLayout();
	}
	
	/**
	 * Forces the debugger windows to reset to the last specified layout.
	 * The default layout is <code>STANDARD</code>.
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
				console.reposition(0,0);
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
				stats.reposition(_screen.x,0);
			case RIGHT:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2 - GUTTER);
				log.reposition(_screen.x,0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 - console.height / 2);
				watch.reposition(_screen.x,log.y + log.height + GUTTER);
				stats.reposition(0,0);
			case STANDARD:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0,_screen.y - log.height - console.height - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,_screen.y - watch.height - console.height - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);
				if (bmpLog != null) {
					bmpLog.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
					bmpLog.reposition(_screen.x, _screen.y - watch.height - bmpLog.height - console.height - GUTTER * 1.5);
				}
			default:
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0,_screen.y - log.height - console.height - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,_screen.y - watch.height - console.height - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);				
		}
	}
	
	inline public function onResize(Width:Float, Height:Float):Void
	{
		_screen.x = Width;
		_screen.y = Height;
		_screenBounds = new Rectangle(GUTTER, TOP_HEIGHT + GUTTER / 2, _screen.x - GUTTER * 2, _screen.y - GUTTER * 2 - TOP_HEIGHT);
		stats.updateBounds(_screenBounds);
		log.updateBounds(_screenBounds);
		watch.updateBounds(_screenBounds);
		console.updateBounds(_screenBounds);
		if (bmpLog != null) {
			bmpLog.updateBounds(_screenBounds);
		}
		_topBar.width = FlxG.stage.stageWidth;
		resetButtonLayout();
		resetLayout();
	}

	/**
	* Align an array of debugger buttons, used for the middle and right layouts
	*/
	public function hAlignSprites (Sprites:Array<Dynamic>, Padding:Float = 0, Set:Bool = true, LeftOffset:Float = 0):Float
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
	private function resetButtonLayout ():Void
	{
		hAlignSprites(_leftButtons, 10, true, 10);

		var offset = FlxG.stage.stageWidth*.5 - hAlignSprites(_middleButtons, 10, false)*.5;
		hAlignSprites(_middleButtons, 10, true, offset);

		var offset = FlxG.stage.stageWidth - hAlignSprites(_rightButtons, 10, false);
		hAlignSprites(_rightButtons, 10, true, offset);
	}

	/**
	* Add a debugger button the the middle layout
	*/
	public function addCreateMiddleButton (BitmapUrl:String, ?Handler:Dynamic, UpdateLayout:Bool = true):FlxSystemButton
	{
		var button = new FlxSystemButton(FlxAssets.getBitmapData(BitmapUrl), Handler);

		return addMiddleButton(button, UpdateLayout);
	}

	/**
	* Add a debugger button the the right layout
	*/
	public function addCreateRightButton (BitmapUrl:String, ?Handler:Dynamic, UpdateLayout:Bool = true):FlxSystemButton
	{
		var button = new FlxSystemButton(FlxAssets.getBitmapData(BitmapUrl), Handler);

		return addRightButton(button, UpdateLayout);
	}

	/**
	* Add a debugger button the the right layout
	*/
	public function addCreateLeftButton (BitmapUrl:String, ?Handler:Dynamic, UpdateLayout:Bool = true):FlxSystemButton
	{
		var button = new FlxSystemButton(FlxAssets.getBitmapData(BitmapUrl), Handler);

		return addLeftButton(button, UpdateLayout);
	}

	/**
	* Add a debugger button the the middle layout
	*/
	public function addMiddleButton (Button:FlxSystemButton, UpdateLayout:Bool = true):FlxSystemButton
	{
		Button.y = (TOP_HEIGHT*.5) - (Button.height*.5);
		_middleButtons.push(Button);
		addChild(Button);

		if (UpdateLayout)
			resetButtonLayout();

		return Button;
	}

	/**
	* Add a debugger button the the middle layout
	*/
	public function addLeftButton (Button:FlxSystemButton, UpdateLayout:Bool = true):FlxSystemButton
	{
		Button.y = (TOP_HEIGHT*.5) - (Button.height*.5);
		_leftButtons.push(Button);
		addChild(Button);

		if (UpdateLayout)
			resetButtonLayout();

		return Button;
	}

	/**
	* Add a debugger button the the right layout
	*/
	public function addRightButton (Button:FlxSystemButton, UpdateLayout:Bool = true):FlxSystemButton
	{
		Button.y = (TOP_HEIGHT*.5) - (Button.height*.5);
		_rightButtons.push(Button);
		addChild(Button);

		if (UpdateLayout)
			resetButtonLayout();

		return Button;
	}

	public function toggleConsoleWindow ():Void
	{
		console.visible ? console.visible = false : console.visible = true;
	}

	public function toggleWatchWindow ():Void
	{
		watch.visible ? watch.visible = false : watch.visible = true;
	}

	public function toggleLogWindow ():Void
	{
		log.visible ? log.visible = false : log.visible = true;
	}

	public function toggleStatsWindow ():Void
	{
		stats.visible ? stats.visible = false : stats.visible = true;
	}

	public function toggleVisualDebug ():Void
	{
		FlxG.debugger.visualDebug = !FlxG.debugger.visualDebug;
	}
}
#end
