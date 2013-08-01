import haxe.xml.Fast;
import nme.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxStateX;
import flixel.addons.ui.FlxUI;
/**
 * @author Lars Doucet
 */

class State_Battle extends FlxStateX
{

	override public function create() 
	{
		_xml_id = "state_battle";		
		super.create();
		hideFailedUI();
	}
	
	private function hideFailedUI():Void {
		
		//Determine which is the best layout by looking at failure thresholds
		
		//_ui.setMode("tall");
		
		var ui_wide:FlxUI = cast _ui.getAsset("wide");
		var ui_tall:FlxUI = cast _ui.getAsset("tall");
		
		
		
		if (ui_tall.failed && !ui_wide.failed) {		//Show the tall layout
			_ui.setMode("wide");			
		}else if (ui_wide.failed && !ui_tall.failed) {	//Show the wide layout
			_ui.setMode("tall");
		}else if (ui_wide.failed && ui_tall.failed) {	//Ambiguous, BOTH layouts failed
			
			//Figure out which one failed by LESS and show that one
			var diff:Float = ui_wide.failed_by - ui_tall.failed_by;
			if (diff > 0) { _ui.setMode("tall"); }
			else if (diff < 0) { _ui.setMode("wide"); }
			else {
				_ui.setMode("tall"); //If all else fails, default to "tall"
			}
		}else {
			_ui.setMode("tall");	//If all else fails, default to "tall"
		}
	}
	
	public override function getRequest(id:String, target:Dynamic, data:Dynamic):Dynamic {
		return null;
	}	
	
	public override function getEvent(id:String,target:Dynamic,data:Dynamic):Void {
		if (Std.is(data, Array) && data != null && data.length > 0) {
			switch(cast(data[0], String)) {
				case "back": FlxG.switchState(new State_Title());
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}
	
}