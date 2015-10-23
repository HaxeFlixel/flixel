package flixel.system.debug;
import haxe.ds.StringMap;

#if !FLX_NO_DEBUG
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.debug.FlxDebugger;

/**
 * A powerful console for the flixel debugger screen with supports custom commands, registering 
 * objects and functions and saves the last 25 commands used. Inspired by Eric Smith's "CoolConsole".
 * @link http://www.youtube.com/watch?v=QWfpw7elWk8
 */
class Console extends Window
{
	/**
	 * The text that is displayed in the console's input field by default.
	 */
	private static inline var _DEFAULT_TEXT:String = "(Click here / press [Tab] to enter command. Type 'help' for help.)";
	/**
	 * The amount of commands that will be saved.
	 */
	private static inline var _HISTORY_MAX:Int = 25;
	
	/**
	 * Map containing all registered Objects. You can use registerObject() or add them directly to this map.
	 */
	public var registeredObjects:StringMap<Dynamic>;
	/**
	 * Map containing all registered Functions. You can use registerFunction() or add them directly to this map.
	 */
	public var registeredFunctions:StringMap<Dynamic>;
	/**
	 * Map containing all registered help text. Set these values from registerObject() or registerFunction().
	 */
	public var registeredHelp:StringMap<String>;
	
	/**
	 * Internal helper var containing all the FlxObjects created via the create command.
	 */
	public var objectStack:Array<FlxObject>;
	
	/**
	 * Reference to the array containing the command history.
	 */
	public var cmdHistory:Array<String>;
	
	/**
	 * The history index of the current input.
	 */
	private var _historyIndex:Int = 0;
	/**
	 * The input textfield used to enter commands.
	 */
	private var _input:TextField;
	
	#if (!next && sys)
	private var inputMouseDown:Bool = false;
	private var stageMouseDown:Bool = false;
	#end
	
	/**
	 * Creates a new console window object.
	 */	
	public function new()
	{	
		super("Console", new GraphicConsole(0, 0), 0, 0, false);
		
		ConsoleUtil.init();
		
		registeredObjects = new StringMap<Dynamic>();
		registeredFunctions = new StringMap<Dynamic>();
		registeredHelp = new StringMap<String>();
		
		objectStack = new Array<FlxObject>();
		
		cmdHistory = new Array<String>();
		
		// Load old command history if existant
		if (FlxG.save.data.history != null) 
		{
			cmdHistory = FlxG.save.data.history;
			_historyIndex = cmdHistory.length;
		}
		else 
		{
			cmdHistory = new Array<String>();
			FlxG.save.data.history = cmdHistory;
		}
		
		// Create the input textfield
		_input = new TextField();
		_input.type = TextFieldType.INPUT;
		_input.embedFonts = true;
		_input.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xFFFFFF, false, false, false);
		_input.text = Console._DEFAULT_TEXT;
		_input.width = _width - 4;
		_input.height = _height - 15;
		_input.x = 2;
		_input.y = 15;
		addChild(_input);
		
