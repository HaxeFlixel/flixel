/**
 * FlxFlod
 * -- Part of the Flixel Power Tools set
 * 
 * v1.3 Added full FlxFlectrum support
 * v1.2 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.3 - July 29th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm 
{
	import neoart.flectrum.Flectrum;
	import neoart.flectrum.SoundEx;
	import org.flixel.*;
	import neoart.flod.*;
	
	import flash.utils.ByteArray;
	import flash.media.SoundTransform;
	
	/**
	 * FlxFlod adds support for the Flod AS3 Replay library by Christian Corti.<br />
	 * Flod is an incredibly powerful library allowing you to play tracker music from the Amiga / ST / PC (SoundTracker, ProTracker, etc)<br />
	 * More information about Flod can be found here: http://www.photonstorm.com/flod<br /><br />
	 * 
	 * This class works without modifying flixel, however the mute/volume/pause/resume commands won't be hooked into flixel.<br />
	 * You can either use a patched version of Flixel which is provided in this repository:<br />
	 * flash-game-dev-tips\Flixel Versions\Flixel v2.43 Patch 1.0
	 * <br />
	 * Or you can patch FlxG manually by doing the following:<br /><br />
	 * 
	 * 1) Add <code>import com.photonstorm.flixel.FlxFlod;</code> at the top of FlxG.as:<br />
	 * 2) Find the function <code>static public function set mute(Mute:Boolean):void</code> and add this line at the end of it: <code>FlxFlod.mute = Mute;</code><br />
	 * 3) Find the function <code>static public function set volume(Volume:Number):void</code> and add this line at the end of it: <code>FlxFlod.volume = Volume;</code><br />
	 * 4) Find the function <code>static protected function pauseSounds():void</code> and add this line at the end of it: <code>FlxFlod.pause();</code><br />
	 * 5) Find the function <code>static protected function playSounds():void</code> and add this line at the end of it: <code>FlxFlod.resume();</code><br /><br />
	 * 
	 * Flixel will now be patched so that any music playing via FlxFlod responds to the global flixel mute, volume and pause controls
	 */
	
	public class FlxFlod
	{
		private static var processor:ModProcessor;
		private static var modStream:ByteArray;
		private static var soundform:SoundTransform = new SoundTransform();
		
		private static var fadeTimer:FlxDelay;
		
		private static var callbackHooksCreated:Boolean = false;
		
		private static var sound:SoundEx = new SoundEx;
		public static var flectrum:FlxFlectrum;
		
		/**
		 * Starts playback of a tracker module
		 * 
		 * @param	toon	The music to play
		 * 
		 * @return	Boolean	true if playback started successfully, false if not
		 */
		public static function playMod(toon:Class):Boolean
		{
			stopMod();
			
			modStream = new toon() as ByteArray;
			
			processor = new ModProcessor();
			
			if (processor.load(modStream))
			{
				processor.loopSong = true;
				processor.stereo = 0;
				processor.play(sound);
				
				if (processor.soundChannel)
				{
					soundform.volume = FlxG.volume;
					processor.soundChannel.soundTransform = soundform;
				}
				
				if (callbackHooksCreated == false)
				{
					FlxG.volumeHandler = updateVolume;
					callbackHooksCreated = true;
				}
				
				return true;
				
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Creates a Flectrum (VU Meter / Spectrum Analyser)
		 * 
		 * @param	x				The x position of the flectrum in game world coordinates
		 * @param	y				The y position of the flectrum in game world coordinates
		 * @param	meter			A graphic to use for the meter (bar) of the flectrum. Default null uses a solid fill rectangle.
		 * @param	showBackground	Display an alpha background behind the meters
		 * @param	backgroundBeat	Makes the alpha background pulsate in time to the music
		 * @param	columns			The number of columns in the flectrum
		 * @param	columnSize		The width of each column in pixels - if you use your own meter graphic this value is ignored
		 * @param	columnSpacing	The spacing in pixels between each column (meter) of the flectrum
		 * @param	rows			The number of rows in the flectrum
		 * @param	rowSize			The height of each row. Overall flectrum height is rowSize + rowSpacing * rows - if you use your own meter graphic this value is ignored
		 * @param	rowSpacing		The spacing in pixels between each row of the flectrum - if you use your own meter graphic this value is ignored
		 * 
		 * @return	The FlxFlectrum instance for further modification. Also available via FlxFlod.flectrum
		 */
		public static function createFlectrum(x:int, y:int, meter:Class = null, showBackground:Boolean = false, backgroundBeat:Boolean = false, columns:int = 15, columnSize:int = 10, columnSpacing:int = 0, rows:int = 32, rowSize:int = 3, rowSpacing:int = 0):FlxFlectrum
		{
			flectrum = new FlxFlectrum();
			
			flectrum.init(x, y, sound, columns, columnSize, columnSpacing, rows, rowSize, rowSpacing);
			
			if (meter)
			{
				flectrum.useBitmap(meter);
			}
			
			flectrum.showBackground = showBackground;
			flectrum.backgroundBeat = backgroundBeat;
			
			return flectrum;
		}
		
		/**
		 * Pauses playback of this module, if started
		 */
		public static function pause():void
		{
			if (processor)
			{
				processor.pause();
			}
		}
		
		/**
		 * Resumes playback of this module if paused
		 */
		public static function resume():void
		{
			if (processor)
			{
				processor.resume();
			}
		}
		
		/**
		 * Stops playback of this module, if started
		 */
		public static function stopMod():void
		{
			if (processor)
			{
				processor.stop();
			}
		}
		
		/**
		 * Toggles playback mute
		 */
		public static function set mute(Mute:Boolean):void
		{
			if (processor)
			{
				if (Mute)
				{
					if (processor.soundChannel)
					{
						soundform.volume = 0;
						processor.soundChannel.soundTransform = soundform;
					}
				}
				else
				{
					if (processor.soundChannel)
					{
						soundform.volume = FlxG.volume;
						processor.soundChannel.soundTransform = soundform;
					}
				}
			}
		}
		
		/**
		 * Called by FlxG when the volume is adjusted in-game
		 * 
		 * @param	Volume
		 */
		public static function updateVolume(Volume:Number):void
		{
			volume = Volume;
		}
		
		/**
		 * Sets the playback volume directly (usually controlled by FlxG.volume)
		 */
		public static function set volume(Volume:Number):void
		{
			if (processor)
			{
				if (processor.soundChannel)
				{
					soundform.volume = Volume;
					processor.soundChannel.soundTransform = soundform;
				}
			}
		}
		
		/**
		 * Is a tune already playing?
		 */
		public static function get isPlaying():Boolean
		{
			if (processor)
			{
				return processor.isPlaying;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Is a tune paused?
		 */
		public static function get isPaused():Boolean
		{
			if (processor)
			{
				return processor.isPaused;
			}
			else
			{
				return false;
			}
		}
		
	}

}