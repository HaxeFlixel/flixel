# MinimalistTD

As the name would imply, this is a minimalist tower defense game. This was originally created by [Gama11](https://github.com/Gama11) for [Ludum Dare 26](http://www.ludumdare.com/compo/ludum-dare-26/?action=preview&uid=16160).  You can find the original source code for that [here](https://github.com/Gama11/LudumDare26).

This was ported to the latest version of HaxeFlixel and OpenFL by [Steve Richey](https://github.com/steverichey/) as it was suggested by [Beeblerox](https://github.com/Beeblerox) in [this issue](https://github.com/HaxeFlixel/flixel-demos/issues/25) and it seemed simple enough.

Given that this is a port, very little was changed. However, this version has the following differences:
* Use of inverted circle for tower range, as opposed to transparent circle, except native targets.
* Use of black/white bordered text in buttons instead of grey text.
* Buttons are now their own class that extends FlxButton instead of FlxButtonPlus.
* Enemy gib emitters are inverted, except native targets.
* As to be expected with a Ludum Dare game, there was some redundant/unnecessary code that has been reduced.
* All functions have been commented, hopefully with enough information that this can serve as a useful demo for those learning HaxeFlixel.
* Created a MinimalistTD icon.
* Enemy and tilemap images are drawn dynamically via Reg functions, as opposed to being images. This is to demonstrate that FlxSprite graphics do not need to be image files.
* Added a debug-only option to have unlimited money.
* Support for desktop (tested in Windows only so far).
* Support for HTML5, although it's a bit wonky and blurry.
* Can sell towers; [S]ell Mode added as soon as one tower is bought.
* Press P to play.
* Added an enum for menus to demonstrate at least one way to use them.
* Created a general toggleMenu function