package;

import addons.FlxTilemapExt;
import nme.Assets;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState
{
	
	public var player:FlxSprite;
	
	//major game object storage
	private var _blocks:FlxGroup;
	private var _hud:FlxGroup;
	
	//meta groups, to help speed up collisions
	private var _objects:FlxGroup;

	//HUD/User Interface stuff
	private var _levelText:FlxText;
	
	//Tilemap Stuff
	private var level:FlxTilemapExt;
	
	
	public function new()
	{
		super();
	}
	
	override public function create():Void
	{
		level = new FlxTilemapExt();
		
		FlxG.mouse.hide();
		
		_hud = new FlxGroup();

		#if !neko
		FlxG.bgColor = 0xff050509;
		#else
		FlxG.camera.bgColor = FlxG.WHITE;
		#end
		
		//Simple Version
		//=================================================================
		
		//Create player (a red box)
		player = new FlxSprite(70);
		#if !neko
		player.makeGraphic(10, 12, 0xffaa1111);
		#else
		player.makeGraphic(10, 12, {rgb: 0xaa1111, a: 0xff});
		#end
		
		//Max velocities on player.  If it's a platformer, Y should be high, like 200.
		//Otherwise, set them to something like 80.
		player.maxVelocity.x = 80;
		player.maxVelocity.y = 200;
		
		//Simulate Gravity on the Player
		player.acceleration.y = 200;
		
		player.drag.x = player.maxVelocity.x * 4;
		add(player);
		//====================================================================
		
		//Load in the Level and Define Arrays for different slope types
		add(level.loadMap(Assets.getText("assets/slopemap.txt"), "assets/colortiles.png", 10, 10));
		
		var tempFL:Array<Int> = [5,13,21];
		var tempFR:Array<Int> = [6,14,22];
		var tempCL:Array<Int> = [7,15,23];
		var tempCR:Array<Int> = [8,16,24];
		
		var tempC:Array<Int> = [4,12,20];
		
		level.setSlopes(tempFL, tempFR, tempCL, tempCR);
		level.setClouds(tempC);
		
		//Make the Camera follow the player.
		//FlxG.camera.follow(_player);
		FlxG.camera.setBounds(0, 0, 970, 500, true); //Note, the player does weird things when he walks off screen.
		FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);
		
		//HUD
		add(_hud);
		
		_levelText = new FlxText(FlxG.width - 100, 0, 100);
		_levelText.setFormat(null, 8, 0xaaaaff, "center", 0x111122);
		_levelText.text = "Slope Test";
		_levelText.scrollFactor.x = _levelText.scrollFactor.y = 0;
		_hud.add(_levelText);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_blocks = null;
		_hud = null;
		
		//meta groups, to help speed up collisions
		_objects = null;
	}
	
	override public function update():Void
	{
		//Simple Version
		//===========================================================
		player.acceleration.x = 0;
		if(FlxG.keys.LEFT)
		{
			player.acceleration.x = -player.maxVelocity.x*4;
		}
		if(FlxG.keys.RIGHT)
		{
			player.acceleration.x = player.maxVelocity.x*4;
		}
		if(FlxG.keys.SPACE && player.isTouching(FlxObject.FLOOR))
		{
			player.velocity.y = -player.maxVelocity.y/2;
		}
		
		super.update();
		
		FlxG.collide(level, player);	
	}	
}