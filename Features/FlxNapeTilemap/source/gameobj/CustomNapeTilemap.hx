package gameobj;

import Constants.TileType;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import nape.geom.Vec2;
using Lambda;
using logic.PhyUtil;

class CustomNapeTilemap extends FlxNapeTilemap
{
    public var spawnpoints(default, null) = new Array<FlxPoint>();

    public function new(tiles: String, graphics: FlxGraphic, tilesize: Int)
    {
        super();
        loadMapFromCSV(tiles, graphics, tilesize, tilesize);
        setupTileIndices(TileType.Block);

        var vertices = new Array<Vec2>();
        vertices.push(Vec2.get(16, 0));
        vertices.push(Vec2.get(16, 16));
        vertices.push(Vec2.get(0, 16));
        placeCustomPolygon(TileType.SlopeSE, vertices);
        vertices[0] = Vec2.get(0, 0);
        placeCustomPolygon(TileType.SlopeSW, vertices);
        vertices[1] = Vec2.get(16, 0);
        placeCustomPolygon(TileType.SlopeNW, vertices);
        vertices[2] = Vec2.get(16, 16);
        placeCustomPolygon(TileType.SlopeNE, vertices);
        var prevOneWay = false;
        var length : Int = 0;
        var startx: Int = 0;
        var starty: Int = 0;

        for (ty in 0...heightInTiles)   //生成连续的平台，防止卡脚
        {
            for (tx in 0...widthInTiles)
            {
                if (TileType.OneWay.has(getTileByIndex(ty * widthInTiles + tx)))
                {
                    if (!prevOneWay)
                    {
                        prevOneWay = true;
                        length = 0;
                        startx = tx;
                        starty = ty;
                    }
                    ++length;
                }
                else
                {
                    if (prevOneWay)
                    {
                        prevOneWay = false;
                        PhyUtil.setOneWayLong(this, getTileCoordsByIndex(starty * widthInTiles + startx,
                                              false), length);
                    }
                }
            }
            if (prevOneWay)
            {
                prevOneWay = false;
                PhyUtil.setOneWayLong(this, getTileCoordsByIndex(starty * widthInTiles + startx,
                                      false), length);
            }
        }

        for (p in getTileCoords(TileType.Spawn, false))
        {
            //p.y += _scaledTileWidth * 0.5;
            p.x += _scaledTileHeight * 0.5;
            spawnpoints.push(p);
        }
    }
}