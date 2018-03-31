package flixel.system.debug.interaction;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.KeyboardEvent;
import flixel.FlxObject;
import flash.events.MouseEvent;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.debug.FlxDebugger.GraphicInteractive;
import flixel.system.debug.Window;
import flixel.system.debug.interaction.tools.Eraser;
import flixel.system.debug.interaction.tools.Mover;
import flixel.system.debug.interaction.tools.Pointer;
import flixel.system.debug.interaction.tools.Tool;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;

#if !(FLX_NATIVE_CURSOR && FLX_MOUSE)
import flash.display.Bitmap;
#end

/**
 * Adds a new functionality to Flixel debugger that allows any object
 * on the screen to be dragged, moved or deleted while the game is
 * still running.
 * 
 * @author	Fernando Bevilacqua (dovyski@gmail.com)
 */
class Interaction extends Window
{
	public var activeTool(default, null):Tool;
	public var selectedItems(default, null):FlxTypedGroup<FlxObject> = new FlxTypedGroup();
	
	public var flixelPointer:FlxPoint = new FlxPoint();
	public var pointerJustPressed:Bool = false;
	public var pointerJustReleased:Bool = false;
	public var pointerPressed:Bool = false;
	
	private var _container:Sprite;
	private var _customCursor:Sprite;
	private var _tools:Array<Tool> = [];
	private var _turn:Int = 2;
	private var _keysDown:Map<Int, Bool> = new Map();
	private var _keysUp:Map<Int, Int> = new Map();
	private var _wasMouseVisible:Bool;
	private var _wasUsingSystemCursor:Bool;
	private var _debuggerInteraction:Bool = false;
	private var _flixelPointer:FlxPointer = new FlxPointer();
	
	public function new(container:Sprite)
	{
		super("Tools", new GraphicInteractive(0, 0), 40, 25, false);
		reposition(2, 100);
		_container = container;
		
		_customCursor = new Sprite();
		_customCursor.mouseEnabled = false;
		_container.addChild(_customCursor);
		
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
			saveSystemCursorInfo();
		else
			restoreSystemCursor();
	}
	
	private function updateMouse(event:MouseEvent):Void
	{
		#if (neko || js) // openfl/openfl#1305
		if (event.stageX == null || event.stageY == null)
			return;
		#end

		var offsetX = 0.0;
		var offsetY = 0.0;
		
		// If the active tool has a custom cursor, we assume its
		// "point of click" is the center of the cursor icon.
		if (activeTool != null)
		{
			var cursorIcon = activeTool.cursor;
			if (cursorIcon != null)
			{
				offsetX = cursorIcon.width / FlxG.scaleMode.scale.x / 2;
				offsetY = cursorIcon.height / FlxG.scaleMode.scale.y / 2;
			}
		}
		
		_customCursor.x = event.stageX + offsetX;
		_customCursor.y = event.stageY + offsetY;
		
		#if FLX_MOUSE
		// Calculate in-game coordinates based on mouse position and camera.
		_flixelPointer.setGlobalScreenPositionUnsafe(event.stageX, event.stageY);
		
		// Store Flixel mouse coordinates to speed up all
		// internal calculations (overlap, etc)
		flixelPointer.x = _flixelPointer.x + offsetX;
		flixelPointer.y = _flixelPointer.y + offsetY;
		#end
	}
	
	private function handleMouseClick(event:MouseEvent):Void 
	{
		// Did the user click a debugger UI element instead of performing
		// a click related to a tool?
		if (event.type == MouseEvent.MOUSE_DOWN && belongsToDebugger(event.target))
			return;
		
		pointerJustPressed = event.type == MouseEvent.MOUSE_DOWN;
		pointerJustReleased = event.type == MouseEvent.MOUSE_UP;
		
		if (pointerJustPressed)
			pointerPressed = true;
		else if (pointerJustReleased)
			pointerPressed = false;
	}

