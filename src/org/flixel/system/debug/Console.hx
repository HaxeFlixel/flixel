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
import org.flixel.FlxObject;

#if haxe3
private typedef Hash<T> = Map<String,T>;
#end

/**
 * 
 */
class Console extends FlxWindow
{
	private var _input:TextField;
	
	private var cmdFunctions:Hash<Dynamic>;
	private var cmdObjects:Hash<Dynamic>;
	
	/**
	 * Hash containing all registered Obejects for the set command. You can use the registerObject() 
	 * helper function to register new ones or add them to this Hash directly.
	 */
	public var registeredObjects:Hash<Dynamic>;
	/**
	 * Hash containing all registered Functions for the call command. You can use the registerFunction() 
	 * helper function to register new ones or add them to this Hash directly.
	 */
	public var registeredFunctions:Hash<Dynamic>;
	
	/**
	 * Internal helper var containing all the FlxObjects created via the create command.
	 */
	public var objectStack:Array<FlxObject>;
	
	/**
	 * Reference to the array containing the command history.
	 */
	public var cmdHistory:Array<String>;
	
	/**
	 * Whether the console should auto-pause or not when it's focused. Only works for flash atm.
	 * @default true
	 */
	public var autoPause:Bool = true;
	
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
		
		registeredObjects = new Hash<Dynamic>();
		registeredFunctions = new Hash<Dynamic>();
		
		objectStack = new Array<FlxObject>();
		
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
		addChild(_input);
		
		_input.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		
		// Install commands
		var commands:ConsoleCommands = new ConsoleCommands(this);
	}
	
	private function onFocus(e:FocusEvent):Void
	{
		// Pause game
		#if flash
		if (autoPause)
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
		if (autoPause)
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
			processCommand();
		
		// Quick-unfcous
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
	
	private function processCommand():Void
	{
		var args:Array<Dynamic> = StringTools.rtrim(_input.text).split(" ");
		var command:String = args.shift();
		
		var obj:Dynamic = cmdObjects.get(command);
		var func:Dynamic = cmdFunctions.get(command);
		
		// Check if the commmand exists
		if (func != null) 
		{
			// Only save new commands 
			if (getPreviousCommand() != _input.text) 
			{
				// Save the command to the history
				cmdHistory.push(_input.text);
				FlxG._game._prefsSave.flush();
					
				// Set a maximum for commands you can save
				if (cmdHistory.length > historyMax)
					cmdHistory.shift();
			}
				
			historyIndex = cmdHistory.length;
				
			if (Reflect.isFunction(func)) 
			{
				// Push all the strings into one param for the log command
				if  (command == "log") 
					args = [args.join(" ")];
				// Make the second param of call an array of the ramining params to 
				// be passed to the function you call
				else if (command == "call") 
					args[1] = args.slice(1, args.length);
					
				callFunction(obj, func, args); 
			}
			
			_input.text = "";
		}
		// In case the command doesn't exist
		else {
			FlxG.log("> Invalid command: '" + command + "'");
		}
	}
	
	public function callFunction(obj:Dynamic, func:Dynamic, args:Array<Dynamic>):Void
	{
		try 
		{
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
				if (expected < args.length) 
				{
					// Shorten args accordingly
					var shortenedArgs:Array<Dynamic> = args.slice(0, expected);
					// Try again
					Reflect.callMethod(obj, func, shortenedArgs);
				}
				// ...but not with too few
				else 
				{
					FlxG.log("> Invalid number or paramters: " + expected + " expected, " + args.length + " passed");
					return;
				}
			}
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
	
	/**
	 * Add a custom command to the console on the debugging screen.
	 * @param Command	The command's name.
	 * @param AnyObject Object containing the function (<code>this</code> if function is within the class you're calling this from).
	 * @param Function	Function to be called with params when the command is entered.
	 * @param Alt		Alternative name for the command, useful as a shortcut.
	 */
	public function addCommand(Command:String, AnyObject:Dynamic, Function:Dynamic, Alt:String = ""):Void
	{
		cmdFunctions.set(Command, Function);
		cmdObjects.set(Command, AnyObject);
		
		if (Alt != "") {
			cmdFunctions.set(Alt, Function);
			cmdObjects.set(Alt, AnyObject);
		}
	}
	
	/**
	 * Register a new object to use for the set command.
	 * @param ObjectAlias	The name with which you want to access the object.
	 * @param AnyObject		The object to register.
	 */
	public function registerObject(ObjectAlias:String, AnyObject:Dynamic):Void
	{
		registeredObjects.set(ObjectAlias, AnyObject);
	}
	
	/**
	 * Register a new function to use for the call command.
	 * @param FunctionAlias	The name with which you want to access the function.
	 * @param Function		The function to register.
	 * @param AnyObject		The object that contains the function.
	 */
	public function registerFunction(FunctionAlias:String, Function:Dynamic, AnyObject:Dynamic):Void
	{
		registeredFunctions.set(FunctionAlias, [Function, AnyObject]);
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
		
		registeredObjects = null;
		registeredFunctions = null;
		
		objectStack = null;
		
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
