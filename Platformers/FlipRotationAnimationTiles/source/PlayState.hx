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
		add(level.eventsGroup);
		add(level.foregroundGroup);
		
		add(level.collisionGroup);
		
		//FlxG.camera.follow(player);
		FlxG.camera.bounds = level.getBounds();
		FlxG.worldBounds.copyFrom(level.getBounds());
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
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