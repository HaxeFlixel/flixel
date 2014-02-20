package;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.util.FlxSave;

class Reg
{
	/**
	 * The current total score.
	 */
	static public var score:Int = 0;
	
	/**
	 * High score storage.
	 */
	static public var highScore:Int = 0;
	
	/**
	 * A reference to the active playstate. Lets you call Reg.PS globally to access the playstate.
	 */
	static public var PS:PlayState;
	
	/**
	 * Used for saving and loading high scores.
	 */
	static public var save:FlxSave;
	
	/**
	 * Just a 2px by 2px transparent piece of "dust".
	 */
	static public function dustMote():BitmapData
	{
		if (dustMoteData == null) {
			dustMoteData = new BitmapData(2, 2, true, 0x88FFFFFF);
		}
		
		return dustMoteData;
	}
	
	static private var dustMoteData:BitmapData;
	
	/**
	 * Draws the bounce panels. Useful for mobile devices with wierd resolutions.
	 * 
	 * @param	Height	The height of the panel to draw.
	 * @return	A BitmapData object representing the paddle. Cached for the second paddle to save time.
	 */
	static public function getBounceImage(Height:Int):BitmapData
	{
		if (_bitmapData != null)
			return _bitmapData;
		
		_bitmapData = new BitmapData(8, Height, false, GREY_MED);
		
		_rect = new Rectangle(4, 0, 4, Height);
		_bitmapData.fillRect(_rect, GREY_LIGHT);
		_rect = new Rectangle(0, 1, 1, Height - 2);
		_bitmapData.fillRect(_rect, GREY_DARK);
		_rect.x = 3;
		_bitmapData.fillRect(_rect, GREY_DARK);
		_rect = new Rectangle(1, 0, 2, 1);
		_bitmapData.fillRect(_rect, GREY_DARK);
		_rect.y = Height - 1;
		_bitmapData.fillRect(_rect, GREY_DARK);
		_rect = new Rectangle(4, 1, 1, Height - 2);
		_bitmapData.fillRect(_rect, WHITE);
		_rect.x = 7;
		_bitmapData.fillRect(_rect, WHITE);
		_rect = new Rectangle(5, 0, 2, 1);
		_bitmapData.fillRect(_rect, WHITE);
		_rect.y = Height - 1;
		_bitmapData.fillRect(_rect, WHITE);
		
		return _bitmapData;
	}
	
	// This is all stuff used for drawing the paddles.
	
	static private var _bitmapData:BitmapData;
	static private var _rect:Rectangle;
	
	inline static private var WHITE:Int = 0xffFFFFFF;
	inline static private var GREY_LIGHT:Int = 0xffB0B0BF;
	inline static private var GREY_MED:Int = 0xff646A7D;
	inline static private var GREY_DARK:Int = 0xff35353D;
}