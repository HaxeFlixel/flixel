# ![Icon](assets/icon.png) Flappybalt

<p align="center">
<img src="assets/screenshot.png" alt="Screenshot"/>
</p>

A cross-platform port of [AdamAtomic](https://github.com/AdamAtomic)'s [Flappybalt](http://adamatomic.com/flappybalt/), converted to [Haxe](http://www.haxe.org) and [HaxeFlixel](http://www.haxeflixel.com). You can play this on your Android by downloading it from the [Google Play Store](https://play.google.com/store/apps/details?id=com.steverichey.flappybalt) if you'd like.

# Releasing for Android with HaxeFlixel (Windows)

The process for releasing a HaxeFlixel game as an Android app is a bit complicated, so I thought I'd step through some of the steps. This is for Windows, but the process is largely the same for any platform.

1. [Register](https://play.google.com/apps/publish/signup/) for a Google Play Developer Console account. The charge is currently $25.
2. Prepare to compile by running `lime setup android`. Make sure that your path to the Java JDK looks like `c:\java\jdk1.6.0_37` and NOT to the `bin` directory.
2. Compile your app for Android. This can be done simply by running `lime build android` from the command line in your project directory. Make sure your input is set up properly, accounting for touch controls and the lack of mouse/keyboard! HaxeFlixel has some handy Haxe defines for this, e.g. `FLX_NO_MOUSE`, `FLX_NO_KEYBOARD`, etc.
3. Test your app on an Android device! You can set up the Android Debug Bridge (ADB) for this, but you could just email the APK to yourself. Slower, but easier.
4. Provided everything works, you'll need to sign your app before you release it. So long as your `JAVA_HOME` environment variable points to the BIN directory (e.g. `c:/java/jdk1.6.0_37/bin/`) you can do this by running `keytool` from the command line. [Google recommends](http://developer.android.com/tools/publishing/app-signing.html) the following settings:

````
keytool -genkey -v -keystore YOUR_RELEASE_KEY.keystore -alias YOUR_ALIAS -keyalg RSA -keysize 2048 -validity 10000
````

It will ask for a password and stuff, which you will need to remember! Obviously, use your own values for `YOUR_RELEASE_KEY` and `YOUR_ALIAS`.

In order for Lime to see your certificate, you need to add it to the `Project.XML` file. You can add this line:

````
<certificate path="YOUR_RELEASE_KEY.keystore" alias="YOUR_ALIAS" password="YOUR_PASSWORD" if="android" unless="debug"/>
````

Obviously use your own values where appropriate. Now when you run `lime build android` it will sign the app automagically! Just look for `MyApp-release.apk` in `export/android/bin/bin/`.

Finally, [upload your APK](https://play.google.com/apps/publish/)! You can set up Google Play stuff too.

## Optional Steps

* If you have an SVG file set up as your icon in your `Project.XML` file, Lime will make nice high-res icons for you. Do this! Just add `<icon path="assets/icon.svg"/>` to your `Project.XML` file. You can create SVGs using [InkScape](http://inkscape.org/en/), or even by hand, as they are [basically just XML files](http://www.w3.org/TR/SVG11/).
* Don't want to scare off potential customers with a bunch of app permissions? Lime includes a few by default, but this can be overridden. After building your app at least once, get `export/android/bin/bin/AndroidManifest.xml` and copy it somewhere else (I usually put it into a `libs` directory). Then, in your `Project.XML`, add:

````
<template path="libs/AndroidManifest.xml" rename="AndroidManifest.xml" if="android"/>
````

Now Lime will use this file instead of the default AndroidManifest it would normally generate. Inside this file you'll notice a few lines:

````
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
````

**As far as I know** you can delete these lines without issue. If you do this, when someone goes to launch your app, it will say "This app requires no special permissions". Obviously, this is not applicable if you actually need one of these permissions!

All of the code in this repository is available under an MIT license. Code not included in this repository (mostly just app settings, private keys, etc) is copyright [SteveRichey](https://github.com/steverichey) but if you have questions about implementation let me know and I'll help you out!

### Changes:
* Pixel-perfect collisions.
* Special FX

Canabalt-themed flappy-like for [FlappyJam](http://itch.io/jam/flappyjam).

The original version was programmed in ActionScript 3, and required [flixel](http://flixel.org/) to compile.
