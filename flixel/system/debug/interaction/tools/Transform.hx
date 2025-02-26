package flixel.system.debug.interaction.tools;

import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.debug.Icon;
import flixel.system.debug.Tooltip;
import flixel.system.debug.interaction.Interaction;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.LineScaleMode;
import openfl.geom.Point;

using flixel.util.FlxArrayUtil;

/**
 * A tool to scale and rotate selected game elements.
 *
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Transform extends Tool
{
	var state = State.IDLE;
	final tooltip:TransformTooltip = new TransformTooltip();
	var markers:Array<Marker> = [];
	
	override function init(brain:Interaction):Tool
	{
		markers.resize(0);
		markers.push(new Marker(ROTATE, true, true));
		markers.push(new Marker(SCALE_X, false, true));
		markers.push(new Marker(SCALE_XY, false, false));
		markers.push(new Marker(SCALE_Y, true, false));
		
		super.init(brain);
		
		_name = "Transform";
		setButton(Icon.transform);
		setCursor(Icon.transform);
		
		brain.registerCustomCursor(ROTATE, Icon.rotate, -5, -5);
		brain.registerCustomCursor(SCALE_X, Icon.scaleX, -5, -5);
		brain.registerCustomCursor(SCALE_Y, Icon.scaleY, -5, -5);
		brain.registerCustomCursor(SCALE_XY, Icon.scaleXY, -5, -5);
		
		FlxG.signals.preStateSwitch.add(function()
		{
			tooltip.hide();
			state = IDLE;
		});
		
		return this;
	}
	
	override function activate():Void
	{
		if (_brain.selectedItems.length == 0)
			return;
		
		for (member in _brain.selectedItems)
		{
			if (member != null && member.scrollFactor != null && member.isOnScreen())
			{
				// Allow only a single element to be worked on. Working with multiple
				// elements at once requires some further thoughts and love.
				final target:FlxSprite = cast member;
				state = SELECTED(target);
				
				for (marker in markers)
					marker.reposition(target);
				
				break;
			}
		}
		
		_brain.shouldDrawItemsSelection = false;
	}
	
	override function deactivate():Void
	{
		state = IDLE;
		_brain.shouldDrawItemsSelection = true;
	}
	
	/**
	 * Start an interaction with a marker. Depending on the marker being used, the interaction
	 * can be to resize or rotate something.
	 */
	function startAction(type:TransformType):Void
	{
		final target = switch state
		{
			case SELECTED(target): target;
			case found: throw 'Unexpected state: $found';
		}
		
		final action = switch(type)
		{
			case ROTATE: SET_ANGLE(target.angle);
			case SCALE_X: SET_SCALE_X(target.scale.x);
			case SCALE_Y: SET_SCALE_Y(target.scale.y);
			case SCALE_XY: SET_SCALE_XY(target.scale.x, target.scale.y);
		}
		
		state = TRANSFORM(target, action, _brain.flixelPointer.x, _brain.flixelPointer.y);
		
		final camera = target.getDefaultCamera();
		this.x = _brain.toDebugX(target.x + target.origin.x, camera);
		this.y = _brain.toDebugY(target.y + target.origin.y, camera);
		tooltip.show(x, y);
	}
	
	function checkMarkers():Void
	{
		final mouse = _brain.flixelPointer;
		
		var closest:Marker = null;
		var closestDist = Marker.MOUSE_RADIUS;
		for (marker in markers)
		{
			final dist = mouse.dist(marker.x, marker.y);
			if (closestDist > dist)
			{
				closestDist - dist;
				closest = marker;
			}
		}
		
		if (closest != null)
		{
			setCursorInUse(closest.type);
			if (_brain.pointerJustPressed)
				startAction(closest.type);
		}
		else
			useDefaultCursor();
	}
	
	override function update():Void
	{
		if (!isActive())
			return;
		
		switch state
		{
			case IDLE:
			case SELECTED(target):
				checkMarkers();
			case TRANSFORM(target, type, mouseStartX, mouseStartY):
				final mouseStart = FlxPoint.get(mouseStartX, mouseStartY)
					.subtract(target.x + target.origin.x, target.y + target.origin.y);
				final mouse = _brain.flixelPointer.copyTo()
					.subtract(target.x + target.origin.x, target.y + target.origin.y);
				
				inline function cos(degrees:Float) return Math.cos(FlxAngle.TO_RAD * degrees);
				inline function sin(degrees:Float) return Math.sin(FlxAngle.TO_RAD * degrees);
				inline function int(num:Float) return Std.int(num);
				function dec(num:Float, dec = 2)
				{
					final prefix = (num > 0 ? "" : "-") + (num < 1.0 ? "0" : "");
					final digits = Std.string(int((num < 0 ? -num : num) * Math.pow(10, dec)));
					return prefix + digits.substr(0, -dec) + "." + digits.substr(-dec, dec);
				}
				
				switch type
				{
					case SET_ANGLE(startValue):
						target.angle = mouse.degrees - mouseStart.degrees + startValue;
						
						tooltip.setText('deg: ${dec(target.angle, 1)}\n rad: ${dec(target.angle * FlxAngle.TO_RAD, 2)}');
						
					case SET_SCALE_X(startValue):
						final oldProjX = mouseStart.length * cos(target.angle - mouseStart.degrees);
						final projX = mouse.length * cos(target.angle - mouse.degrees);
						
						target.scale.x = projX / oldProjX * startValue;
						
						tooltip.setText('scale.x: ${dec(target.scale.x)}\n height: ${int(target.scale.x * target.frameWidth)}');
						
					case SET_SCALE_Y(startValue):
						final oldProjY = mouseStart.length * sin(target.angle - mouseStart.degrees);
						final projY = mouse.length * sin(target.angle - mouse.degrees);
						target.scale.y = projY / oldProjY * startValue;
						
						tooltip.setText('scale.y: ${dec(target.scale.y)}\n height: ${int(target.scale.y * target.frameHeight)}');
						
					case SET_SCALE_XY(startValueX, startValueY):
						final oldLen = mouseStart.length;
						final oldDeg = mouseStart.degrees;
						final oldProjX = oldLen * cos(target.angle - oldDeg);
						final oldProjY = oldLen * sin(target.angle - oldDeg);
						final len = mouse.length;
						final deg = mouse.degrees;
						final projX = len * cos(target.angle - deg);
						final projY = len * sin(target.angle - deg);
						
						target.scale.x = projX / oldProjX * startValueX;
						target.scale.y = projY / oldProjY * startValueY;
						final info = 'scale - { x: ${dec(target.scale.x)} | y: ${dec(target.scale.y, 2)} }\n'
							+ 'size   - { x: ${int(target.scale.x * target.frameWidth)} | y: ${int(target.scale.y * target.frameHeight)} }';
						tooltip.setText(info);
				}
				mouseStart.put();
				mouse.put();
				
				for (marker in markers)
					marker.reposition(target);
				
				if (_brain.pointerJustReleased)
				{
					state = SELECTED(target);
					tooltip.hide();
				}
		}
	}
	
	override function draw():Void
	{
		if (!isActive())
			return;
		
		final target = switch state
		{
			case IDLE:
				return;
			case SELECTED(target):
				target;
			case TRANSFORM(target, _, _, _):
				target;
		}
		
		final gfx = _brain.getDebugGraphics();
		if (gfx == null)
			return;
		
		drawSelection(gfx, target.getDefaultCamera());
		Marker.draw(target.x + target.origin.x, target.y + target.origin.y, false, gfx);
		
		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	
	function drawSelection(gfx:Graphics, camera:FlxCamera)
	{
		gfx.lineStyle(1.0, FlxColor.MAGENTA, 1.0, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
		
		// draw lines
		gfx.moveTo(markers[3].x, markers[3].y);
		for (marker in markers)
			gfx.lineTo(marker.x, marker.y);
		
		// draw markers
		for (marker in markers)
		{
			final x = marker.x;
			final y = marker.y;
			Marker.draw(x, y, marker.type == ROTATE, gfx);
		}
	}
}

private class Marker
{
	public static inline var MOUSE_RADIUS = 10;
	
	static inline var BUFFER = 2;
	static inline var CIRCLE_RADIUS = 5;
	static inline var RECT_MARGIN = 2;
	static inline var RECT_SIZE = RECT_MARGIN * 2 + 1;
	
	public var x:Float = 0;
	public var y:Float = 0;
	public final type:TransformType;
	public final left:Bool;
	public final up:Bool;
	
	public function new (type:TransformType, left:Bool, up:Bool)
	{
		this.type = type;
		this.left = left;
		this.up = up;
	}
	
	public function reposition(target:FlxSprite)
	{
		final w = target.frameWidth * target.scale.x * 0.5;
		final h = target.frameHeight * target.scale.y * 0.5;
		final rot = FlxPoint.get((left ? -w : w), (up ? -h : h));
		rot.degrees += target.angle;
		rot.length += BUFFER;
		x = target.x + target.origin.x + rot.x;
		y = target.y + target.origin.y + rot.y;
		rot.put();
	}
	
	public static function draw(screenX:Float, screenY:Float, circle:Bool, gfx:Graphics)
	{
		gfx.beginFill(FlxColor.MAGENTA);
		if (circle)
			gfx.drawCircle(screenX, screenY, CIRCLE_RADIUS);
		else
			gfx.drawRect(screenX - RECT_MARGIN, screenY - RECT_MARGIN, RECT_SIZE, RECT_SIZE);
		gfx.endFill();
	}
}

@:forward(setText)
private abstract TransformTooltip(TooltipOverlay) to TooltipOverlay
{
	public inline function new ()
	{
		this = Tooltip.add(null, "");
		this.textField.wordWrap = false;
		this.visible = false;
	}
	
	public function show(x:Float, y:Float)
	{
		this.setVisible(true);
		this.x = x;
		this.y = y;
	}
	
	public inline function hide()
	{
		this.setVisible(false);
	}
}

private enum abstract TransformType(String) to String
{
	var ROTATE = "transformRotate";
	var SCALE_X = "transformScaleX";
	var SCALE_Y = "transformScaleY";
	var SCALE_XY = "transformScaleXY";
}

private enum State
{
	IDLE;
	SELECTED(target:FlxSprite);
	TRANSFORM(target:FlxSprite, action:TransformAction, startMouseX:Float, startMouseY:Float);
}

private enum TransformAction
{
	SET_ANGLE(start:Float);
	SET_SCALE_X(start:Float);
	SET_SCALE_Y(start:Float);
	SET_SCALE_XY(startX:Float, startY:Float);
}