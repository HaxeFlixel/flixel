package;

import flash.Lib;
import flash.display.BlendMode;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import openfl.Assets;

using flixel.util.FlxSpriteUtil;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class PlayState extends FlxState
{
	// Demo arena boundaries
	static var LEVEL_MIN_X:Float;
	static var LEVEL_MAX_X:Float;
	static var LEVEL_MIN_Y:Float;
	static var LEVEL_MAX_Y:Float;

	var orb:Orb;
	var orbShadow:FlxSprite;
	var hud:HUD;
	var hudCam:FlxCamera;
	var overlayCamera:FlxCamera;
	var deadzoneOverlay:FlxSprite;

	override public function create():Void
	{
		FlxNapeSpace.init();

		LEVEL_MIN_X = -FlxG.stage.stageWidth / 2;
		LEVEL_MAX_X = FlxG.stage.stageWidth * 1.5;
		LEVEL_MIN_Y = -FlxG.stage.stageHeight / 2;
		LEVEL_MAX_Y = FlxG.stage.stageHeight * 1.5;

		super.create();

		FlxG.mouse.visible = false;

		FlxNapeSpace.velocityIterations = 5;
		FlxNapeSpace.positionIterations = 5;

		createFloorTiles();
		FlxNapeSpace.createWalls(LEVEL_MIN_X, LEVEL_MIN_Y, LEVEL_MAX_X, LEVEL_MAX_Y);
		// Walls border.
		add(new FlxSprite(-FlxG.width / 2, -FlxG.height / 2, "assets/Border.png"));

		// Player orb
		orbShadow = new FlxSprite(FlxG.width / 2, FlxG.height / 2, "assets/OrbShadow.png");
		orbShadow.centerOffsets();
		orbShadow.blend = BlendMode.MULTIPLY;

		orb = new Orb();

		add(orbShadow);
		add(orb);

		orb.shadow = orbShadow;

		// Other orbs
		for (i in 0...5)
		{
			var otherOrbShadow = new FlxSprite(100, 100, "assets/OtherOrbShadow.png");
			otherOrbShadow.centerOffsets();
			otherOrbShadow.blend = BlendMode.MULTIPLY;

			var otherOrb = new Orb();
			otherOrb.loadGraphic("assets/OtherOrb.png", true, 140, 140);
			otherOrb.createCircularBody(50);
			otherOrb.setBodyMaterial(1, 0.2, 0.4, 0.5);
			otherOrb.antialiasing = true;
			otherOrb.setDrag(1, 1);

			add(otherOrbShadow);
			add(otherOrb);

			otherOrb.shadow = otherOrbShadow;

			switch (i)
			{
				case 0:
					otherOrb.body.position.setxy(320 - 400, 240 - 400);
					otherOrb.animation.frameIndex = 0;
				case 1:
					otherOrb.body.position.setxy(320 + 400, 240 - 400);
					otherOrb.animation.frameIndex = 4;
				case 2:
					otherOrb.body.position.setxy(320 + 400, 240 + 400);
					otherOrb.animation.frameIndex = 3;
				case 3:
					otherOrb.body.position.setxy(-300, 240);
					otherOrb.animation.frameIndex = 2;
				case 4:
					otherOrb.body.position.setxy(0, 240 + 400);
					otherOrb.animation.frameIndex = 1;
			}
			otherOrb.body.velocity.setxy(FlxG.random.int(75, 150), FlxG.random.int(75, 150));
		}

		hud = new HUD();
		add(hud);

		// Camera Overlay
		deadzoneOverlay = new FlxSprite(-10000, -10000);
		deadzoneOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		deadzoneOverlay.antialiasing = true;

		overlayCamera = new FlxCamera(0, 0, 640, 720);
		overlayCamera.bgColor = FlxColor.TRANSPARENT;
		overlayCamera.follow(deadzoneOverlay);
		FlxG.cameras.add(overlayCamera);
		add(deadzoneOverlay);

		FlxG.camera.setScrollBoundsRect(LEVEL_MIN_X, LEVEL_MIN_Y, LEVEL_MAX_X + Math.abs(LEVEL_MIN_X), LEVEL_MAX_Y + Math.abs(LEVEL_MIN_Y), true);
		FlxG.camera.follow(orb, LOCKON, 1);
		drawDeadzone(); // now that deadzone is present

		hudCam = new FlxCamera(440, 0, hud.width, hud.height);
		hudCam.zoom = 1; // For 1/2 zoom out.
		hudCam.follow(hud.background, FlxCameraFollowStyle.NO_DEAD_ZONE);
		hudCam.alpha = .5;
		FlxG.cameras.add(hudCam);
	}

	function drawDeadzone()
	{
		deadzoneOverlay.fill(FlxColor.TRANSPARENT);
		var dz:FlxRect = FlxG.camera.deadzone;
		if (dz == null)
			return;

		var lineLength:Int = 20;
		var lineStyle:LineStyle = {color: FlxColor.WHITE, thickness: 3};

		// adjust points slightly so lines will be visible when at screen edges
		dz.x += lineStyle.thickness / 2;
		dz.width -= lineStyle.thickness;
		dz.y += lineStyle.thickness / 2;
		dz.height -= lineStyle.thickness;

		// Left Up Corner
		deadzoneOverlay.drawLine(dz.left, dz.top, dz.left + lineLength, dz.top, lineStyle);
		deadzoneOverlay.drawLine(dz.left, dz.top, dz.left, dz.top + lineLength, lineStyle);
		// Right Up Corner
		deadzoneOverlay.drawLine(dz.right, dz.top, dz.right - lineLength, dz.top, lineStyle);
		deadzoneOverlay.drawLine(dz.right, dz.top, dz.right, dz.top + lineLength, lineStyle);
		// Bottom Left Corner
		deadzoneOverlay.drawLine(dz.left, dz.bottom, dz.left + lineLength, dz.bottom, lineStyle);
		deadzoneOverlay.drawLine(dz.left, dz.bottom, dz.left, dz.bottom - lineLength, lineStyle);
		// Bottom Right Corner
		deadzoneOverlay.drawLine(dz.right, dz.bottom, dz.right - lineLength, dz.bottom, lineStyle);
		deadzoneOverlay.drawLine(dz.right, dz.bottom, dz.right, dz.bottom - lineLength, lineStyle);
	}

	public function setZoom(zoom:Float)
	{
		FlxG.camera.zoom = FlxMath.bound(zoom, 0.5, 4);
		hud.updateZoom(FlxG.camera.zoom);
	}

	function createFloorTiles()
	{
		var floorImg = Assets.getBitmapData("assets/FloorTexture.png");
		var imgWidth = floorImg.width;
		var imgHeight = floorImg.height;
		var i = LEVEL_MIN_X;
		var j = LEVEL_MIN_Y;

		while (i <= LEVEL_MAX_X)
		{
			while (j <= LEVEL_MAX_Y)
			{
				add(new FlxSprite(i, j, floorImg));
				j += imgHeight;
			}
			i += imgWidth;
			j = LEVEL_MIN_Y;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var speed = 20;
		if (FlxG.keys.anyPressed([A, LEFT]))
			orb.body.applyImpulse(new Vec2(-speed, 0));
		if (FlxG.keys.anyPressed([S, DOWN]))
			orb.body.applyImpulse(new Vec2(0, speed));
		if (FlxG.keys.anyPressed([D, RIGHT]))
			orb.body.applyImpulse(new Vec2(speed, 0));
		if (FlxG.keys.anyPressed([W, UP]))
			orb.body.applyImpulse(new Vec2(0, -speed));

		if (FlxG.keys.justPressed.Y)
			setStyle(1);
		if (FlxG.keys.justPressed.H)
			setStyle(-1);

		if (FlxG.keys.justPressed.U)
			setLerp(.1);
		if (FlxG.keys.justPressed.J)
			setLerp(-.1);

		if (FlxG.keys.justPressed.I)
			setLead(.5);
		if (FlxG.keys.justPressed.K)
			setLead(-.5);

		if (FlxG.keys.justPressed.O)
			setZoom(FlxG.camera.zoom + .1);
		if (FlxG.keys.justPressed.L)
			setZoom(FlxG.camera.zoom - .1);

		if (FlxG.keys.justPressed.M)
			FlxG.camera.shake();
	}

	function setLead(lead:Float)
	{
		var cam = FlxG.camera;
		cam.followLead.x += lead;
		cam.followLead.y += lead;

		if (cam.followLead.x < 0)
		{
			cam.followLead.x = 0;
			cam.followLead.y = 0;
		}

		hud.updateCamLead(cam.followLead.x);
	}

	function setLerp(lerp:Float)
	{
		var cam = FlxG.camera;
		cam.followLerp += lerp;
		cam.followLerp = Math.round(10 * cam.followLerp) / 10; // adding or subtracting .1 causes roundoff errors
		hud.updateCamLerp(cam.followLerp);
	}

	function setStyle(i:Int)
	{
		var newCamStyleIndex:Int = Type.enumIndex(FlxG.camera.style) + i;
		newCamStyleIndex < 0 ? newCamStyleIndex += 6 : newCamStyleIndex %= 6;

		var newCamStyle = Type.createEnumIndex(FlxCameraFollowStyle, newCamStyleIndex);
		FlxG.camera.follow(orb, newCamStyle, FlxG.camera.followLerp);
		drawDeadzone();

		hud.updateStyle(Std.string(FlxG.camera.style));

		if (FlxG.camera.style == SCREEN_BY_SCREEN)
		{
			setZoom(1);
		}
	}
}
