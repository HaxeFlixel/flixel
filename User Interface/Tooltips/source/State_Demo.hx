import flixel.addons.ui.FlxUIButton;
import haxe.xml.Fast;
import flash.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
/**
 * @author Lars Doucet
 */

class State_Demo extends FlxUIState
{

	override public function create() 
	{
		_xml_id = "state_menu";
		super.create();
	}
	
	public override function getRequest(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic {
		return null;
	}	
	
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		super.getEvent(name, sender, data, params);
	}
	
	public override function update(elapsed:Float):Void {
		super.update(elapsed);
		#if debug
			if (FlxG.keys.justPressed.R)
			{
				FlxG.switchState(new State_Demo());
			}
		#end
	}
	
}