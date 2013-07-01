<?xml version="1.0" encoding="utf-8"?>
<project>
	<app title="${PROJECT_NAME}" file="${PROJECT_NAME}" main="Main" version="0.0.1" company="HaxeFlixel" />
	
	<window width="${WIDTH}" height="${HEIGHT}" fps="60" orientation="portrait" resizable="true" if="web" />
	<window width="${WIDTH}" height="${HEIGHT}" fps="60" orientation="landscape" fullscreen="false" hardware="true" vsync="true" unless="web" />
 	
	<!--The flixel preloader gets stuck in Chrome, so it's disabled by default for now. 
	Safe to use if you embed the swf into a html file!-->
	<!--<app preloader="org.flixel.system.FlxPreloader" />-->
	
	<!--The swf version should be at least 11.2 if you want to use the FLX_MOUSE_ADVANCED option-->
	<set name="SWF_VERSION" value="11.2" />
	
	<set name="BUILD_DIR" value="export" />
	
	<classpath name="source" />
	
	<assets path="assets" if="android" >
		<sound path="data/beep.wav" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets" if="desktop" >
		<sound path="data/beep.wav" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets" if="flash" >
		<sound path="data/beep.mp3" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets" if="html5" >
		<sound path="data/beep.mp3" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets" exclude="*.wav" if="flash" />
	<assets path="assets" exclude="*.svg" if="html5" />
	<assets path="assets" if="desktop" />
	<assets path="assets" if="mobile" />
	
	<icon name="assets/HaxeFlixel.svg" />
	
	
	<haxelib name="openfl" />
	<haxelib name="flixel"/>
	
	
	<!--Enable experimental threading support for cpp targets-->
	<!--<haxedef name="FLX_THREADING" />-->
	
	<!--Enable the flixel core recording system-->
    <!--<haxedef name="FLX_RECORD" />-->
	
	<!--Enable right and middle click support for the mouse. Flash player version 11.2+, no HTML5 support -->
	<!--<haxedef name="FLX_MOUSE_ADVANCED" />-->
	
	<!--Enables checks for antialiasing for sprite rendering on native targets. And could affect perfomance. -->
	<!--<haxedef name="FLX_SPRITE_ANTIALIASING" />-->
	
	
    <!--Disable the Flixel core debugger-->
    <!--<haxedef name="FLX_NO_DEBUG" />-->
	
	<!--Optimise inputs, be careful you will get null errors if you don't use conditionals in your game-->
    <!--<haxedef name="FLX_NO_MOUSE" if="mobile" />-->
    <!--<haxedef name="FLX_NO_KEYBOARD" if="mobile" />-->
    <!--<haxedef name="FLX_NO_TOUCH" if="desktop" />-->
    <!--<haxedef name="FLX_NO_JOYSTICK" />-->
	
	<!--Disable the Flixel core sound tray-->
	<!--<haxedef name="FLX_NO_SOUND_TRAY" />-->

	<!--Disable the Flixel core focus lost screen-->
	<!--<haxedef name="FLX_NO_FOCUS_LOST_SCREEN" />-->
	
</project>