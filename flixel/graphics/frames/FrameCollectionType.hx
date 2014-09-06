package flixel.graphics.frames;

/**
 * Just enumeration of all types of frame collections.
 * Added for faster type detection with less usage of casting.
 */
enum FrameCollectionType 
{
	IMAGE;
	TILES;
	ATLAS;
	FONT;
	BAR(type:flixel.ui.FlxBar.FlxBarFillDirection);
	CLIPPED;
	USER(type:String);
	FILTER;
}