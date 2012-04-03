package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
//import org.flixel.FlxEmitter;
import addons.FlxEmitterExt;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;

class MenuState extends FlxState
{
	//public var gibs:FlxEmitter;
	public var gibs:FlxEmitterExt;
	public var playButton:FlxButton;
	public var title1:FlxText;
	public var title2:FlxText;
	public var fading:Bool;
	public var timer:Float;
	public var attractMode:Bool;
	
	public var pathFollower:FlxSprite;
	public var testPath:FlxPath;
	
	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xff131c1b;
		#else
		FlxG.bgColor = {rgb: 0x131c1b, a: 0xff};
		#end
		
		//Simple use of flixel save game object.
		//Tracks number of times the game has been played.
		var save:FlxSave = new FlxSave();
		if(save.bind("Mode"))
		{
			if(save.data.plays == null)
			{
				save.data.plays = 0.0;
			}
			else
			{
				save.data.plays++;
			}
			FlxG.log("Number of plays: " + save.data.plays);
			//save.erase();
			save.close();
		}

		//All the bits that blow up when the text smooshes together
	//	gibs = new FlxEmitter(FlxG.width / 2 - 50, FlxG.height / 2 - 10);
		gibs = new FlxEmitterExt(FlxG.width / 2 - 50, FlxG.height / 2 - 10);
		gibs.setSize(100, 30);
		gibs.setYSpeed( -200, -20);
		gibs.setRotation( -720, 720);
		gibs.gravity = 100;
		gibs.makeParticles(FlxAssets.imgSpawnerGibs, 650, 32, true, 0);
		add(gibs);

		//the letters "mo"
		title1 = new FlxText(FlxG.width + 16, FlxG.height / 3, 64, "mo");
		title1.size = 32;
		#if neko
		title1.color = { rgb: 0x3a5c39, a: 0xff };
		#else
		title1.color = 0x3a5c39;
		#end
		title1.antialiasing = true;
		title1.velocity.x = -FlxG.width;
		add(title1);

		//the letters "de"
		title2 = new FlxText( -60, title1.y, Math.floor(title1.width), "de");
		title2.size = title1.size;
		title2.color = title1.color;
		title2.antialiasing = title1.antialiasing;
		title2.velocity.x = FlxG.width;
		add(title2);
		
		fading = false;
		timer = 0;
		attractMode = false;
		
