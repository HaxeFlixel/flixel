package com.chipacabra.jumper;

import openfl.Assets;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import org.flixel.FlxU;

class PlayState extends FlxState
{
	public var map:FlxTilemap;
	public var background:FlxTilemap;
	public var ladders:FlxTilemap;
	public var player:Player;
	//public var skelmonsta:Enemy;

	public var _gibs:FlxEmitter;
	public var _mongibs:FlxEmitter;
	public var _bullets:FlxGroup;
	public var _badbullets:FlxGroup;
	public var _restart:Bool;
	public var _text1:FlxText;
	public var _enemies:FlxGroup;
	public var _coins:FlxGroup;
	public var _score:FlxText;
	
	public function new()
	{
		super();
		
		map = new FlxTilemap();
		map.allowCollisions = FlxObject.ANY;
		background = new FlxTilemap();
		ladders = new FlxTilemap();
	}
	
	override public function create():Void
	{
		_restart = false;
		
		add(background.loadMap(Assets.getText("assets/levels/mapCSV_Group1_Map1back.csv"), "assets/art/area02_level_tiles2.png", 16, 16, FlxTilemap.OFF));
		background.scrollFactor.x = background.scrollFactor.y = .5;
		
		add(map.loadMap(Assets.getText("assets/levels/mapCSV_Group1_Map1.csv"), "assets/art/area02_level_tiles2.png", 16, 16));
		add(ladders.loadMap(Assets.getText("assets/levels/mapCSV_Group1_Ladders.csv"), "assets/art/area02_level_tiles2.png", 16, 16));
		
		FlxG.camera.setBounds(0, 0, map.width, map.height);
		
		FlxG.worldBounds.make(0, 0, map.width, map.height);
		
		// Set up the gibs
		_gibs = new FlxEmitter();
		//_gibs.delay = 3;
		_gibs.setXSpeed( -150, 150);
		_gibs.setYSpeed( -200, 0);
		_gibs.setRotation( -720, 720);
		_gibs.makeParticles("assets/art/lizgibs.png", 25, 16, true, .5);
		
		_mongibs = new FlxEmitter();
		//_mongibs.delay = 3;
		_mongibs.setXSpeed( -150, 150);
		_mongibs.setYSpeed( -200, 0);
		_mongibs.setRotation( -720, 720);
		_mongibs.makeParticles("assets/art/spikegibs.png", 25, 16, true, .5);
		
		// Create the actual group of bullets here
		_bullets = new FlxGroup();
		_bullets.maxSize = 4;
		_badbullets = new FlxGroup();
		
		add(player = new Player(112, 92, this, _gibs, _bullets));
		
		FlxG.camera.follow(player, 1); // Attach the camera to the player. The number is how much to lag the camera to smooth things out
		
		//add(skelmonsta = new Enemy(1260, 640, player, _mongibs));// I used DAME to find the coordinates I want.
		
		// Set up the enemies here
		_enemies = new FlxGroup();
		placeMonsters(Assets.getText("assets/data/monstacoords.csv"), Enemy);
		placeMonsters(Assets.getText("assets/data/lurkcoords.csv"), Lurker);
		
		_coins = new FlxGroup();
		placeCoins(Assets.getText("assets/data/coins.csv"), Coin);
		
		add(_coins);
		add(_enemies);
		
		Reg.score = 0;
		
		super.create();
		
		// Set up the individual bullets
		for (i in 0...4)    // Allow 4 bullets at a time
		{
			_bullets.add(new Bullet());
		}
		add(_badbullets);
		add(_bullets); 
		add(_gibs);
		add(_mongibs);
		
		//HUD - score
		var ssf:FlxPoint = new FlxPoint(0, 0);
		_score = new FlxText(0, 0, FlxG.width);
		_score.color = 0xFFFF00;
		_score.size = 16;
		_score.alignment = "center";
		_score.scrollFactor = ssf;
		_score.shadow = 0x131c1b;
		_score.useShadow = true;
		add(_score);
		
		// Set up the game over text
		_text1 = new FlxText(30, 30, 400, "Press R to Restart");
		_text1.visible = false;
		_text1.size = 40;
		_text1.color = 0xFFFF0000;
		_text1.antialiasing = true;
		_text1.scrollFactor.x = _text1.scrollFactor.y = 0;
		add(_text1); // Add last so it goes on top, you know the drill.
		
		FlxG.playMusic(Assets.getSound("assets/music/ScrollingSpace[1]" + Jumper.SoundExtension), .5);
	}
	
	override public function update():Void 
	{
		FlxG.collide(player, map);
		FlxG.collide(_enemies, map);
		FlxG.collide(_gibs, map);
		FlxG.collide(_bullets, map);
		FlxG.collide(_badbullets, map);
		
		super.update();
		
		_score.text = '$' + Std.string(Reg.score);
		
		if (!player.alive)
		{
			_text1.visible = true;
			if (FlxG.keys.justPressed("R")) 
			{
				_restart = true;
			}
		}
		
		//Check for impact!
/*		if (player.overlaps(_enemies))
		{
			player.kill(); // This should probably be more interesting
		}*/
		
		FlxG.overlap(player, _enemies, hitPlayer);
		FlxG.overlap(_bullets, _enemies, hitmonster);
		FlxG.overlap(player, _coins, collectCoin);
		FlxG.overlap(player, _badbullets, hitPlayer);
		
		if (_restart) FlxG.switchState(new PlayState());
		
	}
	
	private function collectCoin(P:FlxObject, C:FlxObject):Void 
	{
		C.kill();
	}
	
	private function hitPlayer(P:FlxObject, Monster:FlxObject):Void 
	{
		if (Std.is(Monster, Bullet))
		{
			Monster.kill();
		}
		
		if (Monster.health > 0)
		{
			P.hurt(1); // This should still be more interesting
		}
	}
	
	private function hitmonster(Blt:FlxObject, Monster:FlxObject):Void 
	{
		if (!Monster.alive) 
		{ 
			return; // Just in case
		}  
		
		if (Monster.health > 0) 
		{
			Blt.kill();
			Monster.hurt(1);
		}
	}
	
	private function placeMonsters(MonsterData:String, Monster:Class<FlxObject>):Void
	{
		var coords:Array<String>;
		var entities:Array<String> = MonsterData.split("\n");   // Each line becomes an entry in the array of strings
		for (j in 0...(entities.length)) 
		{
			coords = entities[j].split(",");  //Split each line into two coordinates
			if (Monster == Enemy)
			{
				_enemies.add(new Enemy(Std.parseInt(coords[0]), Std.parseInt(coords[1]), player, _mongibs)); 
			}
			else if (Monster == Lurker)
			{ 
				_enemies.add(new Lurker(Std.parseInt(coords[0]), Std.parseInt(coords[1]), player, _badbullets));
			}
		}
	}
	
	private function placeCoins(CoinData:String, Sparkle:Class<FlxObject>):Void 
	{
		var coords:Array<String>;
		var entities:Array<String> = CoinData.split("\n");   // Each line becomes an entry in the array of strings
		for (j in 0...(entities.length)) 
		{
			coords = entities[j].split(",");  //Split each line into two coordinates
			if (Sparkle == Coin)
			{
				_coins.add(new Coin(Std.parseInt(coords[0]), Std.parseInt(coords[1]))); 
			}
		}
	}
}