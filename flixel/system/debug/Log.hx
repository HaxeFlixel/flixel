package flixel.system.debug;
#if !FLX_NO_DEBUG

import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.debug.FlxDebugger;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;
import haxe.ds.StringMap;

/**
 * A simple trace output window for use in the debugger overlay.
 */
class Log extends Window
{
	public static inline var MAX_LOG_LINES:Int = 200;

	private var _text:TextField;
	private var _lines:Array<String>;
	
	/**
	 * Creates a log window object.
	 */	
	public function new()
	{
		super("log", new GraphicLog(0, 0));
		
		_text = new TextField();
		_text.x = 2;
		_text.y = 15;
		_text.multiline = true;
		_text.wordWrap = true;
		_text.selectable = true;
		_text.embedFonts = true;
		_text.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xffffff);
		addChild(_text);
		
		_lines = new Array<String>();
		
		#if !android // seems to cause a crash otherwise
		FlxG.log.redirectTraces = true;
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_text != null)
		{
			removeChild(_text);
			_text = null;
		}
		
		_lines = null;
		super.destroy();
	}
	
	/**
	 * Adds a new line to the log window.
	 * @param 	Data		The data being logged.
	 * @param 	Style		The LogStyle to be used for the log
	 * @param 	FireOnce   	Whether you only want to log the Data in case it hasn't been added already
	 */
	public function add(Data:Array<Dynamic>, Style:LogStyle, FireOnce:Bool = false):Bool
	{
		if (Data == null) 
		{
			return false;
		}
		
		var texts:Array<String> = new Array<String>();
		
		// Format FlxPoints, Arrays, Maps or turn the Data entry into a String
		for (i in 0...Data.length) 
		{
			texts[i] = Std.string(Data[i]);
			
			// Make sure you can't insert html tags
			texts[i] = StringTools.htmlEscape(texts[i]);
		}
		
		var text:String = Style.prefix + texts.join(" ");
		
		// Apply text formatting
		#if !js
		text = FlxStringUtil.htmlFormat(text, Style.size, Style.color, Style.bold, Style.italic, Style.underlined);
		#end
		
		// Check if the text has been added yet already
		if (FireOnce)
		{
			for (line in _lines)
			{
				if (text == line)
				{
					return false;
				}
			}
		}
		
		// Actually add it to the textfield
		if (_lines.length <= 0)
		{
			_text.text = "";
		}
		
		_lines.push(text);
		
		if (_lines.length > MAX_LOG_LINES)
		{
			_lines.shift();
			var newText:String = "";
			for (i in 0..._lines.length) 
			{
				newText += _lines[i] + "<br>";
			}
			// TODO: Make htmlText work on HTML5 target
			#if !js
			_text.htmlText = newText;
			#else
			_text.text = newText;
			#end
		}
		else
		{
			// TODO: Make htmlText work on HTML5 target
			#if !js
			_text.htmlText += (text + "<br>");
			#else
			_text.text += text + "\n";
			#end
		}
		
		_text.scrollV = Std.int(_text.maxScrollV);
		return true;
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
