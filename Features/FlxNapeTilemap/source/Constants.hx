package;

import nape.callbacks.CbType;
import nape.phys.Material;

class Constants
{
	public static inline var TILE_SIZE = 16;
	public static var oneWayType:CbType;
	public static var platformMaterial(default, null) = new Material(0.2, 0.8, 0.4, 1);
	public static var playerMaterial(default, null) = new Material(0.5, 0.001, 0.005, 1);
}

class TileType
{
	public static inline var AIR = 0;
	public static inline var SPAWN = 6;
	public static inline var FLAG = 7;
	public static var EMPTY(default, null) = [0, 7];
	public static var BLOCK(default, null) = [1, 6];
	public static var SLOPE_NE(default, null) = [2];
	public static var SLOPE_NW(default, null) = [3];
	public static var SLOPE_SE(default, null) = [4];
	public static var SLOPE_SW(default, null) = [5];
	public static var ONE_WAY(default, null) = [8, 9, 10];
}
