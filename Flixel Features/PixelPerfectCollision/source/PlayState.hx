package; 

import flash.system.System;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flash.display.BitmapData;
import flixel.util.FlxCollision;
import flixel.util.FlxRandom;

using StringTools;	// so we can use String.replace() easily, yay!


/**
 * @author azrafe7
 */
class PlayState extends FlxState
{	
	// total number of objects on screen
	var nObjects:Int = 10;
	
	// array holding the player and the aliens
	var objects:Array<FlxSprite> = new Array<FlxSprite>();
	
	// the player ship
	var player:FlxSprite;
	
	// graphic assets
	var alienBitmapData:BitmapData;
	var playerBitmapData:BitmapData;
	
	// number of collisions at any given time
	var nCollisions:Int = 0;
	
	// setting this to 255 means two object will collide only if totally opaque
	var alphaTolerance:Int = 1;
	
	// wether the objects should rotate
	var rotate:Bool = true;
	
	// info text to show in the bottom-left corner of the screen
	var infoText:flixel.text.FlxText;
	var INFO:String = "collisions: |hits|\n\n" + 
					  "[W/S]           num objects: |objects|\n" +
					  "[A/D]           alpha tolerance: |alpha|\n" +
					  "[ARROWS]    move\n" +
					  "[R]               random\n" +
					  "[SPACE]       toggle rotation";
	
	
	public function new() {
		super();
		
		// retrieve our assets just once
		alienBitmapData = FlxAssets.getBitmapData("assets/alien.png");
		playerBitmapData = FlxAssets.getBitmapData("assets/ship.png");
	}
	
	override public function create():Void
	{	
		// create the player
		player = new FlxSprite(FlxG.width / 2, FlxG.height / 2, playerBitmapData);
		add(player);
		objects.push(player);	// ...so the player will be stored in objects[0]
		
		// add aliens for more interstellar fun!
		for (i in 1...nObjects) addAlien();
		
		// add in some text so we know what's happening
		infoText = new FlxText(2, 0, 400, INFO);
		infoText.y = FlxG.height - infoText.height;
		add(infoText);
	}
	
	/**
	 * Add a new alien.
	 */
	public function addAlien():FlxSprite 
	{
		// create a new alien
		
		var alien = new FlxSprite();
		alien.loadGraphic(alienBitmapData, true);	// load graphics from asset
		alien.animation.add("dance", [0, 1, 0, 2], FlxRandom.intRanged(6, 10));		// set dance dance interstellar animation
		alien.animation.play("dance");	// dance!
		randomize(alien);	// set position, angle and alpha to random values
		
		// add the new alien to our objects array and to the PlayState
		objects.push(alien);
		add(alien);
		
		return alien;
	}
	
	/**
	 * Randomize position, angle and alpha of `obj`.
	 */
	public function randomize(obj:FlxSprite):FlxSprite
	{
		obj.x = FlxRandom.float() * FlxG.width;
		obj.y = FlxRandom.float() * FlxG.height;
		obj.angle = FlxRandom.float() * 360;
		obj.alpha = FlxRandom.floatRanged(.3, 1.0);
		
		return obj;
	}
	
	/**
	 * Here's where the fun happens! \o/.
	 */
	override public function update():Void
	{			
		handleInput();
		
		// add/remove aliens
		if (nObjects != objects.length) {
			var len = objects.length;
			if (nObjects > len) addAlien();
			else remove(objects.pop());
		}
		
		// update rotation and animation
		for (obj in objects) {
			if (rotate) obj.angle += (obj == player) ? 1 : 2;
			obj.animation.update();	// dance! dance! dance!
		}
		
		// pixel perfect collision check between all objects
		nCollisions = 0;
		for (i in 0...objects.length) {
			var obj1 = objects[i];
			var collides = false;
			for (j in 0...objects.length) {
				if (i == j) continue;
				
				var obj2 = objects[j];
				if (FlxCollision.pixelPerfectCheck(obj1, obj2, alphaTolerance)) {	// <-- this is how we check if obj1 and obj2 are colliding
					collides = true;
					nCollisions++;
					break;
				}
			}
			obj1.color = collides ? 0xFF0000 : 0xFFFFFF;	// tint red if colliding
		}
		
		updateInfo();
	}	
	
	public function handleInput():Void 
	{
		// player movement
		if (FlxG.keys.pressed.LEFT) player.x -= 2;
		if (FlxG.keys.pressed.RIGHT) player.x += 2;
		if (FlxG.keys.pressed.UP) player.y -= 2;
		if (FlxG.keys.pressed.DOWN) player.y += 2;
	
		// toggle rotation
		if (FlxG.keys.justPressed.SPACE) rotate = !rotate;
		
		// randomize
		if (FlxG.keys.justPressed.R) {
			for (obj in objects) {
				if (obj == player) continue;
				randomize(obj);
			}
		}
		
		// increment/decrement number of objects
		if (FlxG.keys.justPressed.W) nObjects++;
		if (FlxG.keys.justPressed.S) nObjects = Std.int(Math.max(nObjects - 1, 2));
		
		// increment/decrement alpha tolerance
		if (FlxG.keys.pressed.D) alphaTolerance = Std.int(Math.min(alphaTolerance + 1, 255));
		if (FlxG.keys.pressed.A) alphaTolerance = Std.int(Math.max(alphaTolerance - 1, 1));
		
		// quit on ESC
		if (FlxG.keys.justPressed.ESCAPE) {
		#if (flash || js)
			System.exit(0);
		#else
			Sys.exit(0);
		#end
		}
		
	}
	
	public function updateInfo():Void 
	{
		infoText.text = INFO.replace("|objects|", Std.string(nObjects))
			.replace("|alpha|", Std.string(alphaTolerance))
			.replace("|hits|", Std.string(nCollisions));
	}
}
