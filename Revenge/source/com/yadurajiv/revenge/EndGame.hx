/*
Copyright (c) 2010 Yadu Rajiv

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source
distribution.
*/
package com.yadurajiv.revenge;

import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.util.FlxColor;

/**
 * ...
 * @author Yadu Rajiv
 */
class EndGame extends FlxState 
{
	private var _gameTitle:FlxText;
	private var _btnStart:FlxButton;
	
	override public function create():Void 
	{
		/**
		 * fade in to the scene from black
		 */
		FlxG.flash(FlxColor.BLACK, 3);
		
		/**
		 * show our mouse!
		 */
		FlxG.mouse.show();
		
		/**
		 * add some text to the stage as we did earlier
		 */
		_gameTitle = new FlxText(10, 90, 300, "And so the journey begins!!");
		_gameTitle.setFormat(null, 16, 0xffffff, "center", 0xff00ff);
		add(_gameTitle);
		
		/**
		 * add a button which will take us back to the main menu state
		 */
		_btnStart = new FlxButton(137, 195, "", onStart);
		
		/**
		 * load sprites for different button states
		 */
		_btnStart.loadGraphic("assets/ok0.png");
		add(_btnStart);
		
		_btnStart.onOver = onStartOver;
		
		_btnStart.onOut = onStartOut;
	}
	
	private function onStartOut():Void
	{
		_btnStart.loadGraphic("assets/ok0.png");
	}
	
	private function onStartOver():Void
	{
		_btnStart.loadGraphic("assets/ok1.png");
	}
	
	override public function update():Void 
	{
		/**
		 * update everything on stage..
		 */
		super.update();
	}
	
	private function onStart():Void
	{
		FlxG.fade(FlxColor.BLACK, 2, false, this.onFade);
	}
	
	private function onFade():Void
	{
		FlxG.switchState(new MenuMain());
	}
}