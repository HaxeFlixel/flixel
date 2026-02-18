package flixel.sound;

#if flash
class FlxSoundTest extends FlxTest {}
#else
import FlxAssert;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import massive.munit.Assert;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

@:nullSafety(Strict)
class FlxSoundTest extends FlxTest
{
	
	static final silence1k1 = new DebugSound().loadSilence(1.0);
	static final silence1k2 = new DebugSound().loadSilence(1.0);
	static final silence750 = new DebugSound().loadSilence(0.75);
	static final silence100 = new DebugSound().loadSilence(0.1);
	
	var sound1:FlxSound = new FlxSound();
	var sound2:FlxSound = new FlxSound();
	var group:FlxSoundGroup = new FlxSoundGroup();
	
	@Before
	function before()
	{
		silence1k1.log = false;
		silence1k2.log = false;
		silence750.log = false;
		silence100.log = false;
		sound1 = new FlxSound();
		sound2 = new FlxSound();
		group = new FlxSoundGroup();
		group.add(sound1);
		group.add(sound2);
		FlxG.plugins.addPlugin(sound1);
		FlxG.plugins.addPlugin(sound2);
	}
	
	override function after()
	{
		super.after();
		
		FlxG.plugins.remove(sound1);
		FlxG.plugins.remove(sound2);
		sound2.destroy();
		sound1.destroy();
	}
	
	@Test // #1511
	function testLoadInvalidSoundPathNoCrash()
	{
		var sound = new FlxSound();
		sound.load("assets/invalid");
		sound.play();
	}
	
	@Test
	function testDebugSound()
	{
		Assert.isNotNull(silence1k1);
		Assert.isNotNull(silence1k2);
		Assert.isNotNull(silence750);
		Assert.isNotNull(silence100);
		
		sound1.load(silence100);
		sound1.play();
		Assert.isTrue(sound1.playing);
		Assert.areEqual(sound1.time, 0);
		
		step();
		
		Assert.isTrue(sound1.playing);
		Assert.isTrue(sound1.time > 0);
	}
	
	@Test
	function testCallback()
	{
		sound1.load(silence1k1);
		sound1.play();
		var callbackCalled = false;
		sound1.onComplete = ()->callbackCalled = true;
		
		step(FlxG.updateFramerate + 1);// +1 to account for float arith error
		
		Assert.isTrue(callbackCalled);
	}
	
	@Test
	function testAutoDestroy()
	{
		sound1.load(silence1k1).setup(1.0, false, false);// no autoDestroy
		sound1.play();
		sound2.load(silence1k2).setup(1.0, false, true);// autoDestroy
		sound2.play();
		
		step(FlxG.updateFramerate + 1);// +1 to account for float arith error
		
		Assert.isTrue(sound1.exists);
		Assert.isFalse(sound2.exists);
	}
	
	#if FLX_PITCH
	@Test
	function testPitch()
	{
		sound1.load(silence1k1);
		sound1.pitch = 2.0;
		var callbackCalled = false;
		sound1.onComplete = ()->callbackCalled = true;
		sound1.play();
		
		step(Math.ceil(FlxG.updateFramerate / 2) + 1);// +1 to account for float arith error
		
		if (callbackCalled)
			Assert.assertionCount++;
		else
		{
			@:privateAccess
			final channel = sound1._channel;
			Assert.fail('Expected sound to finish playing, but sound is at ${channel.position}/${sound1.length}');
		}
	}
	#end
	
	@Test
	function testTime()
	{
		sound1.load(silence1k1).play();
		
		step();
		
		final oldTime = sound1.time;
		Assert.isTrue(0 < sound1.time);
	}
	
	@Test
	function testLength()
	{
		sound1.load(silence100).play();
		
		Assert.areEqual(100, sound1.length);
	}
	
	@Test
	function testLooped()
	{
		sound1.load(silence750).setup(1.0, true).play();
		
		step(FlxG.updateFramerate * 10);
		
		Assert.areEqual(13, sound1.loopCount);
		Assert.isTrue(sound1.playing);
		Assert.isTrue(sound1.time < sound1.length && sound1.time > 0);
	}
	
	@Test
	function testLoopUntil()
	{
		sound1.load(silence750).setup(1.0, 3).play();
		
		step(FlxG.updateFramerate);
		
		Assert.areEqual(1, sound1.loopCount);
		Assert.isTrue(sound1.playing);
		Assert.isTrue(sound1.time < sound1.length && sound1.time > 0);
		
		step(FlxG.updateFramerate);
		
		Assert.areEqual(2, sound1.loopCount);
		Assert.isTrue(sound1.playing);
		Assert.isTrue(sound1.time < sound1.length && sound1.time > 0);
		
		step(FlxG.updateFramerate);
		
		Assert.areEqual(3, sound1.loopCount);
		Assert.isTrue(sound1.playing);
		Assert.isTrue(sound1.time < sound1.length && sound1.time > 0);
		
		step(FlxG.updateFramerate);
		
		Assert.areEqual(3, sound1.loopCount);
		Assert.isFalse(sound1.playing);
	}
	
