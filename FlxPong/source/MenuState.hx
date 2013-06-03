package;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

class MenuState extends FlxState 
{
	public static var isNewGame:Bool = false;
	
	override public function create():Void 
	{
		FlxG.bgColor = 0xff000000;
		
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 24, FlxG.width, "FlxPong");
		t.size = 24;
		t.color = 0xffffffff;
		t.alignment = "center";
		add(t);
		
		var b:FlxText;
		b = new FlxText(0, (FlxG.height / 2) + 24, FlxG.width, "Press Enter");
		b.alignment = "center";
		b.flicker( -1);
		add(b);
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (FlxG.keys.ENTER) 
		{
			if (isNewGame) 
			{
				PlayState.ball = new Ball( (FlxG.width / 2) - 16, (FlxG.height / 2) - 16);
				PlayState.rPaddle = new EnemyPaddle(FlxG.width - 16, (FlxG.height / 2) - 32);
				PlayState.paddle = new Paddle(0, (FlxG.height / 2) - 32);
				PlayState.topLeftWall = new Wall(0, -16, 0xffccffaa);
				PlayState.topRightWall = new Wall(112, -16, 0xffffffaa);
				PlayState.bottomLeftWall = new Wall(0, Ball.BOTTOM, 0xff7777aa);
				PlayState.bottomRightWall = new Wall(112, Ball.BOTTOM, 0xffaaaacc);
			}
			
			FlxG.switchState(new PlayState());
		}
	}
	
	override public function destroy():Void 
	{
		super.destroy();
	}
}