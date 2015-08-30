package;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.addons.api.FlxGameJolt;
import flixel.util.FlxTimer;

class Toast extends FlxSpriteGroup
{
	private static inline var WIDTH:Int = 105;
	private static inline var HEIGHT:Int = 115;
	private var _name:String;
	private var _id:Int;
	private var _had:String;
	
	/**
	 * Just a handy class to unlock a trophy, and provide visual notification of such to the player.
	 * 
	 * @param	TrophyID
	 */
	public function new(TrophyID:Int)
	{
		super(FlxG.width, FlxG.height - HEIGHT - 10);
		_id = TrophyID;
		//FlxGameJolt.addTrophy( TrophyID, fetchImage );
		FlxGameJolt.fetchTrophy(_id, setUpTrophy);
	}
	
	private function setUpTrophy(Return:Map<String,String>):Void
	{
		_name = Return.get("title");
		FlxGameJolt.fetchTrophyImage(_id, awardTrophy);
	}
	
	private function awardTrophy(bd:BitmapData):Void
	{
		var bg:PongSprite = new PongSprite(0, 0, WIDTH, HEIGHT, Reg.dark);
		var top:FlxText = new FlxText(0, -2, WIDTH, "Trophy Get!");
		top.color = Reg.med_lite;
		top.alignment = CENTER;
		var img:FlxSprite = new FlxSprite(Math.round((WIDTH - 75) / 2), 16, bd);
		var bottom:FlxText = new FlxText(0, HEIGHT - 23, WIDTH - 1, _name);
		bottom.color = Reg.lite;
		bottom.alignment = CENTER;
		
		add(bg);
		add(img);
		add(top);
		add(bottom);
		
		FlxTween.linearMotion(this, this.x, this.y, this.x - WIDTH - 10, this.y, 1);
		new FlxTimer().start(6, removeThis, 1);
	}
	
	private function removeThis(t:FlxTimer):Void
	{
		visible = false;
		active = false;
		exists = false;
		alive = false;
		destroy();
	}
}