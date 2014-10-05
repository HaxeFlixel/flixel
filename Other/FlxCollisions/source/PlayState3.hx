package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState3 extends FlxState
{
	private var _platform:FlxSprite;
	
	override public function create():Void
	{
		// Limit collision boundaries to just this screen (since we don't scroll in this one)
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		
		// Background
		FlxG.cameras.bgColor = 0xffacbcd7;
		
		// The thing you can move around
		_platform = new FlxSprite((FlxG.width - 64) / 2, 200).makeGraphic(64, 16, 0xff233e58);
		_platform.immovable = true;
		add(_platform);
		
		// Pour nuts and bolts out of the air
		var dispenser:FlxEmitter = new FlxEmitter((FlxG.width - 64) / 2, -64);
		dispenser.acceleration.set(0, 200);
		dispenser.setSize(64, 64);
		dispenser.velocity.set( -20, 50, 20, 100);
		dispenser.angularVelocity.set( -720, 720);
		dispenser.loadParticles("assets/gibs.png", 300, 16, true);
		dispenser.solid = true;
		dispenser.lifespan.set(5);
		dispenser.start(false, 0.025, 0);
		add(dispenser);
		
		// Instructions and stuff
		var tx:FlxText;
		tx = new FlxText(2, FlxG.height - 12, FlxG.width, "Interact with ARROWS + SPACE, or press ENTER for next demo.");
		tx.scrollFactor.x = tx.scrollFactor.y = 0;
		tx.color = 0x49637a;
		add(tx);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		_platform = null;
	}
	
	override public function update(elapsed:Float):Void
	{
		// Platform controls
		var v:Float = 50;
		
		if (FlxG.keys.pressed.SPACE)
		{
			v *= 3;
		}
		
		_platform.velocity.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			_platform.velocity.x -= v;
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			_platform.velocity.x += v;
		}
		
		super.update(elapsed);
		
		FlxG.collide();
		
		if (FlxG.keys.justReleased.ENTER)
		{
			FlxG.switchState(new PlayState());
		}
	}
}