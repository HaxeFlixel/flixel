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
		
		var butt_pause:FlxUIButton = cast _ui.getAsset("butt_pause");
		enablePause(false);
	}
	
	public override function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		if (destroyed) 
		{ 
			return;
		}
		
		if (name == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			if (label == "loop music")
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
				if (sound != null && sound.exists && sound != FlxG.sound.music)
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
			
			if (label == "pause music")
			{
				if (FlxG.sound.music != null && FlxG.sound.music.exists)
				{
					if (fuib.toggled)
					{
						FlxG.sound.music.pause();
					}
					else
					{
						FlxG.sound.music.resume();
					}
				}
			}
			else if (Assets.exists(sound_id, AssetType.SOUND) || Assets.exists(sound_id, AssetType.MUSIC))
			{
				if (label == "music")
				{
					if (FlxG.sound.music != null && FlxG.sound.music.active)
					{
						fuib.toggled = false;
						FlxG.sound.music.stop();
						enablePause(false);
					}
					else
					{
						fuib.toggled = true;
						FlxG.sound.playMusic(sound_id, music_volume, loop_music);
						FlxG.sound.music.onComplete = musicComplete;
						enablePause(true);
					}
				}
				else
				{
					FlxG.sound.play(sound_id, sfx_volume);
				}
			}
		}
	}
	
	private function enablePause(b:Bool):Void
	{
		var butt_pause:FlxUIButton = cast _ui.getAsset("butt_pause");
		if (b)
		{
			butt_pause.active = true;
			butt_pause.toggled = false;
			butt_pause.color = FlxColor.fromRGB(128, 192, 255);
		}
		else
		{ 
			butt_pause.active = false;
			butt_pause.color = FlxColor.fromRGB(128, 128, 128);
		}
	}
	
	private function musicComplete():Void
	{
		if (!loop_music)
		{
			var butt:FlxUIButton = cast _ui.getAsset("butt_music");
			butt.toggled = false;
			enablePause(false);
		}
	}
}