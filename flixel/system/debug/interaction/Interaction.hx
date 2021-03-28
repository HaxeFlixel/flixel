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
import flixel.system.debug.interaction.tools.Transform;
import flixel.system.debug.interaction.tools.Eraser;
import flixel.system.debug.interaction.tools.Mover;
import flixel.system.debug.interaction.tools.Pointer;
import flixel.system.debug.interaction.tools.Tool;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
#if !(FLX_NATIVE_CURSOR && FLX_MOUSE)
import flash.display.Bitmap;
#end
#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
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

	/**
	 * Control if an outline should be drawn on selected elements.
	 * Tools can set this property to `false` if they want to draw custom
	 * selection marks, for instance.
	 */
	public var shouldDrawItemsSelection:Bool = true;

	var _container:Sprite;
	var _customCursor:Sprite;
	var _tools:Array<Tool> = [];
	var _turn:Int = 2;
	var _keysDown:Map<Int, Bool> = new Map();
	var _keysUp:Map<Int, Int> = new Map();
	var _wasMouseVisible:Bool;
	var _wasUsingSystemCursor:Bool;
	var _debuggerInteraction:Bool = false;
	var _flixelPointer:FlxPointer = new FlxPointer();

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
		addTool(new Transform());

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

	function handleDebuggerVisibilityChanged():Void
	{
		if (FlxG.debugger.visible)
			saveSystemCursorInfo();
		else
			restoreSystemCursor();
	}

	function updateMouse(event:MouseEvent):Void
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

	function handleMouseClick(event:MouseEvent):Void
	{
		// Did the user click a debugger UI element instead of performing
		// a click related to a tool?
		if (event.type == MouseEvent.MOUSE_DOWN && belongsToDebugger(cast event.target))
			return;

		pointerJustPressed = event.type == MouseEvent.MOUSE_DOWN;
		pointerJustReleased = event.type == MouseEvent.MOUSE_UP;

		if (pointerJustPressed)
			pointerPressed = true;
		else if (pointerJustReleased)
			pointerPressed = false;
	}

	function belongsToDebugger(object:DisplayObject):Bool
	{
		if (object == null)
			return false;
		else if ((object is FlxDebugger))
			return true;
		return belongsToDebugger(object.parent);
	}

	function handleMouseInDebugger(event:MouseEvent):Void
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

	function handleKeyEvent(event:KeyboardEvent):Void
	{
		if (event.type == KeyboardEvent.KEY_DOWN)
			_keysDown.set(event.keyCode, true);
		else if (event.type == KeyboardEvent.KEY_UP)
		{
			_keysDown.set(event.keyCode, false);
			_keysUp.set(event.keyCode, _turn);
		}
	}

	function countToolsWithUIButton():Int
	{
		var count = 0;
		for (tool in _tools)
			if (tool.button != null)
				count++;
		return count;
	}

	/**
	 * Add a new tool to the interaction system.
	 *
	 * Any tool added to the interaction system must extend the class
	 * `flixel.system.debug.interaction.tools.Tool`. The class contains several methods
	 * that can be used to provide new funcionalities to the interaction, or they can be
	 * overridden to alter existing behavior. For instance, tools can draw things on the
	 * screen, they can be activated when the user clicks a button, and so on. Check
	 * the classes in the package `flixel.system.debug.interaction.tools` for examples.
	 *
	 * @param tool instance of a tool that will be added to the interaction system.
	 */
	public function addTool(tool:Tool):Void
	{
		tool.init(this);
		_tools.push(tool);

		// If the tool has no button, it is not added to the interaction window
		var button = tool.button;
		if (button == null)
			return;

		var buttonsPerLine = 2;
		var buttons = countToolsWithUIButton();
		var lines = Std.int(Math.ceil(buttons / buttonsPerLine));
		var slot = Std.int(buttons / lines);

		button.x = -15 + slot * 25;
		button.y = 20 * lines;

		addChild(button);
		resize(25 * Math.min(buttons, buttonsPerLine) + 10, 25 * lines + 10);
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
	function postDraw():Void
	{
		if (!isActive())
			return;

		for (tool in _tools)
			tool.draw();

		if (shouldDrawItemsSelection)
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

	function drawItemsSelection():Void
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
				gfx.drawRect(member.x - FlxG.camera.scroll.x, member.y - FlxG.camera.scroll.y, member.width * 1.0, member.height * 1.0);
			}
		}

		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}

	/**
	 * Obtain a reference to a tool that has been added to the interaction system and is
	 * available for use. This method can be used to access information provided by any
	 * tool in the system, or to change their behavior.
	 *
	 * @param className name of the class to be fetched, e.g. `flixel.system.debug.interaction.tools.Pointer`.
	 * @return Tool reference to the first tool found whose type matches the class name provided. If no tool is found, `null` is returned.
	 */
	public function getTool(className:Class<Tool>):Tool
	{
		for (tool in _tools)
			if (isOfType(tool, className))
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
				var cursorInUse = activeTool.cursorInUse == "" ? activeTool.getName() : activeTool.cursorInUse;
				#if FLX_NATIVE_CURSOR
				// We have lag-free native cursors available, yay!
				// Activate it then.
				FlxG.mouse.setNativeCursor(cursorInUse);
				#else
				// No fancy native cursors, so we have to emulate it.
				// Let's make the currently active tool's fake cursor visible
				for (i in 0..._customCursor.numChildren)
				{
					var sprite = _customCursor.getChildAt(i);
					sprite.visible = sprite.name == cursorInUse;
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

	function saveSystemCursorInfo():Void
	{
		#if FLX_MOUSE
		_wasMouseVisible = FlxG.mouse.visible;
		_wasUsingSystemCursor = FlxG.mouse.useSystemCursor;
		#end
	}

	function restoreSystemCursor():Void
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

		// If the requested new tool is the same as the already active one,
		// we deactive it (toggle behavior).
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

		#if FLX_MOUSE
		// Allow mouse input only if the interaction tool is visible
		// and no tool is active.
		FlxG.mouse.enabled = !isInUse();
		#end
	}

	function setSystemCursorVisibility(status:Bool):Void
	{
		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = status;
		#end
		_customCursor.visible = !status;
	}

	function setToolsCursorVisibility(status:Bool):Void
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

	/**
	 * Informs whether the interactive debug is in use or not. Usage is defined
	 * as the interactive debug being visible and one of its tools is selected/active.
	 *
	 * @return `true` if the interactive debug is visible and one of its tools is selected/active.
	 */
	public function isInUse():Bool
	{
		return FlxG.debugger.visible && visible && activeTool != null;
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
			else if ((member is FlxSprite) && area.overlaps(cast(member, FlxSprite).getHitbox()))
				items.push(cast member);
		}
	}
}
