package flixel.system;

#if !FLX_NO_SOUND_SYSTEM
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.tweens.FlxTween;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import openfl.Assets;
#end

/**
 * This is the universal flixel sound object, used for streaming, music, and sound effects.
 */
class FlxSound extends FlxBasic
{
	#if !FLX_NO_SOUND_SYSTEM
	/**
	 * The X position of this sound in world coordinates.
	 * Only really matters if you are doing proximity/panning stuff.
	 */
	public var x:Float;
	/**
	 * The Y position of this sound in world coordinates.
	 * Only really matters if you are doing proximity/panning stuff.
	 */
	public var y:Float;
	/**
	 * Whether or not this sound should be automatically destroyed when you switch states.
	 */
	public var persist:Bool;
	/**
	 * The ID3 song name.  Defaults to null.  Currently only works for streamed sounds.
	 */
	public var name:String;
	/**
	 * The ID3 artist name.  Defaults to null.  Currently only works for streamed sounds.
	 */
	public var artist:String;
	/**
	 * Stores the average wave amplitude of both stereo channels
	 */
	public var amplitude:Float;
	/**
	 * Just the amplitude of the left stereo channel
	 */
	public var amplitudeLeft:Float;
	/**
	 * Just the amplitude of the left stereo channel
	 */
	public var amplitudeRight:Float;
	/**
	 * Whether to call destroy() when the sound has finished.
	 */
	public var autoDestroy:Bool;
	/**
	 * Tracker for sound complete callback. Default is null. If assigend, will be called 
	 * each time when sound reaches its end. Works only on flash and desktop targets.
	 */
	public var onComplete:Void->Void;
	/**
	 * Pan amount. -1 = full left, 1 = full right. Proximity based panning overrides this.
	 */
	public var pan(get, set):Float;
	/**
	 * Whether or not the sound is currently playing.
	 */
	public var playing(get, null):Bool;
	/**
	 * Set volume to a value between 0 and 1 to change how this sound is.
	 */
	public var volume(get, set):Float;
	/**
	 * The position in runtime of the music playback.
	 */
	public var time(default, null):Float;

	/**
	 * Internal tracker for a Flash sound object.
	 */
	private var _sound:Sound;
	/**
	 * Internal tracker for a Flash sound channel object.
	 */
	private var _channel:SoundChannel;
	/**
	 * Internal tracker for a Flash sound transform object.
	 */
	private var _transform:SoundTransform;
	/**
	 * Internal tracker for whether the sound is paused or not (not the same as stopped).
	 */
	private var _paused:Bool;
	/**
	 * Internal tracker for volume.
	 */
	private var _volume:Float;
	/**
	 * Internal tracker for total volume adjustment.
	 */
	private var _volumeAdjust:Float = 1.0;
	/**
	 * Internal tracker for whether the sound is looping or not.
	 */
	private var _looped:Bool;
	/**
	 * Internal tracker for the sound's "target" (for proximity and panning).
	 */
	private var _target:FlxObject;
	/**
	 * Internal tracker for the maximum effective radius of this sound (for proximity and panning).
	 */
	private var _radius:Float;
	/**
	 * Internal tracker for whether to pan the sound left and right.  Default is false.
	 */
	private var _proximityPan:Bool;
	/**
	 * Helper var to prevent the sound from playing after focus was regained when it was already paused.
	 */
	private var _alreadyPaused:Bool = false;
	
	/**
	 * The FlxSound constructor gets all the variables initialized, but NOT ready to play a sound yet.
	 */
	public function new()
	{
		super();
		reset();
	}
	
	/**
	 * An internal function for clearing all the variables used by sounds.
	 */
	private function reset():Void
	{
		destroy();
		
		x = 0;
		y = 0;
		
		time = 0;
		_paused = false;
		_volume = 1.0;
		_volumeAdjust = 1.0;
		_looped = false;
		_target = null;
		_radius = 0;
		_proximityPan = false;
		visible = false;
		amplitude = 0;
		amplitudeLeft = 0;
		amplitudeRight = 0;
		autoDestroy = false;
		
		if (_transform == null)
		{
			_transform = new SoundTransform();
		}
		_transform.pan = 0;
	}
	
