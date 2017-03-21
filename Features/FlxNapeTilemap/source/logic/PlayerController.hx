package logic;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import nape.geom.Vec2;
import nape.phys.Body;
using logic.PhysUtil;

class PlayerController extends FlxBasic
{
	inline static var MAX_JUMPS = 2;

	var playerBody:Body;
	var levelBody:Body;
	var onGround:Bool;
	var impulseGround:Float;
	var impulseAir:Float;
	var impulseJump:Float;
	var remainingJumps:Int;
	var maxJumps:Int;
	var keyMap:PlayerControls;

	public function new(playerBody:Body, levelBody:Body, keyMap:PlayerControls,
		impulseGround:Float = 500, impulseAir:Float = 200, impulseJump:Float = 200)
	{
		super();
		this.playerBody = playerBody;
		this.levelBody = levelBody;
		this.impulseGround = impulseGround;
		this.impulseAir = impulseAir;
		this.impulseJump = impulseJump;
		this.keyMap = keyMap;
	}

	override public function update(elapsed:Float)
	{
		var impulseVec = new Vec2();
		onGround = playerBody.onTop();
        
		var impulse = if (onGround) impulseGround else impulseAir;
		var totalX = 0.0;
		if (FlxG.keys.anyPressed(keyMap.leftKeys))
			totalX = -impulse;
		else if (FlxG.keys.anyPressed(keyMap.rightKeys))
			totalX = impulse;
		else
			totalX = 0;
		impulseVec.x = totalX * elapsed;
		if (onGround)
			remainingJumps = MAX_JUMPS;

		if (FlxG.keys.anyJustPressed(keyMap.jumpKeys) && remainingJumps > 0)
		{
			impulseVec.y = -impulseJump;
			remainingJumps--;
		}
		playerBody.applyImpulse(impulseVec);
	}
}

class PlayerControls
{
	public var leftKeys(default, null):Array<FlxKey>;
	public var rightKeys(default, null):Array<FlxKey>;
	public var jumpKeys(default, null):Array<FlxKey>;

	public function new(leftKeys:Array<FlxKey>, rightKeys:Array<FlxKey>, jumpKeys:Array<FlxKey>)
	{
		this.leftKeys = leftKeys;
		this.rightKeys = rightKeys;
		this.jumpKeys = jumpKeys;
	}
}