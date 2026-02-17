package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import massive.munit.Assert;
import openfl.media.Sound;

class SoundFrontEndTest
{
	#if FLX_SOUND_SYSTEM
	@Test // #1511
	function testPlayInvalidSoundPathNoCrash()
	{
		FlxG.sound.play("assets/invalid");
	}

	@Test // #1511
	function testPlayMusicInvalidSoundPathNoCrash()
	{
		FlxG.sound.playMusic("assets/invalid");
	}

	@Test // #1511
	function testLoadInvalidSoundPathNoCrash()
	{
		FlxG.sound.create("assets/invalid").play();
	}

	@Test // #1511
	function testSoundCurve()
	{
		Assert.areEqual(1.0, FlxG.sound.applySoundCurve(1));
		Assert.areEqual(1.0, FlxG.sound.reverseSoundCurve(1));
		
		FlxG.sound.applySoundCurve = function (volume)
		{
			final clampedVolume = Math.max(0, Math.min(1, volume));
			return Math.exp(Math.log(0.001) * (1 - volume));
		};
		
		FlxG.sound.reverseSoundCurve = function (volume)
		{
			final clampedVolume = Math.max(0.001, Math.min(1, volume));
			return 1 - (Math.log(clampedVolume) / Math.log(0.001));
		};
		
		FlxAssert.areNear(1.0, FlxG.sound.applySoundCurve(1));
		FlxAssert.areNear(1.0, FlxG.sound.reverseSoundCurve(1));
		FlxAssert.areNear(0.001, FlxG.sound.applySoundCurve(0));
		FlxAssert.areNear(0.0, FlxG.sound.reverseSoundCurve(0));
		FlxAssert.areNear(0.031, FlxG.sound.applySoundCurve(0.5));
		FlxAssert.areNear(0.899, FlxG.sound.reverseSoundCurve(0.5));
		FlxAssert.areNear(0.5, FlxG.sound.reverseSoundCurve(FlxG.sound.applySoundCurve(0.5)));
	}
	
	@Test
	@:haxe.warning("-WDeprecated")
	function testPlayMusicOverloads()
	{
		final group = new FlxSoundGroup();
		final sound:Sound = debugSound(1000);
		
		function assertSoundProps(volume:Float, loop:Bool, inGroup:Bool)
		{
			final music = FlxG.sound.music;
			Assert.areEqual(volume, music.volume);
			Assert.areEqual(loop, music.looped);
			Assert.areEqual(inGroup ? group : FlxG.sound.defaultMusicGroup, music.group);
		}
		
		// Check that all possible overloads of the old version work with the new overloads
		FlxG.sound.playMusic(sound, 0.5, false, null);
		assertSoundProps(0.5, false, false);
		
		FlxG.sound.playMusic(sound, 0.5, false, group);
		assertSoundProps(0.5, false, true);
		
		FlxG.sound.playMusic(sound, 0.5, false);
		assertSoundProps(0.5, false, false);
		
		FlxG.sound.playMusic(sound, 0.5);
		assertSoundProps(0.5, true, false);
		
		FlxG.sound.playMusic(sound);
		assertSoundProps(1.0, true, false);
		#if !flash
		FlxG.sound.playMusic(sound, 0.5, group);
		assertSoundProps(0.5, true, true);
		
		FlxG.sound.playMusic(sound, null);
		assertSoundProps(1.0, true, false);
		
		FlxG.sound.playMusic(sound, group);
		assertSoundProps(1.0, true, true);
		
		FlxG.sound.playMusic(sound, false);
		assertSoundProps(1.0, false, false);
		#end
	}
	#end
	
