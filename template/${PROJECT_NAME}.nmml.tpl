<?xml version="1.0" encoding="utf-8"?>
<project>
	
	<app title="${PROJECT_NAME}" file="${PROJECT_NAME}" main="Main" version="0.0.1" company="Zaphod" />
	
	<window width="${WIDTH}" height="${HEIGHT}" fps="30" orientation="portrait" resizable="true" if="target_flash" />
	<window width="0" height="0" fps="30" orientation="landscape" fullscreen="true" unless="target_flash" />
 	
	<set name="BUILD_DIR" value="Export" />
	
	<!--<setenv name="no_console" value="1" />-->
	
	<classpath name="Source" />
	
	<haxelib name="nme" />
	<haxelib name="HaxeFlixel"/>
	
	<assets path="Assets" rename="assets" include="*" exclude="*.svg" unless="target_flash" />
	<assets path="Assets" rename="assets" include="*" exclude="*.svg|*.wav|*.ogg" if="target_flash" />
	
	<!--<icon name="Assets/nme.svg" /> -->
	
	<ndll name="std" />
	<ndll name="regexp" />
	<ndll name="zlib" />
	<ndll name="nme" haxelib="nme" />
	
</project>