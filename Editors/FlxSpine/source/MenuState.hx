package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.addons.editors.spine.FlxSpine;
import testclasses.SpineBoyTest;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	var spineSprite:FlxSpine;
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		
		spineSprite = new SpineBoyTest(FlxSpine.readSkeletonData("spineboy", "assets", 0.6), 300, 420);
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
		#if !FLX_NO_DEBUG
		if (FlxG.keys.justPressed.SPACE)
			FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
		#end
		
		// movement
		if (FlxG.keys.anyPressed([W, UP]))
		{
			spineSprite.y -= 500 * elapsed;
		}
		else if (FlxG.keys.anyPressed([S, DOWN]))
		{
			spineSprite.y += 500 * elapsed;
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			spineSprite.x += 500 * elapsed;
			spineSprite.skeleton.flipX = false;
		}
		else if (FlxG.keys.anyPressed([A, LEFT]))
		{
			spineSprite.x -= 500 * elapsed;
			spineSprite.skeleton.flipX = true;
		}
		
		super.update(elapsed);
	}
}
