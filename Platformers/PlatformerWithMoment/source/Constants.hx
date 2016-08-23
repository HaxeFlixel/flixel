package;
import nape.callbacks.CbType;
import nape.phys.Material;

/**
 * ...
 * @author buckle2000
 */

@: final
class Constants
{
    public static inline var TILESIZE = 16;
    public static var oneWayType: CbType;
    public static var platformMaterial: Material = new Material(0.2, 0.8, 0.4, 1);
    public static var playerMaterial: Material = new Material(0.5, 0.001, 0.005, 1);
}

class TileType
{
    public static inline var Air = 0;
    public static inline var Spawn = 6;
    public static inline var Flag = 7;
    public static var Empty = [0, 7];
    public static var Block = [1, 6];
    public static var SlopeNE = [2];
    public static var SlopeNW = [3];
    public static var SlopeSE = [4];
    public static var SlopeSW = [5];
    public static var OneWay = [8, 9, 10];
}