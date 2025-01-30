package flixel.ui;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.input.FlxPointer;
import flixel.input.actions.FlxActionInputAnalog;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;

/**
 * A virtual thumbstick - useful for input on mobile devices.
 */
class FlxVirtualStick extends FlxSpriteContainer
{
	/** The current state of the button */
	public final value:FlxReadOnlyPoint = FlxPoint.get();

	/** The top of the joystick, the part that moves */
	public final thumb:CircleSprite;

	/** The background of the joystick, also known as the base */
	public final base:CircleSprite;
	
	/** The radius in which the stick can move */
	public final radius:Float;
	
	/** Used to smooth the thumb's motion. Should be between 0 and 1.0. */
	public var lerp:Float = 0.25;
	
	/** The minimum absolute value, to consider this input active */
	public var deadzone = 0.1;
	
	public final onJustMove = new FlxSignal();
	public final onJustStop = new FlxSignal();
	public final onMove = new FlxSignal();
	
	public var xStatus(default, null) = FlxAnalogState.STOPPED;
	public var yStatus(default, null) = FlxAnalogState.STOPPED;
	public var status(default, null) = FlxAnalogState.STOPPED;
	
	/** Used to track press events */
	final button:InvisibleCircleButton;
	
	var dragging = false;
	
	/**
	 * Create a virtual thumbstick - useful for input on mobile devices.
	 *
	 * @param   x            The location in screen space.
	 * @param   y            The location in screen space.
	 * @param   radius       The radius where the thumb can move. If 0, half the base's width will be used.
	 * @param   baseGraphic  The graphic you want to display as base of the joystick.
	 * @param   thumbGraphic The graphic you want to display as thumb of the joystick.
	 */
	public function new(x = 0.0, y = 0.0, radius = 0.0, ?baseGraphic:FlxGraphicAsset, ?thumbGraphic:FlxGraphicAsset)
	{
		super(x, y);
		
		add(base = new CircleSprite(0, 0, baseGraphic, "base"));
		add(thumb = new CircleSprite(0, 0, thumbGraphic, "thumb"));
		
		if (radius <= 0)
			radius = base.radius;
		this.radius = radius;
		
		base.x += radius;
		base.y += radius;
		thumb.x += radius;
		thumb.y += radius;
		
		add(button = new InvisibleCircleButton(0, 0, this.radius));
		
		moves = false;
		solid = false;
		
		FlxG.watch.addFunction("stick.state", ()->button.status.toString());
		FlxG.watch.addFunction("base.x|y", ()->'${base.x} | ${base.y}');
		FlxG.watch.addFunction("thumb.x|y", ()->'${thumb.x} | ${thumb.y}');
	}
	
	override function destroy()
	{
		super.destroy();
		
		thumb.destroy();
		base.destroy();
		
		onJustMove.removeAll();
		onJustStop.removeAll();
		onMove.removeAll();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		updateValue(cast value);
		
		final adjustedLerp = FlxMath.getElapsedLerp(lerp, elapsed);
		final newX = x + radius - thumb.radius + value.x * radius;
		final newY = y + radius - thumb.radius + value.y * radius;
		thumb.x += (newX - thumb.x) * adjustedLerp;
		thumb.y += (newY - thumb.y) * adjustedLerp;
	}
	
	function updateValue(pos:FlxPoint)
	{
		final oldX = value.x;
		final oldY = value.y;
		
		if (button.justPressed)
			dragging = true;
		else if (button.released && dragging)
			dragging = false;
		
		final pos:FlxPoint = cast value;
		if (dragging)
		{
			button.calcDeltaToPointer(getCameras()[0], pos);
			pos.scale(1 / radius);
			if (pos.lengthSquared > 1.0)
				pos.normalize();
			
			if (pos.x < deadzone && pos.x > -deadzone)
				pos.x = 0;
			
			if (pos.y < deadzone && pos.y > -deadzone)
				pos.y = 0;
		}
		else
			pos.zero();
		
		xStatus = getStatus(oldX, value.x);
		yStatus = getStatus(oldY, value.y);
		
		if ((yStatus.justMoved && xStatus == STOPPED) || (xStatus.justMoved && yStatus == STOPPED))
		{
			status = JUST_MOVED;
			onJustMove.dispatch();
			onMove.dispatch();
		}
		else if ((yStatus.justStopped && xStatus.stopped) || (xStatus.justStopped && yStatus.stopped))
		{
			status = JUST_STOPPED;
			onJustStop.dispatch();
		}
		else if (xStatus.moved || yStatus.moved)
		{
			status = MOVED;
			onMove.dispatch();
		}
		else
		{
			status = STOPPED;
		}
	}
	
