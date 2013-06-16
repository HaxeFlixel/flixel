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
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.util.FlxColor;

/**
 * ...
 * @author Yadu Rajiv
 */
class MenuMain extends FlxState 
{
	private var _gameTitle:FlxText;
	private var _bg:FlxSprite;
	private var _bgEye:FlxSprite;
	private var _btnStart:FlxButton;
	
	override public function create():Void 
	{
		/**
		 * fade in from black
		 */
		FlxG.flash(FlxColor.BLACK, 3, null);
		
		/**
		 * show the mouse
		 */
		FlxG.mouse.show();
		
		/**
		 * add the game text and set some formatting options along with a shadow; you can also
		 * pass in your own font if you have one embedded or it uses Flixel's default one
		 */
		_gameTitle = new FlxText(10, 90, 300, "Revenge of the Eye from Outer Space!");
		_gameTitle.setFormat(null, 16, 0xffffff, "center", 0xff00ff);
		add(_gameTitle);
		
		/**
		 * adding the background image 320x240
		 */
		_bg = new FlxSprite(0, 0, "assets/bg.png");
		add(_bg);
		
		/**
		 * adding the alien eye image and adding constant angular velocity of 40 also limiting
		 * the maxAngular to 40
		 */
		_bgEye = new FlxSprite(137, 100, "assets/bg_eye_float.png");
		_bgEye.angularVelocity = 40;
		_bgEye.maxAngular = 40;
		add(_bgEye);
		
		/**
		 * adding a button with an anon call back function
		 */
		_btnStart = new FlxButton(137, 195, "", onStart);
		
		/**
		 * we add a couple of sprites to the button to act as normal and mouseover states
		 */
		_btnStart.loadGraphic("assets/btnStart0.png");
		add(_btnStart);
		
		_btnStart.onOver = onStartOver;
		
		_btnStart.onOut = onStartOut;
		
		/**
		 * some credit text
		 */
		add(new FlxText(280, 200, 40, "by Yadu Rajiv"));
	}
	
	override public function update():Void 
	{
		/**
		 * update the sccene
		 */
		super.update();
	}
	
	private function onStart():Void
	{
		FlxG.fade(FlxColor.BLACK, 2, false, this.onFade);
	}
	
	private function onFade():Void
	{
		FlxG.switchState(new Level1());
	}
	
	private function onStartOver():Void
	{
		_btnStart.loadGraphic("assets/btnStart1.png");
	}
	
	private function onStartOut():Void
	{
		_btnStart.loadGraphic("assets/btnStart0.png");
	}
}