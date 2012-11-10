package;

import addons.FlxSkewedSprite;
import flash.ui.Mouse;
import nme.Assets;
import nme.Lib;
import org.flixel.FlxButton;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTileblock;
import org.flixel.plugin.pxText.FlxBitmapTextField;
import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.plugin.pxText.PxTextAlign;

/**
 * ...
 * @author Zaphod
 */
class TestState extends FlxState
{
	public function new()
	{
		super();
	}
	
	override public function create():Void 
	{
		#if flash
		FlxG.framerate = 30;
		FlxG.flashFramerate = 30;
		#else
		FlxG.framerate = 60;
		FlxG.flashFramerate = 60;
		#end
		
		#if !neko
		FlxG.bgColor = 0xffffffff;
		#else
		FlxG.bgColor = {rgb: 0xffffff, a: 0xff};
		#end
		
		var grass1:Grass = new Grass(0, 0, 0, 0);
		var grass2:Grass = new Grass(0, 0, 1, -5);
		var grass3:Grass = new Grass(0, 0, 2, 5);
		
		add(grass1);
		add(grass2);
		add(grass3);
	}
	
}