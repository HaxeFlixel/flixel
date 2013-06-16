package;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.util.FlxAngle;

class StarField extends FlxGroup 
{
	public static var NUM_STARS:Int = 75;

	private var angle:Float;

	public function new(?ang:Float = 90, ?speedMultiplier:Float = 4) 
	{
		super();

		angle = ang;

		var radang:Float = ang * Math.PI / 180;
		var cosang:Float = Math.cos(radang);
		var sinang:Float = Math.sin(radang);

		for (i in 0...(StarField.NUM_STARS)) 
		{
			var str:FlxSprite = new FlxSprite(Math.random() * FlxG.width, Math.random() * FlxG.height);
			var vel:Float = Math.random() * -16 * speedMultiplier;
			
			#if flash
			var transp:UInt = (Math.round(16 * ( -vel / speedMultiplier) - 1) << 24);
			#elseif cpp
			var transp:Int = (Math.round(16 * ( -vel / speedMultiplier) - 1) << 24);
			#elseif neko
			var transp:Int = (Math.round(16 * ( -vel / speedMultiplier) - 1));
			#end
			
			str.makeGraphic(2, 2, 0x00ffffff | transp);
			str.velocity.x = sinang * vel;
			str.velocity.y = cosang * vel;
			add(str);
		}
	}

	public function rotate(?howMuch:Float = 1):Void 
	{	
		angle += howMuch;

		var radang:Float = angle * Math.PI / 180;
		var cosang:Float = Math.cos(radang);
		var sinang:Float = Math.sin(radang);
		
		var star:FlxSprite;
		for (starBasic in members) 
		{	
			star = cast(starBasic, FlxSprite);
			FlxAngle.rotatePoint(star.velocity.x, star.velocity.y, 0, 0, howMuch, star.velocity);
		}
	}

	override public function update():Void 
	{	
		super.update();

		var star:FlxSprite;
		for (starBasic in members) 
		{
			star = cast(starBasic, FlxSprite);
			if (star.x > FlxG.width) 
			{
				star.x = 0;
			}
			else if (star.x < 0) 
			{
				star.x = FlxG.width;
			}

			if (star.y > FlxG.height) 
			{	
				star.y = 0;
			}
			else if (star.y < 0) 
			{	
				star.y = FlxG.height;
			}
		}
	}
}