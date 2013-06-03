<?xml version="1.0" encoding="utf-8"?>
<project>
	<app title="${PROJECT_NAME}" file="${PROJECT_NAME}" main="Main" version="0.0.1" company="Zaphod" />
	
	<window width="${WIDTH}" height="${HEIGHT}" fps="30" orientation="portrait" resizable="true" if="web" />
	<window width="${WIDTH}" height="${HEIGHT}" fps="30" orientation="landscape" fullscreen="false" vsync="true" unless="web" />
 	
	<set name="BUILD_DIR" value="export" />
	
	<!--<setenv name="no_console" value="1" />-->
	
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
	
	<assets path="assets" if="target_js" >
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
	
    <!--Disable the Flixel core debugger-->
    <!--<haxedef name="FLX_NO_DEBUG" />-->
	
    <!--Disable the Flixel core recording system if you're not using it-->
    <!--<haxedef name="FLX_NO_RECORD" />-->
	
	<!--Optimise inputs, be careful you will get null errors if you don't use conditionals in your game-->
    <!--<haxedef name="FLX_NO_MOUSE" if="mobile" />-->
    <!--<haxedef name="FLX_NO_KEYBOARD" if="mobile" />-->
    <!--<haxedef name="FLX_NO_TOUCH" if="desktop" />-->
    <!--<haxedef name="FLX_NO_JOYSTICK" />-->
    <!--<haxedef name="thread" />-->
	
	<!--Disable the Flixel core sound tray-->
	<!--<haxedef name="FLX_NO_SOUND_TRAY" />-->

	<!--Disable the Flixel core focus lost screen-->
	<!--<haxedef name="FLX_NO_FOCUS_LOST_SCREEN" />-->
	
	<!--Enable right and middle click support for the mouse. Requires flash player version 11.2 or higher. Doesn't work for HTML5. -->
	<!--<haxedef name="FLX_MOUSE_ADVANCED" />-->
	<!--<app swf-version="11.2" />--> 

</project>