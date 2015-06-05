package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSave;
using flixel.util.FlxSpriteUtil;

class GameOverState extends FlxState
{
	private var _score:Int = 0;			// number of coins we've collected
	private var _win:Bool;				// if we won or lost
	private var _txtTitle:FlxText;		// the title text
	private var _txtMessage:FlxText;	// the final score message text
	private var _sprScore:FlxSprite;	// sprite for a coin icon
	private var _txtScore:FlxText;		// text of the score
	private var _txtHiScore:FlxText;	// text to show the hi-score
	private var _btnMainMenu:FlxButton;	// button to go to main menu
	
	/**
	 * Called from PlayState, this will set our win and score variables
	 * @param	Win		true if the player beat the boss, false if they died
	 * @param	Score	the number of coins collected
	 */
	public function new(Win:Bool, Score:Int) 
	{
		_win = Win;
		_score = Score;
		super();
	}
	
	override public function create():Void 
	{
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = true;
		#end
		
		// create and add each of our items
		
		_txtTitle = new FlxText(0, 20, 0, _win ? "You Win!" : "Game Over!", 22);
		_txtTitle.alignment = "center";
		_txtTitle.screenCenter(true, false);
		add(_txtTitle);
		
		_txtMessage = new FlxText(0, (FlxG.height / 2) - 18, 0, "Final Score:", 8);
		_txtMessage.alignment = "center";
		_txtMessage.screenCenter(true, false);
		add(_txtMessage);
		
		_sprScore = new FlxSprite((FlxG.width / 2) - 8, 0, AssetPaths.coin__png);
		_sprScore.screenCenter(false, true);
		add(_sprScore);
		
		_txtScore = new FlxText((FlxG.width / 2), 0, 0, Std.string(_score), 8);
		_txtScore.screenCenter(false, true);
		add(_txtScore);
		
		// we want to see what the hi-score is
		var _hiScore = checkHiScore(_score);
		
		_txtHiScore = new FlxText(0, (FlxG.height / 2) + 10, 0, "Hi-Score: " + Std.string(_hiScore), 8);
		_txtHiScore.alignment = "center";
		_txtHiScore.screenCenter(true, false);
		add(_txtHiScore);
		
		_btnMainMenu = new FlxButton(0, FlxG.height - 32, "Main Menu", goMainMenu);
		_btnMainMenu.screenCenter(true, false);
		_btnMainMenu.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_btnMainMenu);
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);
		
		super.create();
	}
	
	/**
	 * This function will compare the new score with the saved hi-score. 
	 * If the new score is higher, it will save it as the new hi-score, otherwise, it will return the saved hi-score.
	 * @param	Score	The new score
	 * @return	the hi-score
	 */
	private function checkHiScore(Score:Int):Int
	{
		var _hi:Int = Score;
		var _save:FlxSave = new FlxSave();
		if (_save.bind("flixel-tutorial"))
		{
			if (_save.data.hiscore != null)
			{
				if (_save.data.hiscore > _hi)
				{
					_hi = _save.data.hiscore;
				}
				else
				{
					_save.data.hiscore = _hi;
				}
			}
		}
		_save.close();
		return _hi;
	}
	
	/**
	 * When the user hits the main menu button, it should fade out and then take them back to the MenuState
	 */
	private function goMainMenu():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {
			FlxG.switchState(new MenuState());
		});
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		// clean up all our objects!
		_txtTitle = FlxDestroyUtil.destroy(_txtTitle);
		_txtMessage = FlxDestroyUtil.destroy(_txtMessage);
		_sprScore = FlxDestroyUtil.destroy(_sprScore);
		_txtScore = FlxDestroyUtil.destroy(_txtScore);
		_btnMainMenu = FlxDestroyUtil.destroy(_btnMainMenu);
	}
}