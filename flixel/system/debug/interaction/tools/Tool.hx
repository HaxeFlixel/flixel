package flixel.system.debug.interaction.tools;

import flash.display.*;
import flixel.system.debug.interaction.Interaction;

/**
 * The base class of all tools in the interactive debug. 
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Tool extends Sprite
{		
	private var _brain:Interaction;
	private var _active:Bool;
	
	public function init(Brain:Interaction):Tool
	{
		_active = false;
		_brain = Brain;
		return this;
	}
	
	public function update():Void
	{
	}
	
	public function draw():Void
	{
	}
	
	public function activate():Void
	{
		_active = true;
	}
	
	public function deactivate():Void
	{
		_active = false;
	}
	
	public function isActive():Bool
	{
		return _active;
	}
	
	public function getBrain():Interaction
	{
		return _brain;
	}
}
