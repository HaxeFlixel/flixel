package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxSave;
import flixel.system.FlxAssets;
import openfl.Assets;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	var _gibs:FlxEmitter;
	var _playButton:FlxButton;
	var _title1:FlxText;
	var _title2:FlxText;
	var _fading:Bool;
	var _timer:Float;
	var _demoMode:Bool;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		// Simple use of flixel save game object.
		// Tracks number of times the game has been played.
		var save:FlxSave = new FlxSave();
		
		if (save.bind("Mode"))
		{
			if (save.data.plays == null)
				save.data.plays = 0.0;
			else
				save.data.plays++;
			
			FlxG.log.add("Number of plays: " + save.data.plays);
			save.close();
		}
		
		// All the bits that blow up when the text smooshes together
		_gibs = new FlxEmitter(FlxG.width / 2 - 50, FlxG.height / 2 - 10);
		_gibs.width = 100;
		_gibs.height = 30;
		_gibs.velocity.set(0, -200, 0, -20);
		_gibs.angularVelocity.set( -720, 720);
		_gibs.acceleration.set(0, 100);
		_gibs.loadParticles(AssetPaths.spawner_gibs__png, 650, 32, true);
		_gibs.lifespan.set(5, 5);
		add(_gibs);
		
		// The letters "mo"
		_title1 = new FlxText(FlxG.width + 16, FlxG.height / 3, 64, "mo");
		_title1.size = 32;
		_title1.color = 0x3a5c39;
		_title1.antialiasing = true;
		_title1.moves = true;
		_title1.velocity.x = -FlxG.width;
		add(_title1);
		
		// The letters "de"
		_title2 = new FlxText( -60, _title1.y, Math.floor(_title1.width), "de");
		_title2.size = _title1.size;
		_title2.moves = true;
		_title2.color = _title1.color;
		_title2.antialiasing = _title1.antialiasing;
		_title2.velocity.x = FlxG.width;
		add(_title2);
		
		_fading = false;
		_timer = 0;
		_demoMode = false;
		
		#if FLX_MOUSE
		FlxG.mouse.load(AssetPaths.cursor__png, 2);
		FlxG.mouse.visible = true;
		#end
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_gibs = null;
		_playButton = null;
		_title1 = null;
		_title2 = null;
		
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (_title2.x > _title1.x + _title1.width - 4)
		{
			// Once "mo" and "de" cross each other, fix their positions
			_title2.x = _title1.x + _title1.width - 4;
			_title1.velocity.x = 0;
			_title2.velocity.x = 0;
			
			// Then, play a cool sound, change their color, and blow up pieces everywhere
			FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit"));
			
			FlxG.cameras.flash(0xffd8eba2, 0.5);
			FlxG.cameras.shake(0.035, 0.5);
			_title1.color = _title2.color = 0xd8eba2;
			_gibs.start(true, 5);
			_title1.angle = FlxG.random.float( -15, 15);
			_title2.angle = FlxG.random.float( -15, 15);
			
			// Then we're going to add the text and buttons and things that appear
			// If we were hip we'd use our own button animations, but we'll just recolor
			// the stock ones for now instead.
			var text = new FlxText(FlxG.width / 2 - 50, FlxG.height / 3 + 39, 100, "by Adam Atomic");
			text.alignment = CENTER;
			text.color = 0x3a5c39;
			add(text);
			
			text = new FlxText(FlxG.width / 2 - 40, FlxG.height / 3 + 119, 80, "X + C TO PLAY");
			text.color = 0x729954;
			text.alignment = CENTER;
			add(text);
			
			var flixelButton = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 3 + 54, "haxeflixel.com", function()
				FlxG.openURL("http://haxeflixel.com")
			);
			flixelButton.color = 0xff729954;
			flixelButton.label.color = 0xffd8eba2;
			add(flixelButton);
			
			var dannyButton = new FlxButton(flixelButton.x, flixelButton.y + 22, "music: dannyB", function()
				FlxG.openURL("http://dbsoundworks.com")
			);
			dannyButton.color = flixelButton.color;
			dannyButton.label.color = flixelButton.label.color;
			add(dannyButton);
			
			_playButton = new FlxButton(flixelButton.x, flixelButton.y + 62, "CLICK HERE", onPlay);
			_playButton.color = flixelButton.color;
			_playButton.label.color = flixelButton.label.color;
			add(_playButton);
		}

		// X + C were pressed, fade out and change to play state.
		// OR, if we sat on the menu too long, launch the demo mode instead!
		_timer += elapsed;
		
		if (_timer >= 10) //go into demo mode if no buttons are pressed for 10 seconds
			_demoMode = true;
		
		#if FLX_KEYBOARD
		if (!_fading)
		{
			if ((FlxG.keys.pressed.X && FlxG.keys.pressed.C) || _demoMode)
			{
				_fading = true;
				FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit_2"));
				
				FlxG.cameras.flash(0xffd8eba2, 0.5);
				FlxG.cameras.fade(0xff131c1b, 1, false, onFade);
			}
			
			if (FlxG.keys.pressed.R && !_demoMode)
				_demoMode = true;
		}
		#end
		
		#if (FLX_GAMEPAD)
		if (FlxG.gamepads.anyButton())
		{
			if (FlxG.gamepads.lastActive.justPressed.A)
				onPlay();
		}
		#end
	}
	
	function onPlay()
	{
		onFade();
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit_2"));
	}
	
	/**
	 * This function is passed to FlxG.fade() when we are ready to go to the next game state.
	 * When FlxG.fade() finishes, it will call this, which in turn will either load
	 * up a game demo/replay, or let the player start playing, depending on user input.
	 */
	function onFade():Void
	{
		if (_demoMode)
		{
			FlxG.vcr.loadReplay(
				Assets.getText('assets/data/demo${FlxG.random.int(1, 2)}.fgr'),
				new PlayState(), ["ANY"], 22, onDemoComplete);
		}
		else
			FlxG.switchState(new PlayState());
	}
	
	/**
	 * This function is called by FlxG.loadReplay() when the replay finishes.
	 * Here, we initiate another fade effect.
	 */
	function onDemoComplete():Void
	{
		FlxG.cameras.fade(0xff131c1b, 1, false, onDemoFaded);
	}
	
	/**
	 * Finally, we have another function called by FlxG.fade(), this time
	 * in relation to the callback above.  It stops the replay, and resets the game
	 * once the gameplay demo has faded out.
	 */
	function onDemoFaded():Void
	{
		FlxG.vcr.stopReplay();
		FlxG.resetGame();
	}
}