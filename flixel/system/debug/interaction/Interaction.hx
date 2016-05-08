package flixel.system.debug.interaction;

import flixel.system.debug.interaction.tools.*;

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
class Interaction
{
	private var _tools:Array<Tool>;
	
	public function new()
	{		
		// Add all interactive debug tools (pointer, eraser, etc)
		addTools();
		
		// Subscrite to some Flixel signals
		FlxG.signals.postDraw.add(postDraw);
		FlxG.signals.preUpdate.add(preUpdate);
	}
	
	private function addTools():Void
	{
		var availableTools:Array<Class<Tool>> = [
			Pointer,
			//Eraser,
			//Mover
		];
		var tool:Tool;
		var i:Int;
		
		_tools = [];
		
		for (i in 0...availableTools.length)
		{
			tool = Type.createInstance(availableTools[i], null);
			tool.init(this);
			tool.activate();
			
			_tools.push(tool);
			
			// If the tool has an icon, it should be displayed in
			// the tools panel (right of the screen).
			if (tool.icon != null)
			{
				// TODO: add icon to debugger
			}
		}
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
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
		
		for (i in 0...l)
		{
			tool = _tools[i];
			tool.update();
		}
	}
	
	/**
	 * Called after the game state has been drawn.
	 */
	private function postDraw():Void
	{
		var tool:Tool;
		var i:Int;
		var l:Int = _tools.length;
		
		for (i in 0...l)
		{
			tool = _tools[i];
			tool.draw();
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
}
