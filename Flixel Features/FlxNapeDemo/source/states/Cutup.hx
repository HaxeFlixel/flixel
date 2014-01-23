package states;
import flixel.util.FlxRandom;
import FlxPhysicsDemo;
import openfl.Assets;
import openfl.display.FPS;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeSprite;
import flixel.plugin.TweenManager;
import flixel.util.FlxAngle;
import flixel.util.FlxMath;

import nape.geom.Vec2;
import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Ray;
import nape.geom.RayResultList;
import nape.shape.Polygon;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.motion.QuadPath;
import flixel.tweens.motion.LinearPath;

/**
 * ...
 * @author Henry.T
 */
class Cutup extends FlxNapeState
{
	var fps:FPS;
	var ufo:UFO;
	var pieces:FlxTypedGroup<FlxNapeSprite>;
	var lasers:FlxTypedGroup<Laser>;
	var ground:Float;
	var pieceCntTxt:FlxText;

	override public function create():Void
	{
		super.create();
		FlxG.mouse.show();
		napeDebugEnabled = false;
		
		ground = FlxG.height - 100;
		createWalls(0, 0, FlxG.width, ground);
		
		add(new FlxSprite(0, 0, "assets/cutup/cutupbg.jpg"));
		
		pieces = new FlxTypedGroup<FlxNapeSprite>();
		var houseCnt:Int = 3;
		for (i in 0...houseCnt) {
			var house:FlxNapeSprite = new FlxNapeSprite(FlxG.width / 2 - 100 * (Math.floor(houseCnt / 2) - i), FlxG.height / 2, "assets/cutup/cutup_" + i + ".png");
			house.body.userData.flxSprite = house;
			pieces.add(house);
		}
		add(pieces);
		
		lasers = new FlxTypedGroup<Laser>();
		add(lasers);
		ufo = new UFO(0,0,"assets/cutup/ufo.png");
		add(ufo);
		
		pieceCntTxt = new FlxText(FlxG.width - 100, 30, 100, "Total Pieces: ");
		add(pieceCntTxt);

		var txt = new FlxText(-10, 5, 640, "      'R' - reset state, 'G' - toggle physics graphics");
		add(txt);
		txt = new FlxText( -10, 20, 640, "      'LEFT' & 'RIGHT' - switch demo");
		add(txt);
		
		fps = new FPS(FlxG.width - 100, 5, 0xFFFFFF);
		FlxG.stage.addChild(fps);
		
		if (FlxNapeState.space.gravity.y != 500)
			FlxNapeState.space.gravity.setxy(0,500);
	}
	
	override public function update():Void {
		super.update();
		// won't count the default Body added by Nape itself
		pieceCntTxt.text = "Toatal Pieces:  " + (FlxNapeState.space.bodies.length-1);
		
		if (FlxG.keys.justPressed.G)
			if(_physDbgSpr != null)
				napeDebugEnabled = false;
			else
				napeDebugEnabled = true;
		
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
		
		if (FlxG.keys.justPressed.LEFT)
			FlxPhysicsDemo.prevState();
		if (FlxG.keys.justPressed.RIGHT)
			FlxPhysicsDemo.nextState();
			
		if (FlxG.mouse.justPressed && FlxG.mouse.y > ufo.getMidpoint().y)
			shootLaser();
	}
	
	override public function destroy():Void {
		super.destroy();
		FlxG.stage.removeChild(fps);
		FlxTween.manager.clear(true);
	}
	
	private function shootLaser() {
		var source:FlxPoint = ufo.getMidpoint();
		var mouse:FlxPoint = FlxG.mouse.getWorldPosition();
		// getAngle return angle with 0 degree point up, but we need the angle start from pointing right
		var deg:Float = FlxAngle.getAngle(source, mouse)-90;
		var groundPoint:FlxPoint = new FlxPoint(source.x + (ground-source.y)/Math.tan(deg*FlxAngle.TO_RAD), ground);
		var length:Float = FlxMath.getDistance(source, groundPoint);
		
		var laser:Laser = new Laser(source.x, source.y, null, length, deg);
		lasers.add(laser);
		
		var sP:Vec2 = Vec2.get(source.x, source.y);
		var eP:Vec2 = Vec2.get(groundPoint.x, groundPoint.y+1);	// +1 make sure no tiny gap in between groundPoint and groundY 
		var ray:Ray = Ray.fromSegment(sP, eP);
		if (ray.maxDistance > 5) {
			var rayResultList:RayResultList = FlxNapeState.space.rayMultiCast(ray);
			for (rayResult in rayResultList) {
				var orgBody:Body = rayResult.shape.body;
				if (orgBody.isStatic())
					continue;
				var orgPoly:Polygon = rayResult.shape.castPolygon;
				// If the shape's not polygon eg. a circle, it can't get cut
				// You can use a regular polygon to simulate a circle instead
				if (orgPoly == null)
					continue;
				var orgPhySpr:FlxNapeSprite = orgBody.userData.flxSprite;
				if (orgPhySpr != null)
					applyCut(orgPhySpr, sP, eP);
			}
		}
		sP.dispose();
		eP.dispose();
	}
	
