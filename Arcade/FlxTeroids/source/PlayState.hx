package;

import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{
	public static var asteroids:FlxTypedGroup<Asteroid>;
	public static var bullets:FlxTypedGroup<FlxSprite>;

	var _playerShip:PlayerShip;
	var _scoreText:FlxText;

	var _score:Int = 0;

	override public function create():Void
	{
		FlxG.mouse.visible = false;

		// Create a starfield
		add(new FlxStarField2D());

		// Spawn 3 asteroids for a start
		asteroids = new FlxTypedGroup<Asteroid>();
		add(asteroids);

		for (i in 0...2)
		{
			spawnAsteroid();
		}

		// Make sure we don't ever run out of asteroids! :)
		resetTimer(new FlxTimer());

		// Create the player ship
		_playerShip = new PlayerShip();
		add(_playerShip);

		// There'll only ever be 32 bullets that we recycle over and over
		var numBullets:Int = 32;
		bullets = new FlxTypedGroup<FlxSprite>(numBullets);

		var sprite:FlxSprite;

		for (i in 0...numBullets)
		{
			sprite = new FlxSprite(-100, -100);
			sprite.makeGraphic(8, 2);
			sprite.width = 10;
			sprite.height = 10;
			sprite.offset.set(-1, -4);
			sprite.exists = false;

			bullets.add(sprite);
		}

		// A text to display the score
		_scoreText = new FlxText(0, 4, FlxG.width, "Score: " + 0);
		_scoreText.setFormat(null, 16, FlxColor.WHITE, CENTER, OUTLINE);
		add(_scoreText);

		add(bullets);
	}

	override public function destroy():Void
	{
		super.destroy();

		_playerShip = null;
		bullets = null;
		asteroids = null;
	}

	override public function update(elapsed:Float):Void
	{
		// Escape to the menu
		if (FlxG.keys.pressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}

		super.update(elapsed);

		// Don't continue in case we lost
		if (!_playerShip.alive)
		{
			if (FlxG.keys.pressed.R)
			{
				FlxG.resetState();
			}

			return;
		}

		FlxG.overlap(bullets, asteroids, bulletHitsAsteroid);
		FlxG.overlap(asteroids, _playerShip, asteroidHitsShip);
		FlxG.collide(asteroids);

		for (bullet in bullets)
		{
			if (bullet.exists)
			{
				FlxSpriteUtil.screenWrap(bullet);
			}
		}
	}

	function increaseScore(Amount:Int = 10):Void
	{
		_score += Amount;
		_scoreText.text = "Score: " + _score;
		_scoreText.alpha = 0;
		FlxTween.tween(_scoreText, {alpha: 1}, 0.5);
	}

	function bulletHitsAsteroid(Object1:FlxObject, Object2:FlxObject):Void
	{
		Object1.kill();
		Object2.kill();
		increaseScore();
	}

	function asteroidHitsShip(Object1:FlxObject, Object2:FlxObject):Void
	{
		Object1.kill();
		Object2.kill();
		bullets.kill();
		_scoreText.text = "Game Over! Final score: " + _score + " - Press R to retry.";
	}

	function resetTimer(Timer:FlxTimer):Void
	{
		Timer.start(5, resetTimer);
		spawnAsteroid();
	}

	function spawnAsteroid():Void
	{
		var asteroid = asteroids.recycle(Asteroid.new);
		asteroid.init();
	}
}
