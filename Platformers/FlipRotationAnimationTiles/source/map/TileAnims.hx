package map;

import flixel.addons.tile.FlxTileSpecial;
import openfl.Assets;

#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end

typedef AnimData = { name:String, speed:Float, randomizeSpeed:Float, frames:Array<Int>, ?framesData:Array<AnimParams> };

/**
 * Load the tiles animations from the *.tanim file
 * @author MrCdK
 */
class TileAnims
{
	/**
	 * Parse the animations in the *.tanim file.
	 * Returns a map with:
	 *	- Key: the tilesetID of the tile
	 * 	- Value: An array with the differents animations of the tile
	 */
	public static function getAnimations(filePath:String):Map<Int, Array<AnimData>>
	{
		//load the xml file
		var source = new Access(Xml.parse(Assets.getText(filePath)));
		source = source.node.animations;
		
		// parse the file
		var anims:Map<Int, Array<AnimData>> = new Map();
		var node:Access;
		
		var startTileID:Int = -1;
		var name:String;
		var speed:Float = 0;
		var animsData:Array<AnimData>;
		var firstGID:Int = 0;
		for (tileset in source.nodes.tileset)
		{
			firstGID = 0;
			if (tileset.has.firstGID)
			{
				firstGID = Std.parseInt(tileset.att.firstGID);
			}
			for (node in tileset.nodes.tile)
			{
				startTileID = Std.parseInt(node.att.id) + firstGID;
				animsData = new Array<AnimData>();
				for (animation in node.nodes.animation)
				{
					var name:String = "[animation]";
					if (animation.has.id)
					{
						name = animation.att.id;
					}
					var randomizeSpeed:Float = 0;
					if (animation.has.randomizeSpeed)
					{
						randomizeSpeed = Std.parseFloat(animation.att.randomizeSpeed);
					}
					var data:AnimData =
					{
						name: name,
						speed: Std.parseFloat(animation.att.speed),
						randomizeSpeed: randomizeSpeed,
						frames: new Array<Int>(),
						framesData: new Array<AnimParams>() 
					};
					for (frame in animation.nodes.frame)
					{
						data.frames.push(Std.parseInt(frame.att.id) + firstGID);
						if (frame.has.flipX || frame.has.flipY || frame.has.rotation)
						{
							var params:AnimParams =
							{
								flipX: false,
								flipY: false,
								rotate: FlxTileSpecial.ROTATE_0
							};
							
							if (frame.has.flipX && frame.att.flipX == "true")
								params.flipX = true;
							if (frame.has.flipY && frame.att.flipY == "true")
								params.flipY = true;

							if (frame.has.rotation)
							{
								var rotation:Int = Std.parseInt(frame.att.rotation);
								switch (rotation)
								{
									case 90:
										params.rotate = FlxTileSpecial.ROTATE_90;
									case 270:
										params.rotate = FlxTileSpecial.ROTATE_270;
									default:
										params.rotate = FlxTileSpecial.ROTATE_0;
								}
							}
							
							data.framesData.push(params);
						}
						else
						{
							data.framesData.push(null);
						}
					}
					
					animsData.push(data);
				}
				
				anims.set(startTileID, animsData);
			}
		}
		
		return anims;
	}
}