package;
import org.flixel.addons.FlxEmitterExt;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTimer;


class TestState extends FlxState
{
	private var _explosion:FlxEmitterExt;
	private var _explosionOld:FlxEmitter;
	private var _infobox:FlxGroup;
	private var _infoText:FlxText;
	
	public function new()
	{
		super();
	}
	
	override public function create():Void
	{			
		FlxG.bgColor = 0xFF333333;
		FlxG.mouse.show();
		
		//add info box
		_infobox = new FlxGroup();
		_infobox.add(new FlxText(0, 0, 300, "[H] toggle this information"));
		_infobox.add(new FlxText(0, 10, 300, "[G] to toggle gravity"));
		_infobox.add(new FlxText(0, 20, 300, "[CLICK] to spawn explosion"));
		_infobox.add(new FlxText(0, 30, 300, "[SPACE] to toggle emitter type"));
		add(_infobox);	
		
		//add top text
		_infoText = new FlxText (0, FlxG.height - 20, FlxG.width);
		_infoText.alignment = "center";
		add(_infoText);
		
		//add exlposion emitter
		_explosion = new FlxEmitterExt();
		_explosion.setRotation(0, 0);
		_explosion.setMotion(0, 5, 0.2, 360, 200, 1.8);
		_explosion.makeParticles("assets/particles.png", 1200, 0, true, 0);
		add(_explosion);
		
		//add old explosion emitter
		_explosionOld = new FlxEmitter();
		_explosionOld.setRotation(0, 0);
		_explosionOld.makeParticles("assets/particles.png", 1200, 0, true, 0);
		add(_explosionOld);
		
		//add a constant explosion spawner
		FlxTimer.manager.add(new FlxTimer().start(4, 0, onTimer));		
	}
	
	private function onTimer(timer:FlxTimer):Void
	{
		explode(FlxG.width / 2, FlxG.height / 2);
	}
	
	override public function update():Void
	{
		super.update();
		
		//This is just to make the info text fade out
		if (_infoText.alpha > 0) 
		{
			_infoText.alpha -= 0.01;
		}
					
		//spawn explosion
		if (FlxG.mouse.justPressed()) 
		{
				explode(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		//toggle infobox
		if (FlxG.keys.justPressed("H")) 
		{
			_infobox.visible = !_infobox.visible;
		}
		
		//toggle gravity
		if (FlxG.keys.justPressed("G")) {
			if(_explosion.gravity == 0){
				_explosion.gravity = 400;
				_explosionOld.gravity = 400;
			}
			else
			{
				_explosion.gravity = 0;
				_explosionOld.gravity = 0;
			}
		}
					
		//toggle emitter type
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
					
	private function explode(x:Float = 0, y:Float = 0):Void
	{			
		if (_explosion.visible)
		{
			_explosion.x = x;
			_explosion.y = y;
			_explosion.start(true, 0, 0, 400);
			_explosion.update();
		}
		else 
		{
			_explosionOld.x = x;
			_explosionOld.y = y;

			_explosionOld.start(true, 2, 0, 400);
			_explosionOld.update();
		}
	}

}