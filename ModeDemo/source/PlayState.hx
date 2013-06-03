package;

import openfl.Assets;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.Lib;
import org.flixel.FlxButton;
import org.flixel.FlxCamera;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTextField;
import org.flixel.FlxTilemap;

class PlayState extends FlxState
{
	public static inline var TILE_SIZE:Int = 8;
	public static inline var MAP_WIDTH_IN_TILES:Int = 80;
	public static inline var MAP_HEIGHT_IN_TILES:Int = 80;
	private var map:Array<Int>;
	private var tileMap:FlxTilemap;
	
	//major game object storage
	private var _decorations:FlxGroup;
	private var _bullets:FlxGroup;
	private var _player:Player;
	private var _enemies:FlxGroup;
	private var _spawners:FlxGroup;
	private var _enemyBullets:FlxGroup;
	private var _littleGibs:FlxEmitter;
	private var _bigGibs:FlxEmitter;
	private var _hud:FlxGroup;
	private var _gunjam:FlxGroup;
	
	//meta groups, to help speed up collisions
	private var _objects:FlxGroup;
	private var _hazards:FlxGroup;
	
	//HUD/User Interface stuff
	//#if flash
	private var _score:FlxText;
	//#else
	//private var _score:FlxTextField;
	//#end
	private var _score2:FlxText;
	private var _scoreTimer:Float;
	private var _jamTimer:Float;
	
	//just to prevent weirdness during level transition
	private var _fading:Bool;
	
	// touch interface
	public static var LeftButton:FlxButton;
	public static var RightButton:FlxButton;
	public static var JumpButton:FlxButton;
	
	public function new()
	{
		super();
	}
	
