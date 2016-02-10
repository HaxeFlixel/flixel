package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.display.FlxClothSprite;
import flixel.text.FlxText;

/**
 * @author adrianulima
 */
class PlayState extends FlxState
{
	var flag:FlxClothSprite;
	var flag2:FlxClothSprite;
	var rope:FlxClothSprite;
	var rope2:FlxClothSprite;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		super.create();
		
		// This show how to load graphics with animation, set pinnedSide, setMesh and gravity
		flag = new FlxClothSprite(0, 0, "assets/images/flag.png");
		flag.pinnedSide = FlxObject.LEFT;
		flag.setMesh(10, 10);
		flag.maxVelocity.set(200, 200);
		flag.meshVelocity.y = 40;
		add(flag);
		
		// This show how to set mesh scale, custom pinned points and set iterations
		flag2 = new FlxClothSprite(FlxG.width / 2 - 105, 10, "assets/images/flag.png");
		flag2.pinnedSide = FlxObject.NONE;
		flag2.meshScale.set(1.5, 1);
		flag2.setMesh(15, 10, 0, 0, [0, 14]);
		flag2.iterations = 8;
		flag2.maxVelocity.set(200, 200);
		flag2.meshVelocity.y = 40;
		add(flag2);
		
		// This show how to load a simple graphic sprite with crossing constraints
		rope = new FlxClothSprite(FlxG.width / 2 + 200, 10, "assets/images/rope.png", 2, 10, FlxObject.UP, true);
		rope.maxVelocity.set(40, 40);
		rope.meshVelocity.y = 40;
		add(rope);
		
		rope2 = new FlxClothSprite(FlxG.width / 2 - 200, 10, "assets/images/rope.png", 2, 10, FlxObject.UP, true);
		rope2.maxVelocity.set(40, 40);
		rope2.meshVelocity.y = 40;
		add(rope2);
		
		var instruction = new FlxText(0, FlxG.height - 20, FlxG.width, "Click -> Apply wind");
		instruction.alignment = CENTER;
		add(instruction);
	}
	
	override public function update(elapsed:Float):Void
	{
		var halfHeight = flag.frameHeight / 2;
		
		// Apply a volocity to the object based on mouse position
		flag.velocity.x = FlxG.mouse.x - flag.x;
		flag.velocity.y = FlxG.mouse.y - flag.y - halfHeight;
		
		// Move the flag in the direction of mouse
		flag.x += (FlxG.mouse.x - flag.x);
		flag.y += (FlxG.mouse.y - flag.y - halfHeight);
		
		// Apply a random wind
		if (FlxG.mouse.pressed)
		{
			flag.meshVelocity.x = FlxG.random.float(0, flag.maxVelocity.x);
			flag2.meshVelocity.x = FlxG.random.float(0, flag2.maxVelocity.x);
			rope.meshVelocity.x = FlxG.random.float(0, rope.maxVelocity.x);
			rope2.meshVelocity.x = FlxG.random.float(0, rope2.maxVelocity.x);
		}
		else
		{
			flag.meshVelocity.x = 0;
			flag2.meshVelocity.x = 0;
			rope.meshVelocity.x = 0;
			rope2.meshVelocity.x = 0;
		}
		
		super.update(elapsed);
	}
}