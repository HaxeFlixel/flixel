package;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState 
{		
	public static var paddle:Paddle;
	public static var rPaddle:EnemyPaddle;
	public static var ball:Ball;
	
	public var playerScore:FlxText;
	public var enemyScore:FlxText;
	public static var pScoreLiteral:Float = 0;
	public static var eScoreLiteral:Float = 0;
	
	public static var topLeftWall:Wall;
	public static var topRightWall:Wall;
	
	public static var bottomRightWall:Wall;
	public static var bottomLeftWall:Wall;
	public var dead:Bool = false;
	
	public static var scoreCap:Float = 9;
	
	//public const DEBUGMODE:Boolean = true;
	
	override public function create():Void 
	{
		paddle = new Paddle(0, (FlxG.height / 2) - 32);
		rPaddle = new EnemyPaddle(FlxG.width - 16, (FlxG.height / 2) - 32);
		ball = new Ball( (FlxG.width / 2) - 16, (FlxG.height / 2) - 16);
		
		playerScore = new FlxText((FlxG.width / 2) - 24, FlxG.height - 160, 24);
		enemyScore = new FlxText((FlxG.width / 2) + 6, FlxG.height - 160, 24);
		pScoreLiteral = 0;
		eScoreLiteral = 0;
		
		topLeftWall = new Wall(0, -16, 0xffccffaa);
		topRightWall = new Wall(112, -16, 0xffffffaa);
		
		bottomRightWall = new Wall(112, Ball.BOTTOM, 0xffaaaacc);
		bottomLeftWall = new Wall(0, Ball.BOTTOM, 0xff7777aa);
		
		add(topLeftWall);
		add(topRightWall);
		add(bottomLeftWall);
		add(bottomRightWall);
		
		add(paddle);
		add(rPaddle);
		add(ball);
		textSettings(playerScore, enemyScore);
		add(playerScore); 
		add(enemyScore);
	}
	
	private function textSettings(playerTxt:FlxText, enemyTxt:FlxText):Void 
	{	
		playerTxt.color = 0xffffffff;
		playerTxt.text = "0";
		playerTxt.size = 24;
		
		enemyTxt.color = 0xffffffff;
		enemyTxt.text = "0";
		enemyTxt.size = 24;
	}
	
	private function handleScore(playerTxt:FlxText, enemyTxt:FlxText):Void 
	{
		if (pScoreLiteral > scoreCap || eScoreLiteral > scoreCap) 
		{	
			FlxG.switchState(new ResultState());
		}
		else if (pScoreLiteral < scoreCap || eScoreLiteral < scoreCap)
		{
			var tmp1:String = Std.string(pScoreLiteral);
			playerTxt.text = tmp1;
			var tmp2:String = Std.string(eScoreLiteral);
			enemyTxt.text = tmp2;
		}
	}
	
	override public function update():Void 
	{
		super.update();	
		handleScore(playerScore, enemyScore);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		ball = null;
		rPaddle = null;
		paddle = null;
		
		playerScore = null;
		enemyScore = null;
		
		topLeftWall = null;
		topRightWall = null;
		
		bottomLeftWall = null;
		bottomRightWall = null;
	}
}