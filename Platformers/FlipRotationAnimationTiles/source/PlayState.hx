package;

import entities.Character;
import flixel.FlxG;
import flixel.FlxState;
import map.Level;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var level:Level;
	var player:Character;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		
		level = new Level("maps/test2.tmx", "maps/test2.tanim");
		
		add(level.backgroundGroup);
		add(level.characterGroup);
		add(level.foregroundGroup);
		
		add(level.collisionGroup);
		
		FlxG.camera.setScrollBoundsRect(level.bounds.x, level.bounds.y, level.bounds.width, level.bounds.height);
		FlxG.worldBounds.copyFrom(level.bounds);
		
		super.create();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		level.update();
		super.update();
	}	
}