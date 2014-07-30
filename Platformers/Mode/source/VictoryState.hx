package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxSpriteUtil;
import flixel.effects.particles.FlxEmitter;

/**
 * A FlxState which is shown when the player wins.
 */
class VictoryState extends FlxState
{
	private var _timer:Float = 0;
	private var _fading:Bool = false;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.cameras.flash(0xffd8eba2);
		
		// Gibs emitted upon death
		var gibs:FlxEmitter = new FlxEmitter(0, -50);
		gibs.width = FlxG.width;
		gibs.velocity.set(0, 0, 0, 100);
		gibs.angularVelocity.set( -360, 360);
		gibs.acceleration.set(0, 80);
		gibs.loadParticles(Reg.SPAWNER_GIBS, 800, 32, true);
		add(gibs);
		gibs.start(false, 0.005);
		
		var text:FlxText = new FlxText(0, 0, FlxG.width, "VICTORY\n\nSCORE: " + Reg.score, 16);
		text.alignment = CENTER;
		text.color = 0xffD8EBA2;
		FlxSpriteUtil.screenCenter(text, false, true);
		add(text);
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (!_fading)
		{
			_timer += FlxG.elapsed;
			
			if ((_timer > 0.35) && ((_timer > 10) || FlxG.keys.anyJustPressed([X, C])))
			{
				_fading = true;
				FlxG.sound.play("MenuHit2");
				FlxG.cameras.fade(0xff131c1b, 2, false, onPlay);
			}
		}
		
		super.update();
	}
	
	private function onPlay():Void 
	{
		FlxG.switchState(new PlayState());
	}
}