	private function belongsToDebugger(object:DisplayObject):Bool
	{
		if (object == null)
			return false;
		else if (Std.is(object, FlxDebugger))
			return true;
		return belongsToDebugger(object.parent);
	}
	
	private function handleMouseInDebugger(event:MouseEvent):Void 
	{
		// If we are not active, we don't really care about
		// mouse events in the debugger.
		if (!isActive())
			return;
		
		if (event.type == MouseEvent.MOUSE_OVER)
			_debuggerInteraction = true;
		else if (event.type == MouseEvent.MOUSE_OUT)
			_debuggerInteraction = false;
		
		event.stopPropagation();
	}
	
	private function handleKeyEvent(event:KeyboardEvent):Void
	{
		if (event.type == KeyboardEvent.KEY_DOWN)
			_keysDown.set(event.keyCode, true);
		else if (event.type == KeyboardEvent.KEY_UP)
		{
			_keysDown.set(event.keyCode, false);
			_keysUp.set(event.keyCode, _turn);
		}
	}
	
	private function addTool(tool:Tool):Void
	{
		tool.init(this);
		_tools.push(tool);
		
		// If the tool has a button, add it to the interaction window
		var button = tool.button;
		if (button == null)
			return;

		button.x = -10 + _tools.length * 20; // TODO: fix this hardcoded number
		button.y = 20;
		addChild(button);
		
		resize(Math.max(_tools.length * 20, 55), 35);  // TODO: fix this hardcoded number
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
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
		
		if (_customCursor != null)
		{
			_customCursor.parent.removeChild(_customCursor);
			_customCursor = null;
		}
		
		_tools = FlxDestroyUtil.destroyArray(_tools);
		selectedItems = FlxDestroyUtil.destroy(selectedItems);
		flixelPointer = FlxDestroyUtil.destroy(flixelPointer);
		
		_keysDown = null;
		_keysUp = null;
	}
	
	public function isActive():Bool
	{
		return FlxG.debugger.visible && visible;
	}
	
	override public function update():Void 
	{
		if (!isActive())
			return;

		updateCustomCursors();
		
		for (tool in _tools)
			tool.update();
		
		pointerJustPressed = false;
		pointerJustReleased = false;
		_turn++;
	}
	
	/**
	 * Called after the game state has been drawn.
	 */
	private function postDraw():Void
	{
		if (!isActive())
			return;
		
		for (tool in _tools)
			tool.draw();
		
		drawItemsSelection();
	}
	
	public function getDebugGraphics():Graphics
	{
		if (FlxG.renderBlit)
		{
			FlxSpriteUtil.flashGfx.clear();
			return FlxSpriteUtil.flashGfx;
		}
		
		#if FLX_DEBUG
		return FlxG.camera.debugLayer.graphics;
		#end
		
		return null;
	}
	
