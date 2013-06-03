package;

import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState 
{
	private var brickMap:Array<Int>;
	private var rowNumb:Int;
	private var colNumb:Int;
	public var gameInitiated:Bool;
	
	public var ballMC:Ball;
	public var paddleMC:Paddle;
	public var scoreTxt:FlxText;
	public var ballTxt:FlxText;
	
	public var brickGroup:FlxGroup;
	
	override public function create():Void 
	{	
		brickMap = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		rowNumb = 0;
		colNumb = 0;
		gameInitiated = false;
		brickGroup = new FlxGroup();
		
		FlxG.mouse.show();
		this.add(ballMC = new Ball(Math.floor(FlxG.width / 2) + 8, FlxG.height - 20, "assets/ball.png"));
		this.add(paddleMC = new Paddle(Math.floor(FlxG.width / 2), FlxG.height - 10, "assets/paddle.png", gameInitiated, ballMC));
		this.add(scoreTxt = new FlxText(0, 0, 200, Std.string(Reg.score)));
		this.add(brickGroup);
		createMap();
		ballMC._paddle = paddleMC;
		
		super.create();
	}
	
	private function createMap():Void 
	{
		rowNumb = 0;
		colNumb = 0;
		
		for (i in 0...(brickMap.length)) 
		{
			if (i % 13 != 0) 
			{
				colNumb++;
			}
			else 
			{
				colNumb = 0;
				rowNumb ++;
			}
			
			var brick:Brick;
			
			if (brickMap[i] == 0) 
			{
				brick = cast(brickGroup.recycle(Brick), Brick).init(colNumb * 24, (rowNumb * 8) + 8, "assets/black_brick.png", ballMC);
			}
			else 
			{
				brick = cast(brickGroup.recycle(Brick), Brick).init(colNumb * 24, (rowNumb * 8) + 8, "assets/yellow_brick.png", ballMC);
			}				
		}
	}
	
	override public function update():Void 
	{
		super.update();			
		
		scoreTxt.text = "Score: "+ Std.string(Reg.score);			
		
		if (FlxG.mouse.justReleased()) 
		{				
			if (!gameInitiated) 
			{
				gameInitiated = true;
				paddleMC.gameInitiated = true;
				var randDir:Float = Math.random();
				if (randDir > 0.5)
				{
					ballMC.velocity.x = -150;
				}
				else 
				{
					ballMC.velocity.x = 150;
				}
				ballMC.velocity.y = -150;
			}
		}
		if (FlxG.keys.justReleased("R") || ballMC.y > FlxG.height)
		{
			resetGame();
		}
	}
	
	public function resetGame():Void 
	{
		gameInitiated = false;
		paddleMC.gameInitiated = false;
		ballMC.velocity.y = ballMC.velocity.x = 0;
		ballMC.x = (FlxG.width / 2 ) + 8;
		ballMC.y = FlxG.height - 20;
		paddleMC.x = FlxG.width / 2;
		paddleMC.y = FlxG.height - 10;	
		createMap();
	}
}