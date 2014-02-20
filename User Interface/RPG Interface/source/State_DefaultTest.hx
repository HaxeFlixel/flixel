import flixel.addons.ui.FlxUIPopup;
import haxe.xml.Fast;
import flash.Lib;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxInputText;
/**
 * @author Lars Doucet
 */

class State_DefaultTest extends FlxUIState
{

	override public function create() 
	{
		_xml_id = "state_default";
		super.create();
		
		
	}
	
	public override function getRequest(id:String, target:Dynamic, data:Dynamic,?params:Array<Dynamic>):Dynamic {
		return null;
	}	
	
	public override function getEvent(id:String,target:Dynamic,data:Dynamic,?params:Array<Dynamic>):Void {
		if (params != null) {
			switch(id) {
				case "click_button":
					switch(cast(params[0], String)) {
						case "back": FlxG.switchState(new State_Title());
						case "popup":var popup:FlxUIPopup = new FlxUIPopup(); //create the popup
									 popup.quickSetup						  //set it up
									 (
									   Main.tongue.get("$POPUP_DEMO_2_TITLE","ui"), 	//title text
									   Main.tongue.get("$POPUP_DEMO_2_BODY","ui"), 		//body text
									   ["<yes>", "<no>", "<cancel>"]	  //FlxUI will translate labels to "$POPUP_YES", etc, 
									); 	  							  //and localize them if possible, 
																		  //otherwise it will display "YES", "NO", etc
									
									 openSubState(popup);				  //show the popup
									 
									 //you can call quickSetup() before or after setting the subState, it will behave properly either way
									 
									 //since the above example is a little messy, here's what it looks like without the firetongue calls:
									 //  popup.quickSetup("title","body",["Yes","No","Cancel"]);
									
					}
				case "click_popup":
					switch(cast(params[0], Int)) {
						case 0: FlxG.log.add("Yes was clicked");
						case 1: FlxG.log.add("No was clicked");
						case 2: FlxG.log.add("Cancel was clicked");
					}
			}
		}
	}
	
	public override function update():Void {
		super.update();
	}
	
}