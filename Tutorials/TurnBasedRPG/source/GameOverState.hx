package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

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
		
		#if FLX_MOUSE
		FlxG.mouse.visible = true;
		#end
		
		// create and add each of our items
		
		_txtTitle = new FlxText(0, 20, 0, _win ? "You Win!" : "Game Over!", 22);
		_txtTitle.alignment = CENTER;
		_txtTitle.screenCenter(FlxAxes.X);
		add(_txtTitle);
		
		_txtMessage = new FlxText(0, (FlxG.height / 2) - 18, 0, "Final Score:", 8);
		_txtMessage.alignment = CENTER;
		_txtMessage.screenCenter(FlxAxes.X);
		add(_txtMessage);
		
		_sprScore = new FlxSprite((FlxG.width / 2) - 8, 0, AssetPaths.coin__png);
		_sprScore.screenCenter(FlxAxes.Y);
		add(_sprScore);
		
		_txtScore = new FlxText((FlxG.width / 2), 0, 0, Std.string(_score), 8);
		_txtScore.screenCenter(FlxAxes.Y);
		add(_txtScore);
		
		// we want to see what the hi-score is
		var _hiScore = checkHiScore(_score);
		
		_txtHiScore = new FlxText(0, (FlxG.height / 2) + 10, 0, "Hi-Score: " + _hiScore, 8);
		_txtHiScore.alignment = CENTER;
		_txtHiScore.screenCenter(FlxAxes.Y);
		add(_txtHiScore);
		
		_btnMainMenu = new FlxButton(0, FlxG.height - 32, "Main Menu", goMainMenu);
		_btnMainMenu.screenCenter(FlxAxes.X);
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
			if (_save.data.hiscore != null && _save.data.hiscore > _hi)
			{
				_hi = _save.data.hiscore;
			}
			else
			{
				// data is less or there is no data; save current score
				_save.data.hiscore = _hi;
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
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}
}
