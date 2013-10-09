﻿![](http://www.haxeflixel.com/sites/all/themes/haxeflixel_bootstrap/assets/images/haxeflixel-logo.png)
=
###Related:    [flixel-addons](https://github.com/HaxeFlixel/flixel-addons) | [flixel-demos](https://github.com/HaxeFlixel/flixel-demos) | [flixel-tools](https://github.com/HaxeFlixel/flixel-tools) | [flixel-ui](https://github.com/HaxeFlixel/flixel-ui)
______________________________________________________

###Getting Started

You can read our getting started docs [here](http://haxeflixel.com/wiki/getting-started).

It is recomended to use Haxeflixel via [Haxelib](http://lib.haxe.org/p/flixel). Just run `haxelib install flixel` once you have it installed.

###Changes for HaxeFlixel 3.0

This is the third big update to HaxeFlixel. Here are the biggest changes:
- New [Front End](https://github.com/HaxeFlixel/flixel/tree/master/flixel/system/frontEnds) classes to better encapsulate FlxG functionality.
- Refactored the [animation system](https://github.com/HaxeFlixel/flixel/tree/master/flixel/animation).
- Better support for nested sprites via [FlxSpriteGroup](https://github.com/HaxeFlixel/flixel/blob/master/flixel/group/FlxSpriteGroup.hx). FlxSpriteGroups can be contained within other groups, and behave like FlxSprites. They are expensive though, use them sparringly.
- Moved lots of stuff into [utility classes](https://github.com/HaxeFlixel/flixel/tree/master/flixel/util) to reduce clutter in core classes.
- Continued optimizations for cpp targets.

###Upgrading from previous versions

// TODO

###For Developers

Make sure you're using latest version of [Haxe, HaxeLib and OpenFl](http://haxeflixel.com/comment/2584#comment-2584). Also bookmark the [haxelib guide](http://haxe.org/doc/haxelib/using_haxelib).

Clone this repository by running `haxelib git flixel https://github.com/HaxeFlixel/flixel dev`.

We recommended that you use a GUI application to manage your changes ([SourceTree](http://www.sourcetreeapp.com/)).

###Current Build Status [![Build Status](https://travis-ci.org/HaxeFlixel/flixel.png)](https://travis-ci.org/HaxeFlixel/flixel)

______________________________________________________
###Links

In case you're looking for ressources, help, or just want to interact with the community:

- [HaxeFlixel.com](http://www.haxeflixel.com/)
- [Forums](http://www.haxeflixel.com/forum)
- [Wiki](http://www.haxeflixel.com/wiki)
- [@HaxeFlixel on Twitter](https://twitter.com/HaxeFlixel)
- [#haxeflixel IRC channel](http://webchat.freenode.net/?channels=haxeflixel)

______________________________________________________

HaxeFlixel was created by Alexander Hohlov, also known as [Beeblerox](https://github.com/beeblerox) who continues to be the project lead. The codebase started largely from a Haxe port of the [AS3 version of Flixel](https://github.com/AdamAtomic/flixel) written by [Adam “Atomic” Saltsman](http://www.adamatomic.com/) and [Richard Davey's](http://www.photonstorm.com/flixel-power-tools) [Power Tools](https://github.com/photonstorm/Flixel-Power-Tools)

Special thanks go to the community contributors [Werdn](https://github.com/werdn), [crazysam](https://github.com/crazysam), [impaler](https://github.com/impaler), [ProG4mr](https://github.com/ProG4mr), [Gama11](https://github.com/Gama11), [sergey-miryanov](https://github.com/sergey-miryanov) and more.

HaxeFlixel presents substantial enhancements from the original Flixel AS3 code:

- Use of a robust and powerful, opensource language
- Flexible Asset Management System
- Cross-platform development for Linux, Mac and Windows
- Texture Atlas and Layer enhancement for cpp targets
- Integrated and robust Tween System
- Access to OpenFL native extensions
- Compile to Mobile and Desktop targets with native code through OpenFL
- Impressive Native Performance using GPU accelerated drawTiles implimentation in cpp targets
- A powerful debugger with a console as well as an advanced logging system
- A vibrant community that keeps updating the engine and adding new features to it


###Runtime Targets
The current possible targets are:

<table>
  <tr>
    <th>Mobile</th>
    <th>Desktop</th>
    <th>Web</th>
  </tr>
  <tr>
    <td>Blackberry</td>
    <td>Linux</td>
    <td>Flash</td>
  </tr>
  <tr>
    <td>iOS</td>
    <td>Mac</td>
    <td></td>
  </tr>
  <tr>
    <td>Android</td>
    <td>Windows</td>
    <td></td>
  </tr>
  <tr>
    <td>WebOS</td>
    <td>Neko</td>
    <td></td>
  </tr>
</table>

There's also experimental support for HTML5.

______________________________________________________

###Basic Features

- Display thousands of moving objects
- Basic collisions between objects
- Group objects together for simplicity
- Easily generate and emit particles
- Create game levels using tilemaps
- Text display, save games, scrolling
- Mouse, keyboard, controller, and touch inputs
- Math & color utilities
- Record and play back replays
- Powerful interactive debugger
- Camera system for split screen
- Pathfinding and following
- Easy object recycling
