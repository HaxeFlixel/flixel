package org.flixel;

import nme.Assets;
import nme.events.Event;
import nme.media.Sound;
import nme.media.SoundChannel;
import nme.media.SoundTransform;
import nme.net.URLRequest;

/**
 * This is the universal flixel sound object, used for streaming, music, and sound effects.
 */
class FlxSound extends FlxBasic
{
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
	public var survive:Bool;
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
	 * Internal tracker for the position in runtime of the music playback.
	 */
	private var _position:Float;
	/**
	 * Internal tracker for how loud the sound is.
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
	private var _pan:Bool;
	/**
	 * Internal helper for fading sounds.
	 */
	private var _fade:FadeTween;
	/**
	 * Internal flag for what to do when the sound is done fading out.
	 */
	private var _onFadeComplete:Void->Void;
	
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
		
		_position = 0;
		_paused = false;
		_volume = 1.0;
		_volumeAdjust = 1.0;
		_looped = false;
		_target = null;
		_radius = 0;
		_pan = false;
		if (_fade != null)	_fade.destroy();
		_fade = null;
		_onFadeComplete = null;
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
	
	/**
	 * Clean up memory.
	 */
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
		
		_position = _channel.position;
		
		var radialMultiplier:Float = 1.0;
		var fadeMultiplier:Float = 1.0;
		
