package;

import nme.Assets;
import nme.events.MouseEvent;
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
import org.flixel.FlxTileblock;
import org.flixel.tileSheetManager.TileSheetData;
import org.flixel.tileSheetManager.TileSheetManager;

class PlayState extends FlxState
{
	//major game object storage
	private var _blocks:FlxGroup;
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
	#if flash
	private var _score:FlxText;
	#else
	private var _score:FlxTextField;
	#end
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
		
		//Next we create a smaller pool of larger metal bits for exploding.
		_bigGibs = new FlxEmitter();
		_bigGibs.setXSpeed( -200, 200);
		_bigGibs.setYSpeed( -300, 0);
		_bigGibs.setRotation( -720, -720);
		_bigGibs.gravity = 350;
		_bigGibs.bounce = 0.35;
		_bigGibs.makeParticles(FlxAssets.imgSpawnerGibs, 50, 20, true, 0.5);
		
		//Then we'll set up the rest of our object groups or pools
		_blocks = new FlxGroup();
		_decorations = new FlxGroup();
		_enemies = new FlxGroup();
		_enemies.maxSize = 50;
		_spawners = new FlxGroup();
		_hud = new FlxGroup();
		_enemyBullets = new FlxGroup();
		_enemyBullets.maxSize = 100;
		_bullets = new FlxGroup();
		
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
		add(_blocks);
		add(_decorations);
		add(_enemies);

		//Then we add the player and set up the scrolling camera,
		//which will automatically set the boundaries of the world.
		add(_player);
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
		#if flash
		_score = new FlxText(FlxG.width / 4, 0, Math.floor(FlxG.width / 2));
		#else
		_score = new FlxTextField(FlxG.width / 4, 0, Math.floor(FlxG.width / 2));
		#end
		_score.setFormat(null, 16, 0xd8eba2, "center", 0x131c1b);
		_hud.add(_score);
		if(FlxG.scores.length < 2)
		{
			FlxG.scores.push(0);
			FlxG.scores.push(0);
		}
		
		//Then for the player's highest and last scores
		if(FlxG.score > FlxG.scores[0])
		{
			FlxG.scores[0] = FlxG.score;
		}
		if(FlxG.scores[0] != 0)
		{
			_score2 = new FlxText(FlxG.width / 2, 0, Math.floor(FlxG.width / 2));
			_score2.setFormat(null,8,0xd8eba2,"right",_score.shadow);
			_hud.add(_score2);
			_score2.text = "HIGHEST: "+FlxG.scores[0]+"\nLAST: "+FlxG.score;
		}
		FlxG.score = 0;
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
		
		if (Mode.SoundOn)
		{
			FlxG.playMusic(Assets.getSound("assets/mode" + Mode.SoundExtension));
		}
		
		FlxG.flash(0xff131c1b);
		_fading = false;
		
		FlxG.sounds.maxSize = 30;
		
		//Debugger Watch examples
		FlxG.watch(_player, "x");
		FlxG.watch(_player, "y");
		FlxG.watch(_enemies, "length", "numEnemies");
		FlxG.watch(_enemyBullets, "length", "numEnemyBullets");
		
		#if cpp
		TileSheetManager.setTileSheetIndex(_player.getTileSheetIndex(), TileSheetManager.getMaxIndex());
		TileSheetManager.setTileSheetIndex(cast(_hud.getFirstAlive(), FlxSprite).getTileSheetIndex(), TileSheetManager.getMaxIndex());
		#end
		
		LeftButton = new FlxButton(1000, 0, "Left");
		LeftButton.scrollFactor = new FlxPoint(1.0, 1.0);
		LeftButton.color = 0xff729954;
		LeftButton.label.color = 0xffd8eba2;
		add(LeftButton);
		
		var leftCam:FlxCamera = new FlxCamera(Math.floor(10 * FlxG.camera.zoom), Math.floor((FlxG.height - 20) * FlxG.camera.zoom), Math.floor(LeftButton.width), Math.floor(LeftButton.height));
		leftCam.follow(LeftButton, FlxCamera.STYLE_NO_DEAD_ZONE);
		FlxG.addCamera(leftCam);
		
		RightButton = new FlxButton(1000, 100, "Right");
		RightButton.scrollFactor = new FlxPoint(1.0, 1.0);
		RightButton.color = 0xff729954;
		RightButton.label.color = 0xffd8eba2;
		add(RightButton);
		
		var rightCam:FlxCamera = new FlxCamera(Math.floor(100 * FlxG.camera.zoom), Math.floor((FlxG.height - 20) * FlxG.camera.zoom), Math.floor(LeftButton.width), Math.floor(LeftButton.height));
		rightCam.follow(RightButton, FlxCamera.STYLE_NO_DEAD_ZONE);
		FlxG.addCamera(rightCam);
		
