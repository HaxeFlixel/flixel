package;

import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxAction;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
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
	
	static var actions:FlxActionManager;
	static var FIRE_RATE:Float = 1 / 10; // 10 shots per second
	
	public var isReadyToJump:Bool = true;
	public var flickering:Bool = false;
	
	var _shootTimer = new FlxTimer();
	var _jumpPower:Int = 200;
	var _aim:Int = FlxObject.RIGHT;
	var _gibs:FlxEmitter;
	var _bullets:FlxTypedGroup<Bullet>;

	var _up:FlxActionDigital;
	var _down:FlxActionDigital;
	var _left:FlxActionDigital;
	var _right:FlxActionDigital;
	var _shoot:FlxActionDigital;
	var _jump:FlxActionDigital;
	
	/**
	 * This is the player object class.  Most of the comments I would put in here
	 * would be near duplicates of the Enemy class, so if you're confused at all
	 * I'd recommend checking that out for some ideas!
	 */
	public function new(x:Int, y:Int, bullets:FlxTypedGroup<Bullet>, gibs:FlxEmitter)
	{
		super(x, y);
		
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
		_bullets = bullets;
		_gibs = gibs;

		_up = new FlxActionDigital()
			.addGamepad(DPAD_UP, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_UP, PRESSED)
			.addKey(UP, PRESSED)
			.addKey(W, PRESSED);

		_down = new FlxActionDigital()
		 	.addGamepad(DPAD_DOWN, PRESSED)
		 	.addGamepad(LEFT_STICK_DIGITAL_DOWN, PRESSED)
		 	.addKey(DOWN, PRESSED)
		 	.addKey(S, PRESSED);

		_left = new FlxActionDigital()
			.addGamepad(DPAD_LEFT, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED)
			.addKey(LEFT, PRESSED)
			.addKey(A, PRESSED);

		_right = new FlxActionDigital()
			.addGamepad(DPAD_RIGHT, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED)
			.addKey(RIGHT, PRESSED)
			.addKey(D, PRESSED);

		_jump = new FlxActionDigital()
			.addGamepad(A, JUST_PRESSED)
			.addKey(X, JUST_PRESSED);

		_shoot = new FlxActionDigital()
			.addGamepad(X, PRESSED)
			.addKey(C, PRESSED);

		#if VIRTUAL_PAD
		virtualPad = new FlxVirtualPad(FULL, A_B);
		virtualPad.alpha = 0.5;

		_up.addInput(virtualPad.buttonUp, PRESSED);
		_down.addInput(virtualPad.buttonDown, PRESSED);
		_left.addInput(virtualPad.buttonLeft, PRESSED);
		_right.addInput(virtualPad.buttonRight, PRESSED);
		_jump.addInput(virtualPad.buttonA, JUST_PRESSED);
		_shoot.addInput(virtualPad.buttonB, PRESSED);
		#end

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([_up, _down, _left, _right, _jump, _shoot]);
	}

	override public function update(elapsed:Float):Void
	{
		acceleration.x = 0;
		updateInput();
		updateAnimations();
		super.update(elapsed);
	}

	function updateInput()
	{
		if (_left.triggered)
			moveLeft();
		else if (_right.triggered)
			moveRight();

		if (_up.triggered)
			moveUp();
		else if (_down.triggered)
			moveDown();
		
		if (_jump.triggered)
			jump();
		if (_shoot.triggered)
			shoot();
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
	
	override public function hurt(damage:Float):Void
	{
		damage = 0;
		
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
		
		super.hurt(damage);
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

	override public function destroy():Void
	{
		super.destroy();
		
		#if VIRTUAL_PAD
		virtualPad = FlxDestroyUtil.destroy(virtualPad);
		#end
		
		_bullets = null;
		_gibs = null;
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
