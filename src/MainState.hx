package;

import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxState;

/**
 * ...
 * @author Zaphod
 */
class MainState extends FlxState
{
	private var hero:Hero;
	private var heroBullets:FlxGroup;
	
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		var back:FlxSprite = new FlxSprite(0, 0);
		back.makeGraphic(320, 240, 0xffffffff);
		add(back);
		
		hero = new Hero();
		add(hero);
		
		heroBullets = new FlxGroup();
		
		var bullet:FlxSprite;
		for (i in 0...15)
		{
			bullet = new FlxSprite( -20, -20);
			bullet.makeGraphic(2, 8, 0xffff0000);
			heroBullets.add(bullet);
		}
		
		hero.bullets = heroBullets.members;
		add(heroBullets);
	}
	
	override public function update():Void 
	{
		super.update();
	}
	
}