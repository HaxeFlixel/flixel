package;

import nme.Assets;
import org.flixel.FlxButton;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

class Player extends FlxSprite
{
	private var _jumpPower:Int;
	private var _bullets:FlxGroup;
	private var _aim:Int;
	private var _restart:Float;
	private var _gibs:FlxEmitter;
	
	public var isReadyToJump:Bool;
	
	//This is the player object class.  Most of the comments I would put in here
	//would be near duplicates of the Enemy class, so if you're confused at all
	//I'd recommend checking that out for some ideas!
	public function new(X:Int, Y:Int, Bullets:FlxGroup, Gibs:FlxEmitter)
	{
		super(X,Y);
		loadGraphic("assets/spaceman.png", true, true, 8);
	//	updateTileSheet();
		_restart = 0;
		
		//bounding box tweaks
		width = 6;
		height = 7;
		offset.x = 1;
		offset.y = 1;
		
		//basic player physics
		var runSpeed:Int = 80;
		drag.x = runSpeed * 8;
		acceleration.y = 420;
		_jumpPower = 200;
		maxVelocity.x = runSpeed;
		maxVelocity.y = _jumpPower;
		
		//animations
		addAnimation("idle", [0]);
		addAnimation("run", [1, 2, 3, 0], 12);
		addAnimation("jump", [4]);
		addAnimation("idle_up", [5]);
		addAnimation("run_up", [6, 7, 8, 5], 12);
		addAnimation("jump_up", [9]);
		addAnimation("jump_down", [10]);
		
		//bullet stuff
		_bullets = Bullets;
		_gibs = Gibs;
		
		isReadyToJump = true;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		_bullets = null;
		_gibs = null;
	}
	
	override public function update():Void
	{
		//game restart timer
		if(!alive)
		{
			_restart += FlxG.elapsed;
			if(_restart > 2)
			{
				FlxG.resetState();
			}
			return;
		}
		
		//make a little noise if you just touched the floor
		if(justTouched(FlxObject.FLOOR) && (velocity.y > 50))
		{
			if (Mode.SoundOn)
			{
				FlxG.play(Assets.getSound("assets/land" + Mode.SoundExtension));
			}
		}
		
		//MOVEMENT
		acceleration.x = 0;
		if(FlxG.keys.LEFT || PlayState.LeftButton.status == FlxButton.PRESSED)
	//	if(FlxG.keys.LEFT || PlayStateOld.LeftButton.status == FlxButton.PRESSED)
		{
			facing = FlxObject.LEFT;
			acceleration.x -= drag.x;
		}
		else if(FlxG.keys.RIGHT || PlayState.RightButton.status == FlxButton.PRESSED)
	//	else if(FlxG.keys.RIGHT || PlayStateOld.RightButton.status == FlxButton.PRESSED)
		{
			facing = FlxObject.RIGHT;
			acceleration.x += drag.x;
		}
		
		if((FlxG.keys.justPressed("X") || (PlayState.JumpButton.status == FlxButton.PRESSED && isReadyToJump)) && velocity.y == 0)
	//	if((FlxG.keys.justPressed("X") || (PlayStateOld.JumpButton.status == FlxButton.PRESSED && isReadyToJump)) && velocity.y == 0)
		{
			velocity.y = -_jumpPower;
			if (Mode.SoundOn)
			{
				FlxG.play(Assets.getSound("assets/jump" + Mode.SoundExtension));
			}
		}
		
		if (PlayState.JumpButton.status == FlxButton.PRESSED && isReadyToJump)
	//	if (PlayStateOld.JumpButton.status == FlxButton.PRESSED && isReadyToJump)
		{
			isReadyToJump = false;
		}
		else if (PlayState.JumpButton.status == FlxButton.NORMAL)
	//	else if (PlayStateOld.JumpButton.status == FlxButton.NORMAL)
		{
			isReadyToJump = true;
		}
		
		//AIMING
		if(FlxG.keys.UP)
		{
			_aim = FlxObject.UP;
		}
		else if(FlxG.keys.DOWN && velocity.y != 0)
		{
			_aim = FlxObject.DOWN;
		}
		else
			_aim = facing;
		
		//ANIMATION
		if(velocity.y != 0)
		{
			if(_aim == FlxObject.UP) play("jump_up");
			else if(_aim == FlxObject.DOWN) play("jump_down");
			else play("jump");
		}
		else if(velocity.x == 0)
		{
			if(_aim == FlxObject.UP) play("idle_up");
			else play("idle");
		}
		else
		{
			if(_aim == FlxObject.UP) play("run_up");
			else play("run");
		}
		
		//SHOOTING
		if(FlxG.keys.justPressed("C"))
		{
			if(flickering)
			{
				if (Mode.SoundOn)
				{
					FlxG.play(Assets.getSound("assets/jam" + Mode.SoundExtension));
				}
			}
			else
			{
				getMidpoint(_point);
				cast(_bullets.recycle(Bullet), Bullet).shoot(_point, _aim);
				if(_aim == FlxObject.DOWN)
				{
					velocity.y -= 36;
				}
			}
		}
	}
	
	override public function hurt(Damage:Float):Void
	{
		Damage = 0;
		if(flickering)
		{
			return;
		}
		if (Mode.SoundOn)
		{
			FlxG.play(Assets.getSound("assets/hurt" + Mode.SoundExtension));
		}
		
		flicker(1.3);
		if(FlxG.score > 1000) FlxG.score -= 1000;
		if(velocity.x > 0)
		{
			velocity.x = -maxVelocity.x;
		}
		else
		{
			velocity.x = maxVelocity.x;
		}
		super.hurt(Damage);
	}
	
	override public function kill():Void
	{
		if(!alive)
		{
			return;
		}
		solid = false;
		if (Mode.SoundOn)
		{
			FlxG.play(Assets.getSound("assets/asplode" + Mode.SoundExtension));
			FlxG.play(Assets.getSound("assets/menu_hit_2" + Mode.SoundExtension));
		}
		
		super.kill();
		flicker(0);
		exists = true;
		visible = false;
		velocity.make();
		acceleration.make();
		FlxG.camera.shake(0.005, 0.35);
		#if !neko
		FlxG.camera.flash(0xffd8eba2, 0.35);
		#else
		FlxG.camera.flash({rgb: 0xd8eba2, a: 0xff}, 0.35);
		#end
		if(_gibs != null)
		{
			_gibs.at(this);
			_gibs.start(true, 5, 0, 50);
		}
	}
}