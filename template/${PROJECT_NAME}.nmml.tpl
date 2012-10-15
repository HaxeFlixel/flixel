<?xml version="1.0" encoding="utf-8"?>
<project>
	
	<app title="${PROJECT_NAME}" file="${PROJECT_NAME}" main="Main" version="0.0.1" company="Zaphod" />
	
	<window width="${WIDTH}" height="${HEIGHT}" fps="30" orientation="portrait" resizable="true" if="web" />
	<window width="0" height="0" fps="30" orientation="landscape" fullscreen="true" unless="web" />
 	
	<set name="BUILD_DIR" value="export" />
	
	<set name="SWF_VERSION" value="10.1" />
	
	<app preloader="org.flixel.system.FlxPreloader" unless="html5" />
	
	<!--<setenv name="no_console" value="1" />-->
	
	<classpath name="source" />
	
	<haxelib name="nme" />
	<haxelib name="flixel"/>
	
	<assets path="assets" if="android" >
		<sound path="data/beep.wav" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets" if="desktop" >
		<sound path="data/beep.wav" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets" if="target_flash" >
		<sound path="data/beep.mp3" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets" if="target_js" >
		<sound path="data/beep.mp3" id="Beep" />
		
		<!-- Your sound embedding code here... -->
		
	</assets>
	
	<assets path="assets/data" include="*.ttf" type="font" />
	<assets path="assets" include="*.fgr" type="text" />
	<assets path="assets" include="*.csv" type="text" />
	<assets path="assets" include="*.txt" type="text" />
	<assets path="assets" include="*.png" type="image" />
	<assets path="assets/data" include="*.png" type="image" />
	<assets path="assets/data/vcr" include="*.png" type="image" />
	<assets path="assets/data/vis" include="*.png" type="image" />
	
	<icon name="assets/HaxeFlixel.svg" />
	
	<ndll name="std" />
	<ndll name="regexp" />
	<ndll name="zlib" />
	<ndll name="nme" haxelib="nme" />
	
</project>