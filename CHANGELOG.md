2.7.4 (April 17, 2021)
------------------------------
* Added Lime XSD schema references to enable completion

2.7.3 (July 2, 2020)
------------------------------
* FileBrowse: fixed compilation on HashLink
* Updated some demos' sounds for compatibility with Apple devices (#276)
* FlxTilemapExt: make use of the new `setDownwardsGlue()` method
* GamepadTest: added a gamepad list and increased the window size
* Fixed `Std.is()` deprecation warnings with Haxe 4.2

2.7.2 (March 28, 2020)
------------------------------
* Modernized the TurnBasedRPG tutorial

2.7.1 (May 1, 2019)
------------------------------
* Replaced `nape` in `Project.xml` with `nape-haxe4`

2.7.0 (February 4, 2019)
------------------------------
* Compatibility with Flixel 4.6.0 and Haxe 4.0.0-rc.1
* Added 2 new demos:
   * FlxAction (#268)
   * FlxSimplex (#270)
* Mode: use `FlxAction` for the player controls
* Tilemap: update for `FlxTilemapAutoTiling.FULL` (#271)
* FlxBunnyMark: fixed Android compilation

2.6.1 (August 10, 2018)
------------------------------
* Compatibility with flixel 4.5.0
* Compatibility with latest Haxe dev
* FlxAccelerometer improvements + HTML5 support

2.6.0 (May 4, 2018)
------------------------------
* Compatibility with flixel 4.4.0
* Disabled `vsync` by default in `Project.xml` files
* NeonVector: fixed Neko compatibility (#243)
* Flixius: fixed Android compilation (#232)
* FlxBunnyMark:
  * added support for `-Dbunnies=<amount>`
  * added the ability to toggle the UI overlay with space
* Fixed HTML5 compatibility of several demos (FlxTween, Filters, ...)

2.5.0 (March 28, 2018)
------------------------------
* Added the FlxLightPuzzle demo (#263)
* MosaicEffect: replaced the camera shader with a sprite shader
* FlxBunnyMark: removed the pirate

2.4.3 (November 30, 2017)
------------------------------
* Fixed flixel-tools not finding demos if dependencies are missing

2.4.2 (September 10, 2017)
------------------------------
* FlxMouseEventManager and MinimalistTD:
  * fixed some crashes (637e29e, #261)
  * cleaned up the code a bit
* Added a `flixel-demos.code-workspace` file

2.4.1 (July 22, 2017)
------------------------------
* Updated the FlxTween demo for Flixel 4.3.0 (#260)

2.4.0 (May 15, 2017)
------------------------------
* Added a BlendModeShaders demo (#255)
* Fixed a missing trail effect in FlxNape
* Updated the FlxSpine demo
* TiledEditor: added a flipped image (#257)

2.3.0 (October 11, 2016)
------------------------------
* Compatibility with flixel 4.2.0
* FlxTextFormat: added an example of multi-character markers for `applyMarkup()`
* FlxCamera: removed some unnecessary zooming logic
* MinimalistTD: fixed a crash when touching the goal (#238)
* Replaced FlxNapeTilemap with an improved demo (#242)
* FlxPexParser: added support for changing `scale` (#246)
* TurnBasedRPG: fixed highscore not being saved (#248)
* TiledEditor: added animated tiles (#251)

2.2.0 (July 10, 2016)
------------------------------
* Compatibility with flixel 4.1.0
* Added 2 new demos: (#225)
  * MosaicEffect
  * FloodFill
* FlxReplay: [Flash] fixed an exception when loading a replay (#216)
* TiledEditor: fixed all objects being loaded twice (#220)
* FlxCamera: added an overlay visualizing the camera deadzone (#224)
* FlxBunnyMark: added a shader example for OpenFL Next (#229)

2.1.0 (February 28, 2016)
------------------------------
* FlxSnake:
 * fixed the pickup sound effect not being played
 * fixed snake being able to crash into itself (#215)
* Project Jumper" -> "ProjectJumper"
* "RPG Interface" -> "RPGInterface"
* "MouseEventManager" -> "FlxMouseEventManager"
* `/Flixel Features` -> `/Features`
* `/User Interface` -> `/UserInterface`
* TurnBasedRPG: removed unnecessary comments and `destroy()` overrides
* FlxSpriteFilters: mobile compile fix
* Minor code cleanup for several demos

2.0.0 (February 16, 2016)
------------------------------
* Compatibility with flixel 4.0.0
* Renamed "Arcade Classics" to "Arcade"
* Moved 3 demos to Arcade:
 * Flappybalt
 * MinimalistTD
 * FlxPongAPI
* Added 23 new demos:
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
    * FlxAtlas
    * FrameCollections
 * User Interface
    * Tooltips
* Merged Effects/ParticlesExt into Effects/Particles
* Renamed FlxBitmapTextField to FlxBitmapText
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

1.1.2 (June 5, 2015)
------------------------------
* Added Tutorials/TurnBasedRPG

1.1.1 (May 3, 2014)
------------------------------
* GamepadTest: now compatible with OpenFL 1.4.0
* Mode: fixed infinite gun jam
* FlxAccelerometer: fix orientation

1.1.0 (April 24, 2014)
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

1.0.2 (February 21, 2014)
------------------------------
* Compatibility with flixel 3.2.0
* Added demos:
 * BlendModes
 * Flappybalt
* Replaced usage of Actuate with FlxTween 

1.0.1 (February 6, 2014)
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

1.0.0 (December 28, 2013)
------------------------------
* Initial haxelib release
