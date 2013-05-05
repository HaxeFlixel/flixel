package org.flixel.system.debug;

import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.net.SharedObject;
import flash.text.TextFieldType;
import flash.ui.Keyboard;
import nme.Assets;
import nme.display.BitmapInt32;
import nme.errors.ArgumentError;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;
import org.flixel.FlxAssets;
import org.flixel.FlxObject;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.system.FlxWindow;

/**
 * 
 */
class Console extends FlxWindow
{
	private var _input:TextField;
	public var _shared:SharedObject;
	
	private var defaultText:String = "(Click here / press [Tab] to enter command. Type 'help' for help.)";
	
	private var commandList:Hash<Dynamic>;
	private var commandObjects:Hash<Dynamic>;
	public var commandHistory:Array<String>;
	
	private var focusTextFormat:TextFormat;
	private var focusLostTextFormat:TextFormat;
	
	private var watchingMouse:Bool = false;
	private var historyIndex:Int;
	private var historyMax:Int = 25;
	
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
	#if flash
	public function new(Title:String, Width:Float, Height:Float, Resizable:Bool = true, Bounds:Rectangle = null, ?BGColor:UInt = 0xAA000000, ?TopColor:UInt = 0x7f000000)
	#else
	public function new(Title:String, Width:Float, Height:Float, Resizable:Bool = true, Bounds:Rectangle = null, ?BGColor:BitmapInt32, ?TopColor:BitmapInt32)
	#end
	{	
		super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
		
		commandList = new Hash<Dynamic>();
		commandObjects = new Hash<Dynamic>();
		commandHistory = new Array<String>();
		
		focusTextFormat = new TextFormat(Assets.getFont(FlxAssets.debuggerFont).fontName, 14, 0xFFFFFF, false, false, false);
		focusLostTextFormat = new TextFormat(Assets.getFont(FlxAssets.debuggerFont).fontName, 14, 0xFFFFFF, false, true, false);
		
		// Createa a shared object for command history
		_shared = SharedObject.getLocal("CommandHistory");
		
		if (_shared.data.history) {
			commandHistory = _shared.data.history;
			historyIndex = commandHistory.length;
		}
		else {
			commandHistory = new Array<String>();
			_shared.data.history = commandHistory;
			historyIndex = 0;
		}
		
		// Create the input textfield
		_input = new TextField();
		_input.type = TextFieldType.INPUT;
		_input.defaultTextFormat = focusTextFormat;
		_input.selectable = true;
		_input.text = defaultText;
		_input.width = _width;
		_input.height = _height - 15;
		_input.x = 0;
		_input.y = 15;
		_input.restrict = "a-zA-Z 0-9.";
		addChild(_input);
		
		_input.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		
		// Install commands
		var commands:Commands = new Commands(this);
	}
	
	private function onFocus(e:FocusEvent):Void
	{
		FlxG._game.useSoundHotKeys = false;
		
		if (_input.text == defaultText) 
			_input.text = "";
	}
	
	private function onFocusLost(e:FocusEvent):Void
	{
		FlxG._game.useSoundHotKeys = true;
		
		if (_input.text == "") 
			_input.text = defaultText;
	}
	
	private function onKeyPress(e:KeyboardEvent):Void
	{
		// Don't allow spaces at the start, they break commands
		if (e.keyCode == Keyboard.SPACE) {
			if (_input.text == " ") {
				_input.text = "";	
				_input.setSelection(0, 0);
			}
		}
		
		// Submitting the command
		if (e.keyCode == Keyboard.ENTER && _input.text != "") 
		{ 
			var args:Array<Dynamic> = _input.text.split(" ");
			var command:String = args.shift();
			var obj:Dynamic = commandObjects.get(command);
			var func:Dynamic = commandList.get(command);
			
			if (func != null) 
			{
				// Only save new commands 
				if (getPreviousCommand() != _input.text) {
					commandHistory.push(_input.text);
					_shared.flush();
					// Set a maximum for commands you can save
					if (commandHistory.length > historyMax)
						commandHistory.shift();
				}
					
				historyIndex = commandHistory.length;
				
				if (Reflect.isFunction(func)) {
					try {
						// For the log command, push all the arguments into the first parameter
						if (command == "log") {
							Reflect.callMethod(obj, func, [args.join(" ")]);
						}
						else 
							Reflect.callMethod(obj, func, args);
					}
					catch(e:ArgumentError)
					{
						if (e.errorID == 1063)
						{
							/* Retrieve the number of expected arguments from the error message
							The first 4 digits in the message are the error-type (1063), 5th is 
							the one we are looking for */
							var expected:Int = Std.parseInt(filterDigits(e.message).charAt(4));
							
							// We can deal with too many parameters...
							if (expected < args.length) {
								// Shorten args accordingly
								var shortenedArgs:Array<Dynamic> = args.slice(0, expected);
								// Try again
								Reflect.callMethod(obj, func, shortenedArgs);
							}
							// ...but not with too few
							else {
								FlxG.log("> Invalid number or paramters: " + expected + " expected, " + args.length + " passed");
								return;
							}
						}
					}
				}
				
				_input.text = "";
			}
			else {
				FlxG.log("> Invalid command: '" + command + "'");
			}
		}
		
		// Quick-access
		else if (e.keyCode == Keyboard.TAB) {
			FlxG.stage.focus = _input;
		}
		
		// Delete the current text
		else if (e.keyCode == Keyboard.DELETE) {
			_input.text = "";
		}
		
		// Show previous command in history
		else if (e.keyCode == Keyboard.UP) {
			if (commandHistory.length == 0) return;
			
			_input.text = getPreviousCommand();
			_input.setSelection(0, _input.length);
		}
		// Show next command in history
		else if (e.keyCode == Keyboard.DOWN) {
			if (commandHistory.length == 0) return;
			
			_input.text = getNextCommand();
			_input.setSelection(0, _input.length);
		}
	}
	
	private function filterDigits(str:String):String 
	{
		var out = new StringBuf();
		for (i in 0...str.length) {
			var c = str.charCodeAt(i);
			if (c >= '0'.code && c <= '9'.code) out.addChar(c);
		}
		return out.toString();
	}
	
	private function getPreviousCommand():String
	{
		if (historyIndex > 0) 
			historyIndex --;
			
		return commandHistory[historyIndex];
	}
	
	private function getNextCommand():String
	{
		if (historyIndex < commandHistory.length) 
			historyIndex ++;
			
		if (commandHistory[historyIndex] != null) 
			return commandHistory[historyIndex];
		else 
			return "";
	}
	
	public function addCommand(Command:String, Object:Dynamic, Function:Dynamic):Void
	{
		commandList.set(Command, Function);
		commandObjects.set(Command, Object);
	}

	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_input.removeEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.removeEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		removeChild(_input);
		
		super.destroy();
	}
	
	/**
	 * Adjusts the width and height of the text field accordingly.
	 */
	override private function updateSize():Void
	{
		_input.width = _width;
		_input.height = _height - 15;
		
		super.updateSize();
	}
}