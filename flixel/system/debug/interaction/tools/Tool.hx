package flixel.system.debug.interaction.tools;

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
	private var _cursor:BitmapData;
	private var _name:String;
	
	public function init(Brain:Interaction):Tool
	{
		_brain = Brain;
		_button = null;
		_name = "(Unknown tool)";
		return this;
	}
	
	public function update():Void {}
	
	public function draw():Void {}
	
	public function activate():Void
	{	
	}
	
	public function deactivate():Void
	{	
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
	
	public function setCursor(Icon:BitmapData):Void
	{
		_cursor = Icon;
		_brain.registerCustomCursor(_name, _cursor);
	}
	
	public function setName(Name:String):Void
	{
		_name = Name;
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
	
	public function getName():String
	{
		return _name;
	}
	
	public function getCursor():BitmapData
	{
		return _cursor;
	}
}
