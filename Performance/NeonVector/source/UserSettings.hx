package;

import flixel.util.FlxSave;
import flixel.FlxG;

/**
 * ...
 * @author Masadow
 */
class UserSettings
{
	private static var _save:FlxSave; //The FlxSave instance
	private static var _loaded:Bool = false; //Did bind() work? Do we have a valid SharedObject?
	private static var _highScore:UInt = 0;
	private static var _tempHighScore:UInt;
	public static var highScore(get, set):UInt;

	public static function get_highScore():UInt
	{
		if (_loaded) return _save.data.highScore;
		else return _highScore;
	}
	
	public static function set_highScore(value:UInt):UInt
	{
		if (_loaded) _save.data.highScore = value;
		else _tempHighScore = value;
		return value;
	}

	public static function load():Void
	{
		_save = new FlxSave();
		_loaded = _save.bind("ShapeBlasterSaveFile");
		
		if (_loaded)
		{
			//if (_save.data.levels == null) _save.data.levels = 0;
			if (_save.data.highScore == null) 
			{
				//FlxG.log("loading default high score of 0 ...");
				_save.data.highScore = 0;
				PlayerShip.highScore = 0;
			}
			else 
			{
				//FlxG.log("loading previous high score ...");
				_save.data.highScore = UserSettings.highScore;
				PlayerShip.highScore = UserSettings.highScore;
			}
		}
	}

	public static function save():Void
	{
		_save.flush();
	}
}