	override public function create():Void
	{
		#if (cpp || neko)
		atlas = createAtlas("GeneralAtlas", 1024, 1024);
		#end
		
		//FlxG.mouse.hide();
		
		//Here we are creating a pool of 100 little metal bits that can be exploded.
		//We will recycle the crap out of these!
		_littleGibs = new FlxEmitter();
		_littleGibs.setXSpeed( -150, 150);
		_littleGibs.setYSpeed( -200, 0);
		_littleGibs.setRotation( -720, -720);
		_littleGibs.gravity = 350;
		_littleGibs.bounce = 0.5;
		_littleGibs.makeParticles(FlxAssets.imgGibs, 100, 10, true, 0.5);
		
		#if (cpp || neko)
		_littleGibs.atlas = atlas;
		#end
		
		//Next we create a smaller pool of larger metal bits for exploding.
		_bigGibs = new FlxEmitter();
		_bigGibs.setXSpeed( -200, 200);
		_bigGibs.setYSpeed( -300, 0);
		_bigGibs.setRotation( -720, -720);
		_bigGibs.gravity = 350;
		_bigGibs.bounce = 0.35;
		_bigGibs.makeParticles(FlxAssets.imgSpawnerGibs, 50, 20, true, 0.5);
		
		#if (cpp || neko)
		_bigGibs.atlas = atlas;
		#end
		
		//Then we'll set up the rest of our object groups or pools
		_decorations = new FlxGroup();
		_enemies = new FlxGroup();
		#if flash
		_enemies.maxSize = 50;
		#else
		_enemies.maxSize = 25;
		#end
		_spawners = new FlxGroup();
		_hud = new FlxGroup();
		_enemyBullets = new FlxGroup();
		#if flash
		_enemyBullets.maxSize = 100;
		#else
		_enemyBullets.maxSize = 50;
		#end
		_bullets = new FlxGroup();
		_bullets.maxSize = 20;
		
		//Now that we have references to the bullets and metal bits,
		//we can create the player object.
		_player = new Player(316, 300, _bullets, _littleGibs);
		
		//This refers to a custom function down at the bottom of the file
		//that creates all our level geometry with a total size of 640x480.
		//This in turn calls buildRoom() a bunch of times, which in turn
		//is responsible for adding the spawners and spawn-cameras.
		generateLevel();
		
		//Add bots and spawners after we add blocks to the state,
		//so that they're drawn on top of the level, and so that
		//the bots are drawn on top of both the blocks + the spawners.
		add(_spawners);
		add(_littleGibs);
		add(_bigGibs);
		add(_decorations);
		add(_enemies);

		//Then we add the player and set up the scrolling camera,
		//which will automatically set the boundaries of the world.
		add(_player);
		
		#if (cpp || neko)
		_player.atlas = atlas;
		#end
		
		FlxG.camera.setBounds(0, 0, 640, 640, true);
		FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
		
		//We add the bullets to the scene here,
		//so they're drawn on top of pretty much everything
		add(_enemyBullets);
		add(_bullets);
		add(_hud);
		
		//Finally we are going to sort things into a couple of helper groups.
		//We don't add these groups to the state, we just use them for collisions later!
		_hazards = new FlxGroup();
		_hazards.add(_enemyBullets);
		_hazards.add(_spawners);
		_hazards.add(_enemies);
		_objects = new FlxGroup();
		_objects.add(_enemyBullets);
		_objects.add(_bullets);
		_objects.add(_enemies);
		_objects.add(_player);
		_objects.add(_littleGibs);
		_objects.add(_bigGibs);
		
		//From here on out we are making objects for the HUD,
		//that is, the player score, number of spawners left, etc.
		//First, we'll create a text field for the current score
	//	#if flash
		_score = new FlxText(FlxG.width / 4, 0, Math.floor(FlxG.width / 2));
	//	#else
	//	_score = new FlxTextField(FlxG.width / 4, 0, Math.floor(FlxG.width / 2));
	//	#end
		_score.setFormat(null, 16, 0xd8eba2, "center", 0x131c1b, true);
		_hud.add(_score);
		if(Reg.scores.length < 2)
		{
			Reg.scores.push(0);
			Reg.scores.push(0);
		}
		
		//Then for the player's highest and last scores
		if(Reg.score > Reg.scores[0])
		{
			Reg.scores[0] = Reg.score;
		}
		if(Reg.scores[0] != 0)
		{
			_score2 = new FlxText(FlxG.width / 2, 0, Math.floor(FlxG.width / 2));
			_score2.setFormat(null, 8, 0xd8eba2, "right", _score.shadow, true);
			_hud.add(_score2);
			_score2.text = "HIGHEST: "+Reg.scores[0]+"\nLAST: "+Reg.score;
		}
		Reg.score = 0;
		_scoreTimer = 0;
		
		//Then we create the "gun jammed" notification
		_gunjam = new FlxGroup();
		_gunjam.add(new FlxSprite(0, FlxG.height - 22).makeGraphic(FlxG.width, 24, 0xff131c1b));
		_gunjam.add(new FlxText(0, FlxG.height - 22, FlxG.width, "GUN IS JAMMED").setFormat(null, 16, 0xd8eba2, "center"));
		_gunjam.visible = false;
		_hud.add(_gunjam);
		
		//After we add all the objects to the HUD, we can go through
		//and set any property we want on all the objects we added
		//with this sweet function.  In this case, we want to set
		//the scroll factors to zero, to make sure the HUD doesn't
		//wiggle around while we play.
		_hud.setAll("scrollFactor", new FlxPoint(0, 0));
		_hud.setAll("cameras", [FlxG.camera]);
		
		FlxG.playMusic("Mode");
		
		FlxG.flash(0xff131c1b);
		_fading = false;
		
		FlxG.sounds.maxSize = 20;
		
		//Debugger Watch examples
		//FlxG.watch(_player, "x");
		//FlxG.watch(_player, "y");
		FlxG.watch(_enemies, "length", "numEnemies");
		FlxG.watch(_enemyBullets, "length", "numEnemyBullets");
		FlxG.watch(FlxG.sounds, "length", "numSounds");
		
		LeftButton = new FlxButton(1000, 0, "Left");
		LeftButton.scrollFactor = new FlxPoint(1.0, 1.0);
		LeftButton.color = 0xff729954;
		LeftButton.label.color = 0xffd8eba2;
		add(LeftButton);
		#if (cpp || neko)
		_bigGibs.atlas = atlas;
		#end
		
		var leftCam:FlxCamera = new FlxCamera(Math.floor(10 * FlxG.camera.zoom), Math.floor((FlxG.height - 20) * FlxG.camera.zoom), Math.floor(LeftButton.width), Math.floor(LeftButton.height));
		leftCam.follow(LeftButton, FlxCamera.STYLE_NO_DEAD_ZONE);
		FlxG.addCamera(leftCam);
		
		RightButton = new FlxButton(1000, 100, "Right");
		RightButton.scrollFactor = new FlxPoint(1.0, 1.0);
		RightButton.color = 0xff729954;
		RightButton.label.color = 0xffd8eba2;
		add(RightButton);
		#if (cpp || neko)
		RightButton.atlas = atlas;
		#end
		
		var rightCam:FlxCamera = new FlxCamera(Math.floor(100 * FlxG.camera.zoom), Math.floor((FlxG.height - 20) * FlxG.camera.zoom), Math.floor(LeftButton.width), Math.floor(LeftButton.height));
		rightCam.follow(RightButton, FlxCamera.STYLE_NO_DEAD_ZONE);
		FlxG.addCamera(rightCam);
		
		JumpButton = new FlxButton(1000, 200, "Jump");
		JumpButton.scrollFactor = new FlxPoint(1.0, 1.0);
		JumpButton.color = 0xff729954;
		JumpButton.label.color = 0xffd8eba2;
		add(JumpButton);
		#if (cpp || neko)
		_bigGibs.atlas = atlas;
		#end
		
		var jumpCam:FlxCamera = new FlxCamera(Math.floor((FlxG.width - 90) * FlxG.camera.zoom), Math.floor((FlxG.height - 20) * FlxG.camera.zoom), Math.floor(LeftButton.width), Math.floor(LeftButton.height));
		jumpCam.follow(JumpButton, FlxCamera.STYLE_NO_DEAD_ZONE);
		FlxG.addCamera(jumpCam);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_decorations = null;
		_bullets = null;
		_player = null;
		_enemies = null;
		_spawners = null;
		_enemyBullets = null;
		_littleGibs = null;
		_bigGibs = null;
		_hud = null;
		_gunjam = null;
		
		//meta groups, to help speed up collisions
		_objects = null;
		_hazards = null;
		
		//HUD/User Interface stuff
		_score = null;
		_score2 = null;
		
		LeftButton = null;
		RightButton = null;
		JumpButton = null;
		
		map = null;
		tileMap = null;
	}