	@Test
	function testLoopTimes()
	{
		sound1.load(silence1k1);
		sound1.play(true);
		sound1.looped = true;
		sound1.loopTime = 250;
		
		sound2.load(silence1k2);
		sound2.play(true);
		sound2.looped = true;
		sound2.loopTime = 250;
		sound2.endTime = 750;
		
		step(FlxG.updateFramerate + 1);// +1 to account for float arith error
		
		assertTimeGT(sound1, 250);
		assertTimeGT(sound2, 500);
	}
	
	@Test
	function testSetup()
	{
		final func = ()->{}
		
		function assertFields(volume:Float, looped:Bool, loops:Int, autoDestroy:Bool, onComplete:Null<()->Void>, ?pos)
		{
			Assert.areEqual(volume     , sound1.volume     , 'Expected volume to be ${volume     }, found: [${sound1.volume     }]', pos);
			Assert.areEqual(looped     , sound1.looped     , 'Expected looped to be ${looped     }, found: [${sound1.looped     }]', pos);
			Assert.areEqual(loops      , sound1.loopUntil  , 'Expected volume to be ${loops      }, found: [${sound1.volume     }]', pos);
			Assert.areEqual(autoDestroy, sound1.autoDestroy, 'Expected volume to be ${autoDestroy}, found: [${sound1.autoDestroy}]', pos);
			Assert.areEqual(onComplete , sound1.onComplete , 'Expected volume to be ${onComplete }, found: [${sound1.onComplete }]', pos);
		}
		
		sound1.setup(0.5, true, true, func);
		assertFields(0.5, true, -1, true, func);
		
		sound1.setup();
		assertFields(1.0, false, -1, false, null);
		
		sound1.setup(0.75, 3, true, func);
		assertFields(0.75, true, 3, true, func);
		
		sound1.setup(0.75, 2);
		assertFields(0.75, true, 2, false, null);
		
		sound1.setup(0.75, 0);
		assertFields(0.75, true, 0, false, null);
		
		sound1.setup(0.75, -1);
		assertFields(0.75, true, -1, false, null);
	}
	
	@Test
	@:access(flixel.sound.FlxSound)
	function testProximity()
	{
		sound1.load(silence100).setup(0.5, true).play();
		final transform = sound1._transform;
		final object = new FlxObject(50, 50, 1, 1);
		
		sound1.proximity(50, 50, object, 50, false);
		sound1.update(FlxG.elapsed);
		
		FlxAssert.areNear(0.5, transform.volume);
		
		sound1.proximity(75, 50, object, 50, false);
		sound1.update(FlxG.elapsed);
		
		FlxAssert.areNear(0.5, sound1.volume);
		FlxAssert.areNear(0.25, transform.volume);
		FlxAssert.areNear(0.0, sound1.pan);
		
		sound1.proximity(150, 50, object, 50, false);
		sound1.update(FlxG.elapsed);
		
		FlxAssert.areNear(0.0, transform.volume);
		
		sound1.proximity(75, 50, object, 50, true);
		sound1.update(FlxG.elapsed);
		
		FlxAssert.areNear(0.25, transform.volume);
		FlxAssert.areNear(0.5, sound1.pan);
		
		sound1.proximity(25, 50, object, 50, true);
		sound1.update(FlxG.elapsed);
		
		FlxAssert.areNear(0.25, transform.volume);
		FlxAssert.areNear(-0.5, sound1.pan);
	}
	
	@Test
	function testPlay()
	{
		sound1.load(silence100);
		sound1.play();
		
		Assert.isTrue(sound1.playing);
		Assert.areEqual(0, sound1.time);
		Assert.isNull(sound1.endTime);
		
		sound1.play(false, 250, 750);// no force restart, does nothing
		
		Assert.isTrue(sound1.playing);
		Assert.areEqual(0, sound1.time);
		Assert.isNull(sound1.endTime);
		
		sound1.play(true, 250, 750);// force restart
		
		Assert.isTrue(sound1.playing);
		Assert.areEqual(250, sound1.time);
		Assert.areEqual(750, sound1.endTime);
	}
	
