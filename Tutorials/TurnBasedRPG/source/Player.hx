package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;

class Player extends FlxSprite
{
	public var speed:Float = 200;
	private var _sndStep:FlxSound;
	
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.player__png, true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		drag.x = drag.y = 1600;
		setSize(8, 14);
		offset.set(4, 2);
		
		_sndStep = FlxG.sound.load(AssetPaths.step__wav);
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		
		#if FLX_KEYBOARD
		_up = FlxG.keys.anyPressed([UP, W]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, A]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
		#end
		#if mobile
		var virtualPad = PlayState.virtualPad;
		_up = _up || virtualPad.buttonUp.pressed;
		_down = _down || virtualPad.buttonDown.pressed;
		_left  = _left || virtualPad.buttonLeft.pressed;
		_right = _right || virtualPad.buttonRight.pressed;
		#end
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
		
		if ( _up || _down || _left || _right)
		{
			var mA:Float = 0;
			if (_up)
			{
				mA = -90;
				if (_left)
					mA -= 45;
				else if (_right)
					mA += 45;
					
				facing = FlxObject.UP;
			}
			else if (_down)
			{
				mA = 90;
				if (_left)
					mA += 45;
				else if (_right)
					mA -= 45;
				
				facing = FlxObject.DOWN;
			}
			else if (_left)
			{
				mA = 180;
				facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				mA = 0;
				facing = FlxObject.RIGHT;
			}
			
			velocity.set(speed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), mA);
			
			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			{
				_sndStep.play();
				
				switch (facing)
				{
					case FlxObject.LEFT, FlxObject.RIGHT:
						animation.play("lr");
						
					case FlxObject.UP:
						animation.play("u");
						
					case FlxObject.DOWN:
						animation.play("d");
				}
			}
		}
		else if (animation.curAnim != null)
		{
			animation.curAnim.curFrame = 0;
			animation.curAnim.pause();
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		movement();
		super.update(elapsed);
	}
}