	private function drawItemsSelection():Void 
	{
		var gfx:Graphics = getDebugGraphics();
		if (gfx == null)
			return;
		
		for (member in selectedItems)
		{
			if (member != null && member.scrollFactor != null && member.isOnScreen())
			{
				// Render a red rectangle centered at the selected item
				gfx.lineStyle(0.9, 0xff0000);
				gfx.drawRect(member.x - FlxG.camera.scroll.x,
					member.y - FlxG.camera.scroll.y,
					member.width * 1.0, member.height * 1.0);
			}
		}
		
		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	
	private function getTool(className:Class<Tool>):Tool
	{
		for (tool in _tools)
			if (Std.is(tool, className))
				return tool;
		return null;
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
	
	public function registerCustomCursor(name:String, icon:BitmapData):Void
	{
		if (icon == null)
			return;
	
		#if (FLX_NATIVE_CURSOR && FLX_MOUSE)
		FlxG.mouse.registerSimpleNativeCursorData(name, icon);
		#else
		var sprite = new Sprite();
		sprite.visible = false;
		sprite.name = name;
		sprite.addChild(new Bitmap(icon));
		_customCursor.addChild(sprite);
		#end
	}
	
	public function updateCustomCursors():Void
	{
		#if FLX_MOUSE
		// Do we have an active tool and we are not interacting
		// with the debugger (e.g. moving the cursor over the
		// tools bar or the top bar)?
		if (activeTool != null && !_debuggerInteraction)
		{
			// Yes, there is an active tool. Does it has a cursor of its own?
			if (activeTool.cursor != null)
			{
				// Yep. Let's show it then
				#if FLX_NATIVE_CURSOR
				// We have lag-free native cursors available, yay!
				// Activate it then.
				FlxG.mouse.setNativeCursor(activeTool.getName());
				#else
				// No fancy native cursors, so we have to emulate it.
				// Let's make the currently active tool's fake cursor visible
				for (i in 0..._customCursor.numChildren)
				{
					var sprite = _customCursor.getChildAt(i);
					sprite.visible = sprite.name == activeTool.getName();
				}
				if (FlxG.mouse.visible)
					FlxG.mouse.visible = false;
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
	
	public function setActiveTool(value:Tool):Void
	{
		if (activeTool != null)
		{
			activeTool.deactivate();
			activeTool.button.toggled = true;
		}
		
		if (activeTool == value)
			value = null;
		
		activeTool = value;
		
		if (activeTool != null)
		{
			// A tool is active. Enable cursor specific cursors
			setToolsCursorVisibility(true);
			
			activeTool.button.toggled = false;
			activeTool.activate();
			updateCustomCursors();
		}
		else
		{
			// No tool is active. Enable the system cursor
			// so the user can click buttons, drag windows, etc.
			setSystemCursorVisibility(true);
		}
	}
	
	private function setSystemCursorVisibility(status:Bool):Void
	{
		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = status;
		#end
		_customCursor.visible = !status;
	}
	
	private function setToolsCursorVisibility(status:Bool):Void
	{
		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = #if FLX_NATIVE_CURSOR status #else false #end;
		#end
		_customCursor.visible = status;
		
		if (status)
			return;
		
		// Hide any display-list-based custom cursor.
		// The proper cursor will be marked as visible
		// in the update loop.
		for (i in 0..._customCursor.numChildren)
			_customCursor.getChildAt(i).visible = false;
	}
	
	public function clearSelection():Void
	{
		selectedItems.clear();
	}
	
	public function keyPressed(key:Int):Bool
	{
		return _keysDown.get(key);
	}
	
	public function keyJustPressed(key:Int):Bool
	{
		var value:Int = _keysUp.get(key) == null ? 0 : _keysUp.get(key);
		return (_turn - value) == 1;
	}
	
	public function findItemsWithinState(items:Array<FlxBasic>, state:FlxState, area:FlxRect):Void
	{
		findItemsWithinArea(items, state.members, area);
		if (state.subState != null)
			findItemsWithinState(items, state.subState, area);
	}

	/**
	 * Find all items within an area. In order to improve performance and reduce temporary allocations,
	 * the method has no return, you must pass an array where items will be placed. The method decides
	 * if an item is within the searching area or not by checking if the item's hitbox (obtained from
	 * `getHitbox()`) overlaps the area parameter.
	 * 
	 * @param	items		array where the method will place all found items. Any previous content in the array will be preserved.
	 * @param	members		array where the method will recursively search for items.
	 * @param	area		a rectangle that describes the area where the method should search within.
	 */
	@:access(flixel.group.FlxTypedGroup)
	public function findItemsWithinArea(items:Array<FlxBasic>, members:Array<FlxBasic>, area:FlxRect):Void
	{
		// we iterate backwards to get the sprites on top first
		var i = members.length;
		while (i-- > 0)
		{
			var member = members[i];
			// Ignore invisible or non-existent entities
			if (member == null || !member.visible || !member.exists)
				continue;

			var group = FlxTypedGroup.resolveGroup(member);
			if (group != null)
				findItemsWithinArea(items, group.members, area);
			else if (Std.is(member, FlxSprite) &&
				area.overlaps(cast(member, FlxSprite).getHitbox()))
				items.push(cast member);
		}
	}
}
