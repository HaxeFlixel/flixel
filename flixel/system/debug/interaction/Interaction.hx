package flixel.system.debug.interaction;

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flixel.group.FlxGroup;
import flash.events.MouseEvent;
import flixel.math.FlxPoint;
import flixel.system.debug.FlxDebugger;
import flixel.system.debug.Window;
import flixel.system.debug.interaction.tools.*;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxSpriteUtil;

/**
 * A plugin to visually and interactively debug a game while it is running.
 * 
 * TODO:
 * - Make Tool#init(brain) instead of passing that in the constructor
 * - Make tools setIcon() instead of using _icon or something
 * - Move _selectedItems from brain to Pointer tool (make tools able to communicate with brain.getTool(Class).
 * - Create update/draw methods for tools?
 * - Add signals to tools, so Pointer can dispatch when an item was selected?
 * - Make ToolsPanel only contain the tool icons, not the tools itself, it should be the brain's responsability
 * 
 * @author	Fernando Bevilacqua (dovyski@gmail.com)
 */
class Interaction extends Window
{
	private var _container:Sprite;
	private var _selectedItems:FlxGroup;
	private var _tools:Array<Tool>;
	private var _turn:UInt;
	
	public var flixelPointer:FlxPoint;
	public var systemPointer:FlxPoint;
	public var pointerJustPressed:Bool;
	public var pointerJustReleased:Bool;
	public var pointerPressed:Bool;
	public var keysDown:Array<UInt>;
	public var keysUp:Array<UInt>;	
	
	public function new(Container:Sprite)
	{		
		super("", new GraphicInteractive(0, 0), 10, 50, false);
		reposition(0, 100);
		
		_container = Container;
		_selectedItems = new FlxGroup();
		_tools = [];
		keysDown = [];
		keysUp = [];
		_turn = 2;
		
		flixelPointer = new FlxPoint();
		systemPointer = new FlxPoint();
		pointerJustPressed = false;
		pointerJustReleased = false;
		pointerPressed = false;
		
		// Add all built-in tools
		addTool(new Pointer());
		addTool(new Mover());
		addTool(new Eraser());
		
		// Subscrite to some Flixel signals
		FlxG.signals.postDraw.add(postDraw);
		FlxG.signals.preUpdate.add(preUpdate);
		
		// Listen to important events
		FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
		FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseClick);
		FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseClick);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyEvent);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyEvent);
	}
	
	private function updateMouse(Event:MouseEvent):Void
	{
		// Store Flixel mouse coordinates to speed up all
		// internal calculations (overlap, etc)
		flixelPointer.x = FlxG.mouse.x; // TODO: calculate mouse according to Flixel coordinate system
		flixelPointer.y = FlxG.mouse.y; // TODO: calculate mouse according to Flixel coordinate system
		
		// Position the custom interaction mouse cursor
		systemPointer.x = Event.stageX;
		systemPointer.y = Event.stageY;
	}
	
	private function handleMouseClick(Event:MouseEvent):Void 
	{
		pointerJustPressed = Event.type == MouseEvent.MOUSE_DOWN;
		pointerJustReleased = Event.type == MouseEvent.MOUSE_UP;
		
		if (pointerJustPressed)
		{
			pointerPressed = true;
		}
		else if (pointerJustReleased)
		{
			pointerPressed = false;
		}
	}
	
	private function handleKeyEvent(Event:KeyboardEvent):Void
	{
		if (Event.type == KeyboardEvent.KEY_DOWN)
		{
			keysDown[Event.keyCode] = _turn;
		}
		else if (Event.type == KeyboardEvent.KEY_UP)
		{
			keysUp[Event.keyCode] = _turn;
		}
	}
	
	/**
	 * 
	 * @param	Instance
	 */
	public function addTool(Instance :Tool):Void
	{	
		var button :FlxSystemButton;
		
		Instance.init(this);
		_tools.push(Instance);
		
		button = Instance.getButton();
		
		// If the tool has a button, add it to the interaction window
		if (button != null)
		{
			button.y = 10 + _tools.length * 10;
			addChild(button);
		}
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		// TODO: remove all entities and free memory.
	}
	
	/**
	 * Called before the game gets updated.
	 */
	private function preUpdate():Void
	{
		var tool:Tool;
		var i:Int;
		var l:Int = _tools.length;
		
		if (!FlxG.debugger.visible)
		{
			return;
		}
		
		for (i in 0...l)
		{
			tool = _tools[i];
			tool.update();
		}
		
		pointerJustPressed = false;
		pointerJustReleased = false;
		_turn++;
	}
	
	/**
	 * Called after the game state has been drawn.
	 */
	private function postDraw():Void
	{
		var tool:Tool;
		var i:Int;
		var l:Int = _tools.length;
		
		if (!FlxG.debugger.visible)
		{
			return;
		}
		
		for (i in 0...l)
		{
			tool = _tools[i];
			tool.draw();
		}
		
		drawItemsSelection();
	}
	
	private function drawItemsSelection():Void 
	{
		var i:Int = 0;
		var length:Int = _selectedItems.members.length;
		var item:FlxObject;
		
		//Set up global flash graphics object to draw out the debug stuff
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		gfx.clear();
		
		while (i < length)
		{
			item = cast _selectedItems.members[i++];
			if (item != null && item.scrollFactor != null && item.isOnScreen())
			{
				// Render a red rectangle centered at the selected item
				gfx.lineStyle(1.5, 0xff0000);
				gfx.drawRect(item.x - FlxG.camera.scroll.x, item.y - FlxG.camera.scroll.y, item.width * 1.0, item.height * 1.0);
			}
		}
		
		if (FlxG.renderBlit)
		{
			// Draw the debug info to the main camera buffer.
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		}
	}
	
	public function getTool(ClassName:Class<Tool>):Tool
	{
		var tool:Tool = null;
		var i:Int;
		var l:Int = _tools.length;
		
		for (i in 0...l)
		{
			if (Std.is(_tools[i], ClassName))
			{
				tool = _tools[i];
				break;
			}
		}
		
		return tool;
	}
	
	public function activate():Void
	{
		// TODO: improve this!
		_tools[0].activate();
	}
	
	/**
	 * 
	 * @return
	 */
	public function getContainer():Sprite
	{
		return _container;
	}
	
	/**
	 * 
	 * @return
	 */
	public function getSelectedItems():FlxGroup
	{
		return _selectedItems;
	}
	
	/**
	 * 
	 */
	public function clearSelection():Void
	{
		_selectedItems.clear();
	}
	
	/**
	 * 
	 * @param	Key
	 * @return
	 */
	public function keyPressed(Key:Int):Bool
	{
		return _turn <= keysDown[Key];
	}
	
	/**
	 * 
	 * @param	Key
	 * @return
	 */
	public function keyJustPressed(Key:Int):Bool
	{
		return (_turn - keysUp[Key]) == 1;
	}
}
