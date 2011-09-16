package org.flixel.system;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

import org.flixel.FlxG;
import org.flixel.system.debug.Log;
import org.flixel.system.debug.Perf;
import org.flixel.system.debug.VCR;
import org.flixel.system.debug.Vis;
import org.flixel.system.debug.Watch;

/**
 * Container for the new debugger overlay.
 * Most of the functionality is in the debug folder widgets,
 * but this class instantiates the widgets and handles their basic formatting and arrangement.
 */
class FlxDebugger extends Sprite
{
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
	 * Whether the mouse is currently over one of the debugger windows or not.
	 */
	public var hasMouse:Bool;
	
	/**
	 * Internal, tracks what debugger window layout user has currently selected.
	 */
	#if flash
	private var _layout:UInt;
	#else
	private var _layout:Int;
	#end
	/**
	 * Internal, stores width and height of the Flash Player window.
	 */
	private var _screen:Point;
	/**
	 * Internal, used to space out windows from the edges.
	 */
	#if flash
	private var _gutter:UInt;
	#else
	private var _gutter:Int;
	#end
	
	
	/**
	 * Instantiates the debugger overlay.
	 * 
	 * @param Width		The width of the screen.
	 * @param Height	The height of the screen.
	 */
	public function new(Width:Float, Height:Float)
	{
		super();
		visible = false;
		hasMouse = false;
		_screen = new Point(Width,Height);

		addChild(new Bitmap(new BitmapData(Math.floor(Width), 15, true, 0x7f000000)));
		
		var txt:TextField = new TextField();
		txt.x = 2;
		txt.width = 160;
		txt.height = 16;
		txt.selectable = false;
		txt.multiline = false;
		txt.defaultTextFormat = new TextFormat("Courier",12,0xffffff);
		var str:String = FlxG.getLibraryName();
		if (FlxG.debug)
		{
			str += " [debug]";
		}
		else
		{
			str += " [release]";
		}
		txt.text = str;
		addChild(txt);
		
		_gutter = 8;
		var screenBounds:Rectangle = new Rectangle(_gutter,15+_gutter/2,_screen.x-_gutter*2,_screen.y-_gutter*1.5-15);
		
		log = new Log("log",0,0,true,screenBounds);
		addChild(log);
		
		watch = new Watch("watch",0,0,true,screenBounds);
		addChild(watch);
		
		perf = new Perf("stats",0,0,false,screenBounds);
		addChild(perf);
		
		vcr = new VCR();
		vcr.x = (Width - vcr.width/2)/2;
		vcr.y = 2;
		addChild(vcr);
		
		vis = new Vis();
		vis.x = Width-vis.width - 4;
		vis.y = 2;
		addChild(vis);
		
		setLayout(FlxG.DEBUGGER_STANDARD);
		
		//Should help with fake mouse focus type behavior
		addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_screen = null;
		removeChild(log);
		log.destroy();
		log = null;
		removeChild(watch);
		watch.destroy();
		watch = null;
		removeChild(perf);
		perf.destroy();
		perf = null;
		removeChild(vcr);
		vcr.destroy();
		vcr = null;
		removeChild(vis);
		vis.destroy();
		vis = null;
		
		removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
		removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
	}
	
	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseOver(?E:MouseEvent = null):Void
	{
		hasMouse = true;
	}
	
	/**
	 * Mouse handler that helps with fake "mouse focus" type behavior.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseOut(?E:MouseEvent = null):Void
	{
		hasMouse = false;
	}
	
	/**
	 * Rearrange the debugger windows using one of the constants specified in FlxG.
	 * @param	Layout		The layout style for the debugger windows, e.g. <code>FlxG.DEBUGGER_MICRO</code>.
	 */
	#if flash
	public function setLayout(Layout:UInt):Void
	#else
	public function setLayout(Layout:Int):Void
	#end
	{
		_layout = Layout;
		resetLayout();
	}
	
	/**
	 * Forces the debugger windows to reset to the last specified layout.
	 * The default layout is <code>FlxG.DEBUGGER_STANDARD</code>.
	 */
	public function resetLayout():Void
	{
		switch(_layout)
		{
			case FlxG.DEBUGGER_MICRO:
				log.resize(_screen.x/4,68);
				log.reposition(0,_screen.y);
				watch.resize(_screen.x/4,68);
				watch.reposition(_screen.x,_screen.y);
				perf.reposition(_screen.x,0);
			case FlxG.DEBUGGER_BIG:
				log.resize((_screen.x-_gutter*3)/2,_screen.y/2);
				log.reposition(0,_screen.y);
				watch.resize((_screen.x-_gutter*3)/2,_screen.y/2);
				watch.reposition(_screen.x,_screen.y);
				perf.reposition(_screen.x,0);
			case FlxG.DEBUGGER_TOP:
				log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
				log.reposition(0,0);
				watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
				watch.reposition(_screen.x,0);
				perf.reposition(_screen.x,_screen.y);
			case FlxG.DEBUGGER_LEFT:
				log.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
				log.reposition(0,0);
				watch.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
				watch.reposition(0,_screen.y);
				perf.reposition(_screen.x,0);
			case FlxG.DEBUGGER_RIGHT:
				log.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
				log.reposition(_screen.x,0);
				watch.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
				watch.reposition(_screen.x,_screen.y);
				perf.reposition(0,0);
			case FlxG.DEBUGGER_STANDARD:
			default:
				log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
				log.reposition(0,_screen.y);
				watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
				watch.reposition(_screen.x,_screen.y);
				perf.reposition(_screen.x,0);
		}
	}
}