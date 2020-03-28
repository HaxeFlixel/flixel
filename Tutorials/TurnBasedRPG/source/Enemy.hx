package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;

using flixel.util.FlxSpriteUtil;

enum EnemyType
{
	REGULAR;
	BOSS;
}

class Enemy extends FlxSprite
{
	static inline var SPEED:Float = 140;

	var brain:FSM;
	var idleTimer:Float;
	var moveDirection:Float;
	var stepSound:FlxSound;

	public var type(default, null):EnemyType;
	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;

	public function new(x:Float, y:Float, type:EnemyType)
	{
		super(x, y);
		this.type = type;
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
		loadGraphic(graphic, true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		drag.x = drag.y = 10;
		width = 8;
		height = 14;
		offset.x = 4;
		offset.y = 2;

		brain = new FSM(idle);
		idleTimer = 0;
		seesPlayer = false;
		playerPosition = FlxPoint.get();

		stepSound = FlxG.sound.load(AssetPaths.step__wav, 0.4);
		stepSound.proximity(x, y, FlxG.camera.target, FlxG.width * 0.6);
	}

	override public function update(elapsed:Float)
	{
		if (this.isFlickering())
			return;

		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
		{
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
					facing = FlxObject.LEFT;
				else
					facing = FlxObject.RIGHT;
			}
			else
			{
				if (velocity.y < 0)
					facing = FlxObject.UP;
				else
					facing = FlxObject.DOWN;
			}

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

		if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
		{
			stepSound.setPosition(x + frameWidth / 2, y + height);
			stepSound.play();
		}

		brain.update(elapsed);
		super.update(elapsed);
	}

	function idle(elapsed:Float)
	{
		if (seesPlayer)
		{
			brain.activeState = chase;
		}
		else if (idleTimer <= 0)
		{
			if (FlxG.random.bool(1))
			{
				moveDirection = -1;
				velocity.x = velocity.y = 0;
			}
			else
			{
				moveDirection = FlxG.random.int(0, 8) * 45;

				velocity.set(SPEED * 0.5, 0);
				velocity.rotate(FlxPoint.weak(), moveDirection);
			}
			idleTimer = FlxG.random.int(1, 4);
		}
		else
			idleTimer -= elapsed;
	}

	function chase(elapsed:Float)
	{
		if (!seesPlayer)
		{
			brain.activeState = idle;
		}
		else
		{
			FlxVelocity.moveTowardsPoint(this, playerPosition, Std.int(SPEED));
		}
	}

	public function changeType(type:EnemyType)
	{
		if (this.type != type)
		{
			this.type = type;
			var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
			loadGraphic(graphic, true, 16, 16);
		}
	}
}
