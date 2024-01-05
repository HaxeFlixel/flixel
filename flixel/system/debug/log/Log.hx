package flixel.system.debug.log;

#if FLX_DEBUG
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.system.debug.FlxDebugger.GraphicLog;

/**
 * A simple trace output window for use in the debugger overlay.
 */
class Log extends Window
{
	public static inline var MAX_LOG_LINES:Int = 200;
	static inline var LINE_BREAK:String = #if js "\n" #else "<br>" #end;

	var _text:TextField;
	var _lines:Array<String>;

	/**
	 * Creates a log window object
	 */
	public function new()
	{
		super("Log", new GraphicLog(0, 0));

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
	}

	/**
	 * Clean up memory
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
	 * 
	 * @param   data      The data being logged
	 * @param   style     The LogStyle to be used
	 * @param   fireOnce  If true, the log history is checked for matching logs
	 */
	public function add(data:Array<Dynamic>, style:LogStyle, fireOnce = false):Bool
	{
		if (data == null)
		{
			return false;
		}
		
		// Apply text formatting
		#if (!js && !lime_console)
		final text = style.toHtmlString(data);
		#else
		final text = style.toLogString(data);
		#end
		
		// Check if the text has been added yet already
		if (fireOnce)
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
				newText += _lines[i] + LINE_BREAK;
			}
			// TODO: Make htmlText work on HTML5 target
			#if (!js && !lime_console)
			_text.htmlText = newText;
			#else
			_text.text = newText;
			#end
		}
		else
		{
			// TODO: Make htmlText work on HTML5 target
			#if (!js && !lime_console)
			_text.htmlText += (text + LINE_BREAK);
			#else
			_text.text += text + LINE_BREAK;
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
	override function updateSize():Void
	{
		super.updateSize();

		_text.width = _width - 10;
		_text.height = _height - 15;
	}
}
#end