	private function applyCut(orgPhySpr:FlxNapeSprite, sP:Vec2, eP:Vec2):Void {
		var orgBody = orgPhySpr.body;
		var geomPoly:GeomPoly = new GeomPoly(orgBody.shapes.at(0).castPolygon.worldVerts);
		var geomPolyList:GeomPolyList = geomPoly.cut(sP, eP, true, true);

		// Make current FlxNapeSprite graphic (may rotated) a reference BitmapData
		var bmp:BitmapData = new BitmapData(Math.ceil(orgBody.bounds.width), Math.ceil(orgBody.bounds.height), true, 0x0);
		var mat:Matrix = new Matrix();
		mat.translate(-orgPhySpr.origin.x, -orgPhySpr.origin.y);
		mat.rotate(orgPhySpr.angle * Math.PI/180 % 360);
		mat.translate(orgBody.position.x - orgBody.bounds.x, orgBody.position.y - orgBody.bounds.y);
		bmp.draw(orgPhySpr.pixels, mat);

		if (geomPolyList.length > 1){
			for (cutGeomPoly in geomPolyList){ 	
				// Make a new body in world space
				var cutPoly:Polygon = new Polygon(cutGeomPoly);
				var cutBody:Body = new Body(BodyType.DYNAMIC);
				cutBody.setShapeMaterials(Material.steel());
				cutBody.shapes.add(cutPoly);
				cutBody.align();
				// too small piece cause problem when creating BitmapData
				if (cutBody.bounds.width < 2 && cutBody.bounds.height < 2)
					continue;
				cutBody.space = FlxNapeState.space;
				
				// Sprite has ability to do polygon fill to fit new body's vertices
				var sprite:Sprite = new Sprite();
				sprite.graphics.beginBitmapFill(bmp,
					new Matrix(1, 0, 0, 1,
						orgBody.bounds.x - cutBody.position.x, 
						orgBody.bounds.y - cutBody.position.y));
				for (i in 0...cutPoly.localVerts.length)
				{
					var vert:Vec2 = cutPoly.localVerts.at(i);
					if (i == 0)
						sprite.graphics.moveTo(vert.x, vert.y);
					else
						sprite.graphics.lineTo(vert.x, vert.y);
				}
				sprite.graphics.endFill();
				
				// don't create the unnecessary default body on construction, it will become a ghost!
				var cutPhySpr = pieces.recycle(FlxNapeSprite, [0,0,null,false]);
				cutPhySpr.reset(0,0);
				cutPhySpr.body = cutBody;
				// force the bitmap to be unique, or same-sized bmp will share one instance
				cutPhySpr.makeGraphic(Math.ceil(cutBody.bounds.width), Math.ceil(cutBody.bounds.height), 0x00ff0000, true);
				cutPhySpr.pixels.draw(sprite, new Matrix(1, 0, 0, 1, cutBody.worldCOM.x - cutBody.bounds.x, cutBody.worldCOM.y - cutBody.bounds.y));
				cutPhySpr.origin.set(cutBody.worldCOM.x - cutBody.bounds.x, cutBody.worldCOM.y - cutBody.bounds.y);
				cutPhySpr.setPosition(cutBody.worldCOM.x - cutPhySpr.origin.x, cutBody.worldCOM.y - cutPhySpr.origin.y);
				cutPhySpr.angle = cutBody.rotation * 180 / Math.PI;
				pieces.add(cutPhySpr);
				
				// apply small random impulse
				var pulseAgl:Float = FlxRandom.float() * Math.PI * 2;
				var power:Float = FlxRandom.floatRanged(100, 250);
				cutPhySpr.body.applyImpulse(Vec2.weak(
					power * Math.cos(pulseAgl), power * Math.sin(pulseAgl)
				));
				cutBody.userData.flxSprite = cutPhySpr;
			}
			orgPhySpr.kill();
			orgPhySpr.destroyPhysObjects();
		}
	}
}

class UFO extends FlxSprite {
	public function new(X:Float, Y:Float, SimpleGraphics:Dynamic){
		super(X, Y, SimpleGraphics);
		loadGraphic("assets/cutup/ufo.png", true, true, 32, 32);
		animation.add("fly", [for (i in 0...9) i], 10, true);
		animation.play("fly");
		var ufoTween:QuadPath = new QuadPath(null, FlxTween.LOOPING);	// NOTE Loop seems not working
		ufoTween.setObject(this);
		ufoTween.addPoint(50, 100).addPoint(FlxG.width / 2, 20).addPoint(FlxG.width - 50, 100).addPoint(FlxG.width / 2, 150).addPoint(50, 100); 
		ufoTween.setMotion(5);
		FlxTween.manager.add(ufoTween);
	}

	override public function update(){
		// after super.update() x and last.x become the same
		if(x>last.x)
			set_facing(flixel.FlxObject.RIGHT);
		else
			set_facing(flixel.FlxObject.LEFT);

		super.update();
	}
}

class Laser extends FlxSprite {
	public function new(X:Float, Y:Float, SimpleGraphics:Dynamic, Length:Float, Rotation:Float) {
		super(X, Y, SimpleGraphics);
		loadGraphic("assets/cutup/laser.png");
		angle = Rotation;
		scale.set(Length / pixels.width, 1);
		origin.set(0, pixels.height/2);
		
		var alphaTween:VarTween = new VarTween(function(t:FlxTween) { kill(); }, FlxTween.ONESHOT);
		alphaTween.tween(this, "alpha", 0, 0.4, FlxEase.quadOut);
		alphaTween.start();
		FlxTween.manager.add(alphaTween);
	}
}