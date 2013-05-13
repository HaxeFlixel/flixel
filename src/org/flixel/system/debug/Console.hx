package org.flixel.system.debug;

import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.text.TextFieldType;
import flash.ui.Keyboard;
import nme.Assets;
import nme.display.BitmapInt32;
import nme.errors.ArgumentError;
import nme.events.Event;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;
import org.flixel.FlxAssets;
import org.flixel.FlxG;
import org.flixel.system.FlxWindow;

/**
 * 
 */
class Console extends FlxWindow
{
	private var _input:TextField;
	
	private var cmdFunctions:Hash<Dynamic>;
	private var cmdObjects:Hash<Dynamic>;
	
	public var cmdHistory:Array<String>;
	
	private var historyIndex:Int = 0;
	private var historyMax:Int = 25;
	
	private var defaultText:String = "(Click here / press [Tab] to enter command. Type 'help' for help.)";
	
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
	public function new(Title:String, Width:Float, Height:Float, Resizable:Bool = true, Bounds:Rectangle = null, ?BGColor:BitmapInt32 = 0xAA000000, ?TopColor:BitmapInt32)
	#end
	{	
		super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
		
		cmdFunctions = new Hash<Dynamic>();
		cmdObjects = new Hash<Dynamic>();
		cmdHistory = new Array<String>();
		
		// Load old command history if existant
		if (FlxG._game._prefsSave.data.history != null) {
			cmdHistory = FlxG._game._prefsSave.data.history;
			historyIndex = cmdHistory.length;
		}
		else {
			cmdHistory = new Array<String>();
			FlxG._game._prefsSave.data.history = cmdHistory;
		}
		
		// Create the input textfield
		_input = new TextField();
		_input.type = TextFieldType.INPUT;
		_input.defaultTextFormat = new TextFormat(Assets.getFont(FlxAssets.debuggerFont).fontName, 14, 0xFFFFFF, false, false, false);
		_input.text = defaultText;
		_input.width = _width - 4;
		_input.height = _height - 15;
		_input.x = 2;
		_input.y = 15;
		#if flash
		_input.restrict = "a-zA-Z 0-9.";
		#end
		addChild(_input);
		
		_input.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		
		// Install commands
		var commands:Commands = new Commands(this);
	}
	
	private function onFocus(e:FocusEvent):Void
	{
		// Pause game
		#if flash
		FlxG._game.debugger.vcr.onPause();
		#end
		// Shouldn't be able to trigger sound control when console has focus
		FlxG._game.tempDisableSoundHotKeys = true;
		
		if (_input.text == defaultText) 
			_input.text = "";
	}
	
	private function onFocusLost(e:FocusEvent):Void
	{
		// Unpause game
		#if flash
		FlxG._game.debugger.vcr.onPlay();
		#end
		FlxG._game.tempDisableSoundHotKeys = false;
		
		if (_input.text == "") 
			_input.text = defaultText;
	}
	
	private function onKeyPress(e:KeyboardEvent):Void
	{
		// Don't allow spaces at the start, they break commands
		if (e.keyCode == Keyboard.SPACE && _input.text == " ") 
			_input.text = "";	
		
		// Submitting the command
		if (e.keyCode == Keyboard.ENTER && _input.text != "") 
		{ 
			var args:Array<Dynamic> = _input.text.split(" ");
			var command:String = args.shift();
			var obj:Dynamic = cmdObjects.get(command);
			var func:Dynamic = cmdFunctions.get(command);
			
			if (func != null) 
			{
				// Only save new commands 
				if (getPreviousCommand() != _input.text) 
				{
					cmdHistory.push(_input.text);
					FlxG._game._prefsSave.flush();
					
					// Set a maximum for commands you can save
					if (cmdHistory.length > historyMax)
						cmdHistory.shift();
				}
					
				historyIndex = cmdHistory.length;
				
				if (Reflect.isFunction(func)) 
				{
					try 
					{
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
		else if (e.keyCode == Keyboard.ESCAPE) 
			FlxG.stage.focus = null;
		
		// Delete the current text
		else if (e.keyCode == Keyboard.DELETE) 
			_input.text = "";
		
		// Show previous command in history
		else if (e.keyCode == Keyboard.UP) {
			if (cmdHistory.length == 0) return;
			
			_input.text = getPreviousCommand();
			
			// Workaround to override default behaviour of selection jumping to 0 when pressing up
			addEventListener(Event.RENDER, overrideDefaultSelection, false, 0, true);
			FlxG.stage.invalidate();
		}
		// Show next command in history
		else if (e.keyCode == Keyboard.DOWN) {
			if (cmdHistory.length == 0) return;
			
			_input.text = getNextCommand();
		}
	}
	
	private function overrideDefaultSelection(e:Event):Void
	{
		_input.setSelection(_input.text.length, _input.text.length);
		removeEventListener(Event.RENDER, overrideDefaultSelection);
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
			
		return cmdHistory[historyIndex];
	}
	
	private function getNextCommand():String
	{
		if (historyIndex < cmdHistory.length) 
			historyIndex ++;
			
		if (cmdHistory[historyIndex] != null) 
			return cmdHistory[historyIndex];
		else 
			return "";
	}
	
	public function addCommand(Command:String, Object:Dynamic, Function:Dynamic, Alt:String = ""):Void
	{
		cmdFunctions.set(Command, Function);
		cmdObjects.set(Command, Object);
		
		if (Alt != "") {
			cmdFunctions.set(Alt, Function);
			cmdObjects.set(Alt, Object);
		}
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_input.removeEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.removeEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		
		if (_input != null)
			removeChild(_input);
		_input = null;
		
		cmdFunctions = null;
		cmdObjects = null;
		cmdHistory = null;
		
		super.destroy();
	}
	
	/**
	 * Adjusts the width and height of the text field accordingly.
	 */
	override private function updateSize():Void
	{
		_input.width = _width - 4;
		_input.height = _height - 15;
		
		super.updateSize();
	}
}