	@Test
	function testPlayPaused()
	{
		sound1.load(silence1k1);
		sound1.play();
		
		step();
		
		Assert.isTrue(sound1.playing);
		
		sound1.pause();
		final oldTime = sound1.time;
		
		step(10);
		
		Assert.isFalse(sound1.playing);
		Assert.areEqual(oldTime, sound1.time);
		
		sound1.play(false, 250, 750);
		
		Assert.isTrue(sound1.playing);
		Assert.areEqual(oldTime, sound1.time);
		Assert.areEqual(750, sound1.endTime);
		
		step();
		
		assertTimeGT(sound1, oldTime + 1);
	}
	
	@Test
	function testResume()
	{
		sound1.load(silence1k1);
		sound1.play();
		
		step();
		
		Assert.isTrue(sound1.playing);
		final oldTime = sound1.time;
		
		sound1.resume();// no effect
		Assert.isTrue(sound1.playing);
		Assert.areEqual(oldTime, sound1.time);
		
		sound1.pause();
		step(10);
		
		Assert.isFalse(sound1.playing);
		Assert.areEqual(oldTime, sound1.time);
		
		sound1.resume();
		
		Assert.isTrue(sound1.playing);
		Assert.areEqual(oldTime, sound1.time);
		
		step();
		
		assertTimeGT(sound1, oldTime + 1);
	}
	
	@Test
	function testStop()
	{
		sound1.load(silence1k1);
		sound1.play();
		
		step();
		
		sound1.stop();
		
		Assert.isFalse(sound1.playing);
		Assert.isTrue(sound1.exists);
		Assert.areEqual(0, sound1.time);
		
		step(10);
		
		Assert.isFalse(sound1.playing);
		Assert.areEqual(0, sound1.time);
		
		sound1.resume();
		
		Assert.isFalse(sound1.playing);
		Assert.areEqual(0, sound1.time);
		
		sound1.play(false, 250);
		
		Assert.isTrue(sound1.playing);
		Assert.areEqual(250, sound1.time);
		
		sound1.autoDestroy = true;
		sound1.stop();
		
		Assert.isFalse(sound1.playing);
		Assert.isFalse(sound1.exists);
		Assert.areEqual(0, sound1.time);
	}
	
	@Test
	function testFadeOut()
	{
		Assert.areEqual(0, FlxG.updateFramerate % 2, 'This test requires an even updateFramerate, found ${FlxG.updateFramerate}');
		
		sound1.load(silence1k1);
		sound1.looped = true;
		sound1.volume = 0.75;
		sound1.play();
		
		step(FlxG.updateFramerate);
		
		var fadeComplete = false;
		sound1.fadeOut(1.0, 0.25, function (tween)
		{
			Assert.areEqual(tween, sound1.fadeTween);
			fadeComplete = true;
		});
		
		Assert.areEqual(0.75, sound1.volume);
		
		step(FlxG.updateFramerate >> 1);
		
		Assert.areEqual(0.5, sound1.volume);
		Assert.isFalse(fadeComplete);
		
		step(FlxG.updateFramerate >> 1);
		
		FlxAssert.areNear(0.25, sound1.volume);
		Assert.isFalse(fadeComplete, 'Expected fadeOut to be uncompleted, was completed');
		
		step();// one more for tween to complete
		
		Assert.areEqual(0.25, sound1.volume);
		Assert.isTrue(fadeComplete, 'Expected fadeOut to be completed, was not');
		Assert.isTrue(sound1.playing);
	}
	
	@Test
	function testFadeIn()
	{
		Assert.areEqual(0, FlxG.updateFramerate % 2, 'This test requires an even updateFramerate, found ${FlxG.updateFramerate}');
		
		sound1.load(silence1k1);
		sound1.looped = true;
		Assert.isFalse(sound1.playing);
		
		var fadeComplete = false;
		sound1.fadeIn(1.0, 0.25, 0.75, function (tween)
		{
			Assert.areEqual(tween, sound1.fadeTween);
			fadeComplete = true;
		});
		
		Assert.isTrue(sound1.playing);
		
		step(FlxG.updateFramerate >> 1);
		
		Assert.areEqual(0.5, sound1.volume);
		Assert.isFalse(fadeComplete);
		
		step(FlxG.updateFramerate >> 1);
		
		Assert.areEqual(0.75, sound1.volume);
		Assert.isFalse(fadeComplete, 'Expected fadeIn to be uncompleted');
		
		step();// one more for tween to complete
		
		Assert.areEqual(0.75, sound1.volume);
		Assert.isTrue(fadeComplete, 'Expected fadeIn to be completed');
	}
	
	@Test
	function testVolume()
	{
		sound1.volume = 1.0;
		Assert.areEqual(1.0, sound1.volume);
		
		sound1.volume = 0.0;
		Assert.areEqual(0.0, sound1.volume);
		
		sound1.volume = -0.5;
		Assert.areEqual(0.0, sound1.volume);
		
		sound1.volume = 1.5;
		Assert.areEqual(1.0, sound1.volume);
	}
	
