2.0.0
------------------------------
* Compatibility with flixel 4.0.0
* Renamed "Arcade Classics" to "Arcade"
* Moved 3 demos to Arcade:
 * Flappybalt
 * MinimalistTD
 * FlxPongAPI
* Added 22 new demos:
 * Arcade:
    * Flixius
 * Editors:
    * FlxPexParser
 * Effects:
    * DynamicShadows
    * Filters
    * FlxClothSprite
    * FlxEffectSprite (replaces the FlxGlitchSprite and FlxWaveSprite demos)
    * Parallax
    * PostProcess
    * Transitions
 * Flixel Features:
    * Colors
    * FlxFSM
    * FlxNapeTerrain
    * FlxNapeTilemap
    * FlxPieDial
    * FlxScene
    * FlxShape
    * FlxSound
    * SubState
 * Other:
    * BSPMapGen
    * Calculator
    * FrameCollections
 * User Interface
    * Tooltips
* Merged Effects/ParticlesExt into Effects/Particles
* FlxNape:
 * added a SolarSystem demo
 * fixed a crash on Neko
* GamepadTest:
 * added a gamepad model dropdown
 * added a deadzone numeric stepper
 * added a list of all connected gamepads
 * added Wii Remote support
 * added a label with the gamepad's name
* TiledEditor: updated to showcase support for image layers and image tilesets

1.1.2
------------------------------
* Added Tutorials/TurnBasedRPG

1.1.1
------------------------------
* GamepadTest: now compatible with OpenFL 1.4.0
* Mode: fixed infinite gun jam
* FlxAccelerometer: fix orientation

1.1.0
------------------------------
* Compatibility with flixel 3.3.0
* Added 8 new demos:
 * HeatmapPathfinding
 * FlxUICursor
 * FlxWaveSprite
 * FlxTextFormat
 * NeonVector
 * FlxGlitchSprite
 * FlxAccelerometer
 * FlxBitmapTextField
* Added flash gamepad support to GamepadTest and Mode
* FlxSpine now uses the default timeScale 
* TexturePackerAtlas: added examples for Sparrow and LibGDX formats
* FlxTeroids and FlxSpine: added WASD controls
* GridMovement: added a FlxVirtualPad on mobile
* Breakout: added touch controls for mobile

1.0.2
------------------------------
* Compatibility with flixel 3.2.0
* Added demos:
 * BlendModes
 * Flappybalt
* Replaced usage of Actuate with FlxTween 

1.0.1
------------------------------
* Compatibility with flixel 3.1.0
* Added several new demos:
  * FlxRandom 
  * TexturePackerAtlas
  * FlxTrailArea
  * FlxTypeText
  * ScaleModes
  * PixelPerfectCollision
  * FlxAsyncLoop
* Made Mode compatible with gamepad input (and the OUYA target), Android compatibility 
* RPGInterface: added dropdown menus
* Renamed Xbox-Gamepad to GamepadTest, some improvements
* FlxTween: improvements to the UI (now using dropdown menus)

1.0.0
------------------------------
* Initial haxelib release