	function getStatus(prev:Float, curr:Float)
	{
		return if (prev == 0 && curr != 0)
			JUST_MOVED;
		else if (prev != 0 && curr != 0)
			MOVED;
		else if (prev != 0 && curr == 0)
			JUST_STOPPED;
		else if (prev == 0 && curr == 0)
			STOPPED;
		else
			throw 'Unexpected case - prev: $prev, curr:$curr';// not possible
	}
}

@:forward
@:forward.new
abstract CircleSprite(FlxSprite) to FlxSprite
{
	public var radius(get, never):Float;
	public var radiusSquared(get, never):Float;
	
	public function new (centerX = 0.0, centerY = 0.0, graphic, ?backupId:String)
	{
		this = new FlxSprite(centerX, centerY, graphic);
		if (graphic == null)
		{
			this.frames = FlxAssets.getVirtualInputFrames();
			this.animation.frameName = backupId;
			this.resetSizeFromFrame();
		}
		this.x -= radius;
		this.y -= radius;
		this.moves = false;
		
		#if FLX_DEBUG
		// this.ignoreDrawDebug = true;
		#end
	}
	
	inline function get_radius() return this.frameWidth * 0.5;
	inline function get_radiusSquared() return radius * radius;
}

/**
 * Special button that covers the virtual stick and tracks mouse and touch
 */
class InvisibleCircleButton extends FlxTypedButton<FlxSprite>
{
	public var radius(get, never):Float;
	public var lastPointer(default, null):Null<FlxPointer>;
	
	inline function get_radius():Float return frameWidth * 0.5;
	
	public function new (x = 0.0, y = 0.0, radius:Float, ?onClick)
	{
		super(x, y, onClick);
		final size = Math.ceil(radius * 2);
		loadGraphic(FlxG.bitmap.create(size, size * 4, FlxColor.WHITE), true, size, size);
	}
	
	override function draw()
	{
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
	
	override function checkInput(pointer, input, justPressedPosition, camera):Bool
	{
		if (super.checkInput(pointer, input, justPressedPosition, camera))
		{
			lastPointer = pointer;
			return true;
		}
		
		return false;
	}
	
	override function updateButton()
	{
		if (currentInput != null)
		{
			if (currentInput.justReleased)
				onUpHandler();
			return;
		}
		
		super.updateButton();
	}
	
	override function onUpHandler()
	{
		super.onUpHandler();
		lastPointer = null;
	}
	
	override function overlapsPoint(point:FlxPoint, inScreenSpace = false, ?camera:FlxCamera):Bool
	{
		if (!inScreenSpace)
			return point.distanceSquaredTo(x + radius, y + radius) < radius * radius;

		if (camera == null)
			camera = getCameras()[0];
		
		return calcDeltaTo(point, camera, _point).lengthSquared < radius * radius;
	}
	
	public function calcDeltaTo(point:FlxPoint, camera:FlxCamera, ?result:FlxPoint)
	{
		if (result == null)
			result = FlxPoint.get();
		 
		final xPos = point.x - camera.scroll.x - radius;
		final yPos = point.y - camera.scroll.y - radius;
		getScreenPosition(result, camera);
		point.putWeak();
		return result.subtract(xPos, yPos).negate();
	}
	
	public function calcDeltaToPointer(camera:FlxCamera, ?result:FlxPoint)
	{
		final point = lastPointer.getViewPosition(camera, FlxPoint.weak());
		return calcDeltaTo(point, camera, result);
	}
}