	override public function destroy():Void
	{
		_transform = null;
		exists = false;
		active = false;
		_target = null;
		name = null;
		artist = null;
		
		if (_channel != null)
		{
			_channel.removeEventListener(Event.SOUND_COMPLETE, stopped);
			_channel.stop();
			_channel = null;
		}
		
		if (_sound != null)
		{
			_sound.removeEventListener(Event.ID3, gotID3);
			_sound = null;
		}
		
		onComplete = null;
		
		super.destroy();
	}
	
	/**
	 * Handles fade out, fade in, panning, proximity, and amplitude operations each frame.
	 */
	override public function update():Void
	{
		if (!playing)
		{
			return;
		}
		
		time = _channel.position;
		
		var radialMultiplier:Float = 1.0;
		var fadeMultiplier:Float = 1.0;
		
		//Distance-based volume control
		if (_target != null)
		{
			radialMultiplier = FlxMath.getDistance(FlxPoint.get(_target.x, _target.y), FlxPoint.get(x, y)) / _radius;
			if (radialMultiplier < 0) radialMultiplier = 0;
			if (radialMultiplier > 1) radialMultiplier = 1;
			
			radialMultiplier = 1 - radialMultiplier;
			
			if (_proximityPan)
			{
				var d:Float = (x - _target.x) / _radius;
				if (d < -1) 
				{
					d = -1;
				}
				else if (d > 1) 
				{
					d = 1;
				}
				_transform.pan = d;
			}
		}
		
		_volumeAdjust = radialMultiplier * fadeMultiplier;
		updateTransform();
		
		if (_transform.volume > 0)
		{
			amplitudeLeft = _channel.leftPeak / _transform.volume;
			amplitudeRight = _channel.rightPeak / _transform.volume;
			amplitude = (amplitudeLeft + amplitudeRight) * 0.5;
		}
		else
		{
			amplitudeLeft = 0;
			amplitudeRight = 0;
			amplitude = 0;			
		}
	}
	
	override public function kill():Void
	{
		super.kill();
		cleanup(false);
	}
	
