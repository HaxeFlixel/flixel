package flixel.system.debug.interaction;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flixel.group.FlxGroup;
import flash.events.MouseEvent;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.system.debug.FlxDebugger.GraphicInteractive;
import flixel.system.debug.Window;
import flixel.system.debug.interaction.tools.Eraser;
import flixel.system.debug.interaction.tools.Mover;
import flixel.system.debug.interaction.tools.Pointer;
import flixel.system.debug.interaction.tools.Tool;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxSpriteUtil;

/**
 * Adds a new funcionality to Flixel debugger that allows any object
 * on the screen to be dragged, moved or deleted while the game is
 * still running.
 * 
 * @author	Fernando Bevilacqua (dovyski@gmail.com)
 */
class Interaction extends Window
{
	private var _container:Sprite;
	private var _customCursor:Sprite;
	private var _selectedItems:FlxGroup;
	private var _tools:Array<Tool>;
	private var _turn:Int;
	private var _keysDown:Map<Int, Int>;
	private var _keysUp:Map<Int, Int>;		
	private var _activeTool:Tool;		
	private var _wasMouseVisible:Bool;
	private var _wasUsingSystemCursor:Bool;
	private var _debuggerInteraction:Bool;
	private var _flixelPointer:FlxPointer;
	
	public var flixelPointer:FlxPoint;
	public var pointerJustPressed:Bool;
	public var pointerJustReleased:Bool;
	public var pointerPressed:Bool;

	
	public function new(Container:Sprite)
	{		
		super("Tools", new GraphicInteractive(0, 0), 40, 25, false);
		reposition(2, 100);
		
		_container = Container;
		_selectedItems = new FlxGroup();
		_tools = [];
		_keysDown = new Map<Int, Int>();
		_keysUp = new Map<Int, Int>();
		_turn = 2;
		_debuggerInteraction = false;
		_flixelPointer = new FlxPointer();
		
		_customCursor = new Sprite();
		_customCursor.mouseEnabled = false;
		_container.addChild(_customCursor);
		
		flixelPointer = new FlxPoint();
		pointerJustPressed = false;
		pointerJustReleased = false;
		pointerPressed = false;
		
		// Add all built-in tools
		addTool(new Pointer());
		addTool(new Mover());
		addTool(new Eraser());
		
		FlxG.signals.postDraw.add(postDraw);
		FlxG.debugger.visibilityChanged.add(handleDebuggerVisibilityChanged);
		
		FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
		FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseClick);
		FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseClick);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyEvent);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyEvent);
		
		_container.addEventListener(MouseEvent.MOUSE_OVER, handleMouseInDebugger);
		_container.addEventListener(MouseEvent.MOUSE_OUT, handleMouseInDebugger);
	}
	
	private function handleDebuggerVisibilityChanged():Void
	{
		if (FlxG.debugger.visible)
		{
			saveSystemCursorInfo();
		}
		else
		{
			restoreSystemCursor();
		}
	}
	
	private function updateMouse(Event:MouseEvent):Void
	{
		var offsetX:Float = 0, offsetY:Float = 0;
		var cursorIcon:BitmapData;
		
		// If the active tool has a custom cursor, we assume its
		// "point of click" is the center of the cursor icon.
		if (_activeTool != null)
		{
			cursorIcon = _activeTool.getCursor();
			
			if (cursorIcon != null)
			{
				offsetX = cursorIcon.width / FlxG.scaleMode.scale.x / 2;
				offsetY = cursorIcon.height / FlxG.scaleMode.scale.y / 2;
			}
		}
		
		_customCursor.x = Event.stageX + offsetX;
		_customCursor.y = Event.stageY + offsetY;
		
		#if FLX_MOUSE
		// Calculate in-game coordinates based on mouse position and camera.
		_flixelPointer.setGlobalScreenPositionUnsafe(Event.stageX, Event.stageY);
		
		// Store Flixel mouse coordinates to speed up all
		// internal calculations (overlap, etc)
		flixelPointer.x = _flixelPointer.x + offsetX;
		flixelPointer.y = _flixelPointer.y + offsetY;
		#end
	}
	
	private function handleMouseClick(Event:MouseEvent):Void 
	{
		if (Std.is(Event.target, FlxSystemButton))
		{
			// User clicked a debugger icon instead of performing
			// a click related to a tool.
			return;
		}
		
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
	
	private function handleMouseInDebugger(Event:MouseEvent):Void 
	{
		// If we are not active, we don't really care about
		// mouse events in the debugger.
		if (!isActive())
			return;
		
		if (Event.type == MouseEvent.MOUSE_OVER)
		{
			_debuggerInteraction = true;
		}
		else if (Event.type == MouseEvent.MOUSE_OUT)
		{
			_debuggerInteraction = false;
		}
		
		Event.stopPropagation();
	}
	
	private function handleKeyEvent(Event:KeyboardEvent):Void
	{
		if (Event.type == KeyboardEvent.KEY_DOWN)
		{
			_keysDown.set(Event.keyCode, _turn);
		}
		else if (Event.type == KeyboardEvent.KEY_UP)
		{
			_keysUp.set(Event.keyCode, _turn);
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
			button.x = -10 + _tools.length * 20; // TODO: fix this hardcoded number
			button.y = 20;
			addChild(button);
			
			resize(Math.max(_tools.length * 20, 55), 35);  // TODO: fix this hardcoded number
		}
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		var i:Int;
		
		FlxG.signals.postDraw.remove(postDraw);
		FlxG.debugger.visibilityChanged.remove(handleDebuggerVisibilityChanged);
		
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseClick);
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseClick);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyEvent);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyEvent);
		
		if (_container != null)
		{
			_container.removeEventListener(MouseEvent.MOUSE_OVER, handleMouseInDebugger);
			_container.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseInDebugger);
		}
		
		for (i in 0..._tools.length)
		{
			_tools[i].destroy();
			_tools[i] = null;
		}
		
		_selectedItems.destroy();
		_tools = null;
		_customCursor.parent.removeChild(_customCursor);
		flixelPointer.destroy();
		
		_selectedItems = null;
		_customCursor = null;
		flixelPointer = null;
		_keysDown = null;
		_keysUp = null;
		_tools = null;
	}
	
	public function isActive():Bool
	{
		return FlxG.debugger.visible && visible;
	}
	
	override public function update():Void 
	{
		var tool:Tool;
		var i:Int;
		var l:Int = _tools.length;

		if (!isActive())
			return;

		updateCustomCursors();
		
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
		
		if (!isActive())
			return;
		
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
		var gfx:Graphics = null;
		
		if (FlxG.renderBlit)
		{
			gfx = FlxSpriteUtil.flashGfx;
			gfx.clear();	
		}
		else
		{
			#if FLX_DEBUG
			gfx = FlxG.camera.debugLayer.graphics;
			#end
		}
		
		while (i < length && gfx != null)
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
	
	override public function toggleVisible():Void 
	{
		super.toggleVisible();
		
		if (!visible)
		{
			// De-select any activate tool
			setActiveTool(null);
			restoreSystemCursor();
		}
	}
	
	public function registerCustomCursor(Name:String, Icon:BitmapData):Void
	{
		var sprite:Sprite;

		if (Icon != null)
		{		
			#if (FLX_NATIVE_CURSOR && FLX_MOUSE)
			FlxG.mouse.setSimpleNativeCursorData(Name, Icon);
			#else
			sprite = new Sprite();
			sprite.visible = false;
			sprite.name = Name;
			sprite.addChild(new Bitmap(Icon));
			_customCursor.addChild(sprite);
			#end
		}
	}
	
	public function updateCustomCursors():Void
	{
		#if FLX_MOUSE
		var name:String;
		var sprite:DisplayObject;
		var i:Int;
		
		// Do we have an active tool and we are not interacting
		// with the debugger (e.g. moving the cursor over the
		// tools bar or the top bar)?
		if (_activeTool != null && !_debuggerInteraction)
		{
			// Yes, there is an active tool. Does it has a cursor of its own?
			if (_activeTool.getCursor() != null)
			{
				// Yep. Let's show it then
				name = _activeTool.getName();
				
				#if FLX_NATIVE_CURSOR
				// We have lag-free native cursors available, yay!
				// Activate it then.
				FlxG.mouse.setNativeCursor(name);
				#else
				// No fancy native cursors, so we have to emulate it.
				// Let's make the currently active tool's fake cursor visible
				for (i in 0..._customCursor.numChildren)
				{
					sprite = _customCursor.getChildAt(i);
					sprite.visible = sprite.name == name;
				}
				#end
			}
			else
			{
				// No, the current tool has no cursor of its own.
				// Let's show the system cursor then for navigation
				FlxG.mouse.useSystemCursor = true;
			}
		}
		else
		{
			// No active tool or we are using the debugger.
			// Let's show the system cursor for navigation.
			FlxG.mouse.useSystemCursor = true;
		}
		#end
	}
	
	private function saveSystemCursorInfo():Void
	{
		#if FLX_MOUSE
		_wasMouseVisible = FlxG.mouse.visible;
		_wasUsingSystemCursor = FlxG.mouse.useSystemCursor;
		#end
	}
	
	private function restoreSystemCursor():Void
	{
		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = _wasUsingSystemCursor;		
		FlxG.mouse.visible = _wasMouseVisible;
		_customCursor.visible = false;
		#end
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
	
	public function getActiveTool():Tool
	{
		return _activeTool;
	}
	
	public function setActiveTool(Value:Tool):Void
	{
		if (_activeTool != null)
		{
			_activeTool.deactivate();
			_activeTool.getButton().toggled = true;
		}
		
		if (_activeTool == Value)
		{
			Value = null;
		}
		
		_activeTool = Value;
		
		if (_activeTool != null)
		{
			// A tool is active. Enable cursor specific cursors
			setToolsCursorVisibility(true);
			
			_activeTool.getButton().toggled = false;
			_activeTool.activate();
			updateCustomCursors();
		}
		else
		{
			// No tool is active. Enable the system cursor
			// so the user can click buttons, drag windows, etc.
			setSystemCursorVisibility(true);
		}
	}
	
	private function setSystemCursorVisibility(Status:Bool):Void
	{
		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = Status;
		#end
		_customCursor.visible = !Status;
	}
	
	private function setToolsCursorVisibility(Status:Bool):Void
	{
		var i:Int;
		
		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = #if FLX_NATIVE_CURSOR Status #else false #end;
		#end
		_customCursor.visible = Status;
		
		// Hide any display-list-based custom cursor.
		// The proper cursor will be marked as visible
		// in the update loop.
		if (!Status)
		{
			for (i in 0..._customCursor.numChildren)
			{
				_customCursor.getChildAt(i).visible = false;
			}
		}
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
		var value:Int = _keysDown.get(Key) == null ? 0 : _keysDown.get(Key);
		return _turn <= value;
	}
	
	/**
	 * 
	 * @param	Key
	 * @return
	 */
	public function keyJustPressed(Key:Int):Bool
	{
		var value:Int = _keysUp.get(Key) == null ? 0 : _keysUp.get(Key);
		return (_turn - value) == 1;
	}
}
