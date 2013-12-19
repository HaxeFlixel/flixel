# MinimalistTD
______________________________________________________

As the name would imply, this is a minimalist tower defense game. This was originally created by [Gama11](https://github.com/Gama11) as his entry for [Ludum Dare 26](http://www.ludumdare.com/compo/ludum-dare-26/?action=preview&uid=16160).  You can find the original source code for that [here](https://github.com/Gama11/LudumDare26).

This was ported to the latest version of HaxeFlixel and OpenFL by [Steve Richey](https://github.com/steverichey/) as it was suggested by [Beeblerox](https://github.com/Beeblerox) in [this issue](https://github.com/HaxeFlixel/flixel-demos/issues/25) and it seemed simple enough.
	
Given that this is a port, very little was changed. However, this version has the following differences:
* Use of inverted circle for tower range, as opposed to grey circle
* Use of black/white bordered text in buttons instead of grey text.
* Buttons are now their own class that extends FlxButton instead of FlxButtonPlus.
* Enemy gib emitters are inverted.
* As to be expected with a Ludum Dare game, there was some redundant/unnecessary code that has been reduced.
* All functions have been commented, hopefully with enough information that this can serve as a useful demo for those learning HaxeFlixel.
* Created a MinimalistTD icon.
* Added a debug-only option to have unlimited money.

# TODO

* Add ability to sell/destroy towers (S for sell mode? button?)