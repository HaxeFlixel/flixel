package flixel.system.debug;
#if !FLX_NO_DEBUG

import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.system.FlxAssets;
import flixel.system.FlxDebugger;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import haxe.ds.StringMap;
import openfl.Assets;

/**
 * A simple trace output window for use in the debugger overlay.
 */
class Log extends Window
{
	static public var MAX_LOG_LINES:Int = 200;
	
	static public var STYLE_NORMAL:LogStyle;
	static public var STYLE_WARNING:LogStyle;
	static public var STYLE_ERROR:LogStyle;
	static public var STYLE_NOTICE:LogStyle;
	static public var STYLE_CONSOLE:LogStyle;

	private var _text:TextField;
	private var _lines:Array<String>;
	
	/**
	 * Creates a new window object.  This Flash-based class is mainly (only?) used by <code>FlxDebugger</code>.
	 * @param Title			The name of the window, displayed in the header bar.
	 * @param Width			The initial width of the window.
	 * @param Height		The initial height of the window.
	 * @param Resizable		Whether you can change the size of the window with a drag handle.
	 * @param Bounds		A rectangle indicating the valid screen area for the window.
	 * @param BGColor		What color the window background should be, default is gray and transparent.
	 * @param TopColor		What color the window header bar should be, default is black and transparent.
	 */	
	public function new(Title:String, Width:Float, Height:Float, Resizable:Bool = true, Bounds:Rectangle = null, BGColor:Int = 0x7f7f7f7f, TopColor:Int = 0x7f000000)
	{
		super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
		
		_text = new TextField();
		_text.x = 2;
		_text.y = 15;
		_text.multiline = true;
		_text.wordWrap = true;
		_text.selectable = true;
		_text.defaultTextFormat = new TextFormat(Assets.getFont(FlxAssets.debuggerFont).fontName, 12, 0xffffff);
		addChild(_text);
		
		_lines = new Array<String>();
		
		STYLE_NORMAL = new LogStyle();
		STYLE_WARNING = new LogStyle("[WARNING] ", "FFFF00", 12, true, false, false, "Beep", true);
		STYLE_ERROR = new LogStyle("[ERROR] ", "FF0000", 12, true, false, false, "Beep", true);
		STYLE_NOTICE = new LogStyle("[NOTICE] ", "008000", 12, true);
		STYLE_CONSOLE = new LogStyle("&#62; ", "0000ff", 12, true);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_text != null)
		{
			removeChild(_text);
		}
		_text = null;
		_lines = null;
		STYLE_NORMAL = null;
		STYLE_WARNING = null;
		STYLE_ERROR = null;
		STYLE_NOTICE = null;
		STYLE_CONSOLE = null;
		super.destroy();
	}
	
	/**
	 * Adds a new line to the log window.
	 * @param Data		The data being logged.
	 * @param Style		The <code>LogStyle</code> to be used for the log
	 */
	public function add(Data:Array<Dynamic>, Style:LogStyle):Void
	{
		if (Data == null) 
			return;
			
		var texts:Array<String> = new Array<String>();
		
		// Format FlxPoints, Arrays, Maps or turn the Data entry into a String
		for (i in 0...Data.length) {
			if (Std.is(Data[i], FlxPoint)) 
				texts[i] = FlxStringUtil.formatFlxPoint(Data[i], FlxDebugger.pointPrecision);
			else if (Std.is(Data[i], StringMap))
				texts[i] = FlxStringUtil.formatStringMap(Data[i]);
			else 
				texts[i] = Std.string(Data[i]);
				
			// Make sure you can't insert html tags
			texts[i] = StringTools.replace(texts[i], "<", "");
			texts[i] = StringTools.replace(texts[i], ">", "");
		}
		
		var text:String = texts.join(" ");

		#if !js
		// Create the text and apply color and styles
		var prefix:String = "<font size='" + Style.size + "' color='#" + Style.color + "'>";
		var suffix:String = "</font>";
		
		if (Style.bold) {
			prefix = "<b>" + prefix;
			suffix = suffix + "</b>";
		}
		if (Style.italic) {
			prefix = "<i>" + prefix;
			suffix = suffix + "</i>";
		}
		if (Style.underlined) {
			prefix = "<u>" + prefix;
			suffix = suffix + "</u>";
		}
		
		// TODO: Make htmlText on HTML5 target
		text = prefix + Style.prefix + text + suffix;
		#else
		text = Style.prefix + text;
		#end
		
		// Actually add it to the textfield
		if (_lines.length <= 0)
		{
			_text.text = "";
		}
		
		_lines.push(text);
		
		if(_lines.length > MAX_LOG_LINES)
		{
			_lines.shift();
			var newText:String = "";
			for (i in 0..._lines.length) 
			{
				newText += _lines[i] + "<br>";
			}
			// TODO: Make htmlText on HTML5 target
			#if !js
			_text.htmlText = newText;
			#else
			_text.text = newText;
			#end
		}
		else
		{
			// TODO: Make htmlText on HTML5 target
			#if !js
			_text.htmlText += (text + "<br>");
			#else
			_text.text += text + "\n";
			#end
		}
		#if flash
		_text.scrollV = Std.int(_text.maxScrollV);
		#elseif !js
		_text.scrollV = _text.maxScrollV - Std.int(_text.height / _text.defaultTextFormat.size) + 1;
		#end
	}
	
	public function clear():Void
	{
		_text.text = "";
		_lines.splice(0, _lines.length);
		#if !js
		_text.scrollV = 0;
		#end
	}
	
	/**
	 * Adjusts the width and height of the text field accordingly.
	 */
	override private function updateSize():Void
	{
		super.updateSize();
		
		_text.width = _width-10;
		_text.height = _height-15;
	}
}
#end