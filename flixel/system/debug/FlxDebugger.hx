package flixel.system.debug;

#if !FLX_NO_DEBUG

import flash.text.TextFieldAutoSize;
import flash.Lib;
import flash.text.TextFormatAlign;
import flixel.util.FlxArrayUtil;
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
import flixel.util.FlxMisc;

/**
 * Container for the new debugger overlay.
 * Most of the functionality is in the debug folder widgets,
 * but this class instantiates the widgets and handles their basic formatting and arrangement.
 */
class FlxDebugger extends Sprite
{
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
	
	#if !mobile
	/**
	 * Container for console.
	 */
	public var console:Console;
	#end
	
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
		_layout = STANDARD;
		_screen = new Point();
		
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
		txt.text = FlxG.libraryName;
		
		_leftButtons = new Array<FlxSystemButton>();
		_rightButtons = new Array<FlxSystemButton>();
		_middleButtons = new Array<FlxSystemButton>();
		
		log = new Log("log", FlxAssets.IMG_LOG_DEBUG, 0, 0, true);
		addChild(log);
		
		watch = new Watch("watch", FlxAssets.IMG_WATCH_DEBUG, 0, 0, true);
		addChild(watch);
		
		#if !mobile
		console = new Console("console", FlxAssets.IMG_CONSOLE, 0, 0, false);
		addChild(console);
		#end
		
		stats = new Stats("stats", FlxAssets.IMG_STATS_DEBUG, 0, 0, false);
		addChild(stats);
		
		#if FLX_BMP_DEBUG
		bmpLog = new BmpLog("bmplog", 0, 0, true);
		addChild(bmpLog);
		#end
		
		vcr = new VCR(this);
		
		addButton(LEFT, FlxAssets.IMG_FLIXEL, openHomepage);
		addButton(LEFT, null, openHomepage).addChild(txt);
		
		addButton(RIGHT, FlxAssets.IMG_LOG_DEBUG, log.toggleVisibility, true).toggled = !log.visible; 
		addButton(RIGHT, FlxAssets.IMG_WATCH_DEBUG, watch.toggleVisibility, true).toggled = !watch.visible; 
		#if !mobile
		addButton(RIGHT, FlxAssets.IMG_CONSOLE, console.toggleVisibility, true).toggled = !console.visible; 
		#end
		addButton(RIGHT, FlxAssets.IMG_STATS_DEBUG, stats.toggleVisibility, true).toggled = !stats.visible; 
		addButton(RIGHT, FlxAssets.IMG_VISUAL_DEBUG, toggleVisualDebug, true).toggled = !FlxG.debugger.visualDebug;
		
		#if FLX_RECORD
		addButton(MIDDLE).addChild(vcr.runtimeDisplay);
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
		#if !mobile
		if (console != null) 
		{
			removeChild(console);
			console.destroy();
			console = null;
		}
		#end
		
		removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}
	
	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 * @param	E	Flash mouse event.
	 */
	inline private function onMouseOver(?E:MouseEvent):Void
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
	inline private function onMouseOut(?E:MouseEvent):Void
	{
		hasMouse = false;
		
		#if !FLX_NO_MOUSE
		if (!FlxG.vcr.paused)
		{
			FlxG.mouse.useSystemCursor = false;
		}
		#end
	}
	
	/**
	 * Change the way the debugger's windows are laid out.
	 * 
	 * @param	Layout	The layout codes can be found in <code>FlxDebugger</code>, for example <code>FlxDebugger.MICRO</code>
	 */
	inline public function setLayout(Layout:DebuggerLayout):Void
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
				#if !mobile
				console.resize((_screen.x / 2) - GUTTER * 4, 35);
				console.reposition(log.x + log.width + GUTTER, _screen.y);
				#end
				watch.resize(_screen.x / 4, 68);
				watch.reposition(_screen.x,_screen.y);
				stats.reposition(_screen.x, 0);
			case BIG:
				#if !mobile
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				#end
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 2);
				log.reposition(0, _screen.y - log.height #if !mobile - console.height #end - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 2);
				watch.reposition(_screen.x, _screen.y - watch.height #if !mobile - console.height #end - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);
			case TOP:
				#if !mobile
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(0, 0);
				#end
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0, #if !mobile console.height + #end GUTTER + 15);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x, #if !mobile console.height + #end GUTTER + 15);
				stats.reposition(_screen.x,_screen.y);
			case LEFT:
				#if !mobile
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				#end
				log.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 #if !mobile - (console.height / 2) #end - GUTTER);
				log.reposition(0,0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 #if !mobile - (console.height / 2) #end);
				watch.reposition(0,log.y + log.height + GUTTER);
				stats.reposition(_screen.x,0);
			case RIGHT:
				#if !mobile
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				#end
				log.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 #if !mobile - (console.height / 2) #end - GUTTER);
				log.reposition(_screen.x,0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - GUTTER * 2.5) / 2 #if !mobile  - (console.height / 2) #end);
				watch.reposition(_screen.x,log.y + log.height + GUTTER);
				stats.reposition(0,0);
			case STANDARD:
				#if !mobile
				console.resize(_screen.x - GUTTER * 2, 35);
				console.reposition(GUTTER, _screen.y);
				#end
				log.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				log.reposition(0,_screen.y - log.height #if !mobile - console.height #end - GUTTER * 1.5);
				watch.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,_screen.y - watch.height #if !mobile - console.height #end - GUTTER * 1.5);
				stats.reposition(_screen.x, 0);
				if (bmpLog != null) {
					bmpLog.resize((_screen.x - GUTTER * 3) / 2, _screen.y / 4);
					bmpLog.reposition(_screen.x, _screen.y - watch.height - bmpLog.height #if !mobile - console.height #end - GUTTER * 1.5);
				}
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
		#if !mobile
		console.updateBounds(_screenBounds);
		#end
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
	public function hAlignSprites(Sprites:Array<Dynamic>, Padding:Float = 0, Set:Bool = true, LeftOffset:Float = 0):Float
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
		hAlignSprites(_leftButtons, 10, true, 10);
		
		var offset = FlxG.stage.stageWidth * 0.5 - hAlignSprites(_middleButtons, 10, false) * 0.5;
		hAlignSprites(_middleButtons, 10, true, offset);
		
		var offset = FlxG.stage.stageWidth - hAlignSprites(_rightButtons, 10, false);
		hAlignSprites(_rightButtons, 10, true, offset);
	}
	
	/**
	 * Create and add a new debugger button.
	 * @param	Position	Either LEFT,  MIDDLE or RIGHT.
	 * @param	IconPath	The path to the image to use as the icon for the button.
	 * @param	DownHandler	The function to be called when the button is pressed.
	 * @param	ToggleMode	Whether this is a toggle button or not.
	 * @param	UpdateLayout	Whether to update the button layout.
	 */
	public function addButton(Position:ButtonAlignment, ?IconPath:String, ?DownHandler:Dynamic, ToggleMode:Bool = false, UpdateLayout:Bool = false):FlxSystemButton
	{
		var button = new FlxSystemButton(IconPath, DownHandler, ToggleMode);
		
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
	 * @param	Button			The FlxSystemButton instance to remove.
	 * @param	UpdateLayout	Whether to update the button layout.
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
	
	private function removeButtonFromArray(Arr:Array<FlxSystemButton>, Button:FlxSystemButton):Void
	{
		var index = FlxArrayUtil.indexOf(Arr, Button);
		if (index != -1)
		{
			Arr.splice(index, 1);
		}
	}

	inline private function toggleVisualDebug ():Void
	{
		FlxG.debugger.visualDebug = !FlxG.debugger.visualDebug;
	}
	
	inline private function openHomepage():Void
	{
		FlxMisc.openURL("http://www.haxeflixel.com");
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
