package flixel.system.debug.interaction.tools;

import flash.display.*;
import flixel.system.debug.interaction.Interaction;
import flixel.system.ui.FlxSystemButton;

/**
 * The base class of all tools in the interactive debug. 
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Tool extends Sprite
{		
	private var _brain:Interaction;
	private var _active:Bool;
	private var _button:FlxSystemButton;
	
	public function init(Brain:Interaction):Tool
	{
		_active = false;
		_brain = Brain;
		_button = null;
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
	
	public function toggleActivation():Void
	{
		if (isActive())
			deactivate();
		else
			activate();
	}
	
	public function isActive():Bool
	{
		return _active;
	}
	
	public function getBrain():Interaction
	{
		return _brain;
	}
	
	public function setButton(Icon:Class<BitmapData>):Void
	{
		_button = new FlxSystemButton(Type.createInstance(Icon, [0, 0]), toggleActivation, true);
	}
	
	/**
	 * 
	 * @return
	 */
	public function getButton():FlxSystemButton
	{
		return _button;
	}
}