	override public function update():Void
	{			
		//save off the current score and update the game state
		var oldScore:Int = Reg.score;
		super.update();
		
		//collisions with environment
		FlxG.collide(tileMap, _objects);
		FlxG.overlap(_hazards, _player, overlapped);
		FlxG.overlap(_bullets, _hazards, overlapped);
		
		//check to see if the player scored any points this frame
		var scoreChanged:Bool = oldScore != Reg.score;
		
		//Jammed message
		if(FlxG.keys.justPressed("C") && _player.flickering)
		{
			_jamTimer = 1;
			//_gunjam.visible = true;
		}
		if(_jamTimer > 0)
		{
			if(!_player.flickering)
			{
				_jamTimer = 0;
			}
			_jamTimer -= FlxG.elapsed;
			if(_jamTimer < 0)
			{
				//_gunjam.visible = false;
			}
		}

		if(!_fading)
		{
			//Score + countdown stuffs
			if(scoreChanged)
			{
				_scoreTimer = 2;
			}
			_scoreTimer -= FlxG.elapsed;
			if(_scoreTimer < 0)
			{
				if(Reg.score > 0)
				{
					if(Reg.score > 100)
					{
						Reg.score -= 100;
					}
					else
					{
						Reg.score = 0;
						_player.kill();
					}
					_scoreTimer = 1;
					scoreChanged = true;
					
					//Play loud beeps if your score is low
					var volume:Float = 0.35;
					if(Reg.score < 600)
					{
						volume = 1.0;
					}
					FlxG.play("Countdown", volume);
				}
			}
		
			//Fade out to victory screen stuffs
			if(_spawners.countLiving() <= 0)
			{
				_fading = true;
				FlxG.fade(0xffd8eba2, 3, false, onVictory);
			}
		}
		
		//actually update score text if it changed
		if(scoreChanged)
		{
			if(!_player.alive) Reg.score = 0;
			_score.text = Std.string(Reg.score);
		}
	}

