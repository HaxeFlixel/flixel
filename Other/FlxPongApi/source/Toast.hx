package;

import flash.display.BitmapData;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.addons.api.FlxGameJolt;

class Toast extends FlxSpriteGroup
{
	inline static private var SIZE:Int = 80;
	private var _name:String;
	
	public function new( TrophyID:Int )
	{
		super( FlxG.width, FlxG.height - SIZE - 10 );
		FlxGameJolt.fetchTrophy( TrophyID, setUpTrophy );
	}
	
	private function setUpTrophy( Return:Map<String,String> ):Void
	{
		_name = Return.get( "title" );
		var request:URLRequest = new URLRequest( Return.get( "image_url" ) );
		var loader = new URLLoader();
		loader.addEventListener( Event.COMPLETE, awardTrophy );
		loader.load( request );
	}
	
	private function awardTrophy( e:Event ):Void
	{
		trace( e.currentTarget.data );
		var bg:PongSprite = new PongSprite( 0, 0, SIZE, SIZE, Reg.dark );
		var top:FlxText = new FlxText( 1, 1, SIZE - 2, "Trophy Get!" );
		top.color = Reg.med_lite;
		var mid:FlxText = new FlxText( 1, 12, SIZE - 2, _name );
		mid.color = Reg.lite;
		//var img:FlxSprite = new FlxSprite( 1, 22, e.currentTarget.data );
		
		add( bg );
		//add( img );
		add( top );
		add( mid );
		
		FlxTween.linearMotion( this, this.x, this.y, this.x - SIZE - 10, this.y, 1 );
	}
}