package flixel.graphics.frames;

/**
 * Just enumeration of all types of frames.
 * Added for faster type detection with less usage of casting.
 */
enum FrameType 
{
	REGULAR;
	ROTATED;
	EMPTY;
	GLYPH;
	FILTER;
}