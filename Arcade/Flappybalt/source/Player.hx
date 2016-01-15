package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	public function new()
	{
		super(FlxG.width * 0.5 - 4, FlxG.height * 0.5 - 4);
		loadGraphic("assets/dove.png", true);
		animation.frameIndex = 2;
		animation.add("flap",[1,0,1,2],12,false);
	}
	
	override public function update(elapsed:Float)
	{
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justPressed.SPACE)
		#elseif !FLX_NO_TOUCH
		if (FlxG.touches.justStarted().length > 0)
		#end
		{
			if (acceleration.y == 0)
			{
				acceleration.y = 500;
				velocity.x = 80;
			}
			
			velocity.y = -240;
			
			animation.play("flap", true);
		}
		
		super.update(elapsed);
	}
	
	override public function kill():Void
	{
		if (!exists)
			return;
		
		Reg.PS.launchFeathers(x, y, 10);
		
		super.kill();
		
		FlxG.camera.flash(0xffFFFFFF, 1, onFlashDone);
		FlxG.camera.shake(0.02, 0.35);
	}
	
	override public function revive():Void
	{
		x = FlxG.width * 0.5 - 4;
		y = FlxG.height * 0.5 - 4;
		acceleration.x = 0;
		acceleration.y = 0;
		velocity.x = 0;
		velocity.y = 0;
		
		super.revive();
	}
	
	public function onFlashDone():Void
	{
		PlayState.saveScore();
		revive();
		Reg.PS.reset();
	}
}