	//This is an overlap callback function, triggered by the calls to FlxU.overlap().
	private function overlapped(Sprite1:FlxObject, Sprite2:FlxObject):Void
	{
		if(Std.is(Sprite1, EnemyBullet) || Std.is(Sprite1, Bullet))
		{
			Sprite1.kill();
		}
		Sprite2.hurt(1);
	}
	
	//A FlxG.fade callback, like in MenuState.
	private function onVictory():Void
	{
		//FlxG.music.stop();
		FlxG.switchState(new VictoryState());
	}
	
	//These next two functions look crazy, but all they're doing is generating
	//the level structure and placing the enemy spawners.
	private function generateLevel():Void
	{
		var r:Int = 160;
		
		map = new Array<Int>();
		var numTilesTotal:Int = MAP_HEIGHT_IN_TILES * MAP_WIDTH_IN_TILES;
		for (i in 0...(numTilesTotal))
		{
			map[i] = 0;
		}
		
		//First, we create the walls, ceiling and floors:
		fillTileMapRectWithRandomTiles(0, 0, 640, 16, 1, 6, map, MAP_WIDTH_IN_TILES);
		fillTileMapRectWithRandomTiles(0, 16, 16, 640 - 16, 1, 6, map, MAP_WIDTH_IN_TILES);
		fillTileMapRectWithRandomTiles(640 - 16, 16, 16, 640 - 16, 1, 6, map, MAP_WIDTH_IN_TILES);
		fillTileMapRectWithRandomTiles(16, 640 - 24, 640 - 32, 8, 16, 17, map, MAP_WIDTH_IN_TILES);
		fillTileMapRectWithRandomTiles(16, 640 - 16, 640 - 32, 16, 32, 47, map, MAP_WIDTH_IN_TILES);
		
		//Then we split the game world up into a 4x4 grid,
		//and generate some blocks in each area.  Some grid spaces
		//also get a spawner!
		buildRoom(r * 0, r * 0, true);
		buildRoom(r * 1, r * 0);
		buildRoom(r * 2, r * 0);
		buildRoom(r * 3, r * 0, true);
		buildRoom(r * 0, r * 1, true);
		buildRoom(r * 1, r * 1);
		buildRoom(r * 2, r * 1);
		buildRoom(r * 3, r * 1, true);
		buildRoom(r * 0, r * 2);
		buildRoom(r * 1, r * 2);
		buildRoom(r * 2, r * 2);
		buildRoom(r * 3, r * 2);
		buildRoom(r * 0, r * 3, true);
		buildRoom(r * 1, r * 3);
		buildRoom(r * 2, r * 3);
		buildRoom(r * 3, r * 3, true);
		
		tileMap = new FlxTilemap();
		tileMap.loadMap(FlxTilemap.arrayToCSV(map, MAP_WIDTH_IN_TILES), "assets/img_tiles.png", 8, 8, FlxTilemap.OFF);
		add(tileMap);
		
		#if (cpp || neko)
		tileMap.atlas = atlas;
		#end
	}
	
