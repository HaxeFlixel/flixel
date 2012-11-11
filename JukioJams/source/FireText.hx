package;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;

class FireText extends FlxGroup
{	
	static public inline var MM:Int = 0;
	static public inline var KOZILEK:Int = 1;
	static public inline var FISH:Int = 2;
	static public inline var GAMECITY:Int = 3;
	static public inline var GUNGOD:Int = 4;
	
	public var mm:FlxSprite;
	public var kozilek:FlxSprite;
	public var fish:FlxSprite;
	public var gameCity:FlxSprite;
	public var gunGod:FlxSprite;
	
	public function new()
	{
		super();
		
		add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xff110000));

		var i:Int;
		var e:FlxEmitter;
		i = 400;
		e = new FlxEmitter(10, 10, i);
		while(i-- > 0)
		{
			e.add(new Fire());
		}
		e.width = FlxG.width - 20;
		e.height = FlxG.height - 20;
		e.setYSpeed( -100, 0);
		e.gravity = -200;
		e.setXSpeed( -50, 50);
		e.setRotation();
		e.start(false, 2, 0.002);
		add(e);
		
		mm = new FlxSprite(0, 0, "assets/text_mm.png");
		add(mm);
		
		kozilek = new FlxSprite().loadGraphic("assets/text_kozilek.png", true, false, 256, 192);
		kozilek.addAnimation("idle", [0, 1, 2, 3, 2, 1], 12);
		kozilek.play("idle");
		add(kozilek);
		
		fish = new FlxSprite().loadGraphic("assets/text_fish.png", true, false, 256, 192);
		//fish.addAnimation("idle",[0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1],16);
		//fish.play("idle");
		fish.frame = 7;
		add(fish);
		
		gameCity = new FlxSprite(0, 0, "assets/text_gc.png");
		add(gameCity);
		
		gunGod = new FlxSprite().loadGraphic("assets/gungod.png", true, false, 256, 192);
		gunGod.addAnimation("idle", [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 3, 4, 5, 3, 4, 5, 3, 4, 5, 3, 4, 5], 12);
		gunGod.play("idle");
		add(gunGod);
	}
	
	public function resetText(Text:Int):Void
	{
		mm.visible = kozilek.visible = fish.visible = gameCity.visible = gunGod.visible = false;
		switch (Text)
		{
			case 0:
				mm.visible = true;
			case 1:
				kozilek.visible = true;
			case 2:
				fish.visible = true;
			case 3:
				gameCity.visible = true;
			case 4:
				gunGod.visible = true;
		}
	}
}