		JumpButton = new FlxButton(1000, 200, "Jump");
		JumpButton.scrollFactor = new FlxPoint(1.0, 1.0);
		JumpButton.color = 0xff729954;
		JumpButton.label.color = 0xffd8eba2;
		add(JumpButton);
		
		var jumpCam:FlxCamera = new FlxCamera(Math.floor((FlxG.width - 90) * FlxG.camera.zoom), Math.floor((FlxG.height - 20) * FlxG.camera.zoom), Math.floor(LeftButton.width), Math.floor(LeftButton.height));
		jumpCam.follow(JumpButton, FlxCamera.STYLE_NO_DEAD_ZONE);
		FlxG.addCamera(jumpCam);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_blocks = null;
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
	}

	override public function update():Void
	{			
		//save off the current score and update the game state
		var oldScore:Int = FlxG.score;
		super.update();
		
		//collisions with environment
		FlxG.collide(_blocks, _objects);
		FlxG.overlap(_hazards, _player, overlapped);
		FlxG.overlap(_bullets, _hazards, overlapped);
		
		//check to see if the player scored any points this frame
		var scoreChanged:Bool = oldScore != FlxG.score;
		
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
				if(FlxG.score > 0)
				{
					if(FlxG.score > 100)
					{
						FlxG.score -= 100;
					}
					else
					{
						FlxG.score = 0;
						_player.kill();
					}
					_scoreTimer = 1;
					scoreChanged = true;
					
					//Play loud beeps if your score is low
					var volume:Float = 0.35;
					if(FlxG.score < 600)
					{
						volume = 1.0;
					}
					if (Mode.SoundOn)
					{
						FlxG.play(Assets.getSound("assets/countdown" + Mode.SoundExtension), volume);
					}
				}
			}
		
			//Fade out to victory screen stuffs
			if(_spawners.countLiving() <= 0)
			{
				_fading = true;
				FlxG.fade(0xffd8eba2, 3, onVictory);
			}
		}
		
		//actually update score text if it changed
		if(scoreChanged)
		{
			if(!_player.alive) FlxG.score = 0;
			_score.text = Std.string(FlxG.score);
		}
	}

	//This is an overlap callback function, triggered by the calls to FlxU.overlap().
	private function overlapped(Sprite1:FlxSprite, Sprite2:FlxSprite):Void
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
		var b:FlxTileblock;
	
		//First, we create the walls, ceiling and floors:
		b = new FlxTileblock(0,0,640,16);
		b.loadTiles(FlxAssets.imgTechTiles);
		_blocks.add(b);
		
		b = new FlxTileblock(0,16,16,640-16);
		b.loadTiles(FlxAssets.imgTechTiles);
		_blocks.add(b);
		
		b = new FlxTileblock(640-16,16,16,640-16);
		b.loadTiles(FlxAssets.imgTechTiles);
		_blocks.add(b);
		
		b = new FlxTileblock(16,640-24,640-32,8);
		b.loadTiles(FlxAssets.imgDirtTop);
		_blocks.add(b);
		
		b = new FlxTileblock(16,640-16,640-32,16);
		b.loadTiles(FlxAssets.imgDirt);
		_blocks.add(b);
		
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
			
			var b:FlxTileblock;
			b = new FlxTileblock(RX + bx * 8, RY + by * 8, bw * 8, bh * 8);
			b.loadTiles(FlxAssets.imgTechTiles);
			_blocks.add(b);
			
			//If the block has room, add some non-colliding "dirt" graphics for variety
			if((bw >= 4) && (bh >= 5))
			{
				b = new FlxTileblock(RX + bx * 8 + 8, RY + by * 8, bw * 8 - 16, 8);
				b.loadTiles(FlxAssets.imgDirtTop);
				_decorations.add(b);
				
				b = new FlxTileblock(RX + bx * 8 + 8, RY + by * 8 + 8, bw * 8 - 16, bh * 8 - 24);
				b.loadTiles(FlxAssets.imgDirt);
				_decorations.add(b);
			}
		}

		if(Spawners)
		{
			//Finally actually add the spawner
			var sp:Spawner = new Spawner(RX + sx * 8, RY + sy * 8, _bigGibs, _enemies, _enemyBullets, _littleGibs, _player);
			_spawners.add(sp);
			
			//Then create a dedicated camera to watch the spawner
			_hud.add(new FlxSprite(3 + (_spawners.length - 1) * 16, 3, FlxAssets.imgMiniFrame));
			var camera:FlxCamera = new FlxCamera(10 + (_spawners.length - 1) * 32, 10, 24, 24, 1);
			camera.follow(sp, FlxCamera.STYLE_NO_DEAD_ZONE);
			FlxG.addCamera(camera);
		}
	}
}