4.0.0
------------------------------
* Rendering:
 * more code is shared between blitting and tilesheet rendering
 * added `FlxStrip` which supports rendering via `drawTriangles()`
 * the tile renderer now uses `Tilesheet.TILE_RECT` instead of `addTileRect()`
 * renderers are now distuingished by `FlxG.renderMethod` (`FlxG.renderBlit` / `FlxG.renderTile` for easy access) instead of defines (`FLX_RENDER_BLIT` / `FLX_RENDER_TILE`). This allows for a fallback to software rendering on certain targets if hardware rendering is not available. (#1668)
 * added an experimental rendering method using `drawTriangles()` (enabled by defining `FLX_RENDER_TRIANGLE`, requires `FlxG.renderTile to be true).
* `FlxFrame`:
 * doesn't store the frame's bitmapatas anymore, so `getBitmap()` and other bitmap methods have been removed
 * added `paint()` and `paintFlipped()` methods instead. This solution requires much less memory, but will be a bit slower.
 * added `flipX` and `flipY` (#1591)
* `FlxArrayUtil`: removed `indexOf()`
* Changed `static inline` vars to enums: (#998)
 * `FlxCamera` follow styles
 * `FlxCamera` shake modes
 * `FlxText` border styles
 * `FlxTilemap` auto-tiling options
 * `FlxBar` fill directions
 * `FlxG.html5` browser types
* `FlxCamera`: 
 * added `pixelPerfectRender` as a global setting for sprites and tilemaps (#1060)
 * `pixelPerfectRender` now defaults to `false` with `FlxG.renderTile` (#1065)
 * `bounds` -> `minScrollX`, `maxScrollX`, `minScrollY` and `maxScrollY` (`null` means unbounded) (#1070)
 * `setBounds()` -> `setScrollBoundsRect()` (#1070)
 * added `setScrollBounds()`
 * added `targetOffset` (#1056)
 * added `scrollRect` sprite which crops the camera's view when the camera is scaled
 * camera now scales from its center, not its top left corner
 * `followLerp` is now a range taking values from 0 to (`60 / FlxG.updateFramerate`) - the closer to zero the more lerp! (#1220)
 * added `snapToTarget()` (#1477)
 * `fade()`: fixed `FadeIn == true` not working in a fade out callback (#1666)
 * `follow()`: removed the `Offset` argument (#1056)
* `FlxMath`:
 * `bound()` and `inBounds()` now accept `null` as values, meaning "unbounded in that direction" (#1070)
 * `wrapValue()` -> `wrap()`, replaced the `amount` argument with a lower bound
 * changed `MIN_VALUE` and `MAX_VALUE` to `MIN_VALUE_FLOAT` and `MAX_VALUE_FLOAT`, added `MAX_VALUE_INT` (#1148)
 * added `sinh()` (#1309)
 * added `fastSin()` and `fastCos()` (#1534)
 * optimized `isEven()` and `isOdd()`
 * added `remapToRange()` (#1633)
 * `getDistance()` -> `FlxPoint#distanceTo()` (#1716)
* `FlxTypedSpriteGroup`: added `iterator()`
* `FlxTimer`, `FlxTween`, `FlxPath`: `active` is now only true when they are active
* `FlxAnimationController`:
 * `curAnim` does also return animations that have finished now
 * removed `get()`
 * `callback`: fixed old `frameIndex` value being passed instead of the current one
 * `add()` now makes a copy of the `Frames` array before calling `splice()` on it
 * fixed `finished` not being true during the last animation frame in the `callback`
 * added `Reversed` argument in `play()` method, which allows you to set animation's playback direction
* `FlxAnimation`:
 * added `reversed` var which allows you to play animation backwards
 * second argument of `play()` method is `Reversed` now
 * added `flipX` and `flipY` (#1670)
* `FlxSpriteUtil`:
 * `drawLine()`: default settings for `lineStyle` are now thickness 1 and color white
 * `fadeIn()` and `fadeOut()` now tween `alpha` instead of `color`
 * added `drawCurve()` (#1263)
 * removed `FillStyle`, the same functionality is now covered by `FillColor`
 * moved `screenCenter()` to `FlxObject` and changed the the arguments from two booleans to the `FlxAxes` enum (#1541)
* `FlxEmitter`:
 * `at()` -> `focusOn()`
 * `on` -> `emitting`
 * emitters and particles now use `FlxColor` instead of separate red, green, and blue values
 * removed `FlxEmitterExt`, `FlxEmitter` now has two launch modes: `CIRCLE` (the new default) and `SQUARE` (#1174)
 * removed `xPosition`, `yPosition`, `life`, `bounce`, and various other properties, and property setting convenience functions (see below) (#1174)
 * a variety of values can now be set with much greater control, via `lifespan.set()`, `scale.set()`, `velocity.set()` and so on (#1174)
 * simplified `start()` parameters (#1174)
 * added `angularDrag` and `angularAcceleration` (#1246)
* `FlxParticle`: (#1174)
 * `maxLifespan` -> `lifespan`, `lifespan` -> `age`, percent indicates `(age / lifespan)`
 * `age` counts up (as opposed to `lifespan`, which counted down)
 * range properties (`velocityRange`, `alphaRange`) which determine particle behavior after launch
 * "active" flags (`alphaRange.active`, `velocityRange.active`, etc) which `FlxEmitter` uses to control particle behavior
* Moved `FlxMath`, `FlxPoint`, `FlxVector`, `FlxRect`, `FlxAngle`, `FlxVelocity` and `FlxRandom` to `flixel.math`
* `FlxPath`: exposed `nodeIndex` as a read-only property
* `FlxAssets`: `cacheSounds()` -> `FlxG.sound.cacheAll()` (#1097)
* `FlxMouse` and `FlxTouch` now extend a new common base class `FlxPointer` instead of `FlxPoint` (#1099)
 * adds `overlaps()` to `FlxMouse`
* `FlxTilemap`:
 * separated rendering and logic, adding `FlxBaseTilemap` (#1101)
 * added `getTileIndexByCoords()` and `getTileCoordsByIndex()`
 * fixed a bug in `overlapsAt()`
 * `loadMap()` now treats tile indices with negative values in the map data as 0 (#1166)
 * added `blend`, `alpha` and `color`
 * added `frames` property, so you can change tilemap's graphic without reloading map
 * `loadMap()` accepts `FlxGraphic`, `String`, `FlxTileFrames` or `BitmapData` as `TileGraphic` now
 * `loadMap()` has been split into `loadMapFromCSV()` and `loadMapFromArray()` (#1292)
 * added `loadMapFrom2DArray()` (#1292)
 * added `offset` property (#1444)
 * `allowCollisions` now sets the `allowCollisions` property of each tile
 * fixed `ray()` not detecting a collision with perfectly diagonal start and end points (#1617)
 * `findPath()`: replaced `WideDiagonal` argument with `DiagonalPolicy` (#1659)
* `FlxBaseTilemap`: added `setRect()` method which allows you to set a rectangular region of tiles to the provided index
* `FlxTile`: added `frame` variable which holds tile's "graphic"
* `FlxTileblock`: 
 * added `setTile()` and `tileSprite` (#1300)
 * added `loadFrames()` method which allows you to use frames collection as a source of graphic
* `Console`:
 * refactored the console to be powered by hscript (#1637)
 * added auto-completion
 * fixed focus on native targets
* `FlxColor`:
 * `FlxColor` is now an `abstract`, interchangable with `Int` - the `FlxColorUtil` functions have been merged into it (#1027)
 * the color presets have been reduced to a smaller, more useful selection (#1117)
* Moved "typed" classes: (#1100)
 * `FlxTypedGroup` into `FlxGroup.hx`
 * `FlxTypedSpriteGroup` into `FlxSpriteGroup.hx`
 * `FlxTypedEmitter` into `FlxEmitter.hx`
 * `FlxTypedButton` into `FlxButton.hx`
* `FlxBitmapUtil` -> `FlxBitmapDataUtil` (#1118)
* `FlxKeyboard`: 
 * added `preventDefaultKeys` for HTML5
 * added an `abstract` enum for key names (`FlxG.keys.anyPressed([A, LEFT])` is now possible)
 * the any-functions now take an Array of `FlxKey`s instead of Array of Strings (string names are still supported)
 * removed `FlxKey.NUMPADSLASH` (`SLASH` has the same keycode)
* `FlxTypedGroup`:
 * added a `recurse` argument to the `forEach()` functions
 * removed `callAll()` and `setAll()` - use `forEach()` instead (#1086)
 * replaced the parameter array in `recycle()` with an optional factory method (#1191)
 * `revive()` now calls `revive()` on all `members` of a group as well (#1243)
 * added `insert()` (#1671)
* `FlxGamepadManager`:
 * better handling of disconnecting and reconnecting gamepads. `getByID()` can now return `null`.
 * `anyButton()` now has a `state` argument
 * `globalDeadZone` can now be 0
 * `globalDeadZone` now overshadows instead of overriding the gamepad's deadzone values
* `FlxGamepad`:
 * refactored gamepads to include mappings, removing the need to write separate logic for each gamepad type (#1502):
 	* each gamepad now has a `model`, `mapping` and `name`
 	* moved the ID classes to `flixel.input.gamepad.id`
 	* all IDs are now mapped to a value in `FlxGamepadInputID`
 	* the previous "raw" gamepad IDs are now available via separate functions
 	* added `pressed`, `justPressed`, `justReleased` and `analog`
 	* removed the dpad properties, they are now mapped to buttons
 * added a `connected` flag
 * added `deadZoneMode`, circular deadzones are now supported (#1177)
 * `anyButton()` now has a `state` argument
 * added support for WiiMote (#1563) and PS Vita (#1714) controllers
* `FlxRandom`:
 * `FlxRandom` functions are now member functions, call `FlxG.random` instead of `FlxRandom` (#1201)
 * exposed `currentSeed` as an external representation of `internalSeed` (#1138)
 * removed `intRanged()` and `floatRanged()`, `int()` and `float()` now provide optional ranges (#1138)
 * removed `weightedGetObject()`, `getObject()` now has an optional `weights` parameter (#1148)
 * removed `colorExt()`, try using `FlxColor` to get finer control over randomly-generated colors (#1158)
 * updated random number generation equation to avoid inconsistent results across platforms; may break recordings made in 3.x! (#1148)
 * can now create an instance of `FlxRandom` to create deterministic pseudorandom numbers independently of HaxeFlixel core functions (e.g. particle emitters)
 * `chanceRoll()` -> `bool()`
 * added `floatNormal()` (#1251)
* `FlxArrayUtil`: removed randomness-related functions, please use `FlxRandom` instead (#1138)
* `FlxText`:
 * added an `abstract` enum for alignment (`text.alignment = CENTER;` is now possible)
 * `font` now supports font assets not embedded via `openfl.Assets` (i.e. `@:font`)
 * `font = null;` now resets it to the default font
 * fixed an issue where the value returned by `get_font()` wouldn't be the same as the one passed into `set_font()`
 * added `applyMarkup()` (#1229)
 * fixed issues with `borderStyle` and `FlxTextFormat` on native
 * added `stampOnAtlas()` method, which stamps text graphic on provided atlas and loads result node's graphic into this text object
 * retrieving text dimensions (`width` and `height`) can now trigger text graphic regeneration (if any changes led to a dimensions change) to report the correct values
 * `borderColor` now supports alpha values / ARBG colors
 * fixed `setFormat()` resetting `alignment` (#1629)
* `FlxTypedButton`:
 * now implements `IFlxInput`, adding `pressed`, `justPressed`, `released` and `justReleased`
 * now uses animations for statuses instead of setting `frameIndex` directly for more flexibility (removes `allowHighlightOnMobile`, adds `statusAnimations`)
 * disabling the highlight frame is now tied to `#if FLX_NO_MOUSE` instead of `#if mobile`
 * `labelAlphas[FlxButton.HIGHLIGHT]` is now 1 for `FLX_NO_MOUSE`
 * `set_label()` now updates the label position
 * added `maxInputMovement`
 * added `mouseButtons` to control which mouse buttons can trigger the button
 * don't initialize label when the label's text passed in the constructor is null
 * added `stampOnAtlas()` method which stamps button's label graphic and button's graphic on the provided atlas and then loads result nodes into button and label. This helps reduce number of drawcalls on native targets
* `FlxMouseEventManager`:
 * moved from `flixel.plugin.MouseEventManager` to `flixel.input.mouse.FlxMouseEventManager`
 * added `removeAll()` (#1141)
 * fixed inaccurate pixel-perfect sprite overlap checks (#1075)
 * now supports all mouse buttons (`mouseButtons` argument in `add()` / `setObjectMouseButtons()`)
* `FlxObject`:
 * added `getPosition()` and `getHitbox()`
 * added `setPositionUsingCenter()` (#1482)
 * split some of `separate()`'s functionality into `updateTouchingFlags()`, allowing `touching` to be used without any separate calls (#1555)
* `PS4ButtonID` / `PS3ButtonID`: removed the `_BUTTON` suffix for consistency with other button ID classes (#1137)
* `FlxSprite`:
 * added `graphicLoaded()` which is called whenever a new graphic is loaded
 * `getScreenXY()` -> `getScreenPosition()`
 * removed the `NewSprite` argument from `clone()`
 * added `clipRect`
 * `frames` -> `numFrames`
 * added `frames` which reflects the sprite's current frames collection
 * removed `loadGraphicFromTexture()` and `loadRotatedGraphicFromTexture()`
 * `cachedGraphics` -> `graphic`
 * added `setFrames()` which allows you to save animations which already exists in the sprite
 * `colorTransform` is always instantiated
 * added `loadRotatedFrame()` which allows you to generate prerotated image from given frame and load it
 * added error message then trying to get pixels and graphic is null
 * `drawFrame()` is no longer `inline` so it can be redefined in subclasses.
 * `set_angle()`: always change the prerotated animation angle to prevent delays
 * removed `resetFrameBitmaps()` method, since frames don't store bitmaps anymore. Set `dirty` to true to force the frame graphic to be regenerated in the next render loop.
 * added `useFramePixels`
 * `setColorTransform()`'s offset arguments now work with drawTiles rendering on OpenFL 3.6.0+ (#1705)
 * `getFlxFrameBitmapData()` -> `updateFramePixels()` (#1710)
* Added some helpful error messages when trying to target older SWF versions
* `FlxAngle`:
 * changed `rotatePoint()` to not invert the y-axis anymore and rotate clockwise (consistent with `FlxSprite#angle`)
 * `rotatePoint()` -> `FlxPoint#rotate()` (#1143)
 * `getAngle()` -> `FlxPoint#angleBetween()` (#1143)
 * added `angleFromFacing()` (#1193)
 * fixed `wrapAngle()` (#1610)
 * removed `angleLimit()` (#1618)
* Added GitSHA macro that includes the SHA of the current commit into `FlxVersion` for dev builds
* Flixel sound assets are now being embedded via `embed="true"`
* `FlxRect`:
 * added `weak()`, `putWeak()`, `ceil()` and `floor()`
 * `containsFlxPoint()` -> `containsPoint()`
* `FlxPoint`: `inFlxRect()` -> `inRect` 
* Added support for reloading graphics via OpenFL live asset reloading (native targets)
* `FlxSound`
 * can now be used even if `FLX_NO_SOUND_SYSTEM` is enabled (#1199)
 * `looped` is now `public`
 * added `pitch` (#1465)
 * added `FlxSoundGroup` (#1316)
* `FlxVelocity`: `accelerateTowards*()`-functions now only take a single `maxSpeed` argument (instead of `x` and `y`)
* `BaseScaleMode`: added `horizontalAlign` and `verticalAlign`
* `RatioScaleMode#new()`: added a `fillScreen` option
* `FlxPath`: fixed an issue where a velocity would be set even if the object positon matches the current node
* `FlxGraphic`: added `defaultPersist` (#1241)
* `FlxPool`: improved pooling performance (#1189)
* `FlxTween`
 * `complete` callback parameter in options is now called `onComplete`. Its type, `CompleteCallback`, is now called `TweenCallback`. (#1273)
 * added `onStart` and `onUpdate` callback parameters in options (#1273)
 * fixed `active = false;` not doing anything during `onComplete()` of `LOOPING` or `PINGPONG` tweens
 * angle tween sets sprite's angle on start now
 * added `then()` and `wait()` for chaining (#1614)
 * made `start()` public (#1692)
* `FlxTimer`: `complete` -> `onComplete` (#1275)
* `FlxSwipe`: `duration` now uses seconds instead of milliseconds (#1272)
* `FlxPath` and motion tweens now restore the original `immovable` value of `FlxObject`s after completion
* The signature of `update()` was changed to `update(elapsed:Float)`. The `elapsed` argument should be used instead of `FlxG.elapsed`. (#1188)
* `FlxState`:
 * `onFocus()` and `onFocusLost()` no longer require `FlxG.autoPause` to be false
 * added `switchTo()` (#1676)
* `FlxNode`:
 * moved to `flixel.graphics.atlas`
 * added `getTileFrames()` and `getImageFrame()`
* `FlxAtlas`:
 * moved to `flixel.graphics.atlas`
 * added `addNodeWithSpacings()`
 * added `minWidth`, `maxWidth`, `minHeight` and `maxHeight` (the size starts at `min` and grows up until `max` as images are added)
 * added `powerOfTwo` (forces atlas size to a power of two)
 * added `allowRotation` (indicates whether added images may be rotated to save space)
* Changed game scaling behavior for all targets: it scales the camera's sprite now
* `CachedGraphics` -> `FlxGraphic`, moved to `flixel.graphics`
* Added static methods to `FlxGraphic` class for generation of objects of this type from various sources: `fromAssetKey()`, `fromClass()`, `fromBitmapData()`
* `FlxGraphic`'s `bitmap` property is now settable, changing it will lead to regeneration of graphic's tilesheet. `FlxAtlas` uses this feature, since it could increase its size and therefore change its `BitmapData` canvas.
* Added new conception of frames collections instead of regions, which required a lot of typing to get simple spritesheet from image region
* Added `FlxImageFrame` frames collection which contains single frame
* Added `FlxTileFrames` frames collection which contains frames for spritesheet, which can be generated from image region or frame (including rotated and trimmed frames)
* Added `FlxAtlasFrames` frames collection instead of various texture atlas loaders (like `SparrowData` and `TexturePackerData`). It contains various static methods for parsing atlas files
* Rewrote `PxBitmapFont` class and renamed it to `FlxBitmapFont`. It supports AngelCode, XNA and Monospace bitmap fonts now.
* Rewrote `FlxBitmapTextField` class and renamed it to `FlxBitmapText`
* `FlxBitmapText`: removed `size`
* Added `FlxFilterFrames` frames collection instead of `FlxSpriteFilter` (see filters demo)
* Changed `FlxGraphicAsset` from `OneOfFive<String, Class<Dynamic>, CachedGraphics, TextureRegion, BitmapData>` to `OneOfThree<FlxGraphic, BitmapData, String>` which means that graphic loading methods (in all classes) accept only these three types of objects
* `FlxBitmapDataUtil`:
 * added `replaceColor()` which is used by `FlxSprite`'s `replaceColor()` method
 * added `addSpacing()` which takes BitmapData and generates new one with spaces between frames
 * added `generateRotations()` which generates new BitmapData with prerotated given BitmapData object (this functionality is moved from `FlxSprite`)
* `FlxAnalog` and `FlxVirtualPad` now have their own atlas with default graphic, so they propduce less draw calls
* Added `FlxSpriteButton` which is button which label is a simple `FlxSprite`. It has a useful `createTextLabel()` method which generates a sprite with text graphic.
* `FlxSignal`: fixed a bug that occured when calling `remove()` during a dispatch (#1420)
* `FlxG`:
 * `debugger`: fixed a crash when calling `addTrackerProfile()` before `track()`
 * `signals`:
 	* split `gameReset` into pre/post signals
 	* added `preStateCreate` (#1557)
 * `android`: `preventDefaultBackAction` has been replaced by `preventDefaultKeys`
 * `inputs`: added `resetOnStateSwitch`
 * added `FlxG.addPostProcess()` / `removePostProcess()`
 * added `resizeWindow()`
* Added `filtersEnabled` and `setFilters()` to `FlxCamera` and `FlxGame` (#1635)

3.3.12
------------------------------
* Fix compilation with OpenFL 3.5 / Lime 2.8

3.3.11
------------------------------
* Fix compilation with OpenFL next
* `FlxAssets.getFileReferences()`:
  * now ignores invisible files (#1280)
  * fixed compiler error with iOS builds (#1276)

3.3.10
------------------------------
* Fix HTML5 compilation with OpenFL 3.1.1 / Lime 2.4.5

3.3.9
------------------------------
* HTML5 builds no longer default to using openfl-bitfive over OpenFL's backend
* `FlxTilemap`:
  * fixed a collision bug near the edge of the tilemap (#1546)
  * fixed `loadMap()` with trailing whitespace in CSV files (#1550)
* `FlxTextField`: fixed a crash when calling the constructor with `Text == null`
* `FlxGamepadManager`: fixed `lastActive` only updating when a new gamepad connects
* `FlxText`: fixed the default font not working on Android due to an OpenFL bug (#1399)
* `FlxVector`:
  * fixed behaviour of `set_length()` for `(0, 0)` vectors (#1144)
  * fixed `subtractNew()` (#1231)
* `FlxTimer`: timers with a time of 0 can now be started
* `FlxSignal`: fixed `addOnce()` not working on neko (#1223)
* `FlxSave`: fixed `data` still having the deleted properties after `erase()` (#1302)
* `FlxPool`: fixed a bug with point / rect pooling that could lead to them being recycled when they shouldn't be

3.3.8
------------------------------
* Use lime legacy with OpenFL 3+

3.3.7
------------------------------
* Compatibility fix for Haxe 3.2.0 (recursive @:generic function)


3.3.6
------------------------------
* Compatibility fix for OpenFL 2.1.6


3.3.5
------------------------------
* FlxTilemap:
 * fixed pixelPerfectRender not being respected with FLX_RENDER_TILE
 * fixed a crash when trying to create a single-column tilemap
* FlxCamera: fixed defaultCameras not being reset on state switches
* FlxPoint#putWeak(): fixed an issue which could lead to a single point being allocated more than once when weak() is used
* FlxVector: fixed radiansBetween() / degreesBetween()
* FlxTypedSpriteGroup: fixed update() order leading to collision issues with members
* FlxTypedEmitter: fixed type parameter not being respected (T was always FlxSprite)
* FlxAssets#getFileReferences(): fixed the filterExtensions parameter
* FlxBitmapTextField:
 * fixed issue with width increasing when the text is updated
 * fixed text disappearing after state switches on HTML5
* FlxAnalog: changed the default value for scrollFactor to (0, 0) and for moves to false
* FlxGamepad:
 * fixed a bug that would prevent buttons from being updated
 * anyPressed() now also works when the button status is justPressed
* FlxTween: fixed a bug when tweening the same field with several tweens + startDelay
* FlxSubState:
 * fixed calling close() within create()
 * fixed openSubState() not working when close() is called afterwards on the current substate on the same frame

3.3.4
------------------------------
* Combatibility with OpenFL 2.0.0

3.3.3
------------------------------
* FlxSpriteFilter: fixed graphic being destroyed when not used elsewhere
* FlxTileblock: fixed graphic not showing up
* FlxBar: fixed a crash
* TexturePackerData: fixed a crash when destroy() is called more than once
* FlxSprite: fixes for drawFrame() and stamp()
* FlxVelocity and FlxAngle: removed arbitrary limitation of some parameters being of type Int (now Float)
* FlxTypedEmitter: added a set() to Bounds<T>

3.3.2
------------------------------
* Updated the Xbox 360 button IDs to work with OpenFL 1.4.0
* FlxBitmapTextField: fixed graphic "corrupting" after state switches
* Added a bitmapLog window to the debugger to view BitmapData, used via FlxG.bitmapLog
* Added a way to view the graphics cache via FlxG.bitmapLog.viewCache() or by typing "viewCache" / "vc" into the console
* CachedGraphics: destroyOnNoUse is now true by default
* FlxBitmapUtil: added getMemorySize()
* FlxStringUtil: added formatBytes()
* FlxTimer: fixed a bug where a timer could be added to the TimerManager more than once
* FlxTilemap.ray() consistency fix
* FlxTextField: fix initial height being too small
* FlxAnimationController: fixed frameIndex not being reset after a graphic is loaded
* FlxKeyboard: added FlxKey.PRINTSCREEN for native targets
* Allowed changing the HTML5-backend (before including flixel: `<set name="html5-backend" value="new-backend">`)
* FlxSprite: optimization for less BitmapData creation of simple sprites with blitting. Might require an additional dirty = true; when manipulating the BitmapData directly.
* FlxCollision.pixelPerfectCheck() now works with bitfive

3.3.1
------------------------------
* FlxKeyboard: fixed function keys being offset by 1 on cpp (F2-F13)
* FlxTilemap: fixed possible crash during collision checks
* FlxG.sound.play(): fixed volume parameter not working

3.3.0
------------------------------
* Added flash gamepad support. This either requires a swf-player-version of 11.8 to be set or FLX_NO_GAMEPAD to be defined.
 * FlxGamepad.getAxis() has been split into getXAxis() and getYAxis() for consistency across targets
 * FlxGamepad.dpadUp / Down / Left / Right don't work in flash, use getButton() in conjunction with the IDs in the button ID classes instead
* Added "tracker" window to the debugger which creates a Watch window with the most important properties of an object
 * Use FlxG.debugger.track(Object); to create a new tracker window
 * Use FlxG.debugger.addTrackerProfile() to add a profile for classes don't have one yet or override existing ones
 * Use the "track [object]" command to open a tracker window from the console
* FlxCamera: 
 * Added static defaultCameras array which is used by FlxBasics when their cameras array has not been set - previously the use of FlxG.cameras.list / all existing cameras was hardcoded
 * Fixed a bug where following a target would prevent you from setting the coordinates of the camera
* Added pooling for FlxPoint, FlxVector, and FlxRect. Usage: var point = FlxPoint.get(); /* do stuff with point */ point.put(); // recycle point. FlxPoint.weak() should be used instead of get() when passing points into flixel functions, that way they'll be recycled automatically.
* Debugger windows:
 * Fixed dragging of overlapping windows
 * Fixed the visibility of windows on native targets (now saving correctly)
 * Fixed resizing when moving the mouse to the left / above the window
* FlxPath: fixed a bug with drawDebug()
* FlxG:
 * fullscreen: fixed offset in flash
 * openURL(): now adds "http://" to the URL if necessary
 * Added maxElapsed
 * Fixed some variables not being reset in resetGame()
 * added FlxG.accelerometer for mobile targets
* FlxSound: 
 * Added loadByteArray()
 * Now has a read-only variable time
 * Allow sound caching on all targets instead of only on Android
 * Added FlxG.sound.soundTrayEnabled to allow dis- and enabling the tray at runtime
 * survive -> persist
* MouseEventManager: 
 * Improved handling of visible / exists
 * Now works on FlxObjects
 * addSprite() -> add()
* FlxPoint: 
 * Added floor() and ceil()
 * Added add() and addPoint() (removed add() from FlxVector)
 * Added subtract() and subtractPoint() (removed substract() from FlxVector)
* Changed the default html5 backend to openfl-bitfive
 * Middle and right mouse events are now supported
 * Sounds are now supported
* FlxObject: replaced forceComplexRender by pixelPerfectRender which rounds coordinates by default (if true) for drawing (also on cpp targets, making it consistent with flash)
* FlxText: 
 * Added shadowOffset
 * Fixed the widthInc and heightInc of addFilter() which did not work at all previously
 * Seperated visible and physical width by adding fieldWidth to fix a bug
 * Added autoSize that makes sure the entire text is displayed if true with wordWrap = false. Setting fieldWidth to 0 in the constructor is now allowed and activates this behaviour.
 * Fixed variation in height of empty texts
* FlxSpriteUtil: added bound()
* FlxSpriteGroup:
 * Added FlxTypedSpriteGroup, which can be used in the same way as FlxTypedGroup, but its type parameter is T:FlxSprite
 * Setting cameras will now set cameras on its members, add()-ing a sprite will synchronize the values
* Abstracted rendering into FLX_RENDER_TILE and FLX_RENDER_BLIT conditionals as opposed to being hardcoded based on the target
* FlxTween:
 * num(): added an optional tweenFunction parameter which can be used for increased performance (as MultiVarTween and SingleVarTween are fairly slow, using Reflection)
 * singleVar() and multiVar() have been replaced by tween()
 * Removed SfxFader and Fader
* FlxKeyboard:
 * Implemented a workaround for function and numpad keys not working on native targets
 * Added FlxKey.NUMPADMULTIPLY / "NUMPADMULTIPLY"
 * Added firstPressed(), firstJustPressed() and firstJustReleased()
* Added FlxCallbackPoint, a FlxPoint that calls a function when x, y or both are changed.
* FlxTilemap: 
 * Replaced scaleX and scaleY by a scale FlxPoint
 * Removed rayHit(), ray() provides the same functionality
* Added FlxDestroyUtil (FlxG.safeDestroy() -> FlxDestroyUtil.destroy())
* Debugger stats window: added a button to expand the window and show two more graphs (draw and update time)
* Added buildFileReferences() macro to FlxAssets.hx (auto-completion for asset string paths)
* FlxTilemap.computePathDistance() is now public and has a new StopOnEnd parameter
* Added FlxColor.MAGENTA
* Added FlxMouse.setGlobalScreenPositionUnsafe()
* FlxTypedButton: 
 * Fixed label.visible = false; not working
 * Fixed a one-frame-delay between setting the label's position and it taking effect
 * Fixed label scrollfactor being out of sync before the first update()
* FlxButton: Added a text property as a shortcut for label.text
* FlxSprite:
 * Added support for more texture packer formats: LibGDXData, SparrowData, TexturePackerXMLData
 * Fixed a null error crash in FlxAtlas on cpp targets with haxe 3.1.0+
 * setOriginToCenter() -> centerOrigin()
 * Fixed a "jittering"-issue between simple and complex render sprites due to rounding
 * Removed flipped as well as the "Reverse" param from loadGraphic() and loadGraphicFromTexture()
 * Added flipX, flipY and setFacingFlip() - graphics can now be flipped vertically as well
 * Fixed a bug with flipped graphics + origin on FLX_RENDER_TILE targets
* FlxPreloader:
 * Spit up FlxPreloader into FlxPreloader and FlxPreloaderBase to make it easier to extend
 * Small fix that should prevent it from getting stuck
 * Added siteLockURLIndex to control which URL in allowdURLs is used when the site-lock triggers
 * allowedURLs now works with URLs that don't start with "http://"
* Fixed camera shifting after resizing with StageSizeScaleMode
* Added flixel.util.FlxSignal and FlxG.signals
* FlxAnimationController:
 * Added append(), appendByNames(), appendByStringIndices(), appendByIndices() and appendByPrefix()
 * addByStringIndicies() -> addByStringIndices()
 * addByIndicies() -> addByIndices()
 * Fixed a bug with callback firing every time play() was called instead of only when the frame changes
* FlxTypedGroup: added forEachOfType() iterator
* FlxGamepad: 
 * Added anyPressed(), anyJustPressed() and anyJustReleased()
 * Added PS4ButtonID
* Traces are not being redirected to the debugger log window anymore by default
* Fixed mouse cursor scale at initial camera zoom levels different from 1
* FlxState: active, visible and exists are now respected
* FlxVector: substractNew() -> subtractNew()
* FlxGradient: fixed a memory leak in the overlayGradientOn()-functions
* FlxTimer and FlxPath:
 * paused -> active
 * abort() -> cancel()
 * removed pooling due to potential issues
 * start() -> new FlxTimer() / FlxPath()
 * run() -> start()
* FlxTimer and FlxTween: removed userData

3.2.2
------------------------------
* Removed the allow-shaders="false" attribute from the window tag in the include.xml, as it causes problems (white screen) with lime 0.9.5 on iOS

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