		_input.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		
		#if (!next && sys) // workaround for broken TextField focus on native
		_input.addEventListener(MouseEvent.MOUSE_DOWN, function(_)
		{
			inputMouseDown = true;
		});
		FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(_)
		{
			stageMouseDown = true;
		});
		#end
		
		// Install commands
		#if !FLX_NO_DEBUG
		new ConsoleCommands(this);
		#end
	}
	
	#if (!next && sys)
	override public function update():Void
	{
		super.update();
		
		if (FlxG.stage.focus == _input && stageMouseDown && !inputMouseDown)
		{
			FlxG.stage.focus = null;
			// setting focus to null will trigger a focus lost event, let's undo that
			FlxG.game.onFocus(null);
		}
		
		stageMouseDown = false;
		inputMouseDown = false;
	}
	#end
	
	@:access(flixel.FlxGame)
	private function onFocus(_):Void
	{
		#if (sys && next)
			if (!FlxG.game._lostFocus)
			{
				return;
			}
		#end
		
		#if !FLX_NO_DEBUG
		#if flash 
		// Pause game
		if (FlxG.console.autoPause)
			FlxG.vcr.pause();
		#end
		
		// Block keyboard input
		#if !FLX_NO_KEYBOARD
		FlxG.keys.enabled = false;
		#end
		
		if (_input.text == Console._DEFAULT_TEXT) 
			_input.text = "";
		#end
	}
	
	@:access(flixel.FlxGame)
	private function onFocusLost(_):Void
	{
		#if (sys && next)
			if (FlxG.game._lostFocus)
			{
				return;
			}
		#end
		
		#if !FLX_NO_DEBUG
		#if flash
		// Unpause game
		if (FlxG.console.autoPause)
		{
			FlxG.vcr.resume();
		}
		#end
		// Unblock keyboard input
		#if !FLX_NO_KEYBOARD
		FlxG.keys.enabled = true;
		#end
		
		if (_input.text == "") 
			_input.text = Console._DEFAULT_TEXT;
		#end
	}
	
	private function onKeyPress(e:KeyboardEvent):Void
	{
		// Submitting the command
		if (e.keyCode == Keyboard.ENTER && _input.text != "")
			processCommand();
		
		// Quick-unfocus
		else if (e.keyCode == Keyboard.ESCAPE)
			FlxG.stage.focus = null;
		
		// Delete the current text
		else if (e.keyCode == Keyboard.DELETE)
			_input.text = "";
		
		// Show previous command in history
		else if (e.keyCode == Keyboard.UP) 
		{
			if (cmdHistory.length == 0)
				return;
			
			_input.text = getPreviousCommand();
			
			// Set caret to the end of the command
			_input.setSelection(_input.text.length, _input.text.length);
		}
		// Show next command in history
		else if (e.keyCode == Keyboard.DOWN) 
		{
			if (cmdHistory.length == 0) 
				return;
			
			_input.text = getNextCommand();
			
			// Set caret to the end of the command
			_input.setSelection(_input.text.length, _input.text.length);
		}
	}
	
	private function processCommand():Void
	{
		try
		{
			var text = StringTools.trim(_input.text);
			
			if (registeredFunctions.get(text) != null)
			{
				// Force registered functions to have "()" if the command doesn't already include them
				// so when the user types "help" or "resetGame", something useful happens
				text += "()";
			}
			
			// Attempt to parse, run, and output the command
			var output = ConsoleUtil.runCommand(text);
			
			if (output != null) ConsoleUtil.log(output);
			
			// Only save new commands 
			if (getPreviousCommand() != _input.text)
			{
				// Save the command to the history
				cmdHistory.push(_input.text);
				FlxG.save.flush();
				
				// Set a maximum for commands you can save
				if (cmdHistory.length > Console._HISTORY_MAX)
					cmdHistory.shift();
			}
			
			_historyIndex = cmdHistory.length;
			
			// Step forward one frame to see the results of the command
			#if (flash && !FLX_NO_DEBUG)
			if (FlxG.vcr.paused)
			{
				FlxG.game.debugger.vcr.onStep();
			}
			#end
			
			_input.text = "";
		}
		
		catch (e:Dynamic)
		{
			// Parsing error, improper syntax
			FlxG.log.error("Console: Invalid syntax: '" + e + "'");
		}
	}
	
	private inline function getPreviousCommand():String
	{
		if (_historyIndex > 0)
			_historyIndex--;
		
		return cmdHistory[_historyIndex];
	}
	
	private inline function getNextCommand():String
	{
		if (_historyIndex < cmdHistory.length)
			_historyIndex++;
		
		return if (cmdHistory[_historyIndex] != null)
			cmdHistory[_historyIndex];
		else "";
	}
	
	/**
	 * Register a new object to use in any command.
	 * 
	 * @param 	ObjectAlias		The name with which you want to access the object.
	 * @param 	AnyObject		The object to register.
	 * @param 	HelpText		An optional string to trace to the console using the "help" command.
	 */
	public inline function registerObject(ObjectAlias:String, AnyObject:Dynamic, ?HelpText:String):Void
	{
		registeredObjects.set(ObjectAlias, AnyObject);
		ConsoleUtil.registerObject(ObjectAlias, AnyObject);
		
		if (HelpText != null)
		{
			registeredHelp.set(ObjectAlias, HelpText);
		}
	}
	
	/**
	 * Register a new function to use in any command.
	 * 
	 * @param 	FunctionAlias	The name with which you want to access the function.
	 * @param 	Function		The function to register.
	 * @param 	HelpText		An optional string to trace to the console using the "help" command.
	 */
	public inline function registerFunction(FunctionAlias:String, Function:Dynamic, ?HelpText:String):Void
	{
		registeredFunctions.set(FunctionAlias, Function);
		ConsoleUtil.registerFunction(FunctionAlias, Function);
		
		if (HelpText != null)
		{
			registeredHelp.set(FunctionAlias, HelpText);
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_input.removeEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.removeEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		
		if (_input != null) 
		{
			removeChild(_input);
			_input = null;
		}
		
		registeredObjects = null;
		registeredFunctions = null;
		registeredHelp = null;
		
		objectStack = null;
	}
	
	/**
	 * Adjusts the width and height of the text field accordingly.
	 */
	override private function updateSize():Void
	{
		super.updateSize();
		
		_input.width = _width - 4;
		_input.height = _height - 15;
	}
}
#end