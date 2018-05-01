package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * The class declaration for the main game state
 */
class PlayState extends FlxState
{
	/**
	 * The status message to show. Static so that it carries over to a new PlayState.
	 */
	public static var statusMessage:String = "WELCOME TO FLX INVADERS";
	
	/**
	 * Refers to all the bullets the enemies shoot at you
	 */
	public var alienBullets:FlxTypedGroup<FlxSprite>;
	/**
	 * Refers to the bullets you shoot
	 */
	public var playerBullets:FlxTypedGroup<FlxSprite>;
	
	/**
	 * Refers to the little player ship at the bottom
	 */ 
	var _player:PlayerShip;
	/**
	 * Refers to all the squid monsters
	 */
	var _aliens:FlxTypedGroup<Alien>;
	/**
	 * Refers to the box shields along the bottom of the game
	 */
	var _shields:FlxTypedGroup<FlxSprite>;
	
	//Some meta-groups for speeding up overlap checks later
	
	/**
	 * Meta-group to speed up the shield collisions later
	 */
	var _vsPlayerBullets:FlxGroup;
	/**
	 * Meta-group to speed up the shield collisions later
	 */
	var _vsAlienBullets:FlxGroup;
	
	/**
	 * This is where we create the main game state!
	 * Inside this function we will create and orient all the important game objects.
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		// First we will instantiate the bullets you fire at your enemies.
		var numPlayerBullets:Int = 8;
		// Initializing the array is very important and easy to forget!
		playerBullets = new FlxTypedGroup(numPlayerBullets);
		var sprite:FlxSprite;
		
		// Create 8 bullets for the player to recycle
		for (i in 0...numPlayerBullets)
		{
			// Instantiate a new sprite offscreen
			sprite = new FlxSprite( -100, -100);
			// Create a 2x8 white box
			sprite.makeGraphic(2, 8);
			sprite.exists = false;
			// Add it to the group of player bullets
			playerBullets.add(sprite);
		}
		
		add(playerBullets);
		
		//NOTE: what we're doing here with bullets might seem kind of complicated but
		// it is a good thing to get into the practice of doing. What we are doing
		// is creating a big pile of bullets that we can recycle, because there are only
		// ever like 10 bullets or something on screen at once anyways.
		
		// Now that we have a list of bullets, we can initialize the player (and give them the bullets)
		_player = new PlayerShip();
		// Adds the player to the state
		add(_player);
		
		// Then we kind of do the same thing for the enemy invaders; first we make their bullets.
		var numAlienBullets:Int = 32;
		alienBullets = new FlxTypedGroup(numAlienBullets);
		
		for (i in 0...numAlienBullets)
		{
			sprite = new FlxSprite( -100, -100);
			sprite.makeGraphic(2, 8);
			sprite.exists = false;
			alienBullets.add(sprite);
		}
		
		add(alienBullets);
		
		// ...then we go through and make the invaders. This looks all mathy but it's not that bad!
		// We're basically making 5 rows of 10 invaders, and each row is a different color.
		var numAliens:Int = 50;
		_aliens = new FlxTypedGroup(numAliens);
		var a:Alien;
		var colors:Array<Int>;
		
		colors = [FlxColor.BLUE, (FlxColor.BLUE | FlxColor.GREEN), FlxColor.GREEN, (FlxColor.GREEN | FlxColor.RED), FlxColor.RED];
		
		for (i in 0...numAliens)
		{
			a = new Alien(8 + (i % 10) * 32, 24 + Std.int(i / 10) * 32,	colors[Std.int(i / 10)], alienBullets);
			_aliens.add(a);
		}
		
		add(_aliens);

		// Finally, we're going to make the little box shields at the bottom of the screen.
		// Each shield is made up of a bunch of little white 2x2 pixel blocks.
		// That way they look like they're getting chipped apart as they get shot.
		// This also looks kind of crazy and mathy (it sort of is), but we're just
		// telling the game where to put all the individual bits that make up each box.
		_shields = new FlxTypedGroup();
		
		for (i in 0...64)
		{
			sprite = new FlxSprite(32 + 80 * Std.int(i / 16) + (i % 4) * 4, FlxG.height - 32 + (Std.int((i % 16) / 4) * 4));
			sprite.active = false;
			sprite.makeGraphic(4, 4);
			_shields.add(sprite);
		}
		
		add(_shields);
		
		// This "meta-group" stores the things the player bullets can shoot. 
		_vsPlayerBullets = new FlxGroup();
		_vsPlayerBullets.add(_shields);
		_vsPlayerBullets.add(_aliens);
		
		// This "meta-group" stores the things the alien bullets can shoot.
		_vsAlienBullets = new FlxGroup();
		_vsAlienBullets.add(_shields);
		_vsAlienBullets.add(_player);
		
		// Then we're going to add a text field to display the label we're storing in the scores array.
		var t = new FlxText(4, 4, FlxG.width - 8, statusMessage);
		t.alignment = CENTER;
		add(t);
	}
	
	/**
	 * This is the main game loop function, where all the logic is done.
	 */
	override public function update(elapsed:Float):Void
	{	
		// Space invaders doesn't really even use collisions, we're just checking for overlaps between
		// the bullets flying around and the shields and player and stuff.
		FlxG.overlap(playerBullets, _vsPlayerBullets, stuffHitStuff);
		FlxG.overlap(alienBullets, _vsAlienBullets, stuffHitStuff);
		
		// THIS IS SUPER IMPORTANT and also easy to forget. But all those objects that we added
		// to the state earlier (i.e. all of everything) will not get automatically updated
		// if you forget to call this function.  This is basically saying "state, call update
		// right now on all of the objects that were added."
		super.update(elapsed);
		
		// Now that everything has been updated, we are going to check and see if there
		// is a game over yet.  There are two ways to get a game over - player dies,
		// OR player kills all aliens.  First we check to see if the player is dead:
		if (!_player.exists)
		{
			// Player died, so set our label to YOU LOST
			statusMessage = "YOU LOST";
			FlxG.resetState();
		}
		else if (_aliens.getFirstExisting() == null)
		{
			// No aliens left; you win!
			statusMessage = "YOU WON";
			FlxG.resetState();
		}
	}
	
	/**
	 * We want aliens to mow down shields when they touch them, not die
	 */
	function stuffHitStuff(Object1:FlxObject, Object2:FlxObject):Void
	{
		Object1.kill();
		Object2.kill();
	}
}