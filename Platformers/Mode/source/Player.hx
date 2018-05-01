package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.system.FlxAssets;

#if VIRTUAL_PAD
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxDestroyUtil;
#end

class Player extends FlxSprite
{
	#if VIRTUAL_PAD
	public static var virtualPad:FlxVirtualPad;
	#end
	
	static var FIRE_RATE:Float = 1 / 10; // 10 shots per second
	
	public var isReadyToJump:Bool = true;
	public var flickering:Bool = false;
	
	var _shootTimer = new FlxTimer();
	var _jumpPower:Int = 200;
	var _aim:Int = FlxObject.RIGHT;
	var _gibs:FlxEmitter;
	var _bullets:FlxTypedGroup<Bullet>;
	
	/**
	 * This is the player object class.  Most of the comments I would put in here
	 * would be near duplicates of the Enemy class, so if you're confused at all
	 * I'd recommend checking that out for some ideas!
	 */
	public function new(X:Int, Y:Int, Bullets:FlxTypedGroup<Bullet>, Gibs:FlxEmitter)
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.spaceman__png, true, 8);
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		// Bounding box tweaks
		width = 6;
		height = 7;
		offset.set(1, 1);
		
		// Basic player physics
		var runSpeed:Int = 80;
		drag.x = runSpeed * 8;
		acceleration.y = 420;
		maxVelocity.set(runSpeed, _jumpPower);
		
		// Animations
		animation.add(Animation.IDLE, [0]);
		animation.add(Animation.IDLE_UP, [5]);

		animation.add(Animation.RUN, [1, 2, 3, 0], 12);
		animation.add(Animation.RUN_UP, [6, 7, 8, 5], 12);
		
		animation.add(Animation.JUMP, [4]);
		animation.add(Animation.JUMP_UP, [9]);
		animation.add(Animation.JUMP_DOWN, [10]);
		
		// Bullet stuff
		_bullets = Bullets;
		_gibs = Gibs;
		
		#if VIRTUAL_PAD
		virtualPad = new FlxVirtualPad(FULL, A_B);
		virtualPad.alpha = 0.5;
		#end
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		#if VIRTUAL_PAD
		virtualPad = FlxDestroyUtil.destroy(virtualPad);
		#end
		
		_bullets = null;
		_gibs = null;
	}
	
	override public function update(elapsed:Float):Void
	{
		acceleration.x = 0;
		
		updateKeyboardInput();
		updateGamepadInput();
		updateVirtualPadInput();
		
		updateAnimations();
		
		super.update(elapsed);
	}
	
	function updateKeyboardInput():Void
	{
		#if FLX_KEYBOARD
		if (FlxG.keys.anyPressed([A, LEFT]))
			moveLeft();
		else if (FlxG.keys.anyPressed([D, RIGHT]))
			moveRight();
		
		if (FlxG.keys.anyPressed([W, UP]))
			moveUp();
		else if (FlxG.keys.anyPressed([S, DOWN]))
			moveDown();
		
		if (FlxG.keys.pressed.X)
			jump();
		if (FlxG.keys.pressed.C)
			shoot();
		#end
	}
	
	function updateVirtualPadInput():Void
	{
		#if VIRTUAL_PAD
		if (virtualPad.buttonLeft.pressed)
			moveLeft();
		else if (virtualPad.buttonRight.pressed)
			moveRight();
		
		if (virtualPad.buttonUp.pressed)
			moveUp();
		else if (virtualPad.buttonDown.pressed)
			moveDown();
		
		if (virtualPad.buttonA.justPressed)
			jump();
		if (virtualPad.buttonB.pressed)
			shoot();
		#end
	}
	
	function updateGamepadInput():Void
	{
		#if FLX_GAMEPAD
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad == null)
			return;
		
		if (gamepad.analog.value.LEFT_STICK_X < 0 || gamepad.pressed.DPAD_LEFT)
			moveLeft();
		else if (gamepad.analog.value.LEFT_STICK_X > 0 || gamepad.pressed.DPAD_RIGHT)
			moveRight();
		
		if (gamepad.analog.value.LEFT_STICK_Y < 0 || gamepad.pressed.DPAD_UP)
			moveUp();
		else if (gamepad.analog.value.LEFT_STICK_Y > 0 || gamepad.pressed.DPAD_DOWN)
			moveDown();
		
		if (gamepad.justPressed.A)
			jump();
		
		if (gamepad.pressed.X)
			shoot();
		#end
	}
	
	function updateAnimations():Void
	{
		if (velocity.y != 0)
		{
			animation.play(switch (_aim)
			{
				case FlxObject.UP: Animation.JUMP_UP;
				case FlxObject.DOWN: Animation.JUMP_DOWN;
				default: Animation.JUMP;

			});
		}
		else if (velocity.x == 0)
		{
			animation.play(if (_aim == FlxObject.UP) Animation.IDLE_UP else Animation.IDLE);
		}
		else
		{
			animation.play(if (_aim == FlxObject.UP) Animation.RUN_UP else Animation.RUN);
		}
	}
	
	override public function hurt(Damage:Float):Void
	{
		Damage = 0;
		
		if (flickering)
			return;
		
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/hurt"));
		
		flicker(1.3);
		
		if (Reg.score > 1000) 
			Reg.score -= 1000;
		
		if (velocity.x > 0)
			velocity.x = -maxVelocity.x;
		else
			velocity.x = maxVelocity.x;
		
		super.hurt(Damage);
	}
	
	function flicker(Duration:Float):Void
	{
		FlxSpriteUtil.flicker(this, Duration, 0.02, true, true, function(_)
		{
			flickering = false;
		});
		flickering = true;
	}
	
	override public function kill():Void
	{
		if (!alive)
			return;
		
		solid = false;
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/asplode"));
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit_2"));
		
		super.kill();
		
		exists = true;
		active = false;
		visible = false;
		moves = false;
		velocity.set();
		acceleration.set();
		FlxG.camera.shake(0.005, 0.35);
		FlxG.camera.flash(0xffd8eba2, 0.35);
		
		if (_gibs != null)
		{
			_gibs.focusOn(this);
			_gibs.start(true, 0, 50);
		}
		
		new FlxTimer().start(2, function(_)
		{
			FlxG.resetState();
		});
	}
	
	function moveLeft():Void
	{
		facing = _aim = FlxObject.LEFT;
		acceleration.x -= drag.x;
	}
	
	function moveRight():Void
	{
		facing = _aim = FlxObject.RIGHT;
		acceleration.x += drag.x;
	}
	
	function moveUp():Void
	{
		_aim = FlxObject.UP;
	}
	
	function moveDown():Void
	{
		_aim = FlxObject.DOWN;
	}
	
	function jump():Void
	{
		if (isReadyToJump && (velocity.y == 0))
		{
			velocity.y = -_jumpPower;
			FlxG.sound.play(FlxAssets.getSound("assets/sounds/jump"));
		}
	}
	
	function shoot():Void
	{
		if (_shootTimer.active)
			return;
		_shootTimer.start(FIRE_RATE);
		
		if (flickering)
		{
			FlxG.sound.play(FlxAssets.getSound("assets/sounds/jam"));
		}
		else
		{
			getMidpoint(_point);
			_bullets.recycle(Bullet.new).shoot(_point, _aim);
			
			if (_aim == FlxObject.DOWN)
			{
				velocity.y -= 36;
			}
		}
	}
}

@:enum abstract Animation(String) to String
{
	var IDLE = "idle";
	var IDLE_UP = "idle_up";

	var JUMP = "jump";
	var JUMP_UP = "jump_up";
	var JUMP_DOWN = "jump_down";

	var RUN = "run";
	var RUN_UP = "run_up";
}