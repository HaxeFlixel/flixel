package;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.addons.editors.spine.FlxSpine;
import testclasses.GoblinTest;
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
		
		super.create();
		
		spineSprite = cast new SpineBoyTest(FlxSpine.readSkeletonData("spineboy", "assets"), 300, 420);
		add(spineSprite);
		
		var instructions = new FlxText(0, 0, 250, "Space: Toggle Debug Display\nMove: Arrows / WASD\nLeft mouse: Jump", 12);
		instructions.ignoreDrawDebug = true;
		add(instructions);
		
		//spineSprite.flipX = true;
		spineSprite.flipY = true;
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
		}
		else if (FlxG.keys.anyPressed([A, LEFT]))
		{
			spineSprite.x -= 500 * elapsed;
		}
		
		// NOT YET SUPPORTED
		/*
		// origin movement
		if ( FlxG.keys.justPressed("F") )
		{
			spineSprite.origin.x += 500 * elapsed;
		}
		if ( FlxG.keys.justPressed("G") )
		{
			spineSprite.origin.x -= 500 * elapsed;
		}
		
		// rotation
	 	if ( FlxG.keys.justPressed("A") )
		{
			spineSprite.angle += 20;
		}
		if ( FlxG.keys.justPressed("D") )
		{
			 spineSprite.angle -= 20;
		}
		
		// scale
		if ( FlxG.keys.justPressed("R") )
		{
			 spineSprite.scale.x += 0.2;
			 spineSprite.scale.y += 0.2;
		} 
		if ( FlxG.keys.justPressed("T") )
		{
			 spineSprite.scale.x -= 0.2; 
			 spineSprite.scale.y -= 0.2; 
		}
		*/
		
		super.update(elapsed);
	}
}
