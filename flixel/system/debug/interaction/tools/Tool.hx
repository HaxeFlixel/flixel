package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.display.Sprite;
import flixel.system.debug.interaction.Interaction;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * The base class of all tools in the interactive debug. 
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Tool extends Sprite implements IFlxDestroyable
{
	public var button(default, null):FlxSystemButton;
	public var cursor(default, null):BitmapData;
	
	private var _name:String = "(Unknown tool)";
	private var _brain:Interaction;
	
	public function init(brain:Interaction):Tool
	{
		_brain = brain;
		return this;
	}
	
	public function update():Void {}
	
	public function draw():Void {}
	
	public function activate():Void	{}
	
	public function deactivate():Void {}
	
	public function destroy():Void {}
	
	public function isActive():Bool
	{
		return _brain.activeTool == this && _brain.visible;
	}
	
	private function setButton(Icon:Class<BitmapData>):Void
	{
		button = new FlxSystemButton(Type.createInstance(Icon, [0, 0]), onButtonClicked, true);
		button.toggled = true;
	}
	
	private function setCursor(Icon:BitmapData):Void
	{
		cursor = Icon;
		_brain.registerCustomCursor(_name, cursor);
	}
	
	private function onButtonClicked():Void
	{
		_brain.setActiveTool(this);
	}
	
	public function getName():String
	{
		return _name;
	}
}