		FlxG.mouse.show(FlxAssets.imgCursor, 2);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		gibs = null;
		playButton = null;
		title1 = null;
		title2 = null;
	}

	override public function update():Void
	{
		super.update();
		
		if(title2.x > title1.x + title1.width - 4)
		{
			//Once mo and de cross each other, fix their positions
			title2.x = title1.x + title1.width - 4;
			title1.velocity.x = 0;
			title2.velocity.x = 0;
			
			//Then, play a cool sound, change their color, and blow up pieces everywhere
			if (Mode.SoundOn)
			{
				FlxG.play(Assets.getSound("assets/menu_hit" + Mode.SoundExtension));
			}
			
			#if neko
			FlxG.flash({rgb: 0xd8eba2, a: 0xff}, 0.5);
			#else
			FlxG.flash(0xffd8eba2, 0.5);
			#end
			FlxG.shake(0.035, 0.5);
			#if neko
			title1.color = { rgb:0xd8eba2, a:0xff };
			title2.color = { rgb:0xd8eba2, a:0xff };
			#else
			title1.color = 0xd8eba2;
			title2.color = 0xd8eba2;
			#end
			gibs.start(true, 5);
			title1.angle = FlxG.random() * 30 - 15;
			title2.angle = FlxG.random() * 30 - 15;
			
			//Then we're going to add the text and buttons and things that appear
			//If we were hip we'd use our own button animations, but we'll just recolor
			//the stock ones for now instead.
			var text:FlxText;
			text = new FlxText(FlxG.width / 2 - 50, FlxG.height / 3 + 39, 100, "by Adam Atomic");
			text.alignment = "center";
			#if neko
			text.color = { rgb: 0x3a5c39, a: 0xff };
			#else
			text.color = 0x3a5c39;
			#end
			add(text);
			
			text = new FlxText(FlxG.width / 2 - 40, FlxG.height / 3 + 119, 80, "X+C TO PLAY");
			#if neko
			text.color = { rgb: 0x729954, a: 0xff };
			#else
			text.color = 0x729954;
			#end
			text.alignment = "center";
			add(text);
			
			var flixelButton:FlxButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 3 + 54, "flixel.org", onFlixel);
			#if !neko
			flixelButton.color = 0xff729954;
			flixelButton.label.color = 0xffd8eba2;
			#else
			flixelButton.color = { rgb:0x729954, a:0xff };
			flixelButton.label.color = { rgb:0xd8eba2, a:0xff };
			#end
			add(flixelButton);
			
			var dannyButton:FlxButton = new FlxButton(flixelButton.x, flixelButton.y + 22, "music: dannyB", onDanny);
			dannyButton.color = flixelButton.color;
			dannyButton.label.color = flixelButton.label.color;
			add(dannyButton);
			
			//playButton = new FlxButton(flixelButton.x, flixelButton.y + 62, "CLICK HERE", onPlay);
			playButton = new FlxButton(flixelButton.x, text.y - 2, "CLICK HERE", onPlay);
			playButton.color = flixelButton.color;
			playButton.label.color = flixelButton.label.color;
			add(playButton);
		}

		//X + C were pressed, fade out and change to play state.
		//OR, if we sat on the menu too long, launch the attract mode instead!
		timer += FlxG.elapsed;
		if(timer >= 10) //go into demo mode if no buttons are pressed for 10 seconds
		{
			attractMode = true;
		}
		if(!fading && ((FlxG.keys.X && FlxG.keys.C) || attractMode)) 
		{
			fading = true;
			if (Mode.SoundOn)
			{
				FlxG.play(Assets.getSound("assets/menu_hit_2" + Mode.SoundExtension));
			}
			
			#if !neko
			FlxG.flash(0xffd8eba2, 0.5);
			FlxG.fade(0xff131c1b, 1, false, onFade);
			#else
			FlxG.flash({rgb:0xd8eba2, a:0xff}, 0.5);
			FlxG.fade({rgb:0x131c1b, a:0xff}, 1, false, onFade);
			#end
		}
	}
	
	//These are all "event handlers", or "callbacks".
	//These first three are just called when the
	//corresponding buttons are pressed with the mouse.
	private function onFlixel():Void
	{
		FlxU.openURL("http://flixel.org");
	}
	
	private function onDanny():Void
	{
		FlxU.openURL("http://dbsoundworks.com");
	}
	
	private function onPlay():Void
	{
		//playButton.exists = false;
		onFade();
		if (Mode.SoundOn)
		{
			FlxG.play(Assets.getSound("assets/menu_hit_2" + Mode.SoundExtension));
		}
	}
	
	//This function is passed to FlxG.fade() when we are ready to go to the next game state.
	//When FlxG.fade() finishes, it will call this, which in turn will either load
	//up a game demo/replay, or let the player start playing, depending on user input.
	private function onFade():Void
	{
		if(attractMode)
		{
			FlxG.loadReplay((FlxG.random() < 0.5)?(Assets.getText("assets/attract1.fgr")):(Assets.getText("assets/attract2.fgr")), new PlayState(), ["ANY"], 22, onDemoComplete);
		}
		else
		{
			FlxG.switchState(new PlayState());
		}
	}
	
	//This function is called by FlxG.loadReplay() when the replay finishes.
	//Here, we initiate another fade effect.
	private function onDemoComplete():Void
	{
		#if !neko
		FlxG.fade(0xff131c1b, 1, false, onDemoFaded);
		#else
		FlxG.fade({rgb:0x131c1b, a:0xff}, 1, false, onDemoFaded);
		#end
	}
	
	//Finally, we have another function called by FlxG.fade(), this time
	//in relation to the callback above.  It stops the replay, and resets the game
	//once the gameplay demo has faded out.
	private function onDemoFaded():Void
	{
		FlxG.stopReplay();
		FlxG.resetGame();
	}
}