package flixel.system.debug.interaction.tools;

import flash.display.DisplayObject;
import flash.display.BitmapData;
import flash.display.Sprite;
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
	private var _button:FlxSystemButton;
	private var _cursor:DisplayObject;
	
	public function init(Brain:Interaction):Tool
	{
		_brain = Brain;
		_button = null;
		return this;
	}
	
	public function update():Void {}
	
	public function draw():Void {}
	
	public function activate():Void
	{	
		// If the tool has a custom cursor,
		// show it now
		if (_cursor != null)
		{
			_brain.setCustomCursor(_cursor);
		}
	}
	
	public function deactivate():Void
	{	
		if (_cursor != null)
		{
			_brain.setCustomCursor(null);
		}
	}
	
	public function isActive():Bool
	{
		return _brain.getActiveTool() == this && _brain.visible;
	}
	
	public function getBrain():Interaction
	{
		return _brain;
	}
	
	public function setButton(Icon:Class<BitmapData>):Void
	{
		_button = new FlxSystemButton(Type.createInstance(Icon, [0, 0]), onButtonClicked, true);
	}
	
	public function setCursor(Icon:DisplayObject):Void
	{
		_cursor = Icon;
	}
	
	private function onButtonClicked():Void
	{
		_brain.setActiveTool(this);
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