	/**
	 * One of two main setup functions for sounds, this function loads a sound from an embedded MP3.
	 * 
	 * @param	EmbeddedSound	An embedded Class object representing an MP3 file.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this FlxSound instance should be destroyed when the sound finishes playing.  Default value is false, but FlxG.sound.play() and FlxG.sound.stream() will set it to true by default.
	 * 
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadEmbedded(EmbeddedSound:Dynamic, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
	{
		cleanup(true);
		
		if (Std.is(EmbeddedSound, Sound))
		{
			_sound = EmbeddedSound;
		}
		else if (Std.is(EmbeddedSound, Class))
		{
			_sound = Type.createInstance(EmbeddedSound, []);
		}
		else if (Std.is(EmbeddedSound, String))
		{
			_sound = Assets.getSound(EmbeddedSound);
		}
		
		//NOTE: can't pull ID3 info from embedded sound currently
		_looped = Looped; 
		autoDestroy = AutoDestroy;
		updateTransform();
		exists = true;
		onComplete = OnComplete;
		return this;
	}
	
	/**
	 * One of two main setup functions for sounds, this function loads a sound from a URL.
	 * 
	 * @param	EmbeddedSound	A string representing the URL of the MP3 file you want to play.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this FlxSound instance should be destroyed when the sound finishes playing.  Default value is false, but FlxG.sound.play() and FlxG.sound.stream() will set it to true by default.
	 * 
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadStream(SoundURL:String, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
	{
		cleanup(true);
		
		_sound = new Sound();
		_sound.addEventListener(Event.ID3, gotID3);
		_sound.load(new URLRequest(SoundURL));
		_looped = Looped;
		autoDestroy = AutoDestroy;
		updateTransform();
		exists = true;
		onComplete = OnComplete;
		return this;
	}
	
	/**
	 * One of the main setup functions for sounds, this function loads a sound from a ByteArray.
	 * 
	 * @param	Bytes 			A ByteArray object.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this FlxSound instance should be destroyed when the sound finishes playing.  Default value is false, but FlxG.sound.play() and FlxG.sound.stream() will set it to true by default.
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadByteArray(Bytes:ByteArray, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
	{
		cleanup(true);
		
		#if js
		onComplete();
		#else
		_sound = new Sound();
		_sound.addEventListener(Event.ID3, gotID3);
		_sound.loadCompressedDataFromByteArray(Bytes, Bytes.length);
		_looped = Looped;
		autoDestroy = AutoDestroy;
		updateTransform();
		exists = true;
		onComplete = OnComplete;
		#end
		return this;	
	}
	
	/**
	 * Call this function if you want this sound's volume to change
	 * based on distance from a particular FlxObject.
	 *
	 * @param	X			The X position of the sound.
	 * @param	Y			The Y position of the sound.
	 * @param	TargetObject		The object you want to track.
	 * @param	Radius			The maximum distance this sound can travel.
	 * @param	Pan			Whether panning should be used in addition to the volume changes (default: true).
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function proximity(X:Float, Y:Float, TargetObject:FlxObject, Radius:Float, Pan:Bool = true):FlxSound
	{
		x = X;
		y = Y;
		_target = TargetObject;
		_radius = Radius;
		_proximityPan = Pan;
		return this;
	}
	
	/**
	 * Call this function to play the sound - also works on paused sounds.
	 * 
	 * @param	ForceRestart	Whether to start the sound over or not.  Default value is false, meaning if the sound is already playing or was paused when you call play(), it will continue playing from its current position, NOT start again from the beginning.
	 */
	public function play(ForceRestart:Bool = false):FlxSound
	{
		if (!exists)
		{
			return this;
		}
		if (ForceRestart)
		{
			cleanup(false, true, true);
		}
		else if (playing)
		{
			// Already playing sound
			return this;
		}
		
		if (_paused)
		{
			resume();
		}
		else
		{
			startSound(0);
		}
		return this;
	}
	
	/**
	 * Unpause a sound.  Only works on sounds that have been paused.
	 */
	public function resume():FlxSound
	{
		if (_paused)
		{
			startSound(time);
		}
		return this;
	}
	
	/**
	 * Call this function to pause this sound.
	 */
	public function pause():FlxSound
	{
		if (!playing)
		{
			return this;
		}
		time = _channel.position;
		_paused = true;
		cleanup(false, false, false);
		return this;
	}
	
	/**
	 * Call this function to stop this sound.
	 */
	public inline function stop():FlxSound
	{
		cleanup(autoDestroy, true, true);
		return this;
	}
	
	/**
	 * Helper function that tweens this sound's volume.
	 * 
	 * @param	Duration	The amount of time the fade-out operation should take.
	 * @param	To			The volume to tween to, 0 by default.
	 */
	public inline function fadeOut(Duration:Float = 1, ?To:Float = 0):FlxSound
	{
		FlxTween.num(volume, To, Duration, null, volumeTween);
		return this;
	}
	
	/**
	 * Helper function that tweens this sound's volume.
	 * 
	 * @param	Duration	The amount of time the fade-in operation should take.
	 * @param	From		The volume to tween from, 0 by default.
	 * @param	To			The volume to tween to, 1 by default.
	 */
	public inline function fadeIn(Duration:Float = 1, From:Float = 0, To:Float = 1):FlxSound
	{
		FlxTween.num(From, To, Duration, null, volumeTween);
		return this;
	}
	
	private function volumeTween(f:Float):Void
	{
		volume = f;
	}
	