	@Test
	@:haxe.warning("-WDeprecated")
	function testAddExtDefaults()
	{
		final partialPath = 'assets/sounds/test';
		final fullPath = partialPath + FlxG.assets.defaultSoundExtension;
		final soundAsset = new DebugSound(1000);
		
		final oldGetFunc = FlxG.assets.getAssetUnsafe;
		FlxG.assets.getAssetUnsafe = function (id, _, useCache = true)
		{
			// trace('getting: $id');
			return id == fullPath ? soundAsset : null;
		}
		
		final oldStreamFunc = FlxG.assets.streamSoundUnsafe;
		FlxG.assets.streamSoundUnsafe = function (id)
		{
			// trace('streaming: $id');
			return id == fullPath ? soundAsset : null;
		}
		
		final oldExistsFunc = FlxG.assets.exists;
		FlxG.assets.exists = function (id, ?_)
		{
			// trace('exists: $id');
			return id == fullPath;
		}
		
		final oldCanStreamFunc = FlxG.assets.canStreamSound;
		FlxG.assets.canStreamSound = function (id)
		{
			// trace('canStream: $id');
			return true;
		}
		
		inline function assertPathSuccess(sound:FlxSound, ?pos)
		{
			if (sound == null)
				Assert.fail("Expected sound instance, got null", pos);
			
			@:privateAccess
			final actual = sound._sound;
			Assert.areEqual(soundAsset, actual, pos);
		}
		
		inline function assertPathFail(sound:FlxSound, ?pos)
		{
			// haxe.Log.trace('$sound', pos);
			@:privateAccess
			Assert.isNull(sound._sound, pos);
		}
		
		#if FLX_DEFAULT_SOUND_EXT
		Assert.fail("FLX_DEFAULT_SOUND_EXT was true");
		#end
		try
		{
			assertPathSuccess(FlxG.sound.load(fullPath));
			assertPathFail(FlxG.sound.load(partialPath));
			assertPathSuccess(FlxG.sound.create(fullPath));
			assertPathSuccess(FlxG.sound.create(partialPath));
			#if FLX_STREAM_SOUND
			assertPathSuccess(FlxG.sound.createStreamed(fullPath));
			assertPathSuccess(FlxG.sound.createStreamed(partialPath));
			#end
			
			assertPathSuccess(FlxG.sound.play(fullPath));
			assertPathFail(FlxG.sound.play(partialPath));
			assertPathSuccess(FlxG.sound.playMusic(fullPath));
			assertPathFail(FlxG.sound.playMusic(partialPath));
			#if FLX_STREAM_SOUND
			assertPathSuccess(FlxG.sound.playStreamed(fullPath));
			assertPathSuccess(FlxG.sound.playStreamed(partialPath));
			#end
		}
		catch(e)
		{
			trace('caught: ${e.message}\n@: ${e.stack}');
			FlxG.assets.getAssetUnsafe = oldGetFunc;
			FlxG.assets.exists = oldExistsFunc;
			throw e;
		}
		
		FlxG.assets.getAssetUnsafe = oldGetFunc;
		FlxG.assets.streamSoundUnsafe = oldStreamFunc;
		FlxG.assets.exists = oldExistsFunc;
	}
	
	function debugSound(ms:Float)//:Sound
	{
		return new DebugSound(ms);
	}
}

@:forward
abstract DebugSound(Sound) to Sound
{
	public static inline var ID3_ARTIST = "HaxeFlixel";
	public static inline var ID3_ALBUM = "Unit Tests";
	public static inline var ID3_COMMENT = "Used to test FlxSounds";
	public static inline var ID3_GENRE = "Techno";
	public static inline var ID3_YEAR = "2026";
	
	inline static var SAMPLE_RATE = 44100;
	inline static var HEADER_BYTES
		= '524946460000000057415645666d7420100000000100010044ac000044ac0000020008006461746100000000';
		// |       |       |       |       |       |   |   |       |       |   |   |       |       
		// R_I_F_F_<-size->W_A_V_E_f_m_t_ _<--16--><01><ch><44100-><bytrte><ba><br>d_a_t_a_<sampls>
		
	
	public function new (ms:Float)
	{
		this = new Sound();
		
		final numSamples = Std.int(SAMPLE_RATE * (ms / 1000));
		final samples = haxe.io.Bytes.alloc(numSamples);
		for (i in 0...numSamples)
			samples.set(i, 0x80);
		
		final rawBytes = haxe.io.Bytes.ofHex(HEADER_BYTES + samples.toHex());
		rawBytes.setInt32(4, 36 + samples.length);
		rawBytes.setInt32(40, samples.length);
		
		final bytes = openfl.utils.ByteArray.fromBytes(rawBytes);
		this.loadCompressedDataFromByteArray(bytes, bytes.length);
	}
}