package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxEmitterExt;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var _explosion:FlxEmitterExt;
	private var _explosionOld:FlxEmitter;
	private var _infobox:FlxGroup;
	private var _infoText:FlxText;
	
	override public function create():Void
	{			
		FlxG.cameras.bgColor = FlxColor.BLACK;
		FlxG.mouse.show();
		
		// Add info box
		_infobox = new FlxGroup();
		_infobox.add(new FlxText(0, 0, 300, "[G] to toggle gravity"));
		_infobox.add(new FlxText(0, 10, 300, "[CLICK] to spawn explosion"));
		_infobox.add(new FlxText(0, 20, 300, "[SPACE] to toggle emitter type"));
		add(_infobox);	
		
		// Add top text
		_infoText = new FlxText (0, FlxG.height - 20, FlxG.width);
		_infoText.alignment = "center";
		add(_infoText);
		
		// Add exlposion emitter
		_explosion = new FlxEmitterExt();
		_explosion.setRotation(0, 0);
		_explosion.setMotion(0, 5, 0.2, 360, 200, 1.8);
		_explosion.makeParticles("assets/particles.png", 1200, 0, true, 0);
		_explosion.setAlpha(1, 1, 0, 0);
		add(_explosion);
		
		// Add old explosion emitter
		_explosionOld = new FlxEmitter();
		_explosionOld.setRotation(0, 0);
		_explosionOld.makeParticles("assets/particles.png", 1200, 0, true, 0);
		_explosion.setAlpha(1, 1, 0, 0);
		add(_explosionOld);
		
		// Start off with an explosion
		explode();
	}

	override public function update():Void
	{
		super.update();
		
		// This is just to make the info text fade out
		if (_infoText.alpha > 0) 
		{
			_infoText.alpha -= 0.01;
		}
		
		// Spawn explosion
		if (FlxG.mouse.justPressed()) 
		{
			explode(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		// Toggle gravity
		if (FlxG.keys.justPressed("G")) 
		{
			if (_explosion.gravity == 0)
			{
				_explosion.gravity = 400;
				_explosionOld.gravity = 400;
			}
			else
			{
				_explosion.gravity = 0;
				_explosionOld.gravity = 0;
			}
		}
		
		// Toggle emitter type
		if (FlxG.keys.justPressed("SPACE")) 
		{
			_explosion.visible = !_explosion.visible;
			_explosionOld.visible = !_explosionOld.visible;
			_infoText.alpha = 1;
			
			if (_explosion.visible) 
			{
				_infoText.text = "New Emitter Style (FlxEmitterExt)";	
			}
			else 
			{
				_infoText.text = "Old Emitter Style (FlxEmitter)";
			}
		}
	}
	
	private function explode(X:Float = 0, Y:Float = 0):Void
	{	
		if (X == 0 && Y == 0)
		{
			X = FlxG.width / 2;
			Y = FlxG.height / 2;
		}
		
		if (_explosion.visible)
		{
			_explosion.x = X;
			_explosion.y = Y;
			_explosion.start(true, 2, 0, 400);
			_explosion.update();
		}
		else 
		{
			_explosionOld.x = X;
			_explosionOld.y = Y;
			_explosionOld.start(true, 2, 0, 400);
			_explosionOld.update();
		}
	}
}