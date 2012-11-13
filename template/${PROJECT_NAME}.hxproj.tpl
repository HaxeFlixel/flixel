<?xml version="1.0" encoding="utf-8"?>
<project version="2">
  <!-- Output SWF options -->
  <output>
    <movie outputType="Application" />
    <movie input="" />
    <movie path="${PROJECT_NAME}.nmml" />
    <movie fps="30" />
    <movie width="${WIDTH}" />
    <movie height="${HEIGHT}" />
    <movie version="3" />
    <movie minorVersion="0" />
    <movie platform="NME" />
    <movie background="#FFFFFF" />
  </output>
  <!-- Other classes to be compiled into your SWF -->
  <classpaths>
    <class path="source" />
  </classpaths>
  <!-- Build options -->
  <build>
    <option directives="" />
    <option flashStrict="False" />
    <option mainClass="Test" />
    <option enabledebug="False" />
    <option additional="" />
  </build>
  <!-- haxelib libraries -->
  <haxelib>
    <library name="nme" />
    <library name="flixel" />
  </haxelib>
  <!-- Class files to compile (other referenced classes will automatically be included) -->
  <compileTargets>
    <compile path="source\${PROJECT_CLASS}.hx" />
  </compileTargets>
  <!-- Assets to embed into the output SWF -->
  <library>
    <!-- example: <asset path="..." id="..." update="..." glyphs="..." mode="..." place="..." sharepoint="..." /> -->
  </library>
  <!-- Paths to exclude from the Project Explorer tree -->
  <hiddenPaths>
    <!-- example: <hidden path="..." /> -->
  </hiddenPaths>
  <!-- Executed before build -->
  <preBuildCommand />
  <!-- Executed after build -->
  <postBuildCommand alwaysRun="False" />
  <!-- Other project options -->
  <options>
    <option showHiddenPaths="False" />
    <option testMovie="Custom" />
    <option testMovieCommand="flash" />
  </options>
  <!-- Plugin storage -->
  <storage />
</project>