package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
@:allow(flixel.system.frontEnds.SoundFrontEnd)
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * The volume label
	 */
	var _label:TextField;
	
	var _bg:Bitmap;
	
	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;
	
	/**
	 * The minimum width of the sound tray
	 */
	var _minWidth:Int = 80;

	var _defaultScale:Float = 2.0;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:FlxSoundAsset = "flixel/sounds/beep";

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:FlxSoundAsset = 'flixel/sounds/beep';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

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
		_bg = new Bitmap(new BitmapData(_minWidth, 30, true, 0x7F000000));
		screenCenter();
		addChild(_bg);

		_label = new TextField();
		_label.width = _bg.width;
		// text.height = bg.height;
		_label.multiline = true;
		// text.wordWrap = true;
		_label.selectable = false;

		#if flash
		_label.embedFonts = true;
		_label.antiAliasType = AntiAliasType.NORMAL;
		_label.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		_label.defaultTextFormat = dtf;
		addChild(_label);
		_label.text = "VOLUME";
		_label.y = 16;


		_bars = new Array();

		var tmp:Bitmap;
		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			addChild(tmp);
			_bars.push(tmp);
		}
		updateSize();

		y = -height;
		visible = false;
	}

	/**
	 * This function updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		// Animate sound tray thing
		if (_timer > 0)
		{
			_timer -= (MS / 1000);
		}
		else if (y > -height)
		{
			y -= (MS / 1000) * height * 0.5;

			if (y <= -height)
			{
				visible = false;
				active = false;

				#if FLX_SAVE
				// Save sound preferences
				if (FlxG.save.isBound)
				{
					FlxG.save.data.mute = FlxG.sound.muted;
					FlxG.save.data.volume = FlxG.sound.volume;
					FlxG.save.flush();
				}
				#end
			}
		}
	}
	
	/**
	 * Shows the volume animation for the desired settings
	 * @param   volume    The volume, 1.0 is full volume
	 * @param   sound     The sound to play, if any
	 * @param   duration  How long the tray will show
	 * @param   label     The test label to display
	 */
	public function showAnim(volume:Float, ?sound:FlxSoundAsset, duration = 1.0, label = "VOLUME")
	{
		if (sound != null)
			FlxG.sound.play(FlxG.assets.getSoundAddExt(sound));
		
		_timer = duration;
		y = 0;
		visible = true;
		active = true;
		final numBars = Math.round(volume * 10);
		for (i in 0..._bars.length)
			_bars[i].alpha = i < numBars ? 1.0 : 0.5;

		_label.text = label;
		updateSize();
	}
	
	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param   up  Whether the volume is increasing.
	 */
	@:deprecated("show is deprecated, use showAnim")
	public function show(up:Bool = false):Void
	{
		if (up)
			showIncrement();
		else
			showDecrement();
	}
	
	function showIncrement():Void
	{
		final volume = FlxG.sound.muted ? 0 : FlxG.sound.volume;
		showAnim(volume, silent ? null : volumeUpSound);
	}
	
	function showDecrement():Void
	{
		final volume = FlxG.sound.muted ? 0 : FlxG.sound.volume;
		showAnim(volume, silent ? null : volumeDownSound);
	}
	

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _bg.width * _defaultScale) - FlxG.game.x);
	}
	
	function updateSize()
	{
		if (_label.textWidth + 10 > _bg.width)
			_label.width = _label.textWidth + 10;
			
		_bg.width = _label.textWidth + 10 > _minWidth ? _label.textWidth + 10 : _minWidth;
		
		_label.width = _bg.width;
		
		var bx:Int = Std.int(_bg.width / 2 - 30);
		var by:Int = 14;
		for (i in 0..._bars.length)
		{
			_bars[i].x = bx;
			_bars[i].y = by;
			bx += 6;
			by--;
		}
		
		screenCenter();
	}
}
#end
