package flixel.system.debug.console;

#if FLX_DEBUG
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.debug.FlxDebugger.GraphicConsole;
import flixel.system.debug.completion.CompletionList;
import flixel.system.debug.completion.CompletionHandler;
import flixel.util.FlxStringUtil;
#if (!next && sys)
import openfl.events.MouseEvent;
#end
#if hscript
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.text.TextFieldType;
import openfl.ui.Keyboard;

using StringTools;
#end

/**
 * A powerful console for the flixel debugger screen with supports custom commands, registering
 * objects and functions and saves the last 25 commands used. Inspired by Eric Smith's "CoolConsole".
 * @see http://www.youtube.com/watch?v=QWfpw7elWk8
 */
class Console extends Window
{
	/**
	 * The text that is displayed in the console's input field by default.
	 */
	static inline var DEFAULT_TEXT:String = #if hscript "(Click here / press [Tab] to enter command. Type 'help' for help.)" #else "Using the console requires hscript - please run 'haxelib install hscript'." #end;

	/**
	 * Map containing all registered Objects. You can use registerObject() or add them directly to this map.
	 */
	public var registeredObjects:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * Map containing all registered Functions. You can use registerFunction() or add them directly to this map.
	 */
	public var registeredFunctions:Map<String, Dynamic> = new Map<String, Dynamic>();

	/**
	 * Map containing all registered help text. Set these values from registerObject() or registerFunction().
	 */
	public var registeredHelp:Map<String, String> = new Map<String, String>();

	/**
	 * Internal helper var containing all the FlxObjects created via the create command.
	 */
	public var objectStack:Array<FlxObject> = [];

	/**
	 * The input textfield used to enter commands.
	 */
	var input:TextField;

	#if (!next && sys)
	var inputMouseDown:Bool = false;
	var stageMouseDown:Bool = false;
	#end

	public var history:ConsoleHistory;

	var completionList:CompletionList;

	/**
	 * Creates a new console window object.
	 */
	public function new(completionList:CompletionList)
	{
		super("Console", new GraphicConsole(0, 0), 0, 0, false);
		this.completionList = completionList;
		completionList.setY(y + Window.HEADER_HEIGHT);

		#if hscript
		ConsoleUtil.init();
		#end

		history = new ConsoleHistory();
		createInputTextField();
		new CompletionHandler(completionList, input);
		registerEventListeners();

		// Install commands
		#if FLX_DEBUG
		new ConsoleCommands(this);
		#end
	}

