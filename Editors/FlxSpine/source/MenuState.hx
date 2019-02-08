package;

import flixel.addons.editors.spine.FlxSpine;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class MenuState extends FlxState
{
	var spineSprite:FlxSpine;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		
		spineSprite = new SpineBoyTest(FlxSpine.readSkeletonData("spineboy", "spineboy", "assets", 0.6), 0.5 * FlxG.width, FlxG.height);
		spineSprite.antialiasing = true;
		add(spineSprite);
		
		var instructions = new FlxText(0, 0, 250, "Space: Toggle Debug Display\nMove: Arrows / WASD\nLeft mouse: Jump", 12);
		instructions.ignoreDrawDebug = true;
		add(instructions);
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		// toggle debug display
		if (FlxG.keys.justPressed.SPACE)
			FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
		
		// movement
		if (FlxG.keys.anyPressed([W, UP]))
		{
			spineSprite.y -= 500 * elapsed;
		}
		if (FlxG.keys.anyPressed([S, DOWN]))
		{
			spineSprite.y += 500 * elapsed;
		}
		if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			spineSprite.x += 500 * elapsed;
			spineSprite.skeleton.flipX = false;
		}
		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			spineSprite.x -= 500 * elapsed;
			spineSprite.skeleton.flipX = true;
		}
		
		super.update(elapsed);
	}
}
