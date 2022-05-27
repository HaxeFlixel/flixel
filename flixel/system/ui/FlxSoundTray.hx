package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	#if FLX_SPLIT_SOUND_TRAY
	var _soundBars:Array<Bitmap>;

	var _musicBars:Array<Bitmap>;
	#end

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _height:Int = 30;

	var _defaultScale:Float = 2.0;

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		#if FLX_SPLIT_SOUND_TRAY
		var orientation:String = 'H';
		if (Lib.current.stage.stageWidth > ((_width * 3) + 10) * _defaultScale)
		{
			// HORIZONTAL
			_width = (_width * 3) + 10;
		}
		else
		{
			// VERTICAL
			orientation = 'V';
			_height = 90;
		}
		#end

		var tmp:Bitmap = new Bitmap(new BitmapData(_width, _height, true, 0x7F000000));
		screenCenter();
		addChild(tmp);

		addText("VOLUME", 0, 16);

		_bars = addBars(10, 14);

		#if FLX_SPLIT_SOUND_TRAY
		if (orientation == 'H')
		{
			addText("SOUND", 80, 16);
			_soundBars = addBars(90, 14);

			addText("MUSIC", 160, 16);
			_musicBars = addBars(170, 14);
		}
		else
		{
			addText("SOUND", 0, 46);
			_soundBars = addBars(10, 44);

			addText("MUSIC", 0, 76);
			_musicBars = addBars(10, 74);
		}
		#end

		y = -height;
		visible = false;
	}

	private function addText(Text:String = "", X:Int = 0, Y:Int = 0):Void
	{
		var text:TextField = new TextField();
		text.width = 80;
		text.height = 30;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = Text;
		text.x = X;
		text.y = Y;
	}

	/**
	 * This function creates a group of bars
	 * @param Group 	Which array these bars belong to
	 * @param X 		Start X position
	 * @param Y 		Start Y position
	 */
	private function addBars(X:Int = 0, Y:Int = 0):Array<Bitmap>
	{
		var bx:Int = X;
		var by:Int = Y;

		var bars:Array<Bitmap> = [];

		var tmp:Bitmap = null;

		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			bars.push(tmp);
			bx += 6;
			by--;
		}

		return bars;
	}

	/**
	 * This function just updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		// Animate stupid sound tray thing
		if (_timer > 0)
		{
			_timer -= MS / 1000;
		}
		else if (y > -height)
		{
			y -= (MS / 1000) * FlxG.height * 2;

			if (y <= -height)
			{
				visible = false;
				active = false;

				// Save sound preferences
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				#if FLX_SPLIT_SOUND_TRAY
				FlxG.save.data.soundvolume = FlxG.sound.defaultSoundGroup.volume;
				FlxG.save.data.soundmute = FlxG.sound.defaultSoundGroup.muted;
				FlxG.save.data.musicvolume = FlxG.sound.defaultMusicGroup.volume;
				FlxG.save.data.musicmute = FlxG.sound.defaultMusicGroup.muted;
				#end
				FlxG.save.flush();
			}
		}
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	Silent	Whether or not it should beep.
	 */
	public function show(Silent:Bool = false):Void
	{
		if (!Silent)
		{
			var sound = FlxAssets.getSound("flixel/sounds/beep");
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 1;
		y = 0;
		visible = true;
		active = true;

		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].alpha = 1;
			}
			else
			{
				_bars[i].alpha = 0.5;
			}
		}

		#if FLX_SPLIT_SOUND_TRAY
		globalVolume = Math.round(FlxG.sound.defaultSoundGroup.volume * 10);

		if (FlxG.sound.defaultSoundGroup.muted)
			globalVolume = 0;

		for (i in 0..._soundBars.length)
		{
			if (i < globalVolume)
			{
				_soundBars[i].alpha = 1;
			}
			else
			{
				_soundBars[i].alpha = 0.5;
			}
		}

		globalVolume = Math.round(FlxG.sound.defaultMusicGroup.volume * 10);

		if (FlxG.sound.defaultMusicGroup.muted)
			globalVolume = 0;

		for (i in 0..._musicBars.length)
		{
			if (i < globalVolume)
			{
				_musicBars[i].alpha = 1;
			}
			else
			{
				_musicBars[i].alpha = 0.5;
			}
		}
		#end
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
