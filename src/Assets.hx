package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.media.Sound;

/**
 * ...
 * @author Zaphod
 */

class AutoTilesPNG extends BitmapData 
{  
	public function new() { super(0, 0); } 
}
class ImgAutoTiles extends Bitmap 
{
	public function new() { super(new AutoTilesPNG()); }
}

class AltTilesPNG extends BitmapData 
{  
	public function new() { super(0, 0); } 
}
class ImgAltTiles extends Bitmap 
{
	public function new() { super(new AltTilesPNG()); }
}

class EmptyTilesPNG extends BitmapData 
{  
	public function new() { super(0, 0); } 
}
class ImgEmptyTiles extends Bitmap 
{
	public function new() { super(new EmptyTilesPNG()); }
}

class SpacemanPNG extends BitmapData 
{  
	public function new() { super(0, 0); } 
}
class ImgSpaceman extends Bitmap 
{
	public function new() { super(new SpacemanPNG()); }
}
/*
// Default tilemaps. Embedding text files is a little weird.
[Embed(source = 'default_auto.txt', mimeType = 'application/octet-stream')]private static var default_auto:Class;
[Embed(source = 'default_alt.txt', mimeType = 'application/octet-stream')]private static var default_alt:Class;
[Embed(source = 'default_empty.txt', mimeType = 'application/octet-stream')]private static var default_empty:Class;
*/
 
class Assets 
{
	
	public static var imgAutoTiles:Class<Bitmap> = ImgAutoTiles;
	public static var imgAltTiles:Class<Bitmap> = ImgAltTiles;
	public static var imgEmptyTiles:Class<Bitmap> = ImgEmptyTiles;
	public static var imgSpaceman:Class<Bitmap> = ImgSpaceman;

	
}