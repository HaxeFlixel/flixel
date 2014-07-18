package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;

/**
 * Class declaration for the squid monster class
 */
class Alien extends FlxSprite
{
	/**
	 * A simple timer for deciding when to shoot
	 */ 
	private var _shotClock:Float;
	/**
	 * Saves the starting horizontal position (for movement logic)
	 */
	private var _originalX:Int;				
	
	/**
	 * This is the constructor for the squid monster.
	 * We are going to set up the basic values and then create a simple animation.
	 */
	public function new(X:Int, Y:Int, Color:Int, Bullets:FlxGroup)
	{
		// Initialize sprite object
		super(X, Y);		
		// Load this animated graphic file
		loadGraphic("assets/alien.png", true);	
		// Setting the color tints the plain white alien graphic
		color = Color;		
		_originalX = X;
		resetShotClock();
		
		// Time to create a simple animation! "alien.png" has 3 frames of animation in it.
		// We want to play them in the order 1, 2, 3, 1 (but of course this stuff is 0-index).
		// To avoid a weird, annoying appearance the framerate is randomized a little bit
		// to a value between 6 and 10 (6+4) frames per second.
		this.animation.add("Default", [0, 1, 0, 2], Math.floor(6 + FlxG.random.float() * 4));

		// Now that the animation is set up, it's very easy to play it back!
		this.animation.play("Default");
		
		// Everybody move to the right!
		velocity.x = 10;
	}
	
	/**
	 * Basic game loop is BACK y'all
	 */
	override public function update():Void
	{
		// If alien has moved too far to the left, reverse direction and increase speed!
		if (x < _originalX - 8)
		{
			x = _originalX - 8;
			velocity.x = -velocity.x;
			velocity.y++;
		}
		
		// If alien has moved too far to the right, reverse direction
		if (x > _originalX + 8) 
		{
			x = _originalX + 8;
			velocity.x = -velocity.x;
		}
		
		// Then do some bullet shooting logic
		if (y > FlxG.height * 0.35)
		{
			// Only count down if on the bottom two-thirds of the screen
			_shotClock -= FlxG.elapsed; 
		}
		
		if (_shotClock <= 0)
		{
			// We counted down to zero, so it's time to shoot a bullet!
			resetShotClock();
			var bullet:FlxSprite = cast(cast(FlxG.state, PlayState).alienBullets.recycle(), FlxSprite);
			bullet.reset(x + width / 2 - bullet.width / 2, y);
			bullet.velocity.y = 65;
		}
		
		super.update();
	}
	
	/**
	 * This function just resets our bullet logic timer to a random value between 1 and 11
	 */
	private function resetShotClock():Void
	{
		_shotClock = 1 + FlxG.random.float() * 10;
	}
}