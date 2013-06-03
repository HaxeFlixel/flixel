package com.chipacabra.jumper;

import openfl.Assets;
import org.flixel.FlxG;
import org.flixel.FlxSprite;

/**
 * ...
 * @author David Bell
 */
class Coin extends FlxSprite 
{
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		
		loadGraphic("assets/art/coinspin.png", true, false);
		addAnimation("spinning", [0, 1, 2, 3, 4, 5], 10, true);
		play("spinning");
	}
	
	override public function kill():Void 
	{
		super.kill();
		FlxG.play(Assets.getSound("assets/sounds/coin" + Jumper.SoundExtension), 3, false);
		Reg.score++;
	}
}