package com.chipacabra.jumper;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxU;

/**
 * ...
 * @author David Bell
 */
class Bullet extends FlxSprite 
{
	public function new() 
	{
		super();
		loadGraphic("assets/art/bullet.png", false);
		exists = false; // We don't want the bullets to exist anywhere before we call them.
	}
	
	override public function update():Void 
	{
		if (!alive && finished) //Finished refers to animation, only included here in case I add animation later
		{
			exists = false;   // Stop paying attention when the bullet dies. 
		}
		if (getScreenXY().x < -64 || getScreenXY().x > FlxG.width + 64) 
		{ 
			kill(); // If the bullet makes it 64 pixels off the side of the screen, kill it
		} 
		else if (touching != 0)
		{
			kill(); //We want the bullet to go away when it hits something, not just stop.
		}
		else
		{
			super.update();
		}
	}
	
	// We need some sort of function other classes can call that will let us actually fire the bullet. 
	public function shoot(X:Int, Y:Int, VelocityX:Int, VelocityY:Int):Void
	{
		super.reset(X, Y);  // reset() makes the sprite exist again, at the new location you tell it.
		solid = true;
		velocity.x = VelocityX;
		velocity.y = VelocityY;
	}
	
	public function angleshoot(X:Int, Y:Int, Speed:Int, Target:FlxPoint):Void
	{
		super.reset(X, Y);
		solid = true;
		var rangle:Float = Math.atan2(Target.y - (y + (height / 2)), Target.x - (x + (width / 2)));  //This gives angle in radians
		velocity.x = Math.cos(rangle) * Speed;
		velocity.y = Math.sin(rangle) * Speed;
	}
	
}