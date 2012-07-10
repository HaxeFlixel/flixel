package;

import nme.display.BitmapInt32;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState		//The class declaration for the main game state
{
	public var player:PlayerShip;			//refers to the little player ship at the bottom
	public var playerBullets:FlxGroup;		//refers to the bullets you shoot
	public var aliens:FlxGroup;				//refers to all the squid monsters
	public var alienBullets:FlxGroup;		//refers to all the bullets the enemies shoot at you
	public var shields:FlxGroup;			//refers to the box shields along the bottom of the game
	
	//Some meta-groups for speeding up overlap checks later
	public var vsPlayerBullets:FlxGroup;	//Meta-group to speed up the shield collisions later
	public var vsAlienBullets:FlxGroup;		//Meta-group to speed up the shield collisions later
	
	//This is where we create the main game state!
	//Inside this function we will create and orient all the important game objects.
	override public function create():Void
	{
		var i:Int;
		
		//We're using the global scores array to store a basic, state-independent status string.
		//If there is no status string (the scores array is empty) then make a new welcome message.
		if(FlxG.scores.length <= 0)
		{
			FlxG.scores[0] = "WELCOME TO FLX INVADERS";
		}
		
		//First we will instantiate the bullets you fire at your enemies.
		var numPlayerBullets:Int = 8;
		playerBullets = new FlxGroup(numPlayerBullets);//Initializing the array is very important and easy to forget!
		var sprite:FlxSprite;
		for(i in 0...(numPlayerBullets))			//Create 8 bullets for the player to recycle
		{
			sprite = new FlxSprite( -100, -100);	//Instantiate a new sprite offscreen
			sprite.makeGraphic(2, 8);			//Create a 2x8 white box
			sprite.exists = false;
			playerBullets.add(sprite);			//Add it to the group of player bullets
		}
		add(playerBullets);
		//NOTE: what we're doing here with bullets might seem kind of complicated but
		// it is a good thing to get into the practice of doing.  What we are doing
		// is creating a big pile of bullets that we can recycle, because there are only
		// ever like 10 bullets or something on screen at once anyways.
		
		//Now that we have a list of bullets, we can initialize the player (and give them the bullets)
		player = new PlayerShip();
		add(player);	//Adds the player to the state
		
		//Then we kind of do the same thing for the enemy invaders; first we make their bullets.
		var numAlienBullets:Int = 32;
		alienBullets = new FlxGroup(numAlienBullets);
		for (i in 0...(numAlienBullets))
		{
			sprite = new FlxSprite( -100, -100);
			sprite.makeGraphic(2, 8);
			sprite.exists = false;
			alienBullets.add(sprite);
		}
		add(alienBullets);
		
		//...then we go through and make the invaders.  This looks all mathy but it's not that bad!
		//We're basically making 5 rows of 10 invaders, and each row is a different color.
		var numAliens:Int = 50;
		aliens = new FlxGroup(numAliens);
		var a:Alien;
		#if flash
		var colors:Array<UInt>;
		#else
		var colors:Array<BitmapInt32>;
		#end
		
		#if !neko
		colors = [FlxG.BLUE, (FlxG.BLUE | FlxG.GREEN), FlxG.GREEN, (FlxG.GREEN | FlxG.RED), FlxG.RED];
		#else
		colors = [FlxG.BLUE, {rgb: (FlxG.BLUE.rgb | FlxG.GREEN.rgb), a: 0xFF}, FlxG.GREEN, {rgb: (FlxG.GREEN.rgb | FlxG.RED.rgb), a: 0xFF}, FlxG.RED];
		#end
		for (i in 0...(numAliens))
		{
			a = new Alien(	8 + (i % 10) * 32,		//The X position of the alien
							24 + Std.int(i / 10) * 32,	//The Y position of the alien
							colors[Std.int(i / 10)], alienBullets);
			aliens.add(a);
		}
		add(aliens);

		//Finally, we're going to make the little box shields at the bottom of the screen.
		//Each shield is made up of a bunch of little white 2x2 pixel blocks.
		//That way they look like they're getting chipped apart as they get shot.
		//This also looks kind of crazy and mathy (it sort of is), but we're just
		// telling the game where to put all the individual bits that make up each box.
		shields = new FlxGroup();
		for (i in 0...64)
		{
			sprite = new FlxSprite(	32 + 80 * Std.int(i / 16) + (i % 4) * 4,	//The X position of this shield piece
								FlxG.height - 32 + (Std.int((i % 16) / 4) * 4));//The Y position of this shield piece
			sprite.active = false;
			sprite.makeGraphic(4, 4);
			sprite.updateTileSheet();
			shields.add(sprite);
		}
		add(shields);
		
		//This "meta-group" stores the things the player bullets can shoot. 
		vsPlayerBullets = new FlxGroup();
		vsPlayerBullets.add(shields);
		vsPlayerBullets.add(aliens);
		
		//This "meta-group" stores the things the alien bullets can shoot.
		vsAlienBullets = new FlxGroup();
		vsAlienBullets.add(shields);
		vsAlienBullets.add(player);
		
		//Then we're going to add a text field to display the label we're storing in the scores array.
		var t:FlxText = new FlxText(4, 4, FlxG.width - 8, FlxG.scores[0]);
		t.alignment = "center";
		add(t);
	}
	
	//This is the main game loop function, where all the logic is done.
	override public function update():Void
	{
		//This just says if the user clicked on the game to hide the cursor
		if(FlxG.mouse.justPressed())
			FlxG.mouse.hide();
		
		//Space invaders doesn't really even use collisions, we're just checking for overlaps between
		// the bullets flying around and the shields and player and stuff.
		FlxG.overlap(playerBullets, vsPlayerBullets, stuffHitStuff);
		FlxG.overlap(alienBullets, vsAlienBullets, stuffHitStuff);
		
		//THIS IS SUPER IMPORTANT and also easy to forget.  But all those objects that we added
		// to the state earlier (i.e. all of everything) will not get automatically updated
		// if you forget to call this function.  This is basically saying "state, call update
		// right now on all of the objects that were added."
		super.update();
		
		//Now that everything has been updated, we are going to check and see if there
		// is a game over yet.  There are two ways to get a game over - player dies,
		// OR player kills all aliens.  First we check to see if the player is dead:
		if(!player.exists)
		{
			FlxG.scores[0] = "YOU LOST";	//Player died, so set our label to YOU LOST
			FlxG.resetState();
		}
		else if(aliens.getFirstExtant() == null)
		{
			FlxG.scores[0] = "YOU WON";		//No aliens left; you win!
			FlxG.resetState();
		}
	}
	
	//We want aliens to mow down shields when they touch them, not die
	private function stuffHitStuff(Object1:FlxObject, Object2:FlxObject):Void
	{
		Object1.kill();
		Object2.kill();
	}
}