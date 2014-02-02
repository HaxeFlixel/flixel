package flixel.system.debug;

#if !FLX_NO_DEBUG
import flash.errors.ArgumentError;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.debug.FlxDebugger;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxStringUtil;

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
	 * Hash containing all registered Obejects for the set command. You can use the registerObject() 
	 * helper function to register new ones or add them to this Hash directly.
	 */
	public var registeredObjects:Map<String, Dynamic>;
	/**
	 * Hash containing all registered Functions for the call command. You can use the registerFunction() 
	 * helper function to register new ones or add them to this Hash directly.
	 */
	public var registeredFunctions:Map<String, Dynamic>;
	
	/**
	 * Internal helper var containing all the FlxObjects created via the create command.
	 */
	public var objectStack:Array<FlxObject>;
	
	/**
	 * Reference to the array containing the command history.
	 */
	public var cmdHistory:Array<String>;
	/**
	 * An array holding all the registered commands.
	 */
	public var commands:Array<Command>;
	
	/**
	 * The history index of the current input.
	 */
	private var _historyIndex:Int = 0;
	/**
	 * The input textfield used to enter commands.
	 */
	private var _input:TextField;
	
	/**
	 * Creates a new console window object.
	 */	
	public function new()
	{	
		super("console", new GraphicConsole(0, 0), 0, 0, false);
		
		commands = new Array<Command>();
		
		registeredObjects = new Map<String, Dynamic>();
		registeredFunctions = new Map<String, Dynamic>();
		
		objectStack = new Array<FlxObject>();
		
		cmdHistory = new Array<String>();
		
		// Load old command history if existant
		if (FlxG.save.data.history != null) {
			cmdHistory = FlxG.save.data.history;
			_historyIndex = cmdHistory.length;
		}
		else {
			cmdHistory = new Array<String>();
			FlxG.save.data.history = cmdHistory;
		}
		
		// Create the input textfield
		_input = new TextField();
		_input.type = TextFieldType.INPUT;
		_input.embedFonts = true;
		_input.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 13, 0xFFFFFF, false, false, false);
		_input.text = Console._DEFAULT_TEXT;
		_input.width = _width - 4;
		_input.height = _height - 15;
		_input.x = 2;
		_input.y = 15;
		addChild(_input);
		
		_input.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		_input.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		_input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		
		// Install commands
		#if !FLX_NO_DEBUG
		new ConsoleCommands(this);
		#end
	}
	
	private function onFocus(e:FocusEvent):Void
	{
		#if !FLX_NO_DEBUG
		#if flash 
		// Pause game
		if (FlxG.console.autoPause)
		{
			FlxG.vcr.pause();
		}
		#end
		
		// Block keyboard input
		#if !FLX_NO_KEYBOARD
		FlxG.keys.enabled = false;
		#end
		
		if (_input.text == Console._DEFAULT_TEXT) 
		{
			_input.text = "";
		}
		#end
	}
	
	private function onFocusLost(e:FocusEvent):Void
	{
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
		{
			_input.text = Console._DEFAULT_TEXT;
		}
		#end
	}
	
	private function onKeyPress(e:KeyboardEvent):Void
	{
		// Don't allow spaces at the start, they break commands
		if (e.keyCode == Keyboard.SPACE && _input.text == " ") {
			_input.text = "";	
		}
		
		// Submitting the command
		if (e.keyCode == Keyboard.ENTER && _input.text != "") {
			processCommand();
		}
		
		// Quick-unfcous
		else if (e.keyCode == Keyboard.ESCAPE) {
			FlxG.stage.focus = null;
		}
		
		// Delete the current text
		else if (e.keyCode == Keyboard.DELETE) {
			_input.text = "";
		}
		
		// Show previous command in history
		else if (e.keyCode == Keyboard.UP) 
		{
			if (cmdHistory.length == 0) {
				return;
			}
			
			_input.text = getPreviousCommand();
			
			// Workaround to override default behaviour of selection jumping to 0 when pressing up
			addEventListener(Event.RENDER, overrideDefaultSelection);
			FlxG.stage.invalidate();
		}
		// Show next command in history
		else if (e.keyCode == Keyboard.DOWN) 
		{
			if (cmdHistory.length == 0) {
				return;
			}
			
			_input.text = getNextCommand();
		}
	}
	
	private function processCommand():Void
	{
		var args:Array<Dynamic> = StringTools.rtrim(_input.text).split(" ");
		var alias:String = args.shift();
		var command:Command = ConsoleUtil.findCommand(alias, commands);
		
		// Only if the command exists
		if (command != null) 
		{
			var func:Dynamic = command.processFunction;
			
			#if neko
			/**
			 * Ugly fix to prevent a crash with optional params on neko - requires padding with nulls. 
			 * @link https://github.com/HaxeFoundation/haxe/issues/976
			 */
			if (command.numParams > 0)
			{
				args[command.numParams - 1] = null;
			}
			#end
			
			// Only save new commands 
			if (getPreviousCommand() != _input.text) 
			{
				// Save the command to the history
				cmdHistory.push(_input.text);
				FlxG.save.flush();
				
				// Set a maximum for commands you can save
				if (cmdHistory.length > Console._HISTORY_MAX) {
					cmdHistory.shift();
				}
			}
			
			_historyIndex = cmdHistory.length;
			
			if (Reflect.isFunction(func)) 
			{
				// Push all the remaining params into an array if a paramCutoff has been set
				if (command.paramCutoff > 0)
				{
					var start:Int = command.paramCutoff - 1;
					args[start] = args.slice(start, args.length);
					args = args.slice(0, command.paramCutoff);
				}
				
				ConsoleUtil.callFunction(func, args); 
				
				// Skip to the next step if the game is paused to see the effects of the command
				#if (flash && !FLX_NO_DEBUG)
				if (FlxG.vcr.paused)
				{
					FlxG.game.debugger.vcr.onStep();
				}
				#end
			}
			
			_input.text = "";
		}
		// Error in case the command doesn't exist
		else 
		{
			FlxG.log.error("Console: Invalid command: '" + alias + "'");
		}
	}
	
	private function overrideDefaultSelection(e:Event):Void
	{
		_input.setSelection(_input.text.length, _input.text.length);
		removeEventListener(Event.RENDER, overrideDefaultSelection);
	}
	
	private inline function getPreviousCommand():String
	{
		if (_historyIndex > 0) {
			_historyIndex --;
		}
		
		return cmdHistory[_historyIndex];
	}
	
	private inline function getNextCommand():String
	{
		if (_historyIndex < cmdHistory.length) {
			_historyIndex ++;
		}
		
		if (cmdHistory[_historyIndex] != null) {
			return cmdHistory[_historyIndex];
		}
		else {
			return "";
		}
	}
	
	/**
	 * Register a new object to use for the set command.
	 * 
	 * @param 	ObjectAlias		The name with which you want to access the object.
	 * @param 	AnyObject		The object to register.
	 */
	public inline function registerObject(ObjectAlias:String, AnyObject:Dynamic):Void
	{
		registeredObjects.set(ObjectAlias, AnyObject);
	}
	
	/**
	 * Register a new function to use for the call command.
	 * 
	 * @param 	FunctionAlias	The name with which you want to access the function.
	 * @param 	Function		The function to register.
	 */
	public inline function registerFunction(FunctionAlias:String, Function:Dynamic):Void
	{
		registeredFunctions.set(FunctionAlias, Function);
	}
	
	/**
	 * Add a custom command to the console on the debugging screen.
	 * 
	 * @param 	Aliases			An array of accepted aliases for this command.
	 * @param 	ProcessFunction	Function to be called with params when the command is entered.
	 * @param	Help			The description of this command shown in the help command.
	 * @param	ParamHelp		The description of this command's processFunction's params.
	 * @param 	NumParams		The amount of parameters a function has. Require to prevent crashes on Neko.
	 * @param	ParamCutoff		At which parameter to put all remaining params into an array
	 */
	public inline function addCommand(Aliases:Array<String>, ProcessFunction:Dynamic, ?Help:String, ?ParamHelp:String, NumParams:Int = 0, ParamCutoff:Int = -1):Void
	{
		commands.push( { aliases:Aliases, processFunction:ProcessFunction, help:Help, paramHelp:ParamHelp, 
						numParams:NumParams, paramCutoff:ParamCutoff });
	}
	
	/**
	 * Clean up memory.
	 */
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
		
		commands = null;
		
		registeredObjects = null;
		registeredFunctions = null;
		
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

typedef Command = {
	aliases:Array<String>,
	processFunction:Dynamic,
	?help:String,
	?paramHelp:String,
	?numParams:Int,
	?paramCutoff:Int
}