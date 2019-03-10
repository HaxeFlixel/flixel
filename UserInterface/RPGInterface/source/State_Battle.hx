import flixel.addons.ui.FlxUITypedButton.FlxUITypedButton;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUI;
import openfl.events.Event;
/**
 * @author Lars Doucet
 */

class State_Battle extends FlxUIState
{
	override public function create() 
	{
		_xml_id = "state_battle";
		super.create();
		hideFailedUI();
	}
	
	function hideFailedUI():Void
	{
		
		//Determine which is the best layout by looking at failure thresholds
		
		//_ui.setMode("tall");
		
		var ui_wide:FlxUI = cast _ui.getAsset("wide");
		var ui_tall:FlxUI = cast _ui.getAsset("tall");
		
		#if debug
		trace("ui_tall.failed = " + ui_tall.failed + " by = " + ui_tall.failed_by);
		trace("ui_wide.failed = " + ui_wide.failed + " by = " + ui_wide.failed_by);
		#end
		
		if (ui_tall.failed && !ui_wide.failed)
		{		//Show the tall layout
			_ui.setMode("wide");			
		}
		else if (ui_wide.failed && !ui_tall.failed)
		{	//Show the wide layout
			_ui.setMode("tall");
		}
		else if (ui_wide.failed && ui_tall.failed) 
		{	//Ambiguous, BOTH layouts failed
			
			//Figure out which one failed by LESS and show that one
			var diff:Float = ui_wide.failed_by - ui_tall.failed_by;
			if (diff > 0)
				_ui.setMode("tall");
			else if (diff < 0) 
				_ui.setMode("wide");
			else
				_ui.setMode("tall"); //If all else fails, default to "tall"
		}
		else
		{
			_ui.setMode("tall");	//If all else fails, default to "tall"
		}
	}
	
	override function reloadUI(?e:Event):Void
	{
		super.reloadUI(e);
		hideFailedUI();
	}
	
	override public function getRequest(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		return null;
	}	
	
	override public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		if (params != null)
		{
			switch (id)
			{
				case FlxUITypedButton.CLICK_EVENT: 
					switch (Std.string(params[0]))
					{
						case "back": FlxG.switchState(new State_Title());
					}
			}
		}
	}
}