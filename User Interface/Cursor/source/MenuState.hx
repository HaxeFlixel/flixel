package;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxUIState
{
	private var click_text:FlxUIText;
	private var move_text:FlxUIText;
	private var event_text:FlxUIText;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_xml_id = "menu";
		_makeCursor = true;
		super.create();
		
		click_text = cast _ui.getAsset("click_text");
		move_text = cast _ui.getAsset("move_text");
		event_text = cast _ui.getAsset("event_text");
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}
	
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		var widget:IFlxUIWidget = cast sender;
		if(click_text != null){
			if (widget != null && Std.is(widget, FlxUIButton))
			{
				var fuib:FlxUIButton = cast widget;
				if(name == "cursor_move"){
					move_text.text = name + ": " + fuib.params;
				}else if (name == "cursor_click") {
					click_text.text = name + ": " + fuib.params;
				}else {
					event_text.text = name + ": " + fuib.params;
				}
			}
			else
			{
				event_text.text = name + ": " + params;
			}
		}
	}
}