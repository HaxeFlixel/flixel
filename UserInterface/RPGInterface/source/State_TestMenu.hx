import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
/**
 * @author Lars Doucet
 */

class State_TestMenu extends FlxUIState
{
	override public function create() 
	{
		_xml_id = "state_menu";
		super.create();
	}
	
	public override function getRequest(name:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		return null;
	}	
	
	public override function getEvent(name:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		if (params != null)
		{
			switch (name)
			{
				case "click_button":
					switch (Std.string(params[0]))
					{
						case "back": FlxG.switchState(new State_Title());
					}
			}
		}
	}
	
	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}