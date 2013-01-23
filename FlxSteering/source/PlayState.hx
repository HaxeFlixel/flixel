package;

import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;

class PlayState extends FlxState
{
	private var _fps:FlxText;
	
	private var _seeker:Boid;
	private var _pursuer:Boid;
	
	override public function create():Void
	{
		#if !neko
		FlxG.bgColor = 0xffff0000;	
		#else
		FlxG.camera.bgColor = {rgb: 0xff0000, a: 0xff};	
		#end
		
		FlxG.mouse.show();	
		
		_fps = new FlxText(FlxG.width - 40, 0, 40).setFormat(null, 8, 0xffffff, "right");
		_fps.scrollFactor.x = _fps.scrollFactor.y = 0;
		add(_fps);
		
		_seeker = new Boid(FlxG.width / 2, FlxG.height / 2, 30); 
		add(_seeker);
		_pursuer = new Boid(30, 30, 30); 
		add(_pursuer);
	}
	
	override public function update():Void
	{
		super.update();
		
		//FlxG.log(FlxU.collide(_seeker,_pursuer));
		
		FlxG.collide();
		
		_fps.text = FlxU.floor(1 / FlxG.elapsed) + " fps";
		
		var v:Vector2D = new Vector2D(FlxG.mouse.screenX, FlxG.mouse.screenY);
	
		_seeker.arrive(v);
		_pursuer.pursue(_seeker);
	}
}