package;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;

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
		
		cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_TAB);
		
		click_text = cast _ui.getAsset("click_text");
		move_text = cast _ui.getAsset("move_text");
		event_text = cast _ui.getAsset("event_text");
		
		updateInputMethod();
	}
	
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		if (destroyed) 
		{ 
			return;
		}
		
		var widget:IFlxUIWidget = cast sender;
		if (name == FlxUICheckBox.CLICK_EVENT)
		{
			var checked:Bool = cast data;
			var type:String = cast params[0];
			switch (type)
			{
				case "wrap": 
					cursor.wrap = checked;
				case "tab","arrows","wasd","numpad","dpad","lstick","rstick","bumpers":
					updateInputMethod();
			}
		}
		
		if (click_text != null)
		{
			if (widget != null && Std.is(widget, FlxUIButton))
			{
				var fuib:FlxUIButton = cast widget;
				if (name == "cursor_jump")
				{
					move_text.text = name + ": " + fuib.params;
				}
				else if (name == "cursor_click")
				{
					click_text.text = name + ": " + fuib.params;
				}
				else
				{
					event_text.text = name + ": " + fuib.params;
				}
			}
			else
			{
				event_text.text = name + ": Location (" + cursor.location + ")";
			}
		}
	}
	
	private function updateInputMethod():Void
	{
		var check:FlxUICheckBox;
		var input:Int = 0;
		var modes:Array<String>=[];
		
		check = cast _ui.getAsset("check_tab");
		if (check.checked)
		{
			input = input | FlxUICursor.KEYS_TAB;
			modes.push("Tab/Shift+Tab");
		}
		check = cast _ui.getAsset("check_arrows");
		if (check.checked) { 
			input = input | FlxUICursor.KEYS_ARROWS;
			modes.push("Arrows");
		}
		check = cast _ui.getAsset("check_wasd");
		if (check.checked)
		{
			input = input | FlxUICursor.KEYS_WASD;
			modes.push("WASD");
		}
		check = cast _ui.getAsset("check_numpad");
		if (check.checked)
		{ 
			input = input | FlxUICursor.KEYS_NUMPAD; 
			modes.push("NUMPAD");
		}
		
		check = cast _ui.getAsset("check_dpad");
		if (check.checked)
		{ 
			input = input | FlxUICursor.GAMEPAD_DPAD; 
			modes.push("DPAD");
		}
		check = cast _ui.getAsset("check_lstick");
		if (check.checked)
		{ 
			input = input | FlxUICursor.GAMEPAD_LEFT_STICK; 
			modes.push("LSTICK");
		}
		check = cast _ui.getAsset("check_rstick");
		if (check.checked)
		{ 
			input = input | FlxUICursor.GAMEPAD_RIGHT_STICK; 
			modes.push("RSTICK");
		}
		check = cast _ui.getAsset("check_bumpers");
		if (check.checked)
		{ 
			input = input | FlxUICursor.GAMEPAD_SHOULDER_BUTTONS; 
			modes.push("BUMPERS");
		}
		
		var instructions:FlxUIText = cast _ui.getAsset("text");
		if (modes.length > 0)
		{
			instructions.text = "Move:("+modes.join(", ")+")  Click:(ENTER)";
		}
		else
		{
			instructions.text = "Mouse Input Only";
		}
		
		cursor.setDefaultKeys(input);
	}
}