	@Test
	function testSetPosition()
	{
		sound1.setPosition(5);
		Assert.areEqual(5, sound1.x);
		Assert.areEqual(0, sound1.y);
		
		sound1.setPosition(10, 10);
		Assert.areEqual(10, sound1.x);
		Assert.areEqual(10, sound1.y);
		
		sound1.setPosition();
		Assert.areEqual(0, sound1.x);
		Assert.areEqual(0, sound1.y);
	}
	
	@Test
	@Ignore("Not implemented in openfl")
	function testId3()
	{
		sound1.load(silence100);
		Assert.areEqual('A sound .1 seconds long', sound1.name);
		Assert.areEqual(DebugSound.ID3_ARTIST, sound1.artist);
		
		sound1.load(silence1k1);
		Assert.areEqual('A sound 1 seconds long', sound1.name);
		
		sound1.autoDestroy = true;
		sound1.play();
		
		step(FlxG.updateFramerate + 1);
		
		Assert.isNull(sound1.name);
		Assert.isNull(sound1.artist);
	}
	
	@Test
	@Ignore("Not implemented in openfl")
	function testAmplitude()
	{
	}
	
	function assertTimeGT(sound:FlxSound, expectedMin:Float, ?pos)
	{
		if (sound.time >= expectedMin)
			Assert.assertionCount++;
		else
			Assert.fail('Expected sound.time to be at least ${expectedMin}, found ${sound.time}', pos);
	}
}

class DebugSound extends Sound
{
	public static inline var ID3_ARTIST = "HaxeFlixel";
	public static inline var ID3_ALBUM = "Unit Tests";
	public static inline var ID3_COMMENT = "Used to test FlxSounds";
	public static inline var ID3_GENRE = "Techno";
	public static inline var ID3_YEAR = "2026";
	
	
	static inline var SAMPLE_RATE = 44100;
	static inline var HEADER_BYTES
		= '524946460000000057415645666d7420100000000100010044ac000088580100020008006461746100000000';
		// |       |       |       |       |       |   |   |       |       |       |       |       
		// R_I_F_F_<-size->W_A_V_E_f_m_t_ _<--16--><01><ch><44100-><bytrte><blkaln><btsPer><sampls>
	
	public var log = false;
	
	public function new ()
	{
		super();
	}
	
	public function loadSilence(seconds:Float)
	{
		// id3.songName = 'A sound $seconds seconds long';
		
		final numSamples = Std.int(SAMPLE_RATE * seconds);
		final samples = haxe.io.Bytes.alloc(numSamples);
		for (i in 0...numSamples)
			samples.set(i, 0x80);
		
		final rawBytes = haxe.io.Bytes.ofHex(HEADER_BYTES + samples.toHex());
		rawBytes.setInt32(4, 36 + samples.length);
		rawBytes.setInt32(40, samples.length);
		
		final bytes = openfl.utils.ByteArray.fromBytes(rawBytes);
		loadCompressedDataFromByteArray(bytes, bytes.length);
		return this;
	}
	
	var debugElapsed = 0.0;
	var debugStartTime = 0.0;
	var debugChannel:Null<SoundChannel> = null;
	override function play(startTime:Float = 0.0, loops:Int = 0, sndTransform:SoundTransform = null):SoundChannel
	{
		if (log) trace('play($startTime, $loops, $sndTransform');
		
		debugChannel = super.play(startTime, loops, sndTransform);
		debugStartTime = startTime;
		debugElapsed = 0.0;
		FlxG.signals.preUpdate.add(onStep);
		return debugChannel;
	}
	
	function onStep()
	{
		if (debugChannel == null)
			return;
		
		#if FLX_PITCH
		@:privateAccess
		final source = #if (openfl < "9.3.2") debugChannel.__source #else debugChannel.__audioSource #end;
		if (source == null)
			return;
		final pitch = source.pitch;
		#else
		final pitch = 1.0;
		#end
		
		
		debugElapsed += FlxG.elapsed * pitch;
		final position = Std.int(1000 * debugElapsed) + debugStartTime;
		if (position < length)
		{
			debugChannel.position = position;
			if (log)
				trace('step: ${debugChannel.position}');
		}
		else
		{
			debugChannel.position = length;
			debugChannel.dispatchEvent(new openfl.events.Event(openfl.events.Event.SOUND_COMPLETE));
			if (log)
				trace('complete');
		}
		
		// @:privateAccess 
		// trace('step: $debugPosition-${debugChannel.position} valid: ${debugChannel.__isValid}');
	}
	
	public function destroy()
	{
		FlxG.signals.preUpdate.remove(onStep);
	}
}
#end