package;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxParticle;
import org.flixel.FlxState;
import org.flixel.FlxText;
class PlayState extends FlxState
{
	public var toggle:Bool;
	
	override public function create():Void
	{
		//Title text, nothing crazy here!
		var text:FlxText;
		text = new FlxText(FlxG.width / 4, FlxG.height / 2 - 20, Math.floor(FlxG.width / 2), "FlxBlur", true);
		text.setFormat(null, 32, FlxG.WHITE, "center");
		add(text);
		text = new FlxText(FlxG.width / 4, FlxG.height / 2 + 20, Math.floor(FlxG.width / 2), "press space to toggle", true);
		text.setFormat(null, 16, FlxG.BLUE, "center");
		add(text);
		
		//This is the particle emitter that spews things off the bottom of the screen.
		//I'm not going to go over it in too much detail here, but basically we
		// create the emitter, then we create 50 32x32 sprites and add them to it.
		var emitter:FlxEmitter = new FlxEmitter(0, FlxG.height + 20, 50);
		emitter.width = FlxG.width;
		emitter.gravity = -40;
		emitter.setXSpeed(-20,20);
		emitter.setYSpeed(-75,-25);
		var particle:FlxParticle;
		var particles:Int = 50;
		var colors:Array<Int> = [FlxG.BLUE, (FlxG.BLUE | FlxG.GREEN), FlxG.GREEN, (FlxG.GREEN | FlxG.RED), FlxG.RED];
		for (i in 0...particles)
		{
			particle = new FlxParticle();
			particle.makeGraphic(32, 32, colors[Std.int(FlxG.random() * colors.length)]);
			particle.exists = false;
			emitter.add(particle);
		}
		emitter.start(false, 0, 0.1);
		add(emitter);
		
		//Let the player toggle the effect with the space bar.  Effect starts on.
		toggle = true;
	}
	
	override public function update():Void
	{
		if(FlxG.keys.justPressed("SPACE"))
		{
			toggle = !toggle;
		}
		if(toggle)
		{
			//By setting the background color to a value with a low transparency,
			//we can generate a cool "blur" effect.
			FlxG.bgColor = 0x11000000;
		}
		else
		{
			//Setting it to an opaque color will turn the effect back off.
			FlxG.bgColor = FlxG.BLACK;
		}
		
		super.update();
	}
}