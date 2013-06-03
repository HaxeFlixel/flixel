package;

import openfl.Assets;
import flash.geom.Rectangle;
import org.flixel.FlxButton;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;
import org.flixel.plugin.pxText.FlxBitmapTextField;
import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.plugin.pxText.PxButton;
import org.flixel.plugin.pxText.PxTextAlign;

class MenuState extends FlxState
{
	public var gibs:FlxEmitter;
	public var playButton:FlxButton;
	public var title1:FlxText;
	public var title2:FlxText;
	public var fading:Bool;
	public var timer:Float;
	public var attractMode:Bool;
	
	override public function create():Void
	{
		FlxG.bgColor = 0xff131c1b;
		
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
		gibs = new FlxEmitter(FlxG.width / 2 - 50, FlxG.height / 2 - 10);
		gibs.setSize(100, 30);
		gibs.setYSpeed( -200, -20);
		gibs.setRotation( -720, 720);
		gibs.gravity = 100;
		gibs.makeParticles(FlxAssets.imgSpawnerGibs, 650, 32, true, 0);
		add(gibs);

		//the letters "mo"
		title1 = new FlxText(FlxG.width + 16, FlxG.height / 3, 64, "mo");
		title1.size = 32;
		title1.color = 0x3a5c39;
		title1.antialiasing = true;
		title1.moves = true;
		title1.velocity.x = -FlxG.width;
		add(title1);

		//the letters "de"
		title2 = new FlxText( -60, title1.y, Math.floor(title1.width), "de");
		title2.size = title1.size;
		title2.moves = true;
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
			FlxG.play("MenuHit");
			
			FlxG.flash(0xffd8eba2, 0.5);
			FlxG.shake(0.035, 0.5);
			title1.color = 0xd8eba2;
			title2.color = 0xd8eba2;
			gibs.start(true, 5);
			title1.angle = FlxG.random() * 30 - 15;
			title2.angle = FlxG.random() * 30 - 15;
			
			//Then we're going to add the text and buttons and things that appear
			//If we were hip we'd use our own button animations, but we'll just recolor
			//the stock ones for now instead.
			var text:FlxText;
			text = new FlxText(FlxG.width / 2 - 50, FlxG.height / 3 + 39, 100, "by Adam Atomic");
			text.alignment = "center";
			text.color = 0x3a5c39;
			add(text);
			
			text = new FlxText(FlxG.width / 2 - 40, FlxG.height / 3 + 119, 80, "X+C TO PLAY");
			text.color = 0x729954;
			text.alignment = "center";
			add(text);
			
			var flixelButton:FlxButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 3 + 54, "flixel.org", onFlixel);
			flixelButton.color = 0xff729954;
			flixelButton.label.color = 0xffd8eba2;
			add(flixelButton);
			
			var dannyButton:FlxButton = new FlxButton(flixelButton.x, flixelButton.y + 22, "music: dannyB", onDanny);
			dannyButton.color = flixelButton.color;
			dannyButton.label.color = flixelButton.label.color;
			add(dannyButton);
			
			playButton = new FlxButton(flixelButton.x, flixelButton.y + 62, "CLICK HERE", onPlay);
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
			FlxG.play("MenuHit2");
			
			FlxG.flash(0xffd8eba2, 0.5);
			FlxG.fade(0xff131c1b, 1, false, onFade);
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
		FlxG.play("MenuHit2");
	}
	
	//This function is passed to FlxG.fade() when we are ready to go to the next game state.
	//When FlxG.fade() finishes, it will call this, which in turn will either load
	//up a game demo/replay, or let the player start playing, depending on user input.
	private function onFade():Void
	{
		if(attractMode)
		{
			FlxG.loadReplay((FlxG.random() < 0.5)?(Assets.getText("assets/attract1.fgr")):(Assets.getText("assets/attract2.fgr")), new PlayState(), ["ANY"], 22, onDemoComplete);
		//	FlxG.loadReplay((FlxG.random() < 0.5)?(Assets.getText("assets/attract1.fgr")):(Assets.getText("assets/attract2.fgr")), new PlayStateOld(), ["ANY"], 22, onDemoComplete);
		}
		else
		{
			FlxG.switchState(new PlayState());
		//	FlxG.switchState(new PlayStateOld());
		}
	}
	
	//This function is called by FlxG.loadReplay() when the replay finishes.
	//Here, we initiate another fade effect.
	private function onDemoComplete():Void
	{
		FlxG.fade(0xff131c1b, 1, false, onDemoFaded);
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