	//Just plops down a spawner and some blocks - haphazard and crappy atm but functional!
	private function buildRoom(RX:Int, RY:Int, ?Spawners:Bool = false):Void
	{
		//first place the spawn point (if necessary)
		var rw:Int = 20;
		var sx:Int = 0;
		var sy:Int = 0;
		if(Spawners)
		{
			sx = Math.floor(2 + FlxG.random() * (rw - 7));
			sy = Math.floor(2 + FlxG.random() * (rw - 7));
		}
		
		//then place a bunch of blocks
		var numBlocks:Int = Math.floor(3 + FlxG.random() * 4);
		if(!Spawners) numBlocks++;
		var maxW:Int = 10;
		var minW:Int = 2;
		var maxH:Int = 8;
		var minH:Int = 1;
		var bx:Int;
		var by:Int;
		var bw:Int;
		var bh:Int;
		var check:Bool;
		for(i in 0...(numBlocks))
		{
			do
			{
				//keep generating different specs if they overlap the spawner
				bw = Math.floor(minW + FlxG.random() * (maxW - minW));
				bh = Math.floor(minH + FlxG.random() * (maxH - minH));
				bx = Math.floor( -1 + FlxG.random() * (rw + 1 - bw));
				by = Math.floor( -1 + FlxG.random() * (rw + 1 - bh));
				if(Spawners)
				{
					check = ((sx>bx+bw) || (sx+3<bx) || (sy>by+bh) || (sy+3<by));
				}
				else
				{
					check = true;
				}
			} while(!check);
			
			fillTileMapRectWithRandomTiles(RX + bx * 8, RY + by * 8, bw * 8, bh * 8, 1, 6, map, MAP_WIDTH_IN_TILES);
			
			//If the block has room, add some non-colliding "dirt" graphics for variety
			if((bw >= 4) && (bh >= 5))
			{
				fillTileMapRectWithRandomTiles(RX + bx * 8 + 8, RY + by * 8, bw * 8 - 16, 8, 16, 17, map, MAP_WIDTH_IN_TILES);
				fillTileMapRectWithRandomTiles(RX + bx * 8 + 8, RY + by * 8 + 8, bw * 8 - 16, bh * 8 - 24, 32, 47, map, MAP_WIDTH_IN_TILES);
			}
		}

		if(Spawners)
		{
			//Finally actually add the spawner
			var sp:Spawner = new Spawner(RX + sx * 8, RY + sy * 8, _bigGibs, _enemies, _enemyBullets, _littleGibs, _player);
			_spawners.add(sp);
			#if (cpp || neko)
			sp.atlas = atlas;
			#end
			
			//Then create a dedicated camera to watch the spawner
			var miniFrame:FlxSprite = new FlxSprite(3 + (_spawners.length - 1) * 16, 3, FlxAssets.imgMiniFrame);
			_hud.add(miniFrame);
			#if (cpp || neko)
			miniFrame.atlas = atlas;
			#end
			
			var ratio:Float = FlxCamera.defaultZoom / 2;
			var camera:FlxCamera = new FlxCamera(Math.floor(ratio * (10 + (_spawners.length - 1) * 32)), Math.floor(ratio * 10), 24, 24, ratio);
			camera.follow(sp, FlxCamera.STYLE_NO_DEAD_ZONE);
			FlxG.addCamera(camera);
		}
	}
	
	private function fillTileMapRectWithRandomTiles(x:Int, y:Int, width:Int, height:Int, startTile:Int, endTile:Int, map:Array<Int>, mapWidth:Int):Array<Int>
	{
		var numColsToPush:Int = Math.floor(width / TILE_SIZE);
		var numRowsToPush:Int = Math.floor(height / TILE_SIZE);
		var xStartIndex:Int = Math.floor(x / TILE_SIZE);
		var yStartIndex:Int = Math.floor(y / TILE_SIZE);
		var startColToPush:Int = Math.floor(x / TILE_SIZE);
		var startRowToPush:Int = Math.floor(y / TILE_SIZE);
		var randomTile:Int;
		var currentTileIndex:Int;
		
		for (i in 0...(numRowsToPush))
		{
			for (j in 0...(numColsToPush))
			{
				randomTile = startTile + Math.floor(Math.random() * (endTile - startTile));
				currentTileIndex = (xStartIndex + j) + (yStartIndex + i) * mapWidth;
				map[currentTileIndex] = randomTile;
			}
		}
		
		return map;
	}
}