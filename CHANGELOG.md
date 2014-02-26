3.2.2
------------------------------
* Added "tracker" window to the debugger which creates a Watch window with the most important properties of an object
 * Use FlxG.debugger.track(Object); to create a new tracker window
 * Use FlxG.debugger.addTrackerProfile() to add a profile for classes don't have one yet or override existing ones
 * Use the "track [object]" command to open a tracker window from the console
* FlxCamera: added static defaultCameras array which is used by FlxBasics when their cameras array has not been set - previously the use of FlxG.cameras.list / all existing cameras was hardcoded
* FlxText.setFormat() now accepts Font classes instead of only strings for its Font param
* [gamedevsam] Added pooling functionality to FlxPoint, FlxVector, FlxRect objects (FlxPath and FlxTimer also support pooling, but that is handled transparently). Usage: ```var point = FlxPoint.get(); /* do stuff with point */ point.put(); // recycle point```

3.2.1
------------------------------
* FlxTypedButton:
 * add onUp event listener again for actions that need to be user-initiated, like ExternalInterface.call()
 * fix buttons not working when FLX_NO_TOUCH is defined
* FlxSprite
 * small optimization for set_pixels()
 * fix for frame being null after loadGraphic() in some cases
* FlxRandom: fix inaccurate results in weightedPick()

3.2.0
------------------------------
* Added PixelPerfectScaleMode (scales the game to the highest integer factor possible while maintaning the aspect ratio)
* FlxTween
 * backward is now a public, read-only property
 * renamed delay to startDelay
 * added loopDelay that controls the delay between loop executions with LOOPING and PINGPONG
 * Added easier to use FlxTween.tween() function, which automatically determines whether to use single VarTween or MultivarTween based on the number of Values being tweened
* Added some basic unit tests
* FlxCamera: removed followAdjust(), the followLead point should be set directly
* FlxSpriteUtil.screenWrap(): prevent sprite from ever being offscreen
* FlxSprite:
 * fixed crash on cpp with loadRotatedGraphic() on state switches
 * fixed "jittering" in certain cases with y velocity in simple render on flash (for example when standing on a platform in a platformer)
* Moved FlxTilemap-functions arrayToCSV(), bitmapToCSV() and imageToCSV() to FlxStringUtil
* FlxMath.computeVelocity() -> FlxVelocity.computeVelocity()
* FlxState.setSubState() -> FlxState.openSubState()
* Added FlxStringUtil.getDebugString()
* Improvements to FlxSystemButton
* Window: add optional close button
* Exposed complete callback in FlxTimer, so now you can do: FlxTimer.start(...).complete = function(t) { };
* Fixed a bug with onFocus() not firing the first time on Android
* FlxTypedButton
 * added allowSwiping flag
 * added allowHighlightOnMobile flag

3.1.0
------------------------------
* Refactor of FlxRandom
  * All functions are now deterministic and safe to use with replays
  * Due to the use of a new algorithm for pseudo-random number generation (a linear congruential generator) and a new seed type (integer instead of float values), old replays will have unpredictable results
  * FlxColorUtil.getRandomColor(), FlxArrayUtil.shuffle(), and FlxArrayUtil.getRandom() have been moved to FlxRandom.color(), FlxRandom.shuffleArray(), and FlxRandom.getObject(), respectively. The old functions are still in place but are marked as deprecated.
  * weightedPick(), weightedGetObject() and colorExt() have been added
  * Replays are now fully deterministic, whether replaying the whole game or just a single state.
* New FLX_NO_SOUND_SYSTEM conditional
* FlxTrailArea: 
 * can now be resized with setSize()
 * default delay is now 2
 * removed smoothing, use antialising instead
 * is now compatible with animated sprites / sprites that have a spritesheet
