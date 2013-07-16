package;

import openfl.Assets;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.text.FlxTextField;

class VictoryState extends FlxState
{
	private var _timer:Float;
	private var _fading:Bool;

	override public function create():Void
	{
		_timer = 0;
		_fading = false;
		FlxG.cameraFX.flash(0xffd8eba2);
		
		//Gibs emitted upon death
		var gibs:FlxEmitter = new FlxEmitter(0, -50);
		gibs.setSize(FlxG.width, 0);
		gibs.setXSpeed();
		gibs.setYSpeed(0, 100);
		gibs.setRotation( -360, 360);
		gibs.gravity = 80;
		gibs.makeParticles(FlxAssets.imgSpawnerGibs, 800, 32, true, 0);
		add(gibs);
		gibs.start(false, 0, 0.005);
		
		#if flash
		var text:FlxText = new FlxText(0, FlxG.height / 2 - 35, FlxG.width, "VICTORY\n\nSCORE: " + Reg.score);
		#else
		var text:FlxTextField = new FlxTextField(0, FlxG.height / 2 - 35, FlxG.width, "VICTORY\n\nSCORE: " + Reg.score);
		#end
		text.setFormat(null, 16, 0xd8eba2, "center");
		add(text);
	}

	override public function update():Void
	{
		super.update();
		if(!_fading)
		{
			_timer += FlxG.elapsed;
			if((_timer > 0.35) && ((_timer > 10) || FlxG.keys.justPressed("X") || FlxG.keys.justPressed("C")))
			{
				_fading = true;
				FlxG.sound.play("MenuHit2");
				
				FlxG.cameraFX.fade(0xff131c1b, 2, false, onPlay);
			}
		}
	}
	
	private function onPlay():Void 
	{
		FlxG.switchState(new PlayState());
	//	FlxG.switchState(new PlayStateOld());
	}
}