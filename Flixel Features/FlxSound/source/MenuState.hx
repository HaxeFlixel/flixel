package;

import flixel.addons.ui.FlxUINumericStepper;
import flixel.FlxG;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.util.FlxColor;
import openfl.Assets;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxUIState
{
	private var loop_music:Bool = false;
	private var music_volume:Float = 0.5;
	private var sfx_volume:Float = 0.5;
	private var loop_count:Int = 0;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_xml_id = "menu";
		super.create();
		
		var butt_music:FlxUIButton = cast _ui.getAsset("butt_music");
		butt_music.color = FlxColor.RED;
	}
	
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (destroyed) 
		{ 
			return;
		}
		
		if (name == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			if(label == "loop music")
			{
				loop_music = check.checked;
				if (FlxG.sound.music != null && FlxG.sound.music.exists)
				{
					FlxG.sound.music.looped = loop_music;
				}
			}
		}
		else if (name == FlxUINumericStepper.CHANGE_EVENT && Std.is(sender, FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			if (wname == "music_volume")
			{
				music_volume = nums.value;
			}
			else if (wname == "sfx_volume")
			{
				sfx_volume = nums.value;
			}
			if (FlxG.sound.music != null && FlxG.sound.music.exists)
			{
				FlxG.sound.music.volume = music_volume;
			}
			for (sound in FlxG.sound.list.members)
			{
				if (sound != FlxG.sound.music)
				{
					sound.volume = sfx_volume;
				}
			}
		}
		else if (name == FlxUITypedButton.CLICK_EVENT && Std.is(sender,FlxUIButton))
		{
			var fuib:FlxUIButton = cast sender;
			var label = fuib.label.text;
			
			var sound_id:String = "assets/sounds/"+label;
			#if flash
				sound_id += ".mp3";
			#else
				sound_id += ".ogg";
			#end
			
			if (Assets.exists(sound_id))
			{
				if (label == "music")
				{
					if (FlxG.sound.music != null && FlxG.sound.music.exists && FlxG.sound.music.playing)
					{
						FlxG.sound.music.stop();
					}
					else
					{
						FlxG.sound.playMusic(sound_id, music_volume, loop_music);
						FlxG.sound.music.onComplete = musicComplete;
					}
				}
				else
				{
					FlxG.sound.play(sound_id, sfx_volume);
				}
			}
		}
	}
	
	private function musicComplete():Void
	{
		if (!loop_music)
		{
			var butt:FlxUIButton = cast _ui.getAsset("butt_music");
			butt.toggled = false;
		}
	}
}