* Moved FlxSlider, FlxTrail and FlxTrailArea to flixel-addons
* FlxMisc has been removed, openURL() can now be found in FlxG. Added Target param to openURL().
* FlxCamera: 
 * getContainerSprite() has been removed, as well as the underscore in some public variables ("_flashSprite")
 * BUG: fixed alpha being initialized with 0 instead of 1
 * BUG: fixed FlxSprites not taking camera.alpha into account on cpp targets
* FlxSpriteGroup: Added forEach(), forEachAlive(), forEachDead() and forEachExists()
* FlxSpriteUtil: 
  * new drawTriangle() and drawPolygon(), fadeIn() and fadeOut() functions 
  * more control for the drawing functions via FillStyle and DrawStyle
  * added convenient default values for drawCircle()
  * allow FlxObjects in screenWrap() and screenCenter()
  * now the functions return the sprite / object to allow chaining
  * BUG: fixed null error in alphaMaskFlxSprite()
* FlxTypedButton refactor
  *  Callbacks are now set via the FlxButtonEvent objects, for example button.onDown.callback = someFunction;
  *  The type of callback has been changed from Dynamic to Void->Void to avoid Reflection. This means you need to bind custom parameters to your callback function like so: callback = someFunction.bind(1); ([more info](https://github.com/HaxeFlixel/flixel/issues/805?source=cc))
  *  new labelAlphas and labelOffsets arrays for more control
  *  the highlight frame is now disabled by default on mobile 
  *  "swiping" is now possible (entering the button area while the input is pressed to press the button)
* FlxTypedEmitter and FlxSound: Added setPosition() methods
* FlxSlider: New setVariable flag, improvements to inner update logic
* FlxSprite: 
  * pixelsOverlapPoint() has been removed
  * setGraphicDimensions() -> setGraphicSize(), removed the UpdateHitbox flag
  * added getGraphicsMidpoint()
  * bakedRotation -> bakedRotationAngle
  * loadfromSprite() -> loadGraphicFromSprite()
  * loadImageFromTexture() -> loadGraphicFromTexture()
  * loadRotatedImageFromTexture() -> loadRotatedGraphicFromTexture()
  * setColorTransformation() -> setColorTransform()
* Optimized input checking when using FlxG.keys (aka FlxKeyShortcuts)
* FlxTypedGroup: 
  * autoReviveMembers flag has been removed
  * Revive param has been added to recycle()
  * Fixed a bug with callAll()'s Args parameter which would get lost in recursive mode 
* FlxRect, FlxPoint and FlxBasic and FlxObject now have toString() functions used for traces and the flixel debugger
* The focus lost screen and the sound tray now react to window resizes
* BUG: Fixed numpad minus not working as a default volume down key
* FlxStringUtil:
 * added sameClassName() 
 * added getDomain()
* The stats window of the debugger has been refactored, now has fancy FPS and memory graphs
* FlxGame.focusLostFramerate added
* BUG: Fixed flixel cursor reappearing after regaining focus
* Android sound caching improvement
* Fixes for OUYA gamepad combatibility (fixed some button IDs in OUYAButtonID)
* Fix for a bug in the standalone flash player that would fire onFocus / onFocusLost twice
* Prevent paused sounds from playing after regaining focus
* FlxText:
 * BUG: Fix inaccurate text color when setting both color and alpha
 * BUG: Fix incompatiblity of FlxText.borderStyle and FlxText.alpha
 * BUG: Fixed changing color or alpha of a FlxText affecting its origin
 * Internal optimizations for less BitmapData creations
 * Added basic text formatting via FlxTextFormat, so different sections of the same FlxText can have different formatting. For this, addFormat(), removeFormat() and clearFormats() have been added.
 * Added italic property (flash-only for now)
* Renamed framerates to clear up confusion: 
  * gameFramerate -> updateFramerate
  * flashFramerate -> drawFramerate
* BUG: Fixed order of operations issue that was causing FlxSubStates to crash on close.
* BUG: Fixed a splash screen repeating bug when using default splash screen.
* Gamepad support improvements
  * Improvements and optimizations to gamepad api, fixed Ouya compatibility!
  * FlxGamepadManager: getActiveGamepadIDs(), getActiveGamepads(), getFirstActiveGamepadID(), getFirstActiveGamepad and anyInput() added
  * FlxGamepad: firstPressedButtonID(), firstJustPressedButtonID() and firstJustReleasedButtonID() added
  * Added PS3ButtonID and LogitechButtonID classes
  * FlxG.gamepads.get() -> getByID()
* Ported scale modes from flixel for moneky (FlxG.scaleMode / flixel.system.scaleModes) and removed FlxG.autoResize
* Renamed FlxG.debugger.visualDebug to drawDebug
* FlxTween:
 * optimizations
 * AngleTween now accepts FlxSprite as a parameter
 * Now possible to delay tweens via the TweenOptions typedef 
 * FlxEase: Added elastic easing functions
 * Exposed the duration and the type of tweens so they can be changed after they have been started
* BUG: Fixed jittering movement of FlxObjects following a FlxPath
* Removed FlxG.paused, it was a container variable without functionality
* FlxRect: 
 * Added setSize()
 * top / bottom / left / right can now be set
* FlxArrayUtil:
 * added fastSplice() 
 * moved intFromString() to FlxStringUtil.toIntArray()
 * moved floatFromString() to FlxStringUtil.toFloatArray()
* Moved flixel.system.input to flixel.input
* Moved interfaces into a new interfaces package
* BUG: Fixed crash when using traces on android
* Haxe 3.1.0 compatibility
* FlxG.keyboard has been merged with Flx.keys again. FlxG.keyboard.pressed(), justPressed() and justReleased() have been removed, anyPressed(), anyJustPressed() and anyJustReleased() should be used instead.
* Removed dynamic types and casting in some places
* FlxMouse refactor
 * Removed show() and hide(), visible should be used instead
 * load() should be used for loading a cursor graphic, which was previously possible via show()
 * FLX_MOUSE_ADVANCED has been turned into FLX_NO_MOUSE_ADVANCED, which means the event listeners for middle and right mouse clicks are now available by default / opt-out
 * FlxState.useMouse has been removed
 * The mouse cursor is now by default visible on non-mobile targets
* FlxG.pixelPerfectOverlap() / FlxCollision.pixelPerfectCheck() has been heavily optimized to perform well on cpp targets, default AlphaTolerance is now 1
* FlxG.LIBRARY_MINOR_VERSION, LIBRARY_MAJOR_VERSION, LIBRARY_NAME and libraryName have been refactored into a FlxVersion object available via FlxG.VERSION
* FlxSound:
 * Made fadeIn() and fadeOut() more intuitive to use
 * Added pan property to allow non-proximity-based panning
* FlxAngle:
 * added getCartesianCoords() and getPolarCoords()
 * removed the Round parameter from getAngle()
* FlxVirtualPad now extends FlxSpriteGroups and uses enums for the action and dpad-button-styles
* Added collisionXDrag flag to FlxObject to allow turning off the default "move-with-horizontally-moving-platform"-behaviour
* FlxSoundUtil has been removed
* General improvements to the in-code documentation
* Added `<window allow-shaders="false" />` to the include.xml to boost performance (especially on mobile)
* Added an option for looping to FlxG.sound.playMusic()
* BUG: Fix the last command of the console not working
* BUG: Fix setting a Boolean on cpp not working
* BUG: Added a workaround for onFocus() firing immediately on startup for cpp targets
* Code style change for keyword order, public/private first, see the [styleguide](http://haxeflixel.com/documentation/code-style/) for more info
* Added getByID() to FlxG.touches
* Added FlxG.swipes (contains all the FlxSwipe objects that are active this frame) to allow for better handling of touch inputs. A FlxSwipe has the following properties:
 * startPosition
 * endPosition
 * distance
 * angle
 * duration
* All FlxPoints of FlxObject and FlxSprite are now (default, null) / read-only - this means you should now use .set(x, y) if you were previously new()-ing the point.
* Asset embedding has been optimized to only embed sound / graphic assets when they are needed, as opposed to always including all of them.
* Changed the way FlxTypedGroup.sort() works by adding flixel.util.FlxSort for increased performance
* BUG: fixed onFocus and onFocusLost not working on mobile
* Changed default volume from 0.5 to 1

3.0.4
------------------------------
* Removed experimental FLX_THREADING conditional
* Changes type of CHANGELOG and LICENSE files from .txt to .md - makes it more readable on github
* FlxSpriteGroup: Default scrollFactor is now (1, 1) and upon adding sprites, their scrollFactor is snychronized
* Now using the HaxeFlixel logo as an icon for the application by default again
* FlxAnimationController: Additional null checks to prevent erros with FlxSpriteFilter
* FlxG: addChildBelowMouse() and removeChild() added
* FlxG.debugger.removeButton() added
* Added toString() functions to FlxPoint and FlxRect
* Console: Refactor which includes removing some commands and making it more flexible
* FlxColorUtil: Now uses proper terminology (ARGB instead of the misleading RGBA)
* FlxSprite: setGraphicDimensions() and updateHitbox() helper functions for working with scale added
* FlxStringUtil: htmlFormat() and filterDigits() added
* FlxMath: Improvements to sign() and chanceRoll()
* FlxClickArea: Has been moved to flixel-addons
* FlxText: Internal TextField is now accesible via textField
* FlxTrailArea added, an alternative to FlxTrail which should be more performant
* FlxBitmapUtil.merge() added

3.0.3
------------------------------
* No changes to 3.0.2, just a fix for the faulty 3.0.2 haxelib release

3.0.2
------------------------------
* FlxTilemap: Region size checks added to fix a bug
* FlxSprite.setColorTransformation() added
* FlxAngle.getAngle(): Round parameter added
* FlxPreloader: Workaround for issue in Chrome, enabled by default again
* FlxCollision.pixelPerfectCheck(): Now correctly works with rotated sprites
* FlxSpriteUtil drawing functions: Support for RGBA colors, new lineStyle param
* MouseEventManager: Fix pixel-perfect checks for touchscreens
* FlxSpriteGroup: Get rid of motion variable (velocity etc) overrides to fix a bug with FlxPath, add width and height getters
* Basic HTML5 gamepad support (Chrome and Opera)
* FlxG.android added (supports the back and menu keys for now)
* FlxGame constructor: Added StartFullscreen param for desktop targets
* FlxTypedGroup: Added iterators / iterator(), forEach(), forEachAlive(), forEachDead(), forEachExists()
* FlxColorTween now accepts FlxSprite as a parameter and it will change its color automatically
* QuadPath doesn't generate control points anymore

3.0.1-alpha
------------------------------
* Fixes to gamepad API.
* Added tilemap scaling.
* FlxSpriteGroup has been reworked and now extends FlxSprite instead of FlxTypedGroup<FlxSprite>
* FlxCollisionType introduced
* FlxDebugger: UI improvements, now remembers visibility settings of the windows
* Compiler fix for Blackberry target.
* FlxAssets: Fonts are no longer inlined so they can be changed
* FlxMath: isDistanceWithin(), isDistanceToPointWithin(), isDistanceToMouseWithin() and  isDistanceToTouchWithin() added
* FlxG.fullscreen now works on cpp targets
* FlxObject.inWorldBounds() added
* LICENSE.txt cleanup

3.0.0-alpha
------------------------------
* New Front End classes to better encapsulate FlxG functionality.
* Refactored the animation system.
* Better support for nested sprites via FlxSpriteGroup.
* Moved lots of stuff into utility classe to reduce clutter in core classes.
* Continued optimizations for cpp targets.

2.0.0-alpha.3
------------------------------
* Fix for FLX_MOUSE_ADVANCED (wouldn't compile earlier)
* FlxMath functions are Float-compatible. Thanks @Gama11
* Fix for negative object width and height. Thanks @Gama11
* Fix for FlxPath and FlxObject
* Added Frame parameter for FlxSprite's play(). Now you can start animation from specified Frame
* Added gotoAndPlay(), gotoAndStop(), pauseAnimation() and resumeAnimation() methods for FlxSprite
* Added frameRate property for FlxAnim
* Fixed camera scrollrect on html5 target
* Fixes for reflection which caused crashes
* Added tileScaleHack var for tilemaps and tileblocks. It should help with tilemap tearing problem
* Fixed FlxWindow dragging bug
* Fix null error bug with logging functions. Thanks @Gama11
* Projects now use .xml instead of .nmml. Thanks @Gama11
* Fixed facing for FlxSprite with TextureAtlas
* FlxTrail improvements from Andrei Regiani (now it supports origin and scaling)
* FlxSlider refactoring and fixes. Thanks @Gama11
* Fixed FlxTextField.setFormat() to load font correctly
* Fixed AntTaskManager. Thanks @Henry.T
* Blocked sounds for html5 target (until i'll make them work there)
* Fixed FlxU.formatTime to correctly display milliseconds. Thanks @jayrobin
* Big refactoring regarding FlxPoint, FlxRect, FlxU (now it splitted into FlxAngle, FlxArray, FlxColor, FlxMath, FlxMisc, FlxRandom and FlxVelocity classes). Huge thanks @Gama11
* Merged FlxMath, FlxColor and FlxVelocity plugins from FlixelPowerTools into utility classes from org.flixel.util package. Thanks @Gama11
* Fixed FlxTypedGroup atlas setter
* Fixed FlxBasic updateAtlasInfo() method
* Added @:isVar to FlxButtonPlus x and y so they can be accessed from a derived class. Thanks @ProG4mr
* Temp fix for logging on HTML5 / disable htmlText. Thanks @Gama11
* Moved all color constants to FlxColor util and totally removed them from FlxG. Thanks @Gama11
* Improved nape classes documentation. Thanks @Gama11
* Added forceComplexRender property for FlxObject on flash target. It forces to use BitmapData's draw() method for rendering (smoother, but slower)
* Added onComplete callback for FlxSound. Works on flash and desktop
* Fixed for PxBitmapont's loadPixelizer() on html5. Now it should render without artifacts
* Added FlxG.quickWatch() and renamed FlxString.formatHash() to FlxString.formatStringMap(). Thanks @Gama11
* Added loadFromSprite() method for FlxSprite 
* Added support for animated sprites in FlxTrail
* Added functions to hide, show and toggle the debugger to FlxG. Thanks @Gama11
* Slightly better texture atlas handling. Now you can easily add support for new atlas format
* Fixed tilesheet rendering (for latest openfl release) 

2.0.0-alpha.2
------------------------------
* openfl compatibility
* Removed isColored() method from FlxCamera, since Sprite's colorTransform is working properly with drawTiles() now
* Added XBox controller button definitions for Mac (took from HaxePunk)
* FlxPath enhancement, it has pathAutoCenter property now (true by default) and setPathNode() method for direct change of current path node. Thanks @Gama11
* Little fixes regarding new compiler conditionals and mouse input

2.0.0-alpha
------------------------------
* Perfomance optimization: merged preUpdate(), update() and postUpdate() methods. So you should call super.update(); from your classes.
* A little bit better TexturePacker format support for FlxSprite
* Added missing button definitions for XBox controller to FlxJoystick. Thanks @volvis
* Bitmap filters for FlxSprite and FlxText now works on native targets. Thanks @ProG4mr
* Added experimental update thread. Thanks @crazysam
* Fixed FlxTilemap for multiple map loading. Thanks @SeanHogan
* Added FlxAssets.addBitmapDataToCache() method for more control over image caching
* Added drawCircle() function to FlxSprite. Thanks @Gama11
* Added method for updating tilemap buffers, usefull for camera resizing. Thanks @impaler
* FlxEmitter Improvements: added scaling, fading and coloring. Thanks @Gama11 for the idea and help
* Added powerfull Console to FlxDebugger. Thanks @Gama11
* Improved logging and variable watching functionality. Thanks @Gama11
* Added move function to FlxObject. Thanks @sergey-miryanov
* Fixed FlxTilemap's arrayToCSV() method on neko target. Thanks @pentaphobe
* Added optional right and middle mouse button support. Use FLX_MOUSE_ADVANCED compiler conditional. Thanks @Gama11
* Added FlxColorUtils class. Thanks @Gama11
* Added new compiler conditionals: FLX_NO_FOCUS_LOST_SCREEN and FLX_NO_SOUND_TRAY compiler conditionals. See template.nmml file for details. Thanks @Gama11

1.09
------------------------------
* Fix for FlxSprite.fill() on cpp targets
* Now you can pass BitmapData to FlxTilemap's loadMap() method
* Added Nape support (thanks @ProG4mr). See org.flixel.nape package
* FlxText can be static (i.e. non-changable) now. This can be usefull for cpp targets
* FlxCamera improvements: lerp, lead and following (thanks @ProG4mr)
* Refactored input system (thanks @impaler). Added new compiler conditionals for switching off unnecessary inputs - see template nmml-file.
* Tilesheet rendering for html5 target (it is much faster than blitting)
* Added new compiler conditionals for switching off debugger and recording systems - see template nmml-file (thanks @impaler)
* Improved Joystick support (thanks @crazysam)
* Added FlxTypedGroup - much less casting in the engine's code. Plus you can use it too
* Updated getters/setters (for Haxe 3 compatibility)
* Replaced Math.floor() with Std.int where it was possible
* Fix for FlxSprite's porting (now it works correctly)
* Added filters functionality for FlxSprite (thanks @ProG4mr). Works on flash target
* Fix for FlxBar - now they rotate correctly
* Initial support of TexturePacker format - see org.flixel.plugin.texturepacker (thanks @sergey-miryanov)
* Refactored drawing methods - now they are more readable and compact (thanks @sergey-miryanov)
* Initial SubState support (thanks @IQAndreas for his AS3 code)
* MouseInteractionMgr - mouse events for FlxSprite (thanks @ProG4mr)
* Fix for null Params arrays for callbacks in FlxButtonPlus
* Pausing cameras when the game is paused
* Many other little improvements, fixes and optimizations from FlixelCommunity, @impaler, @crazysam, @ProG4mr and others

1.08
------------------------------
* New draw stack rendering system for cpp and neko targets (replacement for layer system). It is simpler to use but little bit slower.
* NME 3.5.1 compatible
* Bug fixes for FlxText (shadow problem) and tweening (for oneshot tween)
* FlxTextField class now works on flash target also and can be used as input field, but I've removed multicamera support
* Small optimizations from @crazysam
* Added FlxBackdrop addon class
* Added TaskManager addon (ported from AntHill: https://github.com/AntKarlov/Anthill-Framework)
* Added onFocusLost() and onFocus() methods to FlxState class. These methods will called when app losts and gets focus. Override them in subclasses.

1.07
------------------------------
* New layer system for cpp and neko targets. See https://github.com/Beeblerox/HaxeFlixel/wiki/Introduction-in-layer-system-%5BEN%5D
* Fixed draw position round issue for cpp and neko targets. It uses less math methods and more accurate now.
* Added drawTiles() counter in debugger output (on cpp and neko targets).
* Added BACKWARD and PINGPONG tween types. Thanks @devolonter!
* Added cancel() method to FlxTween
* Added initial support for html5 target. But it's very-very slow
* Added NestedSprite addon. It is some sort of display object container, a very limited one, but powerfull enough (it's not in finished state right now but usable).
* Added FlxTrail class (thanks @crazysam)
* Fixed ZoomCamera addon class
* Change FlxEmitter behavior, so it can kill itself when all particles are dead
* Fixed FlxCollision plugin, so all of it's method are working on flash, cpp and neko targets
* Added FlxGamePad and FlxAnalog controls (initial state). Thanks to WingEraser for his Flixel-Android port (I took them from there).
* Lots of small fixes, changes and tweaks (thanks to Samuel Batista aka crazysam and @FlixelCommunity)

1.06
------------------------------
* Added FlxKongregate plugin (flash only). Thanks to goldengrave for porting this class.
* Fixed bug with FlxButton's makeGraphic() crashing on cpp and neko targets.
* Fixed bug with VarTween and MultivarTween on Haxe 2.10
* Fixed bug when FlxGroup's tweens weren't updated
* Added new logo. Huge thanks to Impaler!!!
* Added StarfieldFX class from FlixelPowerTools.

1.05
------------------------------
* Fixed bug with animation callback for FlxSprite on cpp target
* Ported FlxButtonPlus class from FlixelPowerTools
* Fixed Android sound issue. Thanks to Adrian K. (@goshki) for testing
* Added FlxSkewedSprite class (see skewedSprite example on github repo). This class isn't optimized for flash target
* Added loadFrom() method for FlxSprite. So you can easily copy graphics from one FlxSprite to another. This is especially usefull for cpp target. Thanks to Phoenity for this idea
* Initial support for Haxe 2.10
* Added basic support for multitouch (see FlxG.touchManager and multitouch example on github repo). Flash version requires Flash Player 10.1 now.
* Compile fix for FlxPreloader on mac platform. Thanks to Talii for it.
* Integrated tweening system from HaxePunk (Thank you, Matt Tuttle). All FlxBasic's subclasses have this functionality now. See addTween(), removeTween(), clearTweens() methods of FlxBasic instances and 'org.flixel.tweens' package.
* Added basic support for Joystick input (See FlxG.joystickManager and org.flixel.system.input.Joystick and org.flixel.system.input.JoystickManager classes for details). I need someone to test it.

1.04
------------------------------
* Fixed bug with FlxCamera's color property on cpp target. Sorry for it

1.03
------------------------------
* Updated rendering system for cpp target so it uses 2d tile transformations now (which means non-uniform scaling is working now)
* FlxBitmapTextField's background property is working on cpp target now
* Replaced FlxDictionary with ObjectHash (for FlxControlHandler plugin)
* Added BTNTileMap class (which can be found in org.flixel.addons package) from http://bullettimeninja.blogspot.com/2012/01/lasers-and-ray-casting.html
* Added ZoomCamera class (also in org.flixel.addons package) from http://bullettimeninja.blogspot.com/2011/09/zoom-camera.html
* Made a little optimization for FlxSprite's onScreen() method for cpp target (not using Math.sqrt() now)
* Added width and height getters/setters for FlxCamera on flash target
* Made small optimizations in rendering for cpp target (the way it pushes and splices draw data)
* Fixed pixelPerfectPointCheck() method from FlxCollision plugin
* Made pixelPerfectCheck() method from FlxCollision plugin work on flash only. It's always returns false on other targets. Sorry:(
* Fixed FlxCamera's bug with changing it's size (width, height and zoom)

1.02
------------------------------
* Ported FlxBar class
* Added FlxBitmapTextField class (background property isn't working on cpp for now)
* Added PxButton class which uses FlxBitmapTextField for text rendering
* Replaced Dynamic with appropriate types (where it was possible)
* Improvements in FlxQuadTree and FlxObject (less garbage)
* Changed TileSheet creation process to insert gaps between frames. This should solve 'pixel bleeding' problem

1.01
------------------------------
* Finally ported FlxPreloader class
* Fixed issue with FlxTextField class when it wasn't affected by fade() and flash() effects (on cpp and neko targets)
* Improvements in memory consumption for FlxTileBlock and FlxBitmapFont classes
* Updated lib to work with haxe 2.09
* Ported FlxGridOverlay from Flixel-Power-Tools

1.00
------------------------------
* Initial haxelib release