	function createInputTextField()
	{
		// Create the input textfield
		input = new TextField();
		input.embedFonts = true;
		input.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xFFFFFF, false, false, false);
		input.text = Console.DEFAULT_TEXT;
		input.width = _width - 4;
		input.height = _height - 15;
		input.x = 2;
		input.y = 15;
		addChild(input);
	}

	function registerEventListeners()
	{
		#if hscript
		input.type = TextFieldType.INPUT;
		input.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		input.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		input.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

		#if !flash
		// openfl/openfl#1856
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent)
		{
			if (FlxG.debugger.visible && FlxG.game.debugger.console.visible && e.keyCode == Keyboard.TAB)
				FlxG.stage.focus = input;
		});
		#end
		#end

		#if (!next && sys) // workaround for broken TextField focus on native
		input.addEventListener(MouseEvent.MOUSE_DOWN, function(_)
		{
			inputMouseDown = true;
		});
		FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(_)
		{
			stageMouseDown = true;
		});
		#end
	}

	#if (!next && sys)
	@:access(flixel.FlxGame.onFocus)
	override public function update()
	{
		super.update();

		if (FlxG.stage.focus == input && stageMouseDown && !inputMouseDown)
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
	function onFocus(_)
	{
		#if FLX_DEBUG
		// Pause game
		if (FlxG.console.autoPause)
			FlxG.vcr.pause();

		// Block keyboard input
		#if FLX_KEYBOARD
		FlxG.keys.enabled = false;
		#end

		if (input.text == Console.DEFAULT_TEXT)
			input.text = "";
		#end
	}

	@:access(flixel.FlxGame)
	function onFocusLost(_)
	{
		#if FLX_DEBUG
		// Unpause game
		if (FlxG.console.autoPause && !FlxG.game.debugger.vcr.manualPause)
			FlxG.vcr.resume();

		// Unblock keyboard input
		#if FLX_KEYBOARD
		FlxG.keys.enabled = true;
		#end

		if (input.text == "")
			input.text = Console.DEFAULT_TEXT;
		#end

		completionList.close();
		FlxG.game.debugger.onMouseFocusLost();
	}

	#if hscript
	function onKeyDown(e:KeyboardEvent)
	{
		if (completionList.visible)
			return;

		switch (e.keyCode)
		{
			case Keyboard.ENTER:
				if (input.text != "")
					processCommand();

			case Keyboard.ESCAPE:
				FlxG.stage.focus = null;

			case Keyboard.DELETE:
				input.text = "";

			case Keyboard.UP:
				if (!history.isEmpty)
					setText(history.getPreviousCommand());

			case Keyboard.DOWN:
				if (!history.isEmpty)
					setText(history.getNextCommand());
		}
	}

	function setText(text:String)
	{
		input.text = text;
		// Set caret to the end of the command
		input.setSelection(text.length, text.length);
	}

	function processCommand()
	{
		try
		{
			var text = input.text.trim();

			// Force registered functions to have "()" if the command doesn't already include them
			// so when the user types "help" or "resetGame", something useful happens
			if (registeredFunctions.get(text) != null)
				text += "()";

			// Attempt to parse, run, and output the command
			var output = ConsoleUtil.runCommand(text);
			if (output != null)
				ConsoleUtil.log(output);

			history.addCommand(input.text);

			// Step forward one frame to see the results of the command
			#if FLX_DEBUG
			if (FlxG.vcr.paused && FlxG.console.stepAfterCommand)
				FlxG.game.debugger.vcr.onStep();
			#end

			input.text = "";
		}
		catch (e:Dynamic)
		{
			// Parsing error, improper syntax
			FlxG.log.error("Console: Invalid syntax: '" + e + "'");
		}
	}

	override public function reposition(X:Float, Y:Float)
	{
		super.reposition(X, Y);
		completionList.setY(y + Window.HEADER_HEIGHT);
		completionList.close();
	}
	#end

	/**
	 * Register a new function to use in any command.
	 *
	 * @param 	FunctionAlias	The name with which you want to access the function.
	 * @param 	Function		The function to register.
	 * @param 	HelpText		An optional string to trace to the console using the "help" command.
	 */
	public function registerFunction(functionAlias:String, func:Dynamic, ?helpText:String)
	{
		registeredFunctions.set(functionAlias, func);
		#if hscript
		ConsoleUtil.registerFunction(functionAlias, func);
		#end

		if (helpText != null)
			registeredHelp.set(functionAlias, helpText);
	}

	/**
	 * Register a new object to use in any command.
	 *
	 * @param 	ObjectAlias		The name with which you want to access the object.
	 * @param 	AnyObject		The object to register.
	 */
	public function registerObject(objectAlias:String, anyObject:Dynamic)
	{
		registeredObjects.set(objectAlias, anyObject);
		#if hscript
		ConsoleUtil.registerObject(objectAlias, anyObject);
		#end
	}

	/**
	 * Register a new class to use in any command.
	 *
	 * @param	cl	The class to register.
	 */
	public inline function registerClass(cl:Class<Dynamic>)
	{
		registerObject(FlxStringUtil.getClassName(cl, true), cl);
	}

	/**
	 * Register a new enum to use in any command.
	 *
	 * @param	e	The enum to register.
	 * @since 4.4.0
	 */
	public inline function registerEnum(e:Enum<Dynamic>)
	{
		registerObject(FlxStringUtil.getEnumName(e, true), e);
	}

	override public function destroy()
	{
		super.destroy();

		#if hscript
		input.removeEventListener(FocusEvent.FOCUS_IN, onFocus);
		input.removeEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		input.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		#end

		if (input != null)
		{
			removeChild(input);
			input = null;
		}

		registeredObjects = null;
		registeredFunctions = null;
		registeredHelp = null;

		objectStack = null;
	}

	/**
	 * Adjusts the width and height of the text field accordingly.
	 */
	override function updateSize()
	{
		super.updateSize();

		input.width = _width - 4;
		input.height = _height - 15;
	}
}
#end
