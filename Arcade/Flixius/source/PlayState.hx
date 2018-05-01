package;

import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	var _sprPlayer:Player;
	var _map:FlxTilemap;
	var _mapDecoTop:FlxTilemap;
	var _mapDecoBottom:FlxTilemap;
	var _chaser:FlxSprite;
	var _grpAllEnemies:FlxGroup;
	var _grpEnemies:FlxTypedGroup<Enemy>;
	var _grpEnemiesPods:FlxTypedGroup<EnemyPod>;
	var _grpEnemiesSpinners:FlxTypedGroup<EnemySpinner>;
	var _grpPBullets:FlxTypedGroup<PBullet>;
	var _grpEBullets:FlxTypedGroup<EBullet>;
	var _grpEBulletBubbles:FlxTypedGroup<EBulletBubble>;
	var _shootDelay:Float = 0;
	var _hits:FlxTypedGroup<Hit>;
	var _txtScore:FlxText;
	var _sparks:FlxTypedGroup<Spark>;
	var _explosions:FlxTypedGroup<Explosion>;
	var _pThrust:Jet;
	var _grpEThrust:FlxTypedGroup<Jet>;
	var _fading:Bool = false;
	var _healthBar:FlxBar;
	var _launchedSubstate:Bool = false;
	var _starting:Bool = true;
	var _score = 0;
	
	var _stars:FlxStarField2D;
	var _backgroundStuff:FlxTypedGroup<FlxSprite>;
	
	override public function create():Void
	{
		super.create();
		bgColor = 0xff160100;
		FlxG.mouse.visible = false;
		
		_stars = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 60);
		_stars.bgColor = 0x0;
		_stars.scrollFactor.set();
		_stars.setStarSpeed(0, 0);
		add(_stars);
		
		_backgroundStuff = new FlxTypedGroup<FlxSprite>();
		add(_backgroundStuff);
		
		var star:FlxSprite = new FlxSprite(0, 0, AssetPaths.star__png);
		star.scrollFactor.set(.2, .1);
		_backgroundStuff.add(star);
		var star2:FlxSprite = new FlxSprite(FlxG.width * 1.6, 0, AssetPaths.big_star__png);
		star2.scrollFactor.set(.3, .6);
		_backgroundStuff.add(star2);
		
		var planet:FlxSprite = new FlxSprite(FlxG.width + 20, FlxG.height - 118, AssetPaths.planet__png);
		planet.scrollFactor.set(.6, .2);
		_backgroundStuff.add(planet);
		var moon:FlxSprite = new FlxSprite(planet.x + planet.width - 80, planet.y - 60, AssetPaths.moon__png);
		moon.scrollFactor.set(.9, .6);
		_backgroundStuff.add(moon);
		var moon2:FlxSprite = new FlxSprite(FlxG.width * .6,60, AssetPaths.moon2__png);
		moon2.scrollFactor.set(.9, .9);
		_backgroundStuff.add(moon2);
		
		_grpAllEnemies = new FlxGroup();
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		_grpEnemiesSpinners = new FlxTypedGroup<EnemySpinner>();
		_grpEnemiesPods = new FlxTypedGroup<EnemyPod>();
		_grpEThrust = new FlxTypedGroup<Jet>();
		
		loadMaps();
		
		_sprPlayer = new Player(addExplosions);
		
		_sprPlayer.x = 10;
		_sprPlayer.y = (FlxG.height / 2) - (_sprPlayer.height / 2);
		
		_pThrust = new Jet(_sprPlayer);
		add(_pThrust);
		add(_sprPlayer);
		
		_chaser = new FlxSprite();
		_chaser.makeGraphic(2, 2);
		_chaser.visible = false;
		_chaser.x = FlxG.width / 2 -1;
		_chaser.y = _sprPlayer.y + (_sprPlayer.height / 2) - 1;
		add(_chaser);
		
		add(_grpEThrust);
		
		_grpAllEnemies.add(_grpEnemies);
		_grpAllEnemies.add(_grpEnemiesSpinners);
		_grpAllEnemies.add(_grpEnemiesPods);
		add(_grpAllEnemies);
		
		_grpPBullets = new FlxTypedGroup<PBullet>();
		add(_grpPBullets);
		_grpEBullets = new FlxTypedGroup<EBullet>();
		add(_grpEBullets);
		_grpEBulletBubbles = new FlxTypedGroup<EBulletBubble>();
		add(_grpEBulletBubbles);
		
		_hits = new FlxTypedGroup<Hit>();
		add(_hits);
		
		_sparks = new FlxTypedGroup<Spark>();
		add(_sparks);
		
		_explosions = new FlxTypedGroup<Explosion>();
		add(_explosions);
		
		_txtScore = new FlxText(FlxG.width - 202, 2, 200, "0", 8);
		_txtScore.alignment = FlxTextAlign.RIGHT;
		_txtScore.scrollFactor.set();
		add(_txtScore);	
		
		_healthBar = new FlxBar(2, 2, FlxBarFillDirection.LEFT_TO_RIGHT, 90, 6, _sprPlayer, "health", 0, 10, true);
		_healthBar.createGradientBar([0xcc111111], [0xffff0000, 0xff00ff00], 1, 0, true, 0xcc333333);
		_healthBar.scrollFactor.set();
		add(_healthBar);
		
		var shine:FlxSprite = FlxGradient.createGradientFlxSprite(
			Std.int(_healthBar.width), Std.int(_healthBar.height),
			[0x66ffffff, 0xffffffff, 0x66ffffff, 0x11ffffff, 0x0]);
		shine.alpha = .5;
		shine.x = _healthBar.x;
		shine.y = _healthBar.y;
		shine.scrollFactor.set();
		add(shine);
		
		FlxG.camera.setScrollBoundsRect(_map.x,  _map.y, _map.width,  _map.height, true);
		
		FlxG.camera.target = _chaser;
		FlxG.camera.style = FlxCameraFollowStyle.LOCKON;
	}

	function loadMaps():Void
	{
		var gfxMap:FlxSprite = new FlxSprite();
		var arrMap:Array<Array<Int>> = [];
		var arrDecoTop:Array<Array<Int>> = [];
		var arrDecoBottom:Array<Array<Int>> = [];
		_map = new FlxTilemap();
		_mapDecoTop = new FlxTilemap();
		_mapDecoBottom = new FlxTilemap();
		
		gfxMap.loadGraphic(AssetPaths.map__png);
		
		var e:Enemy;
		var s:EnemySpinner;
		var p:EnemyPod;
		
		for (y in 0...Std.int(gfxMap.height))
		{
			arrMap.push([]);
			arrDecoTop.push([]);
			arrDecoBottom.push([]);
			for (x in 0...Std.int(gfxMap.width))
			{
				if (gfxMap.pixels.getPixel(x, y) == 0x000000)
				{
					arrMap[y].push(FlxG.random.int(1, 4));
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0x00ff00)
				{
					arrDecoBottom[y].push(FlxG.random.int(1, 9));
					arrDecoTop[y].push(0);
					arrMap[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0xffff00)
				{
					arrDecoTop[y].push(FlxG.random.int(1, 9)+9);
					arrDecoBottom[y].push(0);
					arrMap[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0xff0000)
				{
					e = new Enemy(x * 16, y * 16, this);
					
					_grpEnemies.add(e);
					_grpEThrust.add(new Jet(e, 1));
					arrMap[y].push(0);
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0xff00ff)
				{
					s = new EnemySpinner(x * 16, y * 16, this);
					
					_grpEnemiesSpinners.add(s);
					
					arrMap[y].push(0);
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0x00ffff)
				{
					p = new EnemyPod(x * 16, y * 16, this);
					
					_grpEnemiesPods.add(p);
					
					arrMap[y].push(0);
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
				else
				{
					arrMap[y].push(0);
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
			}
		}
		
		_map.loadMapFrom2DArray(arrMap, AssetPaths.tiles__png, 16, 16, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_mapDecoTop.loadMapFrom2DArray(arrDecoTop, AssetPaths.deco__png, 16, 16, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_mapDecoBottom.loadMapFrom2DArray(arrDecoBottom, AssetPaths.deco__png, 16, 16, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_mapDecoTop.y -= 4;
		_mapDecoBottom.y += 4;
		
		add(_map);
		add(_mapDecoTop);
		add(_mapDecoBottom);
	}
	
	public function returnFromSubState():Void
	{
		#if flash
		FlxG.sound.playMusic(AssetPaths.music__mp3);
		#else
		FlxG.sound.playMusic(AssetPaths.music__ogg);
		#end
		
		_starting = false;
		
		_chaser.velocity.x = 60;
		_stars.setStarSpeed(60, 160);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (_starting)
		{
			if (!_launchedSubstate)
			{
				_launchedSubstate = true;
				openSubState(new MessagePopup(returnFromSubState));
			}
		}
		else
		{
			if (_sprPlayer.alive)
			{
				if (!_sprPlayer.dying)
				{
					playerMovement();
					
					collision();
					
					_chaser.y = _sprPlayer.y + (_sprPlayer.height / 2) - 1;
					
					if (_shootDelay > 0)
						_shootDelay -= elapsed * 6;
				}
				else
				{
					_sprPlayer.velocity.x = 40;
					_sprPlayer.velocity.y = 40;
				}
			}
			else if (!_fading)
			{
				_fading = true;
				FlxG.sound.music.fadeOut(.6);
				FlxG.camera.fade(FlxColor.BLACK, .8, false, function()
				{
					FlxG.sound.music.stop();
					FlxG.resetState();
				});
			}
			
			_txtScore.text = Std.string(_score);
		}
	}
	
	function bubbleHitsWall(B:EBulletBubble, W:FlxTilemap):Void
	{
		if (B.alive && B.exists && B.isOnScreen())
		{
			FlxG.sound.play(AssetPaths.bounce__wav, .8);
		}
	}
	
	function collision():Void
	{
		FlxG.collide(_sprPlayer, _map,playerHitsWall);
		FlxG.collide(_grpEBulletBubbles, _map, bubbleHitsWall);
		FlxG.collide(_grpEBullets, _map, bulletHitsWall);
		FlxG.collide(_grpPBullets, _map, bulletHitsWall);
		
		var playerMin = _chaser.x - (FlxG.width / 2) + 8;
		if (_sprPlayer.x < playerMin)
			_sprPlayer.x = playerMin;
		
		FlxG.overlap(_grpPBullets, _grpAllEnemies, pBulletHitEnemy);
		FlxG.overlap(_sprPlayer, _grpAllEnemies, playerHitEnemy);
		FlxG.overlap(_grpEBullets, _sprPlayer, eBulletHitPlayer);
		FlxG.overlap(_grpEBulletBubbles, _sprPlayer, eBulletHitPlayer);
	}
	
	function bulletHitsWall(B:FlxSprite, W:FlxTilemap):Void
	{
		if (B.alive)
		{
			B.kill();
		}
	}
	
	function eBulletHitPlayer(EB:FlxSprite, P:FlxSprite):Void
	{
		if (EB.alive)
		{
			EB.kill();
			spawnHit();
			P.hurt(1);
			FlxG.camera.flash(FlxColor.WHITE, .1);
		}
	}
	
	function spawnHit():Void
	{
		var hit = _hits.recycle(Hit.new.bind(_sprPlayer));
		hit.hit();
		_hits.add(hit);
	}
	
	function playerHitEnemy(P:FlxSprite, E:FlxSprite):Void
	{
		if (E.alive)
		{
			E.kill();
			addExplosions(E);
			FlxG.camera.flash(FlxColor.WHITE, .1);
			_score += 100;
			_sprPlayer.hurt(1);
		}
	}
	function playerHitsWall(P:FlxSprite, W:FlxTilemap):Void
	{
		_sprPlayer.kill();
		FlxG.camera.flash(FlxColor.WHITE, .1);
	}
	
	function pBulletHitEnemy(PB:PBullet, E:FlxSprite):Void
	{
		if (PB.alive && E.alive)
		{
			PB.kill();
			E.kill();
			addExplosions(E);
			_score += 100;
		}
	}
	
	function addExplosions(Target:FlxSprite):Void
	{
		for (i in 0...3)
		{
			var explosion = _explosions.recycle(Explosion.new);
			explosion.explode(Target, i);
			_explosions.add(explosion);
		}
	}
	
	function playerMovement():Void
	{
		var v:Float = 0;
		
		#if mobile
		var t:FlxTouch = FlxG.touches.getFirst();
		
		if (t!=null)
		{
			if (t.y < _sprPlayer.y - (_sprPlayer.height / 2))
				v -= 120;
			else if (t.y > _sprPlayer.y + _sprPlayer.height + (_sprPlayer.height / 2))
				v += 120;
		}
		#end
		
		#if FLX_KEYBOARD
		if (FlxG.keys.anyPressed([UP, W]))
			v -= 120;
		if (FlxG.keys.anyPressed([DOWN, S]))
			v += 120;
		#end
		
		if (v < 0)
			_sprPlayer.animation.play("up");
		else if (v > 0)
			_sprPlayer.animation.play("down");
		else
			_sprPlayer.animation.play("normal");
		_sprPlayer.velocity.y = v;
		v = _chaser.velocity.x;
		
		#if mobile
		if (t!=null)
		{
			if (t.x < _sprPlayer.x)
				v -= 90;
			else if (t.x > _sprPlayer.x + _sprPlayer.width)
				v += 90;
		}
		#end
		
		#if FLX_KEYBOARD
		if (FlxG.keys.anyPressed([LEFT, A]))
			v -= 90;
		if (FlxG.keys.anyPressed([RIGHT, D]))
			v += 90;
		#end
		
		_sprPlayer.velocity.x = v;
		
		#if mobile
		var t:FlxTouch = FlxG.touches.getFirst();
		if (t != null && t.pressed)
		{
			shootPBullet();
		}
		#end
		
		#if FLX_KEYBOARD
		if (FlxG.keys.anyPressed([SPACE, X]))
		{
			shootPBullet();
		}
		#end
	}
	
	public function shootEBullet(E:Enemy):Void
	{
		var eB = _grpEBullets.recycle(EBullet.new);
		eB.reset(E.x - eB.width, E.y + E.height - 1);
		_grpEBullets.add(eB);
		FlxG.sound.play(AssetPaths.eshoot__wav, .66);
		var s:Spark = _sparks.recycle(Spark.new);
		s.spark(-1, E.height-2, E,1);
		_sparks.add(s);
	}
	
	public function shootEBulletBubble(E:EnemySpinner):Void
	{
		var eB:EBulletBubble = _grpEBulletBubbles.recycle(EBulletBubble.new);
		eB.reset(E.x +(eB.width / 2) - (eB.width / 2) , E.y + (E.height / 2) - (eB.height / 2));
		eB.velocity.set(100, 0);
		eB.velocity.rotate(FlxPoint.weak(), FlxG.random.int(0, 360));
		_grpEBulletBubbles.add(eB);
		FlxG.sound.play(AssetPaths.bubble__wav,.66);
	}
	
	function shootPBullet():Void
	{
		if (_shootDelay <= 0 && _grpPBullets.countLiving() < 12)
		{
			var pB = _grpPBullets.recycle(PBullet.new);
			pB.reset(_sprPlayer.x + _sprPlayer.width, _sprPlayer.y + _sprPlayer.height -1);
			_grpPBullets.add(pB);
			_shootDelay = .5;
			FlxG.sound.play(AssetPaths.shoot__wav, .33);
			var s = _sparks.recycle(Spark.new);
			s.spark(_sprPlayer.width-1, _sprPlayer.height -2, _sprPlayer, 0);
			_sparks.add(s);
		}
	}
}
