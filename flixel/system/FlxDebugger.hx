package flixel.system;

#if !FLX_NO_DEBUG

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
import flixel.system.debug.Perf;
import flixel.system.debug.VCR;
import flixel.system.debug.Vis;
import flixel.system.debug.Watch;
import flixel.system.FlxAssets;
import openfl.Assets;

#if !FLX_NO_MOUSE
import flash.ui.Mouse;
#end

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
	 * The amount of decimals FlxPoints are rounded to in log / watch.
	 */
	static public var pointPrecision:Int = 3; 
	/**
	 * Container for the performance monitor widget.
	 */
	public var perf:Perf;
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
	 * Container for the visual debug mode toggle.
	 */
	public var vis:Vis;
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
	 * Internal, used to space out windows from the edges.
	 */
	private var _gutter:Int;
	
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
		_screen = new Point(Width, Height);
		
		#if (flash || js)
		addChild(new Bitmap(new BitmapData(Std.int(Width), 15, true, 0x7f000000)));
		#else
		var bg:Sprite = new Sprite();
		bg.graphics.beginFill(0x000000, 0x7f / 255);
		bg.graphics.drawRect(0, 0, Std.int(Width), 15);
		bg.graphics.endFill();
		addChild(bg);
		#end
		
		var txt:TextField = new TextField();
		txt.x = 2;
		txt.width = 170;
		txt.height = 20;
		txt.selectable = false;
		txt.multiline = false;
		txt.defaultTextFormat = new TextFormat(Assets.getFont(FlxAssets.debuggerFont).fontName, 12, 0xffffff);
		var str:String = FlxG.libraryName + " [debug]";
		txt.text = str;
		addChild(txt);
		
		_gutter = 8;
		var screenBounds:Rectangle = new Rectangle(_gutter, 15 + _gutter / 2, _screen.x - _gutter * 2, _screen.y - _gutter * 1.5 - 15);
		
		log = new Log("log", 0, 0, true, screenBounds);
		addChild(log);
		
		watch = new Watch("watch", 0, 0, true, screenBounds);
		addChild(watch);
		
		console = new Console("console", 0, 0, false, screenBounds);
		addChild(console);
		
		perf = new Perf("stats", 0, 0, false, screenBounds);
		addChild(perf);
		
		vcr = new VCR();
		vcr.x = (Width - vcr.width / 2) / 2;
		vcr.y = 2;
		addChild(vcr);
		
		vis = new Vis();
		vis.x = Width - vis.width - 4;
		vis.y = 2;
		addChild(vis);
		
		setLayout(STANDARD);
		
		//Should help with fake mouse focus type behavior
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_screen = null;
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
		if (perf != null)
		{
			removeChild(perf);
			perf.destroy();
			perf = null;
		}
		if (vcr != null)
		{
			removeChild(vcr);
			vcr.destroy();
			vcr = null;
		}
		if (vis != null)
		{
			removeChild(vis);
			vis.destroy();
			vis = null;
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
		Mouse.show();
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
		if (!FlxG.mouse.useSystemCursor && !FlxG._game._debugger.vcr.paused)
			Mouse.hide();
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
				console.resize((_screen.x / 2) - _gutter * 4, 35);
				console.reposition(log.x + log.width + _gutter, _screen.y);
				watch.resize(_screen.x / 4, 68);
				watch.reposition(_screen.x,_screen.y);
				perf.reposition(_screen.x, 0);
			case BIG:
				console.resize(_screen.x - _gutter * 2, 35);
				console.reposition(_gutter, _screen.y);
				log.resize((_screen.x - _gutter * 3) / 2, _screen.y / 2);
				log.reposition(0, _screen.y - log.height - console.height - _gutter * 1.5);
				watch.resize((_screen.x - _gutter * 3) / 2, _screen.y / 2);
				watch.reposition(_screen.x, _screen.y - watch.height - console.height - _gutter * 1.5);
				perf.reposition(_screen.x, 0);
			case TOP:
				console.resize(_screen.x - _gutter * 2, 35);
				console.reposition(0,0);
				log.resize((_screen.x - _gutter * 3) / 2, _screen.y / 4);
				log.reposition(0,console.height + _gutter + 15);
				watch.resize((_screen.x - _gutter * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,console.height + _gutter + 15);
				perf.reposition(_screen.x,_screen.y);
			case LEFT:
				console.resize(_screen.x - _gutter * 2, 35);
				console.reposition(_gutter, _screen.y);
				log.resize(_screen.x / 3, (_screen.y - 15 - _gutter * 2.5) / 2 - console.height / 2 - _gutter);
				log.reposition(0,0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - _gutter * 2.5) / 2 - console.height / 2);
				watch.reposition(0,log.y + log.height + _gutter);
				perf.reposition(_screen.x,0);
			case RIGHT:
				console.resize(_screen.x - _gutter * 2, 35);
				console.reposition(_gutter, _screen.y);
				log.resize(_screen.x / 3, (_screen.y - 15 - _gutter * 2.5) / 2 - console.height / 2 - _gutter);
				log.reposition(_screen.x,0);
				watch.resize(_screen.x / 3, (_screen.y - 15 - _gutter * 2.5) / 2 - console.height / 2);
				watch.reposition(_screen.x,log.y + log.height + _gutter);
				perf.reposition(0,0);
			case STANDARD:
				console.resize(_screen.x - _gutter * 2, 35);
				console.reposition(_gutter, _screen.y);
				log.resize((_screen.x - _gutter * 3) / 2, _screen.y / 4);
				log.reposition(0,_screen.y - log.height - console.height - _gutter * 1.5);
				watch.resize((_screen.x - _gutter * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,_screen.y - watch.height - console.height - _gutter * 1.5);
				perf.reposition(_screen.x, 0);
			default:
				console.resize(_screen.x - _gutter * 2, 35);
				console.reposition(_gutter, _screen.y);
				log.resize((_screen.x - _gutter * 3) / 2, _screen.y / 4);
				log.reposition(0,_screen.y - log.height - console.height - _gutter * 1.5);
				watch.resize((_screen.x - _gutter * 3) / 2, _screen.y / 4);
				watch.reposition(_screen.x,_screen.y - watch.height - console.height - _gutter * 1.5);
				perf.reposition(_screen.x, 0);
		}
	}
}
#end