	/**
	 * Returns the currently selected "real" volume of the sound (takes fades and proximity into account).
	 * 
	 * @return	The adjusted volume of the sound.
	 */
	public inline function getActualVolume():Float
	{
		return _volume * _volumeAdjust;
	}
	
	/**
	 * Helper function to set the coordinates of this object.
	 * Sound positioning is used in conjunction with proximity/panning.
	 * 
	 * @param        X        The new x position
	 * @param        Y        The new y position
 	 */
	public inline function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}
	
	/**
	 * Call after adjusting the volume to update the sound channel's settings.
	 */
	private function updateTransform():Void
	{
		_transform.volume = (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * _volume * _volumeAdjust;
		if (_channel != null)
		{
			_channel.soundTransform = _transform;
		}
	}
	
	/**
	 * An internal helper function used to attempt to start playing the sound and populate the _channel variable.
	 */
	private function startSound(Position:Float):Void
	{
		var numLoops:Int = (_looped && (Position == 0)) ? 9999 : 0;
		time = Position;
		_paused = false;
		_channel = _sound.play(time, numLoops, _transform);
		if (_channel != null)
		{
			_channel.addEventListener(Event.SOUND_COMPLETE, stopped);
			active = true;
		}
		else
		{
			exists = false;
			active = false;
		}
	}
	
	/**
	 * An internal helper function used to help Flash clean up finished sounds or restart looped sounds.
	 * 
	 * @param	event		An Event object.
	 */
	private function stopped(event:Event = null):Void
	{
		if (onComplete != null)
		{
			onComplete();
		}
		
		if (_looped)
		{
			cleanup(false);
			play();
		}
		else
		{
			cleanup(autoDestroy);
		}
	}
	
	/**
	 * An internal helper function used to help Flash clean up (and potentially re-use) finished sounds. Will stop the current sound and destroy the associated SoundChannel, plus, any other commands ordered by the passed in parameters.
	 * 
	 * @param  destroySound    Whether or not to destroy the sound. If this is true, the position and fading will be reset as well.
	 * @param  resetPosition    Whether or not to reset the position of the sound.
	 * @param  resetFading    Whether or not to reset the current fading variables of the sound.
	 */
	private function cleanup(destroySound:Bool, resetPosition:Bool = true, resetFading:Bool = true):Void
	{
		if (destroySound)
		{
			reset();
			return;
		}
		
		if (_channel != null)
		{
			_channel.removeEventListener(Event.SOUND_COMPLETE, stopped);
			_channel.stop();
			_channel = null;
		}
		
		active = false;

		if (resetPosition)
		{
			time = 0;
			_paused = false;
		}
	}
	
	/**
	 * Internal event handler for ID3 info (i.e. fetching the song name).
	 * @param	event	An Event object.
	 */
	private function gotID3(?event:Event):Void
	{
		FlxG.log.notice("Got ID3 info.");
		name = _sound.id3.songName;
		artist = _sound.id3.artist;
		_sound.removeEventListener(Event.ID3, gotID3);
	}
	
	@:allow(flixel.system.frontEnds.SoundFrontEnd)
	private function onFocus():Void
	{
		if (!_alreadyPaused)
		{
			resume();
		}
	}
	
	@:allow(flixel.system.frontEnds.SoundFrontEnd)
	private function onFocusLost():Void
	{
		_alreadyPaused = _paused;
		pause();
	}
	
	private inline function get_playing():Bool
	{
		return (_channel != null);
	}
	
	private inline function get_volume():Float
	{
		return _volume;
	}
	
	private function set_volume(Volume:Float):Float
	{
		_volume = Volume;
		if (_volume < 0)
		{
			_volume = 0;
		}
		else if (_volume > 1)
		{
			_volume = 1;
		}
		updateTransform();
		return Volume;
	}
	
	private inline function get_pan():Float
	{
		return _transform.pan;
	}
	
	private inline function set_pan(pan:Float):Float
	{
		return _transform.pan = pan;
	}
	#end
}
