package;

import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRect;
import flixel.text.FlxText;

/**
 * The various UI buttons and text are collected here, keeping it all out of PlayState.
 * @author MSGhero
 */
class UILayer extends FlxSpriteGroup
{	
	var bg:FlxSprite;
	var ammo:FlxSprite; // bars will represent how many and what color lasers are next
	
	var source:FlxText;
	var patreon:FlxSprite;
	var credits:FlxText;
	
	var restartFunction:Void->Void;
	
	public function new(restartLevel:Void->Void)
	{
		super();
		
		// the restart level function is in a different class, but we want to call it from here when the reset level button is pressed
		// so we pass the function in and save it as a variable to use later
		restartFunction = restartLevel;
		
		// a black background helps the UI buttons stand out
		bg = new FlxSprite();
		bg.makeGraphic(250, FlxG.height, FlxColor.BLACK); // should this change based on the selected color palette?
		
		FlxMouseEventManager.add(bg, null, null, onPanelOver, onPanelOut, true, true, true); // pixel-perfect because we will be using a clipRect and need the extra checks
		
		add(bg);
		
		ammo = new FlxSprite(5, 223);
		ammo.makeGraphic(40, 60, 0x0, true);
		
		add(ammo);
		
		// the original art files from Kenney.nl are in multiple pngs: I combined several using an image editor to make a spritesheet that I can easily load as an animation
		// tools like TexturePacker do all that for you plus more: check out the TexturePackerDemo too!
		
		var mute = new FlxSprite(0, 69);
		mute.loadGraphic(AssetPaths.music__png, true, 50, 50);
		mute.animation.add("unmuted", [0], 0, false);
		mute.animation.add("muted", [1], 0, false);
		mute.animation.play("unmuted");
		
		FlxMouseEventManager.add(mute, null, toggleMute, onMOver, onMOut, true, true, false);
		
		add(mute);
		
		/*
		// I'm leaving fullscreen disabled since it doesn't really work on HTML5
		
		var fullscreen = new FlxSprite(0, 69 + 50);
		fullscreen.loadGraphic(AssetPaths.resize__png, true, 50, 50);
		fullscreen.animation.add("fullscreen", [0], 0, false);
		fullscreen.animation.add("unfullscreen", [1], 0, false);
		fullscreen.animation.play("fullscreen");
		
		FlxMouseEventManager.add(fullscreen, null, toggleFullscreen, onMOver, onMOut, true, true, false);
		
		add(fullscreen);
		*/
		
		var restart = new FlxSprite(0, 69 + 100);
		restart.loadGraphic(AssetPaths.return__png, false);
		
		FlxMouseEventManager.add(restart, null, onRestart, onMOver, onMOut, true, true, false);
		
		add(restart);
		
		source = new FlxText(100, 50, 150, "Click for the source code", 14);
		FlxMouseEventManager.add(source, null, onSource, onMOver, onMOut, true, true, false);
		add(source);
		
		patreon = new FlxSprite(125, 125, AssetPaths.haxeflixel__png); // "click to learn more"?
		FlxMouseEventManager.add(patreon, null, onPatreon, onMOver, onMOut, true, true, false);
		add(patreon);
		
		credits = new FlxText(60, 216, 180, "Made by MSGhero for HaxeFlixel\nArt from Kenney.nl\nWaltz in G minor by Strimlarn87", 8);
		credits.alignment = "center";
		FlxMouseEventManager.add(credits, null, onCredits, onMOver, onMOut, true, true, false);
		add(credits);
		
		source.visible = patreon.visible = credits.visible = false;
		
		// the UI panel will expand when moused over, and that will be controlled by a clipRect
		// which will hide the right side of the panel until the left is moused over
		clipRect = new FlxRect(0, 0, 50, FlxG.height);
		bg.width = 50;
	}
	
	public function setAmmo(remainingAmmo:Array<Color>):Void
	{
		// shows the remaining ammo by editing the sprite's pixels
		// you could also manage separate sprites, each being one unit of ammo (photons?)
		
		var color:FlxColor = 0x0;
		var rect = new Rectangle(0, 0, 40, 20);
		
		for (i in 0...3)
		{
			if (i < remainingAmmo.length) color = ColorMaps.defaultColorMap[remainingAmmo[i]];
			else color = FlxColor.BLACK;
			
			rect.y = 40 - i * 20;
			
			ammo.pixels.fillRect(rect, color); 
		}
		
		ammo.dirty = true;
	}
	
	public function forceMenuExpand(?_):Void
	{
		FlxMouseEventManager.setObjectMouseEnabled(bg, false);
		onPanelOver(bg);
	}
	
	public function unforceMenuExpand(?_):Void
	{
		FlxMouseEventManager.setObjectMouseEnabled(bg, true);
		
		// the one time this gets called in the game, the mouse will be within the 50 px menu, over the reset button
		// we don't really want onPanelOut to be called just for onPanelOver to be called one frame later, or the menu will flicker
		// onPanelOut(bg);
	}
	
	function toggleMute(mute:FlxSprite):Void
	{
		if (mute.animation.curAnim.name == "muted")
		{
			mute.animation.play("unmuted");
			FlxG.sound.muted = false;
		}
		
		else
		{
			mute.animation.play("muted");
			FlxG.sound.muted = true;
		}
	}
	
	/*
	function toggleFullscreen(fullscreen:FlxSprite):Void
	{
		if (fullscreen.animation.curAnim.name == "unfullscreen")
		{
			fullscreen.animation.play("fullscreen");
			FlxG.fullscreen = false;
		}
		
		else
		{
			fullscreen.animation.play("unfullscreen");
			FlxG.fullscreen = true;
		}
	}
	*/
	
	function onRestart(_):Void
	{
		restartFunction();
	}
	
	function onPanelOver(target:FlxSprite):Void
	{
		clipRect.width = bg.width = 250;
		clipRect = clipRect; // you have to set the clipRect for it to update, just changing a property doesn't do anything
		
		source.visible = patreon.visible = credits.visible = true; // we don't want these responding to mouse clicks when covered up, so we have to manually set their visibility
	}
	
	function onPanelOut(target:FlxSprite):Void
	{
		clipRect.width = bg.width = 50;
		clipRect = clipRect;
		
		source.visible = patreon.visible = credits.visible = false;
	}
	
	function onPatreon(_):Void
	{
		FlxG.openURL("https://www.patreon.com/haxeflixel");
	}
	
	function onSource(_):Void
	{
		FlxG.openURL("https://github.com/HaxeFlixel/flixel-demos/tree/dev/Arcade/FlxLightPuzzle");
	}
	
	function onCredits(credits:FlxText):Void
	{
		// roughly correct, doesn't account for 2px gutter
		var whichLink = Std.int((FlxG.mouse.y - credits.y) * 3 / credits.frameHeight); // frameHeight includes the scale adjustment
		
		FlxG.openURL(
			switch (whichLink)
			{
				case 1:
					"https://kenney.nl/";
				case 2:
					"https://www.newgrounds.com/audio/listen/755011";
				case _:
					"http://haxeflixel.com/";
			}
		);
	}
	
	function onMOver(target:FlxSprite):Void
	{
		target.scale.x = 1.25;
		target.scale.y = 1.25;
	}
	
	function onMOut(target:FlxSprite):Void
	{
		target.scale.x = 1;
		target.scale.y = 1;
	}
	
	override function get_width():Float
	{
		// we just want the width to be the background's width, not the width of all children
		// the background's width changes on mouse over and out
		return bg.width;
	}
}
