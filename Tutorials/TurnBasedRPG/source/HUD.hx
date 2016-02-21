package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	private var _sprBack:FlxSprite;
	private var _txtHealth:FlxText;
	private var _txtMoney:FlxText;
	private var _sprHealth:FlxSprite;
	private var _sprMoney:FlxSprite;
	
	public function new() 
	{
		super();
		_sprBack = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		_sprBack.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		_txtHealth = new FlxText(16, 2, 0, "3 / 3", 8);
		_txtHealth.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		_txtMoney = new FlxText(0, 2, 0, "0", 8);
		_txtMoney.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		_sprHealth = new FlxSprite(4, _txtHealth.y + (_txtHealth.height/2)  - 4, AssetPaths.health__png);
		_sprMoney = new FlxSprite(FlxG.width - 12, _txtMoney.y + (_txtMoney.height/2)  - 4, AssetPaths.coin__png);
		_txtMoney.alignment = RIGHT;
		_txtMoney.x = _sprMoney.x - _txtMoney.width - 4;
		add(_sprBack);
		add(_sprHealth);
		add(_sprMoney);
		add(_txtHealth);
		add(_txtMoney);
		
		// HUD elements shouldn't move with the camera
		forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set(0, 0);
		});
	}
	
	public function updateHUD(Health:Int = 0, Money:Int = 0):Void
	{
		_txtHealth.text = Health + " / 3";
		_txtMoney.text = Std.string(Money);
		_txtMoney.x = _sprMoney.x - _txtMoney.width - 4;
	}
}