		//Distance-based volume control
		if (_target != null)
		{
			radialMultiplier = FlxU.getDistance(new FlxPoint(_target.x, _target.y), new FlxPoint(x, y)) / _radius;
			if(radialMultiplier < 0) radialMultiplier = 0;
			if(radialMultiplier > 1) radialMultiplier = 1;

			radialMultiplier = 1 - radialMultiplier;

			if (_pan)
			{
				var d:Float = (x-_target.x)/_radius;
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
		
		//Cross-fading volume control
		if (_fade != null)
		{
			_fade.progress += FlxG.elapsed;
			fadeMultiplier = _fade.value;

			if (_fade.finished)
			{
				_fade = null;
				if (_onFadeComplete != null) 
				{ 
					_onFadeComplete();
				}
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
	 * @param	AutoDestroy		Whether or not this <code>FlxSound</code> instance should be destroyed when the sound finishes playing.  Default value is false, but FlxG.play() and FlxG.stream() will set it to true by default.
	 * 
	 * @return	This <code>FlxSound</code> instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadEmbedded(EmbeddedSound:Dynamic, Looped:Bool = false, AutoDestroy:Bool = false):FlxSound
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
		return this;
	}
	
	/**
	 * One of two main setup functions for sounds, this function loads a sound from a URL.
	 * 
	 * @param	EmbeddedSound	A string representing the URL of the MP3 file you want to play.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this <code>FlxSound</code> instance should be destroyed when the sound finishes playing.  Default value is false, but FlxG.play() and FlxG.stream() will set it to true by default.
	 * 
	 * @return	This <code>FlxSound</code> instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadStream(SoundURL:String, Looped:Bool = false, AutoDestroy:Bool = false):FlxSound
	{
		cleanup(true);
		
		_sound = new Sound();
		_sound.addEventListener(Event.ID3, gotID3);
		_sound.load(new URLRequest(SoundURL));
		_looped = Looped;
		autoDestroy = AutoDestroy;
		updateTransform();
		exists = true;
		return this;
	}
	
	/**
	 * Call this function if you want this sound's volume to change
	 * based on distance from a particular FlxCore object.
	 * 
	 * @param	X		The X position of the sound.
	 * @param	Y		The Y position of the sound.
	 * @param	TargetObject	The object you want to track.
	 * @param	Radius	The maximum distance this sound can travel.
	 * @param	Pan		Whether the sound should pan in addition to the volume changes (default: true).
	 * 
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function proximity(X:Float, Y:Float, TargetObject:FlxObject, Radius:Float, Pan:Bool = true):FlxSound
	{
		x = X;
		y = Y;
		_target = TargetObject;
		_radius = Radius;
		_pan = Pan;
		return this;
	}
	
	/**
	 * Call this function to play the sound - also works on paused sounds.
	 * @param	ForceRestart	Whether to start the sound over or not.  Default value is false, meaning if the sound is already playing or was paused when you call <code>play()</code>, it will continue playing from its current position, NOT start again from the beginning.
	 */
	public function play(ForceRestart:Bool = false):Void
	{
		if (!exists)
		{
			return;
		}
		if (ForceRestart)
		{
			cleanup(false, true, true);
		}
		else if (playing)
		{
			// Already playing sound
			return;
		}
		
		if (_paused)
		{
			resume();
		}
		else
		{
			startSound(0);
		}
	}
	
	/**
	 * Unpause a sound.  Only works on sounds that have been paused.
	 */
	public function resume():Void
	{
		if (_paused)
		{
			startSound(_position);
		}
	}
	
	/**
	 * Call this function to pause this sound.
	 */
	public function pause():Void
	{
		if (!playing)
		{
			return;
		}
		_position = _channel.position;
		_paused = true;
		cleanup(false, false, false);
	}
	
	/**
	 * Call this function to stop this sound.
	 */
	public function stop():Void
	{
		cleanup(autoDestroy, true, true);
	}
	
	/**
	 * Call this function to make this sound fade out over a certain time interval.
	 * @param	Seconds			The amount of time the fade out operation should take.
	 * @param	PauseInstead	Tells the sound to pause on fadeout, instead of stopping.
	 */
	public function fadeOut(Seconds:Float, PauseInstead:Bool = false):Void
	{
		if (!playing)
		{
			return;
		}
		
		var fadeStartVolume:Float = ((_fade != null) ? _fade.value : 1);
		_fade = new FadeTween(fadeStartVolume, 0, Seconds);
		_onFadeComplete = (PauseInstead ? pause : stop);
	}
	
	/**
	 * Call this function to make a sound fade in over a certain
	 * time interval (calls <code>play()</code> automatically).
	 * @param	Seconds		The amount of time the fade-in operation should take.
	 */
	public function fadeIn(Seconds:Float):Void
	{
		if (playing && (_fade == null))
		{
			return;
		}
		
		var fadeStartVolume:Float = ((_fade != null) ? _fade.value : 0);
		_fade = new FadeTween(fadeStartVolume, 1, Seconds);
		_onFadeComplete = null;

		play();
	}
	
	/**
	 * Whether or not the sound is currently playing.
	 */
	public var playing(get_playing, null):Bool;
	
	private function get_playing():Bool
	{
		return (_channel != null);
	}
	
	/**
	 * Set <code>volume</code> to a value between 0 and 1 to change how this sound is.
	 */
	public var volume(get_volume, set_volume):Float;
	
	private function get_volume():Float
	{
		return _volume;
	}
	/**
	 * @private
	 */
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
	
	/**
	 * Returns the currently selected "real" volume of the sound (takes fades and proximity into account).
	 * @return	The adjusted volume of the sound.
	 */
	public function getActualVolume():Float
	{
		return _volume * _volumeAdjust;
	}
	
	/**
	 * Call after adjusting the volume to update the sound channel's settings.
	 */
	private function updateTransform():Void
	{
		_transform.volume = (FlxG.mute ? 0 : 1) * FlxG.volume * _volume * _volumeAdjust;
		if (_channel != null)
		{
			_channel.soundTransform = _transform;
		}
	}
	
	/**
	 * An internal helper function used to attempt to start playing the sound and populate the <code>_channel</code> variable.
	 */
	private function startSound(Position:Float):Void
	{
		var numLoops:Int = (_looped && (Position == 0)) ? 9999 : 0;
		_position = Position;
		_paused = false;
		_channel = _sound.play(_position, numLoops, _transform);
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
	 * @param	event		An <code>Event</code> object.
	 */
	private function stopped(event:Event = null):Void
	{
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
	 * An internal helper function used to help Flash clean up (and potentially re-use) finished sounds. Will stop the current sound and destroy the associated <code>SoundChannel</code>, plus, any other commands ordered by the passed in parameters.
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
			_position = 0;
			_paused = false;
		}

		if (resetFading)
		{
			if (_fade != null)	_fade.destroy();
			_fade = null;
			_onFadeComplete = null;
		}
	}
	
	/**
	 * Internal event handler for ID3 info (i.e. fetching the song name).
	 * @param	event	An <code>Event</code> object.
	 */
	private function gotID3(event:Event = null):Void
	{
		FlxG.log("got ID3 info!");
		name = _sound.id3.songName;
		artist = _sound.id3.artist;
		_sound.removeEventListener(Event.ID3, gotID3);
	}
}

/**
 * Simple class for tweening a simple numerical value from one point to another.
 * For more complex operations, please use a dedicated library such as TweenMax.
 *
 * This class does not use the "global" time to progress the tween, but must 
 * manually be incremented with the `progress` property.
 * 
 * @author	Andreas Renberg (IQAndreas)
 */
class FadeTween
{

	/**
	 * A simple, linear tween (constant motion, with no acceleration).
	 *
	 * @param StartValue	The starting value.
	 * @param EndValue	The end value.
	 * @param Duration	The total duration of the tween.
	 * @param Ease	The easing function used by the tween. Any tweening function from TweenMax library or the `fl.transitions.easing` package can be used. Defaults to `FadeTween.linear`.
	 */
	public function new(StartValue:Float, EndValue:Float, Duration:Float, Ease:Float->Float->Float->Float->Float = null)
	{
		easingFunction = (Ease != null) ? Ease : FadeTween.linear;

		// TODO: Verify perameters (such as negative duration, invalid start or end values, etc)
		startValue = StartValue;
		totalChange = EndValue - StartValue;
		duration = Duration;

		_progress = 0;
	}
	
	public function destroy():Void
	{
		easingFunction = null;
	}

	/**
	 * The easing function used by the Tween.
	 */
	private var easingFunction:Float->Float->Float->Float->Float;
	/**
	 * Internal tracker for the start value of the tween.
	 */
	private var startValue:Float;
	/**
	 * Internal tracker for the total change in value in the tween.
	 */
	private var totalChange:Float;
	/**
	 * Internal tracker for the duration of the tween.
	 */
	private var duration:Float;
	/**
	 * Internal tracker for the progress of the tween.
	 */
	private var _progress:Float;

	public var progress(get_progress, set_progress):Float;
	
	private function get_progress():Float
	{
		return _progress;
	}
	
	private function set_progress(value:Float):Float
	{
		if (value >= duration)
		{
			value = duration;
		}
		else if (value < 0)
		{
			value = 0;
		}

		_progress = value;
		return _progress;
	}

	public var finished(get_finished, null):Bool;
	
	private function get_finished():Bool
	{
		return (_progress >= duration);
	}

	public var value(get_value, null):Float;
	
	private function get_value():Float
	{
		return easingFunction(_progress, startValue, totalChange, duration);
	}

	/**
	 * A simple, linear tween (constant motion, with no acceleration).
	 *
	 * @param t	Specifies the current progress, between 0 and duration inclusive.
	 * @param b	Specifies the starting value.
	 * @param c	Specifies the total change in the value.
	 * @param d	Specifies the duration of the motion.
	 *
	 * @return	The value of the interpolated property at the specified time.
	 */
	public static function linear(t:Float, b:Float, c:Float, d:Float):Float
	{
		return b + (c * t) / d;
	}
}