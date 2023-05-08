5.3.1 (May 7, 2023)
------------------------------
#### Changes and improvements:
- Change all `@:enum abstract` to `enum abstract` to prevent warnings in haxe 4.3.1 ([#2790](https://github.com/HaxeFlixel/flixel/pull/2790))
- `FlxAnimation`: Prevent crash when destroying sprites in an anim callback ([#2785](https://github.com/HaxeFlixel/flixel/pull/2785))
- `FlxCollision`: Fix gap in `createCameraWall` ([#2781](https://github.com/HaxeFlixel/flixel/pull/2781))

5.3.0 (April 26, 2023)
------------------------------
#### Dependencies:
- Dropped support for haxe 4.0 and 4.1, use 4.2.5 or higher

#### New features:
- `FlxAtlasFrames`: Add `addFrameOffset` and `addFramesOffsetByPrefix` ([#2746](https://github.com/HaxeFlixel/flixel/pull/2746))
- `FlxFrame`: Add `duration` ([#2752](https://github.com/HaxeFlixel/flixel/pull/2752))
	- `FlxAtlasFrames`: Add `fromAseprite` which takes Aseprite generated Json, and honors frame duration
- `FlxState`: Add `startOutro`, deprecate `switchTo` ([#2768](https://github.com/HaxeFlixel/flixel/pull/2768))

#### Changes and improvements:
- `FlxSound` and `FlxSoundGroup`: Moved to the `flixel.sound` package, deprecate old package ([#2726](https://github.com/HaxeFlixel/flixel/pull/2726))
- `FlxBitmapText`: Add `x`, `y` and `text` args to constructor ([#2750](https://github.com/HaxeFlixel/flixel/pull/2750))
- `FlxAtlasFrames`: Take `Xml` in `fromSparrow` ([#2751](https://github.com/HaxeFlixel/flixel/pull/2751))
- `FlxBitmapFont`: Take `Xml` in `fromAngelCode` ([#2751](https://github.com/HaxeFlixel/flixel/pull/2751))
- `FlxAnimation`: Deprecate `delay` in favor of the new `frameDuration` field ([#2752](https://github.com/HaxeFlixel/flixel/pull/2752))
- `FlxAnimation` and `FlxColor`: Small fixes ([#2755](https://github.com/HaxeFlixel/flixel/pull/2755))
- `FlxSound`: Fix doc comment ([#2767](https://github.com/HaxeFlixel/flixel/pull/2767))
- `FlxSprite`: Better warnings for invalid `width`/`height` args on `loadGraphic` ([#2762](https://github.com/HaxeFlixel/flixel/pull/2762))
- `FlxCamera`: Allow `followLerp` to be used with `NO_DEAD_ZONE` ([#2771](https://github.com/HaxeFlixel/flixel/pull/2771))
- Improve docs ([#2777](https://github.com/HaxeFlixel/flixel/pull/2777)) ([#2778](https://github.com/HaxeFlixel/flixel/pull/2778))

#### Bugfixes:
- `FlxSave`: Fixed issue with `mergeDataFrom` where `overwrite = true` ([#2738](https://github.com/HaxeFlixel/flixel/pull/2738))
- `FlxText`: Fix `embedFonts` getter ([#2749](https://github.com/HaxeFlixel/flixel/pull/2749))
- `DebugFrontEnd`: Fixed freezing bug when pressing tab on debug ([2760](https://github.com/HaxeFlixel/flixel/pull/2760))
- `LogFrontEnd`: Fixed null crashes when logging before `FlxGame` in created ([2779](https://github.com/HaxeFlixel/flixel/pull/2779))
- `FlxSave`: Fixed saves with multiple invalid characters ([#2779](https://github.com/HaxeFlixel/flixel/pull/2779))

5.2.2 (February 15, 2023)
------------------------------
#### Bugfixes:
- `FlxGamePad`: Fix various "firstPressed" functions ([#2728](https://github.com/HaxeFlixel/flixel/pull/2728))
- `FlxSave`: Prevent crash when hiding debug windows, after `FlxG.save.bind` is called ([#2725](https://github.com/HaxeFlixel/flixel/pull/2725))
- `FlxCamera`: remove uses of camera.camera ([#2731](https://github.com/HaxeFlixel/flixel/pull/2731))

5.2.1 (January 20, 2023)
------------------------------
#### Bugfixes:
- `FlxSave`: Fix save location on android and ios ([#2718](https://github.com/HaxeFlixel/flixel/pull/2718))

5.2.0 January 17, 2023
------------------------------
#### New features:
- `FlxMouse`: added `deltaX`, `deltaY`, `deltaScreenX` and `deltaScreenY` ([#2709](https://github.com/HaxeFlixel/flixel/pull/2709))
- `FlxCamera`: added public `view` and `viewMargin` properties, deprecated old, private viewOffset fields([#2714](https://github.com/HaxeFlixel/flixel/pull/2714))

#### Changes and improvements:
- `FlxStrip`: allows shaders and color transforms ([#2696](https://github.com/HaxeFlixel/flixel/pull/2696))

#### Bugfixes:
- `FlxSpriteGroup`: Fix `findMinY()` and `findMaxY()` returning `x` instead of `y` ([#2713](https://github.com/HaxeFlixel/flixel/pull/2713))

5.1.0 December 22, 2022
------------------------------
#### Changes and improvements:
- `SoundFrontEnd`: added `soundTray` getter for `FlxG.game.soundTray` ([#2706](https://github.com/HaxeFlixel/flixel/pull/2706))

#### New features:
- `FlxArrayUtil`: Added `swap`, `swapByIndex`, `safeSwap` and `safeSwapByIndex` ([#2685](https://github.com/HaxeFlixel/flixel/pull/2685))
- `FlxDirectionFlags`: Added `hasAny` ([#2705](https://github.com/HaxeFlixel/flixel/pull/2705))

#### Bugfixes:
- `FlxPoint`: fixed math error in `rotate`, `pivotDegrees` and `pivotRadians` ([#2700](https://github.com/HaxeFlixel/flixel/pull/2700))
- `FlxObject`: fixed `isTouching` and `wasTouching` to check **any** given instead of **all** ([#2705](https://github.com/HaxeFlixel/flixel/pull/2705))

5.0.2 November 30, 2022
------------------------------
#### Changes and improvements:
- `FlxAssetPaths`: Warnings involving assets will point to that asset instead of the build macro. ([#2684](https://github.com/HaxeFlixel/flixel/pull/2684))
- `FlxTilemap`: Honors `FlxSprite.defaultAntialiasing` ([#2688](https://github.com/HaxeFlixel/flixel/pull/2688))

5.0.1 November 23, 2022
------------------------------
#### Bugfixes:
- Fix lime < 8 not being properly defined to FLX_NO_PITCH ([#2678](https://github.com/HaxeFlixel/flixel/pull/2678))
- `AssetPaths`: various fixes ([#2680](https://github.com/HaxeFlixel/flixel/pull/2680))
	- apply `include`/`exclude` args to files, not directories
	- default file renamer will replace spaces with underscore
 
#### New features:
- `FlxKeys`: Added `SCROLL_LOCK`, `NUMLOCK`, `WINDOWS`, `MENU`, `BREAK` and `NUMPADSLASH` keys ([#2638](https://github.com/HaxeFlixel/flixel/pull/2638))

5.0.0 (November 20, 2022)
------------------------------
The alpha was causing issues with CI due to haxelib issues. We're foregoing the alpha, since the new features are considiered "stable".

5.0.0-alpha.2 (November 19, 2022)
------------------------------
#### Bugfixes:
- `FlxDefines` prevent compile error when targeting lime 7 on non-sys targets ([#2676](https://github.com/HaxeFlixel/flixel/pull/2676))

5.0.0-alpha (November 19, 2022)
------------------------------
#### New features:

- `FlxMouse`: Added `released`, `releasedRight` and `releasedMiddle` ([#2496](https://github.com/HaxeFlixel/flixel/pull/2496))
- Angles: Added various degree/radian specific versions of existing angle helpers ([#2482](https://github.com/HaxeFlixel/flixel/pull/2482))
- `FlxDirectionFlags`: Various helpers
	- Added `degrees` and `radians` fields ([#2482](https://github.com/HaxeFlixel/flixel/pull/2482))
	- added `fromBools` static helper ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480))
- `FlxVector`: Added `copyTo` ([#2550](https://github.com/HaxeFlixel/flixel/pull/2550))
- `FlxCollision`: Added `calcRectEntry` and `calcRectExit` ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480))
- `FlxTilemap`: Overhaul to pathfinding ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480))
	- `FlxPathfinder`: Allows customizable pathfinding algorithms for tilemap
	- `FlxPathSimplifier`: Replace findPath simplify args with a new enum
	- Expose previously private fields: `tileWidth`, `tileHeight`, `scaledTileWidth`, `scaledTileHeight`, `scaledWidth`, and `scaledHeight`
	- `FlxBaseTilemap`: added `calcRayEntry` and `calcRayExit`
- `FlxPath`: various new features
	- added `immovable` bool (previously, objects were always immovable when following paths) ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480))
	- added `angleOffset` to augment the angle of sprites following paths ([2674](https://github.com/HaxeFlixel/flixel/pull/2674))
- `FlxPathDrawData`: added `myFlxPath.debugDrawData` to allow custom colors and draw properties ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480))
- `FlxAxes`: added `x` and `y` getters, `NONE` value, `toString`, `fromString`and `fromBools` methods ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480), [#2659](https://github.com/HaxeFlixel/flixel/pull/2659))
- `FlxTween`: added `ShakeTween` and `FlxTween.shake()` helper ([#2549](https://github.com/HaxeFlixel/flixel/pull/2549))
- `WatchFrontEnd`: added `FlxG.watch.addFunction` ([#2500](https://github.com/HaxeFlixel/flixel/pull/2500))
- `FlxPoint`: added binary operators `+`, `-`, `+=`, `-=`, `*`, and `*=` ([#2557](https://github.com/HaxeFlixel/flixel/pull/2557))
- `FlxColor`: added `rgb` getter and setter ([#2555](https://github.com/HaxeFlixel/flixel/pull/2555))
- `FlxSave`: added `mergeDataFrom`, `mergeData` `status`, `isBound` and `isEmpty` 
([#2566](https://github.com/HaxeFlixel/flixel/pull/2566))
([#2584](https://github.com/HaxeFlixel/flixel/pull/2584))
- `FlxAnimation` - added `loopPoint` to allow looping to a frame other than the starting frame ([#2621](https://github.com/HaxeFlixel/flixel/pull/2621))
- `FlxSound` - added `pitch` to alter the playback speed ([#2564](https://github.com/HaxeFlixel/flixel/pull/2564))
- `FlxSprite` - added `getPixelAt`, `getPixelAtScreen`, `transformWorldToPixels` and `transformScreenToPixels` ([#2640](https://github.com/HaxeFlixel/flixel/pull/2640))
- `FlxStringUtil` - added `toTitleCase` and `toUnderscoreCase` ([#2670](https://github.com/HaxeFlixel/flixel/pull/2670))
- `FlxAssets` - changed parameters to `buildFileReferences` (Affects `AssetPaths`) ([#2575](https://github.com/HaxeFlixel/flixel/pull/2575))
	- replaced `filterExtensions` arg with `include` and `exclude` args
	- changed `rename` arg to take the full filepath, can return `null` to exclude

#### Bugfixes:

- `FlxSprite`: Fixed `loadRotatedGraphic` to solve Mod by 0 ([#2518](https://github.com/HaxeFlixel/flixel/pull/2518))
- `FlxText`: Fixed alignment issues across platforms ([#2536](https://github.com/HaxeFlixel/flixel/pull/2536))
- `FlxBitmapText`: Fixed issue on non-multiline text with wordWrap disabled ([#2590](https://github.com/HaxeFlixel/flixel/pull/2590))
- `FlxTypedButton` - prevent `onOver` sound when releasing a button ([#2657](https://github.com/HaxeFlixel/flixel/pull/2657/files))

#### Changes and improvements:

- Collision: preserve momentum in `FlxG.collide` ([#2422](https://github.com/HaxeFlixel/flixel/pull/2422))
- Angles: All angle utils treat right as 0 (affects `FlxSwipe` and `FlxPath`) ([#2482](https://github.com/HaxeFlixel/flixel/pull/2482))
- `FlxAngle`: deprecated: `getCartesianCoords`, `getPolarCoords`, `angleFromFacing` and `FlxPoint.angleBetween` ([#2482](https://github.com/HaxeFlixel/flixel/pull/2482))
- `FlxTilemap`: renamed `ray` to `rayStep` added new `ray` with no `resolution` arg ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480))
- `FlxPath`: move to `flixel.path.FlxPath` ([#2480](https://github.com/HaxeFlixel/flixel/pull/2480))
- `FlxPoint/FlxVector`: moved all `FlxVector` fields and methods into `FlxPoint` ([#2557](https://github.com/HaxeFlixel/flixel/pull/2557))
- `FlxSave`: changed the default save name and path to unique values based on Project.xml metadata ([#2566](https://github.com/HaxeFlixel/flixel/pull/2566))
- `FlxTilemap`: Replaced `useScaleHack` with static `defaultFramePadding` to fix tile tearing ([#2581](https://github.com/HaxeFlixel/flixel/issues/2581))
- `FlxSprite`: various improvements.
	- improved `pixelsOverlapPoint` with scaled or angled sprites ([#2576](https://github.com/HaxeFlixel/flixel/pull/2576))
	- this also improves `FlxMouseEvents` with the `pixelPerfect` arg enabled
	- added `defaultAntialiasing` ([#2658](https://github.com/HaxeFlixel/flixel/pull/2658))
- `FlxGame`: removed misleading `zoom` arg from constructor ([#2591](https://github.com/HaxeFlixel/flixel/pull/2591))
- `FlxMouseEventManager`: Changed from a static manager to an instance. Use `FlxMouseEvent` for the default manager ([#2540](https://github.com/HaxeFlixel/flixel/pull/2540))

4.11.0 (January 26, 2022)
------------------------------
#### Dependencies:

- Dropped support for haxe 3, use 4.0.5 or higher

#### New features:

- `FlxAnimationController`: added `getAnimationList`, `getNameList`, `exists` and `rename` ([#2473](https://github.com/HaxeFlixel/flixel/pull/2473))
- `FlxRect`: added `getRotatedBounds` ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))
- `FlxObject`: added `getRotatedBounds` ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))
- `FlxSprite`: added `getScreenBounds` ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))
- `FlxSpriteUtil`: added `cameraWrap` and `cameraBounds` ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))
- `FlxCamera`: added `getViewRect` and `containsRect` ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))

#### Bugfixes:

- Fixed segmentation faults on Hashlink for linux ([#2487](https://github.com/HaxeFlixel/flixel/pull/2487))
- `FlxSpriteGroup`: `kill`, `revive` and `revive` call the respective function on members ([#2423](https://github.com/HaxeFlixel/flixel/pull/2423))

#### Changes and improvements:

- `FlxCollision`: improved `pixelPerfectCheck` performance, now honors scale ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))
- `FlxSprite`: improved `isOnScreen` accuracy ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))
- `FlxCamera`: added `putWeak` call in `containsPoint` ([#2298](https://github.com/HaxeFlixel/flixel/pull/2298))
- `FlxObject`: `screenCenter` defaults to `XY` rather than `null` ([#2441](https://github.com/HaxeFlixel/flixel/pull/2441))
- `FlxState`: Clarify restrictions in state constructors ([#2479](https://github.com/HaxeFlixel/flixel/pull/2479))

4.10.0 (September 12, 2021)
------------------------------
#### New features:

- Added `FlxDirectionFlags` and `FlxDirection` ([#2303](https://github.com/HaxeFlixel/flixel/pull/2303))
- `FlxBitmapText`: added support for unicode combining diacritical marks ([#2309](https://github.com/HaxeFlixel/flixel/pull/2309))
- `FlxTextFormat`: added `leading` ([#2334](https://github.com/HaxeFlixel/flixel/pull/2334))
- `FlxAction`: added `addAndroidKey()` ([#2393](https://github.com/HaxeFlixel/flixel/pull/2393))
- `FlxVector`: added `setPolarRadians()` and `setPolarDegrees()` ([#2401](https://github.com/HaxeFlixel/flixel/pull/2401))

#### Bugfixes:

- `FlxAssetPaths`: fixed paths for iOS ([#2345](https://github.com/HaxeFlixel/flixel/pull/2345))
- `VarTween`: fixed an error if `cancel()` is called during `onUpdate` ([#2352](https://github.com/HaxeFlixel/flixel/pull/2352))
- `FlxGradient`: fixed last pixels sometimes not being filled ([#2367](https://github.com/HaxeFlixel/flixel/pull/2367))
- `FlxTilemap`: fixed built-in autotile assets for HTML5 ([#2402](https://github.com/HaxeFlixel/flixel/pull/2402))
- `FlxDebugger`: fixed single-character vertical text in the stats window

#### Changes and improvements:

- `FlxSpriteUtil`: enabled `drawRoundRectComplex()` for non-Flash targets ([#2332](https://github.com/HaxeFlixel/flixel/pull/2332))
- `FlxTween`: allowed `cancelTweensOf()` to cancel "grandchild" tweens ([#2354](https://github.com/HaxeFlixel/flixel/pull/2354))

4.9.0 (April 11, 2021)
------------------------------
#### Dependencies:

- Compatibility with Haxe 4.2.x

#### New features:

- `FlxTween`: added `cancelTweensOf()` and `completeTweensOf()` ([#2273](https://github.com/HaxeFlixel/flixel/pull/2273))
- `FlxSound`: added an `OnLoad` callback to `loadStream()` ([#2276](https://github.com/HaxeFlixel/flixel/pull/2276))
- `FlxState`: added `subStateOpened` and `subStateClosed` signals ([#2280](https://github.com/HaxeFlixel/flixel/pull/2280))
- `FlxG.cameras`: added a `DefaultDrawTarget` argument to `add()` and `setDefaultDrawTarget()` ([#2296](https://github.com/HaxeFlixel/flixel/pull/2296))

#### Bugfixes:

- `FlxTween`: fixed an issue with setting `startDelay` after tween creation ([#2262](https://github.com/HaxeFlixel/flixel/pull/2262))
- `FlxEmitter`: fixed `maxSize` not being set to `Quantity` in `makeParticles()` ([#2265](https://github.com/HaxeFlixel/flixel/pull/2265))
- `FlxBitmapFont`: fixed infinite loops caused by "farbling" in the Brave browser ([#2300](https://github.com/HaxeFlixel/flixel/pull/2300))

#### Changes and improvements:

- `FlxG.plugins`: improved type safety for `get()` and `remove()` ([#2292](https://github.com/HaxeFlixel/flixel/pull/2292))
- `FlxAtlasFrames`: improved animation support in `fromLibGdx()` ([#2278](https://github.com/HaxeFlixel/flixel/pull/2278))
- `FlxBasic`: assign an incremented `ID` for each created instance ([#2266](https://github.com/HaxeFlixel/flixel/pull/2266))
- `FlxCamera`: deprecated `defaultCameras` in favor of default draw targets in `FlxG.cameras` ([#2296](https://github.com/HaxeFlixel/flixel/pull/2296))

4.8.1 (July 16, 2020)
------------------------------
- improved rendering performance on low-end devices

4.8.0 (July 2, 2020)
------------------------------
#### New features:
- `FlxSplash`: added `muted` (defaults to `true` on HTML5)
- `FlxBaseKeyList`: added `NONE` ([#2253](https://github.com/HaxeFlixel/flixel/pull/2253))
- `FlxKeyManager`: added `released` ([#2253](https://github.com/HaxeFlixel/flixel/pull/2253))
- `FlxGamepad`:
	- added Switch Pro controller mappings ([#2254](https://github.com/HaxeFlixel/flixel/pull/2254))
	- added `getInputLabel()` ([#2254](https://github.com/HaxeFlixel/flixel/pull/2254))
- `FlxText`: added support for removing partial ranges in `removeFormat()` ([#2256](https://github.com/HaxeFlixel/flixel/pull/2256))

#### Bugfixes:
- `FlxGamepad`: fixed `pressed` not being `true` during the first `justPressed` frame ([#2253](https://github.com/HaxeFlixel/flixel/pull/2253))
- `FlxKeyManager`: fixed `anyPressed([ANY])` not working ([#2253](https://github.com/HaxeFlixel/flixel/pull/2253))

#### Changes and improvements:
- Fixed `Std.is()` deprecation warnings with Haxe 4.2

4.7.0 (April 12, 2020)
------------------------------
#### New features:

- `FlxGroup`: added support for specifying `cameras` ([#2232](https://github.com/HaxeFlixel/flixel/pull/2232))

#### Bugfixes:

- `FlxButton`: fixed `mouseButtons` handling ([#2246](https://github.com/HaxeFlixel/flixel/issues/2246))
- `FlxTilemap`: handle negative tile indices for all `load` methods, not just CSV ([#2250](https://github.com/HaxeFlixel/flixel/pull/2250))
- `FlxVirtualPad`: fixed graphic not showing up on HTML5
- `OUYAID`: fixed button mappings ([#2234](https://github.com/HaxeFlixel/flixel/pull/2234))

#### Changes and improvements:

- `FlxAnimation`: changed `frameRate` to a `Float` ([#2252](https://github.com/HaxeFlixel/flixel/pull/2252))

4.6.3 (August 21, 2019)
------------------------------
- Compatibility with Haxe 4.0.0-rc.3
- `FlxAssetPaths`: added support for custom renaming ([#2227](https://github.com/HaxeFlixel/flixel/issues/2227))

4.6.2 (June 19, 2019)
------------------------------
- `FlxGraphicsShader`: fixed crashes on some old iOS devices ([#2219](https://github.com/HaxeFlixel/flixel/issues/2219))
- `FlxG.android`:
	- fixed `preventDefaultKeys` handling with OpenFL 8+ ([#2218](https://github.com/HaxeFlixel/flixel/issues/2218))
	- fixed the key codes for `FlxAndroidKey.BACK` and `MENU` with OpenFL 8+ ([#2218](https://github.com/HaxeFlixel/flixel/issues/2218))

4.6.1 (April 2, 2019)
------------------------------
#### Bugfixes:

- `FlxDebugger`:
	- disabled mouse input when the debugger interaction tool is active ([#2209](https://github.com/HaxeFlixel/flixel/issues/2209))
	- clear the transform tool target on state switches
- `FlxBasePreloader`: fixed a crash on the HashLink target

4.6.0 (February 4, 2019)
------------------------------
#### Dependencies:

- Compatibility with Haxe 4.0.0-rc.1

#### New features:

- Added a new `FlxAction` API / `flixel.input.actions` ([#1805](https://github.com/HaxeFlixel/flixel/issues/1805))
- `FlxGamepadManager`: added `deviceConnected` and `deviceDisconnected` ([#1805](https://github.com/HaxeFlixel/flixel/issues/1805))
- `FlxBitmapText`: added `clipRect` support ([#2171](https://github.com/HaxeFlixel/flixel/issues/2171))
- `FlxTilemap`: added 47 tile autotiling ([#2184](https://github.com/HaxeFlixel/flixel/issues/2184))
- `FlxG.signals`:
	- added `preGameStart` ([#2188](https://github.com/HaxeFlixel/flixel/issues/2188))
	- added `postStateSwitch` ([#2207](https://github.com/HaxeFlixel/flixel/issues/2207))
- `FlxSave`: added support for local storage paths ([#2202](https://github.com/HaxeFlixel/flixel/issues/2202))
- `FlxVector`: added `weak()` support and turned it into an `abstract` ([#2191](https://github.com/HaxeFlixel/flixel/issues/2191))
- Added blend mode support for `drawQuads()` rendering with OpenFL 8.8.0+ ([#2199](https://github.com/HaxeFlixel/flixel/issues/2199))

#### Bugfixes:

- `FlxFilterFrames`: fixed previous `offset` being ignored in `applyToSprite()` ([#2176](https://github.com/HaxeFlixel/flixel/issues/2176))
- `FlxBitmapFont`: fixed background only being removed on Flash in `fromXNA()` ([#2187](https://github.com/HaxeFlixel/flixel/issues/2187))
- Fixed `drawQuads()` rendering issues if there are color offsets, but no multipliers ([#2195](https://github.com/HaxeFlixel/flixel/issues/2195))
- Fixed `FlxSubState` not being updated in the frame it is entered ([#2204](https://github.com/HaxeFlixel/flixel/issues/2204))
- `FlxText`: fixed frame size not always being correct when `updateHitbox()` is called ([#2205](https://github.com/HaxeFlixel/flixel/issues/2205))

4.5.1 (September 7, 2018)
------------------------------
- Fixed compatibility with OpenFL 8.5.0
- `FlxSoundGroup`: fixed `add()` adding sounds twice

4.5.0 (August 10, 2018)
------------------------------
#### Dependencies:

- Added support for Lime 7

#### New features:

- `FlxTween`:
	- added support for tweening sub-properties like `"scale.x"` with `tween()` ([#2152](https://github.com/HaxeFlixel/flixel/issues/2152))
	- added a `FlxTweenType` enum abstract and deprecated the constants in `FlxTween`
- `FlxSpriteGroup`: added `directAlpha` ([#2157](https://github.com/HaxeFlixel/flixel/issues/2157))
- `FlxDebugger`: added a transform interaction tool ([#2159](https://github.com/HaxeFlixel/flixel/issues/2159))

#### Bugfixes:

- `FlxBitmapText`: fixed clipping issues with text using borders ([#2151](https://github.com/HaxeFlixel/flixel/issues/2151))
- `FlxAssetPaths`: fixed variables with invalid Haxe identifiers being generated ([#1796](https://github.com/HaxeFlixel/flixel/issues/1796))
- `FlxSpriteUtil`: fixed `spaceFromBounds` in `space()` not being respected ([#1963](https://github.com/HaxeFlixel/flixel/issues/1963))
- `FlxSpriteGroup`: fixed sprites not showing up again after setting `alpha` to `0` ([#1353](https://github.com/HaxeFlixel/flixel/issues/1353))

#### Changes and improvements:

- `FlxSpriteUtil`: added an argument allowing to use a positioning function in `space()` ([#2154](https://github.com/HaxeFlixel/flixel/issues/2154))
- `FlxG.accelerometer`: enabled accelerometer support on HTML5

4.4.2 (June 12, 2018)
------------------------------
- Fixed compatibility with Haxe 4.0.0-preview.4

4.4.1 (May 10, 2018)
------------------------------
- Fixed an issue with code completion on the Flash target in VSCode

4.4.0 (May 4, 2018)
------------------------------
#### Dependencies:

- Added support for OpenFL 8 and Lime 6.3.0 ([#2136](https://github.com/HaxeFlixel/flixel/issues/2136))
- Removed support for Haxe versions < 3.4.0
- Fixed compatibility with Haxe 4 / development

#### New features:

- `FlxStringUtil`: added `getEnumName()` ([95615382](https://github.com/HaxeFlixel/flixel/commit/95615382))
- `FlxG.console`: added `registerEnum()` ([24905c4b](https://github.com/HaxeFlixel/flixel/commit/24905c4b))
- `FlxMouse`: added `justMoved` ([#2087](https://github.com/HaxeFlixel/flixel/issues/2087))
- `FlxMouseEventManager`:
	- added mouse move, click, double-click and wheel events ([#2087](https://github.com/HaxeFlixel/flixel/issues/2087))
	- added `maxDoubleClickDelay` ([#2087](https://github.com/HaxeFlixel/flixel/issues/2087))

#### Bugfixes:

- `FlxDebugger` console: fixed enum completion on non-Flash targets ([404c16b3](https://github.com/HaxeFlixel/flixel/commit/404c16b3))
- `FlxMouseEventManager`:
	- fixed mouseOver being fired before mouseOut ([#2103](https://github.com/HaxeFlixel/flixel/issues/2103))
	- fixed items with `mouseChildren = false` still allowing events for overlapping objects ([#2110](https://github.com/HaxeFlixel/flixel/issues/2110))
- `FlxAssetPaths`: fixed `filterExtensions` for files with multiple dots ([#2107](https://github.com/HaxeFlixel/flixel/issues/2107))
- `FlxDebugger` interaction tool: fixed custom cursors not showing on native targets ([ca52e7a2](https://github.com/HaxeFlixel/flixel/commit/ca52e7a2))
- `FlxDebugger` console: fixed tab not focusing the text field on native targets
- `FlxMath`: fixed `roundDecimals()` for large inputs ([#2127](https://github.com/HaxeFlixel/flixel/issues/2127))
- `FlxG.sound`: fixed sounds not being removed from the default groups on state switches ([#2124](https://github.com/HaxeFlixel/flixel/issues/2124))
- `FlxBar`: fixed bars not reaching 100% by rounding ([#2139](https://github.com/HaxeFlixel/flixel/issues/2139))

#### Changes and improvements:

- `FlxG.keys`: added arrow keys, space and tab to `preventDefaultKeys` on HTML5
- `FlxSpriteGroup`: added a `camera` setter override ([#2146](https://github.com/HaxeFlixel/flixel/issues/2146))

4.3.0 (July 22, 2017)
------------------------------
#### New features:

- `FlxTween`: added `cancelChain()` ([#1988](https://github.com/HaxeFlixel/flixel/issues/1988))
- `FlxMatrix`: added `transformX()` and `transformY()` ([dcc66b3](https://github.com/HaxeFlixel/flixel/commit/dcc66b3))
- `FlxCamera`: added `containsPoint()` ([#1964](https://github.com/HaxeFlixel/flixel/issues/1964))
- `FlxSubState`: added `openCallback` ([#2023](https://github.com/HaxeFlixel/flixel/issues/2023))
- `FlxSpriteGroup`:
	- added `insert()` ([#2020](https://github.com/HaxeFlixel/flixel/issues/2020))
	- added `clipRect` support ([#2051](https://github.com/HaxeFlixel/flixel/issues/2051))
- `FlxSoundGroup`: added `pause()` and `resume()` ([#2043](https://github.com/HaxeFlixel/flixel/issues/2043))
- `FlxDebugger` interaction tool:
	- added tooltips ([#2006](https://github.com/HaxeFlixel/flixel/issues/2006))
	- added a selection rectangle ([#1995](https://github.com/HaxeFlixel/flixel/issues/1995))
- `FlxDebugger` console: added an "Entry Type" quick watch entry ([d354352](https://github.com/HaxeFlixel/flixel/commit/d354352))
- `FlxStringUtil`: added `getHost()` ([#1996](https://github.com/HaxeFlixel/flixel/issues/1996))
- `FlxPoint`: added `toVector()` ([#2061](https://github.com/HaxeFlixel/flixel/issues/2061))
- `FlxGamepad`: added `getAnalogAxes()` ([#2064](https://github.com/HaxeFlixel/flixel/issues/2064))
- `FlxMouse`: added getters for `justPressedTimeInTicks` ([#2070](https://github.com/HaxeFlixel/flixel/issues/2070))
- `FlxEase`: added `linear` / `smooth` / `smoother` functions ([#2080](https://github.com/HaxeFlixel/flixel/issues/2080))

#### Bugfixes:

- `FlxAnimation`: fixed reversed animations ([#1998](https://github.com/HaxeFlixel/flixel/issues/1998))
- `FlxRandom`: fixed `getObject()` not respecting `startIndex` ([#2009](https://github.com/HaxeFlixel/flixel/issues/2009))
- `FlxGroup`: fixed `remove()` with `Splice = true` not decreasing `length` ([#2010](https://github.com/HaxeFlixel/flixel/issues/2010))
- `FlxStringUtil`: fixed an issue with decimals in `formatMoney()` ([#2011](https://github.com/HaxeFlixel/flixel/issues/2011))
- `FlxMouseEventManager`:
	- fixed overlap checks for off-camera sprites ([#1964](https://github.com/HaxeFlixel/flixel/issues/1964))
	- fixed pixel-perfect overlaps with `offset` ([#1999](https://github.com/HaxeFlixel/flixel/issues/1999))
	- fixed reset logic on state switches ([#1986](https://github.com/HaxeFlixel/flixel/issues/1986))
- `FlxPreloader`: fixed missing assets with full DCE ([764a5a8](https://github.com/HaxeFlixel/flixel/commit/764a5a8))
- `FlxG.cameras`: fixed `reset()` not removing all cameras ([#2016](https://github.com/HaxeFlixel/flixel/issues/2016))
- `FlxAnimationController`: fixed `flipX` / `Y` not being copied in `copyFrom()` ([#2027](https://github.com/HaxeFlixel/flixel/issues/2027))
- `haxelib run flixel`: fixed the working directory not being passed on ([61f2c20](https://github.com/HaxeFlixel/flixel/commit/61f2c20))
- `FlxDebugger` interaction tool:
	- fixed selection of `FlxSpriteGroup` members ([89a4ee2](https://github.com/HaxeFlixel/flixel/commit/89a4ee2))
	- fixed selection of objects in substates ([69042ab](https://github.com/HaxeFlixel/flixel/commit/69042ab))
	- fixed selections being canceled on interaction with debugger UI ([897f21f](https://github.com/HaxeFlixel/flixel/commit/897f21f))
- `FlxG.html5`: fixed `platform` detecting iPhone and iPod as "Mac" ([#2052](https://github.com/HaxeFlixel/flixel/issues/2052))
- `FlxTilemap`: fixed a missing bounds check in `getTileIndexByCoords()` ([#2024](https://github.com/HaxeFlixel/flixel/issues/2024))
- `FlxAnalog`: fixed mouse input without `FLX_NO_TOUCH` ([#2067](https://github.com/HaxeFlixel/flixel/issues/2067)) 
- `flixel.input`: fixed `Float` being used for tick values ([#2071](https://github.com/HaxeFlixel/flixel/issues/2071))
- `FlxCamera`: fixed object visibility for `zoom < 1` ([#2003](https://github.com/HaxeFlixel/flixel/issues/2003))
- `FlxEmitter`: fixed issues with `lifespan == 0` ([#2074](https://github.com/HaxeFlixel/flixel/issues/2074))

#### Changes and improvements:

- `FlxBitmapText`: allowed negative `lineSpacing` values ([#1984](https://github.com/HaxeFlixel/flixel/issues/1984))
- `FlxStringUtil`: made `getDomain()` more robust ([#1993](https://github.com/HaxeFlixel/flixel/issues/1993), [#1996](https://github.com/HaxeFlixel/flixel/issues/1996))
- `FlxG.signals`: changed `gameResized` to be dispatched after camera resize ([#2012](https://github.com/HaxeFlixel/flixel/issues/2012))
- `FlxAtlasFrames`: allowed passing a parsed `Description` in `fromTexturePackerJson()` ([#2021](https://github.com/HaxeFlixel/flixel/issues/2021))
- `FlxG.watch`: optimized expression watch entries ([#2004](https://github.com/HaxeFlixel/flixel/issues/2004))
- `FlxDebugger` console:
	- allowed `null` objects in `registerObject()` to unregister ([f52c73e](https://github.com/HaxeFlixel/flixel/commit/f52c73e))
	- registered a reference to the current `selection` of the interaction tool ([1bb7b48](https://github.com/HaxeFlixel/flixel/commit/1bb7b48))
	- prevented unpause after manual pausing through UI ([56854fc](https://github.com/HaxeFlixel/flixel/commit/56854fc))
- `FlxBasePreloader`: improved the design of the sitelock failure notice ([#1994](https://github.com/HaxeFlixel/flixel/issues/1994))
- `FlxFlicker`: made `stop()` public ([#2084](https://github.com/HaxeFlixel/flixel/issues/2084))
- `FlxAnalog`: several fixes and improvements ([#2073](https://github.com/HaxeFlixel/flixel/issues/2073))

4.2.1 (March 4, 2017)
------------------------------
- fixed rendering with Haxe 3.4.0 and OpenFL Next

4.2.0 (October 11, 2016)
------------------------------
#### New features:

* `FlxG.html5`: added `platform` and `onMobile` ([#1897](https://github.com/HaxeFlixel/flixel/issues/1897))
* `FlxText`: added support for multi-character markers in `applyMarkup()` ([#1908](https://github.com/HaxeFlixel/flixel/issues/1908))
* `FlxG`: added `onMobile` ([#1904](https://github.com/HaxeFlixel/flixel/issues/1904))
* `FlxPreloader`: added HTML5 support ([#1846](https://github.com/HaxeFlixel/flixel/issues/1846))
* `FlxTweenManager` and `FlxTimerManager`:
	* added `forEach()` ([#1782](https://github.com/HaxeFlixel/flixel/issues/1782))
	* added `completeAll()` ([#1782](https://github.com/HaxeFlixel/flixel/issues/1782), [#1933](https://github.com/HaxeFlixel/flixel/issues/1933))
	* added `manager`, renamed static `manager` to `globalManager` ([#1934](https://github.com/HaxeFlixel/flixel/issues/1934))
* `FlxPath`:
	* added `setProperties()` ([#1875](https://github.com/HaxeFlixel/flixel/issues/1875))
	* added a `this` return to some methods ([#1875](https://github.com/HaxeFlixel/flixel/issues/1875))
* `FlxG.cameras`: added `cameraAdded`, `cameraRemoved` and `cameraResized` signals ([edf93b5](https://github.com/HaxeFlixel/flixel/commit/edf93b5))
* `FlxDebugger`: added a tools panel to interact with objects ([#1862](https://github.com/HaxeFlixel/flixel/issues/1862))
* `ConsoleCommands`: added a `step()` command ([#1910](https://github.com/HaxeFlixel/flixel/issues/1910))
* `FlxG.console`: added `stepAfterCommand` ([#1910](https://github.com/HaxeFlixel/flixel/issues/1910))
* `FlxSound`:
	* added `length` ([#1915](https://github.com/HaxeFlixel/flixel/issues/1915))
	* added `endTime` ([#1943](https://github.com/HaxeFlixel/flixel/issues/1943))
	* added an `EndTime` argument to `play()` ([#1943](https://github.com/HaxeFlixel/flixel/issues/1943))
* `FlxMouse`: added `registerSimpleNativeCursorData()` ([73b0ff2](https://github.com/HaxeFlixel/flixel/commit/73b0ff2))
* `FlxRandom`: added `shuffle()` ([#1947](https://github.com/HaxeFlixel/flixel/issues/1947))
* `WatchEntry`:
	* added support for cycling through `true` / `false` with up / down ([39f7dca](https://github.com/HaxeFlixel/flixel/commit/39f7dca))
	* added support for cycling through enum values with up / down ([5702c92](https://github.com/HaxeFlixel/flixel/commit/5702c92))
* `FlxAnimation`: added support for changing `frames` ([#1967](https://github.com/HaxeFlixel/flixel/issues/1967))
* `FlxObject`: added `debugBoundingBoxColorSolid`, -`NotSolid` and -`Partial` ([#1847](https://github.com/HaxeFlixel/flixel/issues/1847))
* `FlxTilemap`:
	* `drawDebug` now colors partially collidable tiles differently ([#1847](https://github.com/HaxeFlixel/flixel/issues/1847))
	* non-colliding tiles are now transparent by default in `drawDebug` ([#1847](https://github.com/HaxeFlixel/flixel/issues/1847))
* Added an HTML5 template to center games horizontally ([#1918](https://github.com/HaxeFlixel/flixel/issues/1918))
* Added support for `haxelib run flixel` as an alias for `haxelib run flixel-tools` ([#1950](https://github.com/HaxeFlixel/flixel/issues/1950))

#### Bugfixes:

* `FlxBitmapText`: fixed `alpha` not working ([#1877](https://github.com/HaxeFlixel/flixel/issues/1877))
* `FlxEmitter`: fixed properties not being ignored if their `.active` is set to `false` ([#1903](https://github.com/HaxeFlixel/flixel/issues/1903))
* `FlxCamera`:
	* fixed scroll bounds not taking `zoom` into account ([#1889](https://github.com/HaxeFlixel/flixel/issues/1889))
	* fixed rendering issues with `bgColor == 0x0` on Next ([#1793](https://github.com/HaxeFlixel/flixel/issues/1793))
* `FlxTilemap`: fixed buffers not being resized on camera changes ([#1801](https://github.com/HaxeFlixel/flixel/issues/1801))
* `FlxSpriteGroup`:
	* fixed `drawDebug()` not being called ([#1905](https://github.com/HaxeFlixel/flixel/issues/1905))
	* fixed `revive()` not setting children's `alive` ([#1891](https://github.com/HaxeFlixel/flixel/issues/1891))
* `flixel.input.gamepad.mappings`: fixed some mappings for digitized stick movements ([c04ce96](https://github.com/HaxeFlixel/flixel/commit/c04ce96))
* `FlxAtlasFrames`: fixed offset parsing for whitespace-stripped atlases in `fromLibGdx` ([#1923](https://github.com/HaxeFlixel/flixel/issues/1923))
* `FlxKeyboard`: fixed some `FlxG.debugger.toggleKeys` and `FlxG.vcr.cancelKeys` not working on native ([470c8e8](https://github.com/HaxeFlixel/flixel/commit/470c8e8))
* `FlxMouse`: fixed `FlxButton` presses during VCR playback ([#1729](https://github.com/HaxeFlixel/flixel/issues/1729))
* `FlxSprite`:
	* fixed a position discrepancy between simple and complex render ([#1939](https://github.com/HaxeFlixel/flixel/issues/1939))
	* fixed default graphic not showing on HTML5 ([2da3523](https://github.com/HaxeFlixel/flixel/commit/2da3523))
* `FlxCollision`: fixed an animation-related crash with `FlxG.renderBlit` ([#1928](https://github.com/HaxeFlixel/flixel/issues/1928))
* `FlxTimerManager`: fixed issues related to adding / removing timers in `onComplete` ([#1954](https://github.com/HaxeFlixel/flixel/issues/1954))
* `WatchEntry`: fixed variables being turned into `String` on Neko ([#1911](https://github.com/HaxeFlixel/flixel/issues/1911))
* `FlxVector`: fixed `normalize()` returning `(1,0)` for `(0,0)` ([#1959](https://github.com/HaxeFlixel/flixel/issues/1959))
* `FlxFrame`: fixed inconsistent sorting across platforms ([#1926](https://github.com/HaxeFlixel/flixel/issues/1926))
* `FlxSubState`: fixed `close()` if same instance is used in two different states ([#1971](https://github.com/HaxeFlixel/flixel/issues/1971))
* `CompletionHandler`: fixed completion mid-text ([#1798](https://github.com/HaxeFlixel/flixel/issues/1798))

#### Changes and improvements:

* `flixel.util.helpers`: changed the default value of `active` to `true` ([d863892](https://github.com/HaxeFlixel/flixel/commit/d863892))
* `FlxGitSHA`: optimized for compiler completion ([f5dca1d](https://github.com/HaxeFlixel/flixel/commit/f5dca1d))
* `FlxRect`: added an optional `result` argument to `intersection()` ([c52b534](https://github.com/HaxeFlixel/flixel/commit/c52b534))
* `FlxG.debugger`: added `F2` to `toggleKeys` ([f3f029c](https://github.com/HaxeFlixel/flixel/commit/f3f029c))
* `FlxRandom`: deprecated `shuffleArray()` in favor of `shuffle()` ([#1947](https://github.com/HaxeFlixel/flixel/issues/1947))
* `FlxEmitter`: `emitParticle()` now returns the particle ([#1957](https://github.com/HaxeFlixel/flixel/issues/1957))
* `FlxG.bitmap`:
	* optimized `getUniqueKey()` ([#1965](https://github.com/HaxeFlixel/flixel/issues/1965))
	* clearing the cache now only affects unused graphics ([#1968](https://github.com/HaxeFlixel/flixel/issues/1968))
* `FlxFramesCollection`: frame sizes are now checked and trimmed ([#1966](https://github.com/HaxeFlixel/flixel/issues/1966))

4.1.1 (August 5, 2016)
------------------------------
* fixed the check for Lime <= 2.9.1

4.1.0 (July 10, 2016)
------------------------------

#### New features:

* `FlxG.vcr`: added an `OpenSaveDialog` argument to `stopRecording()` ([#1726](https://github.com/HaxeFlixel/flixel/issues/1726))
* `FlxSound`:
	* added `loopTime` ([#1736](https://github.com/HaxeFlixel/flixel/issues/1736))
	* added a `StartTime` argument to `play()` ([#1736](https://github.com/HaxeFlixel/flixel/issues/1736))
	* added `fadeTween` ([#1834](https://github.com/HaxeFlixel/flixel/issues/1834))
	* added a setter for `time` ([#1792](https://github.com/HaxeFlixel/flixel/issues/1792))
* `FlxMouse:` added `enabled`
* `FlxGamepadInputID`: added IDs for analog stick directions ([#1746](https://github.com/HaxeFlixel/flixel/issues/1746))
* `FlxG.watch`: added `addExpression()` and `removeExpression()` ([#1790](https://github.com/HaxeFlixel/flixel/issues/1790))
* `Console`:
	* added `watch` and `watchExpression` commands ([#1790](https://github.com/HaxeFlixel/flixel/issues/1790))
	* added `Reflect`, `Std`, `StringTools`, `Sys`, `Type` and `FlxTween` to default classes
* `CompletionHandler`: added locals declared with `var` to completion
* `WatchEntry`:
	* added a remove button
	* added `Float` rounding (to `FlxG.debugger.precision` decimals)
	* added support for in- / decrement of numeric values via up / down keys
	* added support for moving selection to start / end via up / down keys (non-numeric values)
* `FlxStringUtil`: added `isNullOrEmpty()`
* `FlxDefines`: added inverted versions of all `FLX_NO`-defines (e.g. `FLX_DEBUG` for `FLX_NO_DEBUG`)
* `FlxTileFrames`: added `spacing` and `border` arguments to `combineTileSets()` and `combineTileFrames()` ([#1807](https://github.com/HaxeFlixel/flixel/issues/1807))
* `FlxBitmapDataUtil`: added `copyBorderPixels()`
* `FlxGame`: `GameWidth` and `GameHeight` in `new()` now use the window size if set to 0 ([#1811](https://github.com/HaxeFlixel/flixel/issues/1811))
* `FlxPoint`: added `scale()` ([#1811](https://github.com/HaxeFlixel/flixel/issues/1811))
* `FlxBar`: added `numDivisions`
* `FlxBaseTilemap`: added `loadMapFromGraphic()` ([#1525](https://github.com/HaxeFlixel/flixel/issues/1525))
* `FlxAnimation`: added the ability to set `paused` directly ([#1538](https://github.com/HaxeFlixel/flixel/issues/1538))
* `FlxTilemap`: added `antialiasing` ([#1850](https://github.com/HaxeFlixel/flixel/issues/1850))
* Added GLSL `shader` support for `FlxSprite`, `FlxTilemap`, `FlxBar` and `FlxBitmapText` ([#1848](https://github.com/HaxeFlixel/flixel/issues/1848))
* `FlxGraphic`: added an optional `Cache` argument to `fromFrame()`
* `FlxG.debugger`: added `visibilityChanged` ([#1865](https://github.com/HaxeFlixel/flixel/issues/1865))

#### Bugfixes:

* `FlxText`: [Flash] fixed blurry lines on multiline texts with `FlxTextAlign.CENTER` ([#1728](https://github.com/HaxeFlixel/flixel/issues/1728))
* `FlxSound`: fixed `fadeOut()` and `fadeIn()` not canceling the previous tween ([#1834](https://github.com/HaxeFlixel/flixel/issues/1834))
* `FlxGamepad:` [Flash] fixed potential range errors when checking axis values
* `CompletionListEntry`: fixed text width exceeding list width
* `FlxGame`: [HTML5] fixed `ticks` holding the current date's timestamp instead of ms since game start
* `FlxCamera`: fixed background scaling for `zoom < 1` on native targets ([#1588](https://github.com/HaxeFlixel/flixel/issues/1588))
* `FlxBaseTilemap`: [Neko,HTML5] fixed invalid array access in `overlapsPoint()` ([#1835](https://github.com/HaxeFlixel/flixel/issues/1835))
* `FlxObject`: fixed `overlapsPoint()` at x / y = 0 ([#1818](https://github.com/HaxeFlixel/flixel/issues/1818))
* `FlxReplay`: fixed simultaneous recording of key and mouse input ([#1739](https://github.com/HaxeFlixel/flixel/issues/1739))
* `FlxVelocity`: fixed `accelerateFromAngle()` setting `maxVelocity` to negative values ([#1833](https://github.com/HaxeFlixel/flixel/issues/1833))
* Fixed compilation with `hscriptPos` defined ([#1840](https://github.com/HaxeFlixel/flixel/issues/1840))
* `FlxDrawTilesItem`: fixed `numTiles` value with color offsets
* `FlxBitmapFont`: fixed a crash related to incorrect UTF-8 handling ([#1857](https://github.com/HaxeFlixel/flixel/issues/1857))
* `FlxAtlas`: fixed a crash when the constructor is called with `powerOfTwo == true` ([#1858](https://github.com/HaxeFlixel/flixel/issues/1858))
* `FlxTween`: fixed nested tween chains ([#1871](https://github.com/HaxeFlixel/flixel/issues/1871))
* `FlxTypedGroup`: fixed recursion in `forEachOfType()` ([#1876](https://github.com/HaxeFlixel/flixel/issues/1876))
* `Tracker`: [Neko] fixed a crash in `setVisible()` ([#1879](https://github.com/HaxeFlixel/flixel/issues/1879))
* Fixed some flixel-internal fields being accessible when they shouldn't be ([#1849](https://github.com/HaxeFlixel/flixel/issues/1849)) 

#### Changes and improvements:

* `Console`: removed `resetState`, `switchState` and `resetGame` commands
* `FlxArrayUtil`: optimized `flatten2DArray()`
* `FlxSpriteUtil`: changed `alphaMask()` arguments from `Dynamic` to `FlxGraphicAsset` ([#1806](https://github.com/HaxeFlixel/flixel/issues/1806))
* `FlxG.signals`: changed `preUpdate` to be dispatched _after_ `FlxG.elapsed` is updated ([#1836](https://github.com/HaxeFlixel/flixel/issues/1836))
* `FlxG.debugger`: changed `drawDebugChanged` to be dispatched _after_ `drawDebug` is updated
* `FlxDefines`: added a check for incompatible OpenFL / Lime versions (should be < 4.0.0 / < 3.0.0 respectively) 

4.0.1 (March 19, 2016)
------------------------------

* `FlxDebugger`: [HTML5] fixed version text color ([#1727](https://github.com/HaxeFlixel/flixel/issues/1727))
* `FlxFlicker` / `LabelValuePair`: fixed DCE issues ([#1757](https://github.com/HaxeFlixel/flixel/issues/1757))
* `FlxMouse`: fixed `useSystemCursor = true` not always working with native cursor API
* `FlxDebugger` mouse handling fixes ([#1775](https://github.com/HaxeFlixel/flixel/issues/1775)):
	* fixed `FlxMouse`'s `visible` and `useSystemCursor` not being restored properly
	* fixed cursor disappearing after losing Console focus with native cursor API
	* fixed mouse focus area of windows being too big
* `FlxAnimationController`: fixed `finishCallback` firing multiple times in one frame ([#1781](https://github.com/HaxeFlixel/flixel/issues/1781))
* `FlxPreloader`: [HTML5] fixed preloader not showing up ([#1750](https://github.com/HaxeFlixel/flixel/issues/1750))
* `FlxStringUtil.formatMoney()`:
	* fixed formatting for `Amount < 0` ([#1754](https://github.com/HaxeFlixel/flixel/issues/1754))
	* fixed formatting for negative amounts
	* [HTML5] fixed formatting for amounts > Int32 
* Debugger Stats window: fixed paused time being taken into account for average FPS

4.0.0 (February 16, 2016)
------------------------------

### Restructures:

* Changed `static inline` vars to enums: ([#998](https://github.com/HaxeFlixel/flixel/issues/998))
	* `FlxCamera` follow styles
	* `FlxCamera` shake modes
	* `FlxText` border styles
	* `FlxTilemap` auto-tiling options
	* `FlxBar` fill directions
	* `FlxG.html5` browser types
* Moved `FlxMath`, `FlxPoint`, `FlxVector`, `FlxRect`, `FlxAngle`, `FlxVelocity` and `FlxRandom` to `flixel.math`
* Moved "typed" classes: ([#1100](https://github.com/HaxeFlixel/flixel/issues/1100))
	* `FlxTypedGroup` into `FlxGroup.hx`
	* `FlxTypedSpriteGroup` into `FlxSpriteGroup.hx`
	* `FlxTypedEmitter` into `FlxEmitter.hx`
	* `FlxTypedButton` into `FlxButton.hx`
* The signature of `update()` functions was changed to `update(elapsed:Float)`. The `elapsed` argument should be used instead of `FlxG.elapsed`. ([#1188](https://github.com/HaxeFlixel/flixel/issues/1188))

### Rendering:

* Added `flixel.FlxStrip` which supports rendering via `drawTriangles()`
* Added an experimental rendering method using `drawTriangles()` (enabled by defining `FLX_RENDER_TRIANGLE`, requires `FlxG.renderTile` to be true).
* The tile renderer now uses `Tilesheet.TILE_RECT` instead of `addTileRect()`
* Renderers are now distinguished by `FlxG.renderMethod` (`FlxG.renderBlit` / `FlxG.renderTile` for easy access) instead of defines (`FLX_RENDER_BLIT` / `FLX_RENDER_TILE`). This allows for a fallback to software rendering on certain targets if hardware rendering is not available. ([#1668](https://github.com/HaxeFlixel/flixel/issues/1668))

### flixel.FlxCamera:

* added `pixelPerfectRender` as a global setting for sprites and tilemaps ([#1060](https://github.com/HaxeFlixel/flixel/issues/1060))
* `pixelPerfectRender` now defaults to `false` with `FlxG.renderTile` ([#1065](https://github.com/HaxeFlixel/flixel/issues/1065))
* `bounds` -> `minScrollX`, `maxScrollX`, `minScrollY` and `maxScrollY` (`null` means unbounded) ([#1070](https://github.com/HaxeFlixel/flixel/issues/1070))
* `setBounds()` -> `setScrollBoundsRect()` ([#1070](https://github.com/HaxeFlixel/flixel/issues/1070))
* added `setScrollBounds()`
* added `targetOffset` ([#1056](https://github.com/HaxeFlixel/flixel/issues/1056))
* added `scrollRect` sprite which crops the camera's view when the camera is scaled
* camera now scales from its center, not its top left corner
* `followLerp` is now a range taking values from 0 to (`60 / FlxG.updateFramerate`) - the closer to zero the more lerp! ([#1220](https://github.com/HaxeFlixel/flixel/issues/1220))
* added `snapToTarget()` ([#1477](https://github.com/HaxeFlixel/flixel/issues/1477))
* `fade()`: fixed `FadeIn == true` not working in a fade out callback ([#1666](https://github.com/HaxeFlixel/flixel/issues/1666))
* `follow()`: removed the `Offset` argument ([#1056](https://github.com/HaxeFlixel/flixel/issues/1056))

### flixel.FlxG:

* `debugger`: fixed a crash when calling `addTrackerProfile()` before `track()`
* `signals`:
	* split `gameReset` into pre/post signals
	* added `preStateCreate` ([#1557](https://github.com/HaxeFlixel/flixel/issues/1557))
* `android`: `preventDefaultBackAction` has been replaced by `preventDefaultKeys`
* `inputs`: added `resetOnStateSwitch`
* added `FlxG.addPostProcess()` / `removePostProcess()`
* added `resizeWindow()`
* Added `filtersEnabled` and `setFilters()` to `FlxCamera` and `FlxGame` ([#1635](https://github.com/HaxeFlixel/flixel/issues/1635))
* `version` now includes the commit SHA via a build macro

### flixel.FlxObject:

* added `getPosition()` and `getHitbox()`
* split some of `separate()`'s functionality into `updateTouchingFlags()`, allowing `touching` to be used without any separate calls ([#1555](https://github.com/HaxeFlixel/flixel/issues/1555))
* added `path` ([#1712](https://github.com/HaxeFlixel/flixel/issues/1712))

### flixel.FlxSprite:

* added `graphicLoaded()`
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
* `setColorTransform()`'s offset arguments now work with drawTiles rendering on OpenFL 3.6.0+ ([#1705](https://github.com/HaxeFlixel/flixel/issues/1705))
* `getFlxFrameBitmapData()` -> `updateFramePixels()` ([#1710](https://github.com/HaxeFlixel/flixel/issues/1710))

### flixel.FlxState:

* `onFocus()` and `onFocusLost()` no longer require `FlxG.autoPause` to be false
* added `switchTo()` ([#1676](https://github.com/HaxeFlixel/flixel/issues/1676))

### flixel.animation:

* `FlxAnimation`:
	* added `reversed` var which allows you to play animation backwards
	* second argument of `play()` method is `Reversed` now
	* added `flipX` and `flipY` ([#1670](https://github.com/HaxeFlixel/flixel/issues/1670))
* `FlxAnimationController`:
	* `curAnim` does also return animations that have finished now
	* removed `get()`
	* `callback`: fixed old `frameIndex` value being passed instead of the current one
	* `add()` now makes a copy of the `Frames` array before calling `splice()` on it
	* fixed `finished` not being true during the last animation frame in the `callback`
	* added `Reversed` argument in `play()` method, which allows you to set animation's playback direction

### flixel.effects:

* `FlxEmitter`:
	* `at()` -> `focusOn()`
	* `on` -> `emitting`
	* emitters and particles now use `FlxColor` instead of separate red, green, and blue values
	* removed `FlxEmitterExt`, `FlxEmitter` now has two launch modes: `CIRCLE` (the new default) and `SQUARE` ([#1174](https://github.com/HaxeFlixel/flixel/issues/1174))
	* removed `xPosition`, `yPosition`, `life`, `bounce`, and various other properties, and property setting convenience functions (see below) ([#1174](https://github.com/HaxeFlixel/flixel/issues/1174))
	* a variety of values can now be set with much greater control, via `lifespan.set()`, `scale.set()`, `velocity.set()` and so on ([#1174](https://github.com/HaxeFlixel/flixel/issues/1174))
	* simplified `start()` parameters ([#1174](https://github.com/HaxeFlixel/flixel/issues/1174))
	* added `angularDrag` and `angularAcceleration` ([#1246](https://github.com/HaxeFlixel/flixel/issues/1246))
* `FlxParticle`: ([#1174](https://github.com/HaxeFlixel/flixel/issues/1174))
	* `maxLifespan` -> `lifespan`, `lifespan` -> `age`, percent indicates `(age / lifespan)`
	* `age` counts up (as opposed to `lifespan`, which counted down)
	* range properties (`velocityRange`, `alphaRange`) which determine particle behavior after launch
	* "active" flags (`alphaRange.active`, `velocityRange.active`, etc) which `FlxEmitter` uses to control particle behavior

### flixel.graphics:

* `FlxGraphic`:
	* renamed from `CachedGraphics` and moved to `flixel.graphics`
	* added `defaultPersist` ([#1241](https://github.com/HaxeFlixel/flixel/issues/1241))
	* added `fromAssetKey()`, `fromClass()` and `fromBitmapData()`
	* `bitmap` is now settable
* `FlxAtlas`:
	* moved to `flixel.graphics.atlas`
	* added `addNodeWithSpacings()`
	* added `minWidth`, `maxWidth`, `minHeight` and `maxHeight` (the size starts at `min` and grows up until `max` as images are added)
	* added `powerOfTwo` (forces atlas size to a power of two)
	* added `allowRotation` (indicates whether added images may be rotated to save space)
* `FlxNode`:
	* moved to `flixel.graphics.atlas`
	* added `getTileFrames()` and `getImageFrame()`
* Introduced a new frames collections concept replacing regions:
	* added `FlxImageFrame` frames collection which contains single frame
	* added `FlxTileFrames` frames collection which contains frames for spritesheet, which can be generated from image region or frame (including rotated and trimmed frames)
	* added `FlxAtlasFrames` frames collection instead of various texture atlas loaders (like `SparrowData` and `TexturePackerData`). It contains various static methods for parsing atlas files
	* added `FlxFilterFrames` frames collection instead of `FlxSpriteFilter` (see filters demo)
* Rewrote `PxBitmapFont` and renamed it to `FlxBitmapFont`. It supports AngelCode, XNA and Monospace bitmap fonts now.
* `FlxFrame`:
	* doesn't store the frame's bitmapatas anymore, so `getBitmap()` and other bitmap methods have been removed
	* added `paint()` and `paintFlipped()` methods instead. This solution requires much less memory, but will be a bit slower.
	* added `flipX` and `flipY` ([#1591](https://github.com/HaxeFlixel/flixel/issues/1591))

### flixel.group:

* `FlxTypedGroup`:
	* added a `recurse` argument to the `forEach()` functions
	* removed `callAll()` and `setAll()` - use `forEach()` instead ([#1086](https://github.com/HaxeFlixel/flixel/issues/1086))
	* replaced the parameter array in `recycle()` with an optional factory method ([#1191](https://github.com/HaxeFlixel/flixel/issues/1191))
	* `revive()` now calls `revive()` on all `members` of a group as well ([#1243](https://github.com/HaxeFlixel/flixel/issues/1243))
	* added `insert()` ([#1671](https://github.com/HaxeFlixel/flixel/issues/1671))
* `FlxTypedSpriteGroup`: added `iterator()`

### flixel.input:

* `FlxSwipe`: `duration` now uses seconds instead of milliseconds ([#1272](https://github.com/HaxeFlixel/flixel/issues/1272))
* `FlxMouse` and `FlxTouch` now extend a new common base class `FlxPointer` instead of `FlxPoint` ([#1099](https://github.com/HaxeFlixel/flixel/issues/1099))
	* adds `overlaps()` to `FlxMouse`

### flixel.input.gamepad:

* `FlxGamepadManager`:
	* better handling of disconnecting and reconnecting gamepads. `getByID()` can now return `null`.
	* `anyButton()` now has a `state` argument
	* `globalDeadZone` can now be 0
	* `globalDeadZone` now overshadows instead of overriding the gamepad's deadzone values
* `FlxGamepad`:
	* refactored gamepads to include mappings, removing the need to write separate logic for each gamepad type ([#1502](https://github.com/HaxeFlixel/flixel/issues/1502)):
 	* each gamepad now has a `model`, `mapping` and `name`
 	* moved the ID classes to `flixel.input.gamepad.id`
 	* all IDs are now mapped to a value in `FlxGamepadInputID`
 	* the previous "raw" gamepad IDs are now available via separate functions
 	* added `pressed`, `justPressed`, `justReleased` and `analog`
 	* removed the dpad properties, they are now mapped to buttons
	* added a `connected` flag
	* added `deadZoneMode`, circular deadzones are now supported ([#1177](https://github.com/HaxeFlixel/flixel/issues/1177))
	* `anyButton()` now has a `state` argument
	* added support for WiiMote ([#1563](https://github.com/HaxeFlixel/flixel/issues/1563)) and PS Vita ([#1714](https://github.com/HaxeFlixel/flixel/issues/1714)) controllers

### flixel.input.keyboard:

* `FlxKeyboard`:
	* added `preventDefaultKeys` for HTML5
	* added an `abstract` enum for key names (`FlxG.keys.anyPressed([A, LEFT])` is now possible)
	* the any-functions now take an Array of `FlxKey`s instead of Array of Strings (string names are still supported)
	* removed `FlxKey.NUMPADSLASH` (`SLASH` has the same keycode)

### flixel.input.mouse:

* `FlxMouseEventManager`:
	* moved from `flixel.plugin.MouseEventManager` to `flixel.input.mouse.FlxMouseEventManager`
	* added `removeAll()` ([#1141](https://github.com/HaxeFlixel/flixel/issues/1141))
	* fixed inaccurate pixel-perfect sprite overlap checks ([#1075](https://github.com/HaxeFlixel/flixel/issues/1075))
	* now supports all mouse buttons (`mouseButtons` argument in `add()` / `setObjectMouseButtons()`)

### flixel.math:

* `FlxAngle`:
	* changed `rotatePoint()` to not invert the y-axis anymore and rotate clockwise (consistent with `FlxSprite#angle`)
	* `rotatePoint()` -> `FlxPoint#rotate()` ([#1143](https://github.com/HaxeFlixel/flixel/issues/1143))
	* `getAngle()` -> `FlxPoint#angleBetween()` ([#1143](https://github.com/HaxeFlixel/flixel/issues/1143))
	* added `angleFromFacing()` ([#1193](https://github.com/HaxeFlixel/flixel/issues/1193))
	* fixed `wrapAngle()` ([#1610](https://github.com/HaxeFlixel/flixel/issues/1610))
	* removed `angleLimit()` ([#1618](https://github.com/HaxeFlixel/flixel/issues/1618))
* `FlxMath`:
	* `bound()` and `inBounds()` now accept `null` as values, meaning "unbounded in that direction" ([#1070](https://github.com/HaxeFlixel/flixel/issues/1070))
	* `wrapValue()` -> `wrap()`, replaced the `amount` argument with a lower bound
	* changed `MIN_VALUE` and `MAX_VALUE` to `MIN_VALUE_FLOAT` and `MAX_VALUE_FLOAT`, added `MAX_VALUE_INT` ([#1148](https://github.com/HaxeFlixel/flixel/issues/1148))
	* added `sinh()` ([#1309](https://github.com/HaxeFlixel/flixel/issues/1309))
	* added `fastSin()` and `fastCos()` ([#1534](https://github.com/HaxeFlixel/flixel/issues/1534))
	* optimized `isEven()` and `isOdd()`
	* added `remapToRange()` ([#1633](https://github.com/HaxeFlixel/flixel/issues/1633))
	* `getDistance()` -> `FlxPoint#distanceTo()` ([#1716](https://github.com/HaxeFlixel/flixel/issues/1716))
* `FlxPoint`:
	* `inFlxRect()` -> `inRect`
* `FlxRandom`:
	* `FlxRandom` functions are now member functions, call `FlxG.random` instead of `FlxRandom` ([#1201](https://github.com/HaxeFlixel/flixel/issues/1201))
	* exposed `currentSeed` as an external representation of `internalSeed` ([#1138](https://github.com/HaxeFlixel/flixel/issues/1138))
	* removed `intRanged()` and `floatRanged()`, `int()` and `float()` now provide optional ranges ([#1138](https://github.com/HaxeFlixel/flixel/issues/1138))
	* removed `weightedGetObject()`, `getObject()` now has an optional `weights` parameter ([#1148](https://github.com/HaxeFlixel/flixel/issues/1148))
	* removed `colorExt()`, try using `FlxColor` to get finer control over randomly-generated colors ([#1158](https://github.com/HaxeFlixel/flixel/issues/1158))
	* updated random number generation equation to avoid inconsistent results across platforms; may break recordings made in 3.x! ([#1148](https://github.com/HaxeFlixel/flixel/issues/1148))
	* can now create an instance of `FlxRandom` to create deterministic pseudorandom numbers independently of HaxeFlixel core functions (e.g. particle emitters)
	* `chanceRoll()` -> `bool()`
	* added `floatNormal()` ([#1251](https://github.com/HaxeFlixel/flixel/issues/1251))
* `FlxRect`:
	* added `weak()`, `putWeak()`, `ceil()` and `floor()`
	* `containsFlxPoint()` -> `containsPoint()`
* `FlxVelocity`:
	* `accelerateTowards*()`-functions now only take a single `maxSpeed` argument (instead of `x` and `y`)

### flixel.system:

* `FlxAssets`:
	* `cacheSounds()` -> `FlxG.sound.cacheAll()` ([#1097](https://github.com/HaxeFlixel/flixel/issues/1097))
	* OpenFL live asset reloading is now supported (native targets) 
* `FlxSound`
	* can now be used even if `FLX_NO_SOUND_SYSTEM` is enabled ([#1199](https://github.com/HaxeFlixel/flixel/issues/1199))
	* `looped` is now `public`
	* added `pitch` ([#1465](https://github.com/HaxeFlixel/flixel/issues/1465))
	* added `FlxSoundGroup` ([#1316](https://github.com/HaxeFlixel/flixel/issues/1316))

### flixel.system.debug:

* `Console`:
	* refactored the console to be powered by hscript ([#1637](https://github.com/HaxeFlixel/flixel/issues/1637))
	* added auto-completion
	* fixed focus on native targets

### flixel.system.scaleModes:

* `BaseScaleMode`: added `horizontalAlign` and `verticalAlign`
* `RatioScaleMode#new()`: added a `fillScreen` option
* The `FlxCamera` sprite is now scaled (instead of `FlxGame`)

### flixel.text:

* Rewrote `FlxBitmapTextField` and renamed it to `FlxBitmapText`
* `FlxText`:
	* added an `abstract` enum for alignment (`text.alignment = CENTER;` is now possible)
	* `font` now supports font assets not embedded via `openfl.Assets` (i.e. `@:font`)
	* `font = null;` now resets it to the default font
	* fixed an issue where the value returned by `get_font()` wouldn't be the same as the one passed into `set_font()`
	* added `applyMarkup()` ([#1229](https://github.com/HaxeFlixel/flixel/issues/1229))
	* fixed issues with `borderStyle` and `FlxTextFormat` on native
	* added `stampOnAtlas()` method, which stamps text graphic on provided atlas and loads result node's graphic into this text object
	* retrieving text dimensions (`width` and `height`) can now trigger text graphic regeneration (if any changes led to a dimensions change) to report the correct values
	* `borderColor` now supports alpha values / ARBG colors
	* fixed `setFormat()` resetting `alignment` ([#1629](https://github.com/HaxeFlixel/flixel/issues/1629))
* Moved `FlxTextField` to flixel-addons

### flixel.tile:

* `FlxBaseTilemap`:
 added `setRect()` method which allows you to set a rectangular region of tiles to the provided index
* `FlxTile`:
 added `frame` variable which holds tile's "graphic"
* `FlxTileblock`: 
	* added `setTile()` and `tileSprite` ([#1300](https://github.com/HaxeFlixel/flixel/issues/1300))
	* added `loadFrames()` method which allows you to use frames collection as a source of graphic
* `FlxTilemap`:
	* separated rendering and logic, adding `FlxBaseTilemap` ([#1101](https://github.com/HaxeFlixel/flixel/issues/1101))
	* added `getTileIndexByCoords()` and `getTileCoordsByIndex()`
	* fixed a bug in `overlapsAt()`
	* `loadMap()` now treats tile indices with negative values in the map data as 0 ([#1166](https://github.com/HaxeFlixel/flixel/issues/1166))
	* added `blend`, `alpha` and `color`
	* added `frames` property, so you can change tilemap's graphic without reloading map
	* `loadMap()` accepts `FlxGraphic`, `String`, `FlxTileFrames` or `BitmapData` as `TileGraphic` now
	* `loadMap()` has been split into `loadMapFromCSV()` and `loadMapFromArray()` ([#1292](https://github.com/HaxeFlixel/flixel/issues/1292))
	* added `loadMapFrom2DArray()` ([#1292](https://github.com/HaxeFlixel/flixel/issues/1292))
	* added `offset` property ([#1444](https://github.com/HaxeFlixel/flixel/issues/1444))
	* `allowCollisions` now sets the `allowCollisions` property of each tile
	* fixed `ray()` not detecting a collision with perfectly diagonal start and end points ([#1617](https://github.com/HaxeFlixel/flixel/issues/1617))
	* `findPath()`: replaced `WideDiagonal` argument with `DiagonalPolicy` ([#1659](https://github.com/HaxeFlixel/flixel/issues/1659))

### flixel.tweens:

* `FlxTween`
	* `complete` callback parameter in options is now called `onComplete`. Its type, `CompleteCallback`, is now called `TweenCallback`. ([#1273](https://github.com/HaxeFlixel/flixel/issues/1273))
	* added `onStart` and `onUpdate` callback parameters in options ([#1273](https://github.com/HaxeFlixel/flixel/issues/1273))
	* fixed `active = false;` not doing anything during `onComplete()` of `LOOPING` or `PINGPONG` tweens
	* angle tween sets sprite's angle on start now
	* added `then()` and `wait()` for chaining ([#1614](https://github.com/HaxeFlixel/flixel/issues/1614))
	* made `start()` public ([#1692](https://github.com/HaxeFlixel/flixel/issues/1692))
	* `active` is now only true when in progress
* Motion tweens:
	* the original `FlxObject#immovable` value is now restored after completion

### flixel.ui:

* `FlxAnalog` and `FlxVirtualPad` now have their own atlas to reduce draw calls
* `FlxTypedButton`:
	* now implements `IFlxInput`, adding `pressed`, `justPressed`, `released` and `justReleased`
	* now uses animations for statuses instead of setting `frameIndex` directly for more flexibility (removes `allowHighlightOnMobile`, adds `statusAnimations`)
	* disabling the highlight frame is now tied to `#if FLX_NO_MOUSE` instead of `#if mobile`
	* `labelAlphas[FlxButton.HIGHLIGHT]` is now 1 for `FLX_NO_MOUSE`
	* `set_label()` now updates the label position
	* added `maxInputMovement`
	* added `mouseButtons` to control which mouse buttons can trigger the button
	* `label` is no longer initialized if the text passed to `new()` is `null`
	* added `stampOnAtlas()` for draw call optimization
* Added `FlxSpriteButton`

### flixel.util:

* `FlxArrayUtil`:
	* removed `indexOf()`
	* moved randomness-related to `FlxRandom` ([#1138](https://github.com/HaxeFlixel/flixel/issues/1138))
* `FlxBitmapDataUtil`:
	* renamed from `FlxBitmapUtil` ([#1118](https://github.com/HaxeFlixel/flixel/issues/1118))
	* added `replaceColor()` (used by `FlxSprite#replaceColor()`)
	* added `addSpacing()`
	* added `generateRotations()`
* `FlxColor`:
	* `FlxColor` is now an `abstract`, interchangeable with `Int` - the `FlxColorUtil` functions have been merged into it ([#1027](https://github.com/HaxeFlixel/flixel/issues/1027))
	* the color presets have been reduced to a smaller, more useful selection ([#1117](https://github.com/HaxeFlixel/flixel/issues/1117))
* `FlxPath`: 
	* the original `FlxObject#immovable` value is now restored after completion
	* `active` is now only true when in progress
	* fixed velocity being set even if the object position matches the current node
	* exposed `nodeIndex` as a read-only property
	* removed the `Object` argument from `start()`, now the path has to be assigned to `FlxObject#path` ([#1712](https://github.com/HaxeFlixel/flixel/issues/1712))
* `FlxPool`:
	* improved pooling performance ([#1189](https://github.com/HaxeFlixel/flixel/issues/1189))
* `FlxSignal`:
	* fixed a bug that occurred when calling `remove()` during a dispatch ([#1420](https://github.com/HaxeFlixel/flixel/issues/1420))
* `FlxSpriteUtil`:
	* `drawLine()`: default settings for `lineStyle` are now thickness 1 and color white
	* `fadeIn()` and `fadeOut()` now tween `alpha` instead of `color`
	* added `drawCurve()` ([#1263](https://github.com/HaxeFlixel/flixel/issues/1263))
	* removed `FillStyle`, the same functionality is now covered by `FillColor`
	* moved `screenCenter()` to `FlxObject` and changed the the arguments from two booleans to the `FlxAxes` enum ([#1541](https://github.com/HaxeFlixel/flixel/issues/1541))
* `FlxTimer`:
	* `complete` -> `onComplete` ([#1275](https://github.com/HaxeFlixel/flixel/issues/1275))
	* `active` is now only true when in progress

### Other:

* Added an initialization macro that aborts compilation with helpful errors when:
	* targeting older SWF versions with invalid defines
	* using an unsupported Haxe version 
* Flixel sound assets are now being embedded via `embed="true"`
